// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import '../api_constants.dart';
import '../base_provider.dart';

class ElectricityApi extends LoginProvider {
  static const factorycode = "E003";
  static const pubKey = """-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCa1ILSkh
0rYX5iONLlpN8AuM2fS5gqYM85c8NDkEB501FiBNIo+NA5P
RMmNqUEySiX0alK9xiCw+ZUQLpc4cmnF3DlXti5KGiV4ilL
qF/80xkHCnLcdXzbEtoEgBvyZsusgeBfmyK2tzpkwh12Gac
xh5zeF9usFgtdabgACU/cQIDAQAB
-----END PUBLIC KEY-----""";

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = ApiConstants.electricityUrl;
  }

  String _rsaEncrypt(String toEnc) {
    final publicKey = RSAKeyParser().parse(pubKey) as RSAPublicKey;
    return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
  }

  Future<Uint8List> getCaptchaImage() async {
    final response = await get(
      "/NetWorkUI/authImage",
      headers: {
        "Accept": "image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
      },
      contentType: "image/*",
    );

    if (response.status.hasError) {
      throw ApiException("获取验证码失败: ${response.statusText}");
    }

    if (response.body == null) {
      throw ApiException("获取验证码失败: 响应数据为空");
    }

    return response.body;
  }

  Future<(String, String)> checkUserInfo({
    required String userId,
    required String password,
    required String checkCode,
  }) async {
    final response = await post(
      "/NetWorkUI/checkUserInfo",
      {
        "p_Userid": _rsaEncrypt(userId),
        "p_Password": _rsaEncrypt(password),
        "checkCode": _rsaEncrypt(checkCode),
        "factorycode": factorycode,
      },
      headers: {
        HttpHeaders.refererHeader: "${ApiConstants.electricityUrl}/NetWorkUI/",
      },
    );

    if (response.statusCode != null && 
        response.statusCode! >= 300 && 
        response.statusCode! < 400) {
      final location = response.headers?["location"];
      if (location == null) {
        throw ApiException("重定向地址为空");
      }
      throw RedirectException(location);
    }

    final data = jsonDecode(response.bodyString ?? "{}");
    if (data["returncode"] == "ERROR") {
      throw ApiException(data["returnmsg"]);
    }

    return (
      data["roomList"][0].toString().split('@')[0],
      data["liveid"].toString(),
    );
  }

  Future<void> perfectUserInfo({
    required String phone,
    required String email,
  }) async {
    await post(
      "/NetWorkUI/perfectUserinfo",
      {
        "tel": phone,
        "email": email,
      },
      headers: {
        HttpHeaders.refererHeader: "${ApiConstants.electricityUrl}/NetWorkUI/",
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );
  }

  Future<String> getElectricityBalance({
    required String addressId,
    required String liveId,
  }) async {
    final response = await post(
      "/NetWorkUI/checkPayelec",
      {
        "addressid": addressId,
        "liveid": liveId,
        'payAmt': 'leftwingpopulism',
        "factorycode": factorycode,
      },
      headers: {
        HttpHeaders.refererHeader: "${ApiConstants.electricityUrl}/NetWorkUI/",
      },
    );

    final data = jsonDecode(response.bodyString ?? "{}");
    if (data["returnmsg"] == "连接超时") {
      return data["rtmeterInfo"]["Result"]["Meter"]["RemainQty"];
    } else {
      throw ApiException("获取电费余额失败");
    }
  }

  Future<String> getOweAmount({
    required String addressId,
    required String liveId,
  }) async {
    final response = await post(
      "/NetWorkUI/getOwefeeInfo",
      {
        "addressid": addressId,
        "liveid": liveId,
        "factorycode": factorycode,
      },
      headers: {
        HttpHeaders.refererHeader: "${ApiConstants.electricityUrl}/NetWorkUI/",
      },
    );

    final data = jsonDecode(response.bodyString ?? "{}");
    if (data["returncode"] == "ERROR" &&
        data["returnmsg"] == "电费厂家返回xml消息体异常") {
      return "0";
    } else {
      return data["dueTotal"].toString();
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class RedirectException implements Exception {
  final String location;
  RedirectException(this.location);
}
