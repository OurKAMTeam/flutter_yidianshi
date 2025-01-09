// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:get/get.dart' as getx;
import 'package:synchronized/synchronized.dart';
import '../base_provider.dart';
import '../api_constants.dart';
import 'jc_captcha.dart';
import 'xd_api_ids.dart';

class ApiProviderEhall extends BaseProvider {
  static final _ehallLock = Lock();

  Map<String, String> headers = {
    HttpHeaders.refererHeader: "http://ehall.xidian.edu.cn/new/index_xd.html",
    HttpHeaders.hostHeader: "ehall.xidian.edu.cn",
    HttpHeaders.acceptHeader: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    HttpHeaders.acceptEncodingHeader: 'identity',
    HttpHeaders.connectionHeader: 'Keep-Alive',
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded; charset=UTF-8",
  };

  final _apiProviderIds = getx.Get.find<ApiProviderIds>();
  final _ids = getx.Get.find<ApiProviderIds>();

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = ApiConstants.ehallUrl;
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.addAll(headers);
      return request;
    });
  }

  Future<String> checkAndLogin({
    required String target,
    required Future<void> Function(String) sliderCaptcha,
  }) async {
    final response = await safeRequest(
      () => httpClient.get("/new/index.html"),
      requiresAuth: false,
    );

    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers?[HttpHeaders.locationHeader]?[0];
      if (location != null && location.contains("org.xidian.edu.cn/authserver")) {
        return await _apiProviderIds.checkAndLogin(
          target: target,
          sliderCaptcha: sliderCaptcha,
        );
      }
    }
    return "";
  }

  Future<bool> isLoggedIn() async {
    var response = await httpClient.get(
      "/jsonp/getAppUsageMonitor.json?type=uv",
    );
    return response.body["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    required void Function(int, String) onResponse,
  }) async {
    String location = await _ids.login(
      username: username,
      password: password,
      sliderCaptcha: sliderCaptcha,
      onResponse: onResponse,
      target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
    );

    var response = await httpClient.get(location);
    while (response.headers?[HttpHeaders.locationHeader] != null) {
      location = response.headers![HttpHeaders.locationHeader]![0];
      response = await httpClient.get(location);
    }
  }

  Future<String> useApp(String appID) async {
    return await _ehallLock.synchronized(() async {
      if (!await isLoggedIn()) {
        String location = await checkAndLogin(
          target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
          sliderCaptcha: (String cookieStr) =>
              SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
        );
        var response = await httpClient.get(location);
        while (response.headers?[HttpHeaders.locationHeader] != null) {
          location = response.headers![HttpHeaders.locationHeader]![0];
          response = await httpClient.get(location);
        }
      }

      var value = await httpClient.get(
        "/appShow?appId=$appID",
      );
      return value.headers?['location']?[0] ?? "";
    });
  }

  Future<Map<String, dynamic>> getPersonalInfo() async {
    await checkAndLogin(
      target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    final response = await safeRequest(
      () => httpClient.get("/jsonp/userDesktopInfo.json"),
    );

    return response.body;
  }

  Future<Map<String, dynamic>> getAppList() async {
    await checkAndLogin(
      target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    final response = await safeRequest(
      () => httpClient.get("/appStore/getUserInstallApps.json"),
    );

    return response.body;
  }

  Future<String> getAppUrl(String appId) async {
    await checkAndLogin(
      target: "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    final response = await safeRequest(
      () => httpClient.get(
        "/appStore/getAppConfig.json",
        query: {'appId': appId},
      ),
    );

    final config = response.body;
    if (config == null) {
      throw Exception('Failed to get app config');
    }

    return config['url'] ?? '';
  }
}

/// 一站式课表相关的 API
class EhallClassTableApiProvider extends ApiProviderEhall {
  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = ApiConstants.ehallUrl;
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers.addAll(headers);
      return request;
    });
  }

  // 获取当前学期信息
  Future<getx.Response> getCurrentSemester() {
    return post(
      "/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do",
      {},
    );
  }

  // 获取学期开始日期
  Future<getx.Response> getTermStartDay(String year, String semester) {
    return post(
      '/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do',
      {
        'XN': year,
        'XQ': semester,
      },
    );
  }

  // 获取课表信息
  Future<getx.Response> getClassTableInfo(String semesterCode, String studentId) {
    return post(
      '/jwapp/sys/wdkb/modules/xskcb/xskcb.do',
      {
        'XNXQDM': semesterCode,
        'XH': studentId,
      },
    );
  }

  // 获取未安排课程信息
  Future<getx.Response> getNotArrangedInfo(String semesterCode, String studentId) {
    return post(
      "jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      {
        'XNXQDM': semesterCode,
        'XH': studentId,
      },
    );
  }

  // 获取课程变更信息
  Future<getx.Response> getClassChanges(String semesterCode) {
    return post(
      'jwapp/sys/wdkb/modules/xskcb/xsdkkc.do',
      {
        'XNXQDM': semesterCode,
        '*order': "-SQSJ",
      },
    );
  }
}
