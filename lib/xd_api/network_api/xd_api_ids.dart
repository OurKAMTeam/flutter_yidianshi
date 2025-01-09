// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:synchronized/synchronized.dart';
import '../base_provider.dart';
import '../api_constants.dart';
import 'jc_captcha.dart';
import 'package:flutter_yidianshi/shared/services/storage_service.dart';
import 'package:flutter_yidianshi/shared/constants/storage.dart';

enum IDSLoginState {
  none,
  requesting,
  success,
  fail,
  passwordWrong,
  manual,
}

IDSLoginState loginState = IDSLoginState.none;

bool get offline =>
    loginState != IDSLoginState.success && loginState != IDSLoginState.manual;

class ApiProviderIds extends BaseProvider {
  static final _idslock = Lock();
  final _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = ApiConstants.idsUrl;
    httpClient.addRequestModifier<dynamic>((request) {
      if (offline) {
        throw "Offline mode, all ids function unuseable.";
      }
      return request;
    });
  }

  /// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
  String aesEncrypt(String toEnc, String key) {
    dynamic k = encrypt.Key.fromUtf8(key);
    var crypt = encrypt.AES(k, mode: encrypt.AESMode.cbc, padding: null);

    /// Start padding
    int blockSize = 16;
    List<int> dataToPad = [];
    dataToPad.addAll(utf8.encode(
        "xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu$toEnc"));
    int paddingLength = blockSize - dataToPad.length % blockSize;
    for (var i = 0; i < paddingLength; ++i) {
      dataToPad.add(paddingLength);
    }
    String readyToEnc = utf8.decode(dataToPad);

    /// Start encrypt.
    return encrypt.Encrypter(crypt)
        .encrypt(readyToEnc, iv: encrypt.IV.fromUtf8('xidianscriptsxdu'))
        .base64;
  }

  static const _header = [
    "lt",
    "execution",
  ];

  String _parsePasswordWrongMsg(String html) {
    var form = parse(html).getElementsByClassName("span")
      ..removeWhere((element) => element.id != "showErrorTip");
    var msg = form.firstOrNull?.children[0].innerHtml ?? "登录遇到问题";

    if (msg.contains(RegExp(r"(用户名|密码).*误", unicode: true, dotAll: true))) {
      msg = "用户名或密码有误。";
    }
    return msg;
  }

  Future<String> checkAndLogin({
    required String target,
    required Future<void> Function(String) sliderCaptcha,
  }) async {
    return await _idslock.synchronized(() async {
      final response = await safeRequest(
        () => httpClient.get(
          "/authserver/login",
          query: {'service': target},
        ),
      );

      if (response.statusCode == 401) {
        throw PasswordWrongException(msg: _parsePasswordWrongMsg(response.body));
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        return response.headers?[HttpHeaders.locationHeader]?[0] ?? "";
      } else {
        var page = parse(response.body ?? "");
        var form = page.getElementsByTagName("form")
          ..removeWhere((element) => element.id != "continue");

        if (form.isNotEmpty) {
          var inputSearch = form[0].getElementsByTagName("input");
          Map<String, String> toPostAgain = {};
          for (var i in inputSearch) {
            toPostAgain[i.attributes["name"]!] = i.attributes["value"]!;
          }
          final redirectResponse = await safeRequest(
            () => httpClient.post(
              "/authserver/login",
              body: toPostAgain,
            ),
          );
          if (redirectResponse.statusCode == 301 ||
              redirectResponse.statusCode == 302) {
            return redirectResponse.headers?[HttpHeaders.locationHeader]?[0] ?? "";
          }
        }
        return await login(
          username: _storageService.getString(StorageConstants.number),
          password: _storageService.getString(StorageConstants.passwd),
          sliderCaptcha: sliderCaptcha,
          target: target,
        );
      }
    });
  }

  Future<String> login({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    String? target,
  }) async {
    if (onResponse != null) {
      onResponse(10, "login_process.ready_page");
    }

    final response = await safeRequest(
      () => httpClient.get(
        "/authserver/login",
        query: target != null ? {'service': target} : null,
      ),
    );

    var page = parse(response.body);
    var form = page.getElementsByTagName("input")
      ..removeWhere((element) => element.attributes["type"] != "hidden");

    String cookieStr = "";
    var cookies = await cookieJar.loadForRequest(Uri.parse(ApiConstants.idsUrl));
    for (var cookie in cookies) {
      cookieStr += "${cookie.name}=${cookie.value}; ";
    }

    if (onResponse != null) {
      onResponse(30, "login_process.get_encrypt");
    }

    String keys = form
        .firstWhere((element) => element.id == "pwdEncryptSalt")
        .attributes["value"]!;

    if (onResponse != null) {
      onResponse(40, "login_process.ready_login");
    }

    Map<String, dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
      'cllt': 'userNameLogin',
      'dllt': 'generalLogin',
      '_eventId': 'submit',
    };

    for (var i in _header) {
      head[i] = form
          .firstWhere(
            (element) => element.attributes["name"] == i || element.id == i,
          )
          .attributes["value"]!;
    }

    if (onResponse != null) {
      onResponse(45, "login_process.slider");
    }

    await safeRequest(
      () => httpClient.get(
        "/authserver/common/openSliderCaptcha.htl",
        query: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      ),
    );

    try {
      await sliderCaptcha(cookieStr);
    } catch (e) {
      throw const LoginFailedException(msg: "验证码校验失败");
    }

    if (onResponse != null) {
      onResponse(50, "login_process.ready_login");
    }

    try {
      final loginResponse = await safeRequest(
        () => httpClient.post("/authserver/login", body: head),
      );

      if (loginResponse.statusCode == 301 || loginResponse.statusCode == 302) {
        if (onResponse != null) {
          onResponse(80, "login_process.after_process");
        }
        return loginResponse.headers?[HttpHeaders.locationHeader]?[0] ?? "";
      } else {
        var page = parse(loginResponse.body ?? "");
        var form = page.getElementsByTagName("form")
          ..removeWhere((element) => element.id != "continue");

        if (form.isNotEmpty) {
          var inputSearch = form[0].getElementsByTagName("input");
          Map<String, String> toPostAgain = {};
          for (var i in inputSearch) {
            toPostAgain[i.attributes["name"]!] = i.attributes["value"]!;
          }
          final redirectResponse = await safeRequest(
            () => httpClient.post(
              "/authserver/login",
              body: toPostAgain,
            ),
          );
          if (redirectResponse.statusCode == 301 ||
              redirectResponse.statusCode == 302) {
            if (onResponse != null) {
              onResponse(80, "login_process.after_process");
            }
            return redirectResponse.headers?[HttpHeaders.locationHeader]?[0] ?? "";
          }
        }
        throw LoginFailedException(msg: "登录失败，响应状态码：${loginResponse.statusCode}。");
      }
    } catch (e) {
      if (e is Response && e.statusCode == 401) {
        throw PasswordWrongException(
          msg: _parsePasswordWrongMsg(e.body),
        );
      }
      rethrow;
    }
  }

  Future<bool> checkWhetherPostgraduate() async {
    String location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/index.do",
      sliderCaptcha: (cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    var response = await safeRequest(() => httpClient.get(location));
    while (response.headers?[HttpHeaders.locationHeader] != null) {
      location = response.headers?[HttpHeaders.locationHeader]![0]?? "";
      response = await safeRequest(() => httpClient.get(location));
    }

    final result = await safeRequest(
      () => httpClient.post(
        "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/modules/pubWork/getCanVisitAppList.do",
      ),
    );

    final isPostgraduate = result.body["res"] != null;
    await _storageService.setBool(StorageConstants.role, isPostgraduate);
    return isPostgraduate;
  }
}

class NeedCaptchaException implements Exception {}

class PasswordWrongException implements Exception {
  final String msg;
  const PasswordWrongException({required this.msg});
  @override
  String toString() => msg;
}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});
  @override
  String toString() => msg;
}
