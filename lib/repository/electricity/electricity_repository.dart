// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/electricity/electricity.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/constants/storage.dart';
import '../../xd_api/network_api/electricity_api.dart';
import 'account_handler.dart';
import 'cache_handler.dart';

class ElectricityRepository {
  final _api = Get.find<ElectricityApi>();
  final _storage = Get.find<StorageService>();
  final _prefs = Get.find<SharedPreferences>();
  late Directory supportPath;
  
  final _accountHandler = AccountHandler();
  late final _cacheHandler = CacheHandler(supportPath);

  String getDormInfo() {
    return _storage.getString(StorageConstants.dorm);
  }
  
  // 默认密码为123456，只有在特殊情况下才需要用户输入
  String _getPassword() => "123456";

  Future<ElectricityInfo> getElectricityInfo({
    bool force = false,
    Future<String> Function(List<int>)? captchaFunction,
  }) async {
    final dorm = getDormInfo();
    if (dorm.isEmpty) {
      throw NoAccountInfoException();
    }

    if (!force) {
      try {
        final cache = await _cacheHandler.loadFromCache();
        if (cache != null) {
          return cache;
        }
      } catch (e) {
        // 缓存读取失败，继续获取新数据
      }
    }

    String lastErrorMessage = "";
    for (int retry = 5; retry > 0; retry--) {
      try {
        // 获取验证码图片
        final picture = await _api.getCaptchaImage();

        // 处理验证码
        String? checkCode = retry == 1
            ? captchaFunction != null
                ? await captchaFunction(picture)
                : throw CaptchaFailedException()
            : await _inferCaptcha(picture);

        if (checkCode == null) {
          retry++; // 不计入重试次数
          continue;
        }

        // 登录并获取信息
        final loginInfo = await _api.checkUserInfo(
          userId: _accountHandler.getElectricityAccount(dorm),
          password: _getPassword(),
          checkCode: checkCode,
        );

        // 获取电费信息
        final balance = await _api.getElectricityBalance(
          addressId: loginInfo.$1,
          liveId: loginInfo.$2,
        );

        // 获取欠费信息
        final owe = await _api.getOweAmount(
          addressId: loginInfo.$1,
          liveId: loginInfo.$2,
        );

        final info = ElectricityInfo(
          fetchDay: DateTime.now(),
          remain: balance,
          owe: owe,
          lastCharge: "0",  
          lastChargeAmount: "0",  
          lastChargeTime: DateTime.now(),  
          lastChargeBalance: "0",  
          monthUsage: "0",  
        );

        await _cacheHandler.saveToCache(info);
        return info;

      } on RedirectException catch (e) {
        // 处理重定向，可能需要完善用户信息
        await _handleRedirect(e.location);
      } on ApiException catch (e) {
        lastErrorMessage = e.toString();
      } catch (e) {
        if (retry == 1) {
          throw ElectricityException('获取电费信息失败：$lastErrorMessage');
        }
      }
    }

    throw ElectricityException('获取电费信息失败：$lastErrorMessage');
  }

  Future<void> _handleRedirect(String location) async {
    // TODO: 处理重定向，完善用户信息
  }

  Future<String?> _inferCaptcha(List<int> picture) async {
    // TODO: 实现验证码识别
    return null;
  }
}

class ElectricityException implements Exception {
  final String message;
  ElectricityException(this.message);
  @override
  String toString() => message;
}

class CaptchaFailedException implements Exception {
  @override
  String toString() => '验证码识别失败';
}
