import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // 当前选中的底部导航栏索引
  final _currentIndex = 0.obs;
  get currentIndex => _currentIndex.value;
  set currentIndex(value) => _currentIndex.value = value;

  // 页面控制器
  late final PageController pageController;
  
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // 切换页面
  void changePage(int index) {
    currentIndex = index;
    pageController.jumpToPage(index);
  }
}
