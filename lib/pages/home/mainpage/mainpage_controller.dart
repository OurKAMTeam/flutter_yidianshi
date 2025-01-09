// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'classtable_controller.dart';

class MainPageController extends GetxController {
  late ClassTableController classTableController;

  // 添加需要的响应式状态
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  @override
  void onInit() {
    super.onInit();
    // 初始化 ClassTableController
    classTableController = Get.put(ClassTableController());
  }

  // 更新数据的方法
  Future<void> updateData({
    required BuildContext context,
    required Future<String> Function(String) sliderCaptcha,
  }) async {
    try {
      isLoading = true;
      // TODO: 实现更新逻辑
      await Future.delayed(const Duration(seconds: 1)); // 模拟更新
    } catch (e) {
      // 处理错误
    } finally {
      isLoading = false;
    }
  }

  @override
  void onClose() {
    Get.delete<ClassTableController>();
    super.onClose();
  }
}