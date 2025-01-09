import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'home_controller.dart';
import 'mainpage/mainpage_screen.dart';
import 'tools/tools_screen.dart';
import 'post/post_screen.dart';
import 'me/me_screen.dart';

class PageInformation {
  final int index;
  final String name;
  final IconData icon;
  final IconData iconChoice;

  PageInformation({
    required this.index,
    required this.name,
    required this.icon,
    required this.iconChoice,
  });
}

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: controller.pageController,
        children: const [
          MainPageScreen(), // 首页
          ToolsScreen(), // 所有功能
          PostScreen(), // 论坛
          MeScreen(), // 我的
        ],
        onPageChanged: (int index) {
          controller.currentIndex = index;
        },
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 64,
          destinations: [
            NavigationDestination(
              icon: Icon(
                controller.currentIndex == 0
                    ? MingCuteIcons.mgc_home_3_fill
                    : MingCuteIcons.mgc_home_3_line,
              ),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(
                controller.currentIndex == 1
                    ? MingCuteIcons.mgc_flag_3_fill
                    : MingCuteIcons.mgc_flag_3_line,
              ),
              label: '所有功能',
            ),
            NavigationDestination(
              icon: Icon(
                controller.currentIndex == 2
                    ? MingCuteIcons.mgc_chat_3_fill
                    : MingCuteIcons.mgc_chat_3_line,
              ),
              label: '论坛',
            ),
            NavigationDestination(
              icon: Icon(
                controller.currentIndex == 3
                    ? MingCuteIcons.mgc_user_2_fill
                    : MingCuteIcons.mgc_user_2_line,
              ),
              label: '我的',
            ),
          ],
          selectedIndex: controller.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (int index) {
            controller.currentIndex = index;
            controller.pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }
}
