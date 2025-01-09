// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ClassTableState {
  initial,
  loading,
  fetched,
  error,
}

class ClassTableController extends GetxController {
  // 状态
  final Rx<ClassTableState> state = ClassTableState.initial.obs;

  // 课程表数据
  late final classTableData;
  final Rx<DateTime> updateTime = DateTime.now().obs;

  // 获取当前时间的问候语
  String getGreeting() {
    DateTime now = DateTime.now();

    if (now.hour >= 5 && now.hour < 9) {
      return "早上好";
    }
    if (now.hour >= 9 && now.hour < 11) {
      return "上午好";
    }
    if (now.hour >= 11 && now.hour < 14) {
      return "中午好";
    }
    if (now.hour >= 14 && now.hour < 18) {
      return "下午好";
    }
    if (now.hour >= 18 || now.hour == 0) {
      return "晚上好";
    }
    return "夜深了";
  }

  // 获取周信息文本
  String getWeekText() {
    if (state.value == ClassTableState.fetched) {
      int currentWeek = getCurrentWeek(updateTime.value);
      if (currentWeek >= 0 && currentWeek < classTableData.semesterLength) {
        return "第${currentWeek + 1}周";
      } else {
        return "假期中";
      }
    } else if (state.value == ClassTableState.error) {
      return "加载失败";
    } else {
      return "加载中...";
    }
  }

  // 获取当前周数
  int getCurrentWeek(DateTime updateTime) {
    // TODO: 实现获取当前周数的逻辑
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    loadClassTableData();
  }

  // 加载课程表数据
  Future<void> loadClassTableData() async {
    try {
      state.value = ClassTableState.loading;
      // TODO: 实现加载课程表数据的逻辑
      await Future.delayed(const Duration(seconds: 1)); // 模拟加载
      state.value = ClassTableState.fetched;
    } catch (e) {
      state.value = ClassTableState.error;
    }
  }
}
