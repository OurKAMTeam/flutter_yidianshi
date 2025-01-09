// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import '../../../models/electricity/electricity.dart';
import '../../../xd_api/network_api/electricity_api.dart';
import '../../../shared/constants/storage.dart';
import '../../../shared/services/storage_service.dart';

class ElectricityController extends GetxController {
  final _isLoading = false.obs;
  final _isCache = false.obs;
  final _electricityInfo = Rx<ElectricityInfo>(
    ElectricityInfo.empty(DateTime.now()),
  );
  final _errorMessage = RxString('');
  
  late final ElectricityApi _api;
  final _storage = Get.find<StorageService>();

  bool get isLoading => _isLoading.value;
  bool get isCache => _isCache.value;
  ElectricityInfo get electricityInfo => _electricityInfo.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ElectricityApi>();
    if (hasDormInfo) {
      updateElectricityInfo();
    } else {
      _errorMessage.value = '请先设置宿舍信息';
    }
  }

  bool get hasDormInfo {
    return _storage.getString(StorageConstants.dorm).isNotEmpty;
  }

  Future<void> updateElectricityInfo({
    Function(List<int>)? captchaFunction,
    bool force = false,
  }) async {
    if (_isLoading.value && !force) return;

    _isLoading.value = true;
    _errorMessage.value = '';
    
    try {
      final addressId = _storage.getString(StorageConstants.dorm);
      
      // 获取电费余额
      final remain = await _api.getElectricityBalance(
        addressId: addressId,
        liveId: addressId, // 根据注释，dorm如果为纯数字即为电费账号，所以这里用相同的值
      );
      
      // 获取欠费金额
      final owe = await _api.getOweAmount(
        addressId: addressId,
        liveId: addressId,
      );

      _electricityInfo.value = ElectricityInfo(
        fetchDay: DateTime.now(),
        remain: remain,
        owe: owe,
        lastCharge: "0",
        lastChargeAmount: "0",
        lastChargeTime: DateTime.now(),
        lastChargeBalance: "0",
        monthUsage: "0",
      );
      _isCache.value = false;
      
      // 保存到缓存
      _saveToCache(_electricityInfo.value);
    } catch (e) {
      _errorMessage.value = '获取电费信息失败：$e';
      Get.snackbar(
        '错误',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      // 如果失败，尝试从缓存加载
      _loadFromCache();
    } finally {
      _isLoading.value = false;
    }
  }

  void _loadFromCache() {
    final cachedData = _storage.getString('electricity_cache');
    if (cachedData.isNotEmpty) {
      try {
        final Map<String, dynamic> json = jsonDecode(cachedData);
        _electricityInfo.value = ElectricityInfo.fromJson(json);
        _isCache.value = true;
      } catch (e) {
        print('Failed to load electricity info from cache: $e');
      }
    }
  }

  void _saveToCache(ElectricityInfo info) {
    try {
      final String json = jsonEncode(info.toJson());
      _storage.setString('electricity_cache', json);
    } catch (e) {
      print('Failed to save electricity info to cache: $e');
    }
  }

  String getDisplayRemain() {
    if (_electricityInfo.value.remain == "electricity_status.pending" ||
        !_electricityInfo.value.remain.contains(RegExp(r'[0-9]'))) {
      return _electricityInfo.value.remain;
    }
    return '剩余电量：${_electricityInfo.value.remain} kWh';
  }

  String getDialogContent() {
    if (_electricityInfo.value.remain == "electricity_status.pending") {
      return '正在加载电费信息...';
    }
    
    final fetchDayStr = Jiffy.parseFromDateTime(_electricityInfo.value.fetchDay)
        .format(pattern: 'yyyy-MM-dd HH:mm:ss');
    
    String content = '';
    
    // 添加缓存提示
    if (_isCache.value && !isToday(_electricityInfo.value.fetchDay)) {
      content += '注意：显示的是缓存数据（$fetchDayStr）\n';
    }
    
    content += '''
剩余电量：${_electricityInfo.value.remain}${_electricityInfo.value.remain.contains(RegExp(r'[0-9]')) ? " kWh" : ""}
欠费金额：${_electricityInfo.value.owe}
''';
    
    return content;
  }

  String getBottomText() {
    if (!isToday(_electricityInfo.value.fetchDay)) {
      return '上次更新：${Jiffy.parseFromDateTime(_electricityInfo.value.fetchDay).format(pattern: 'yyyy-MM-dd HH:mm')}';
    }

    if (_electricityInfo.value.owe.contains(RegExp(r'[0-9]'))) {
      return '需缴费：${_electricityInfo.value.owe} 元';
    }

    return _electricityInfo.value.owe;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool shouldRefresh() {
    if (!hasDormInfo) return false;
    if (_electricityInfo.value.remain == "electricity_status.pending") return true;
    
    final now = DateTime.now();
    // 如果上次更新时间超过1小时，则需要刷新
    return now.difference(_electricityInfo.value.fetchDay).inHours >= 1;
  }

  bool isLowBalance() {
    if (_electricityInfo.value.remain == "electricity_status.pending" ||
        !_electricityInfo.value.remain.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    final remain = double.tryParse(_electricityInfo.value.remain) ?? 0;
    return remain < 10; // 当剩余电量小于10度时认为电量较低
  }
}
