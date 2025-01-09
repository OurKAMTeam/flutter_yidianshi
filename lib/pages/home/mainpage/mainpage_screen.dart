import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:get/get.dart';
import 'mainpage_controller.dart';
import 'classtable_controller.dart';

// 导入工具组件
import '../../../widget/tools/toolbox_card.dart';
import '../../../widget/tools/sport_card.dart';
import '../../../widget/tools/schoolnet_card.dart';
import '../../../widget/tools/score_card.dart';
import '../../../widget/tools/exam_card.dart';
import '../../../widget/tools/empty_classroom.dart';
import '../../../widget/tools/experiment_card.dart';

// 导入信息卡片组件
import '../../../widget/info_widget/electricity_card.dart';
import '../../../widget/info_widget/library_card.dart';
import '../../../widget/info_widget/school_card_info_card.dart';
import '../../../widget/info_widget/classtable_card.dart';

class MainPageScreen extends GetView<MainPageController> {
  const MainPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
          HeaderSliverAppBar(),
        ],
        body: BodyContent(),
      ),
    );
  }
}

class HeaderSliverAppBar extends GetView<MainPageController> {
  const HeaderSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: false,
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: GetBuilder<ClassTableController>(
          init: controller.classTableController,
          builder: (classTableController) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classTableController.getGreeting(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                classTableController.getWeekText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BodyContent extends GetView<MainPageController> {
  BodyContent({super.key});

  final List<Widget> children = const [
    ElectricityCard(),
    // LibraryCard(),
    // SchoolCardInfoCard(),
  ];

  final List<Widget> smallFunction = [
    // const ScoreCard(),
    // const ExamCard(),
    const EmptyClassroomCard(),
    //const SchoolnetCard(),
    // TODO: 实现角色判断逻辑
    // if (prefs.getBool(prefs.Preference.role) == false) ...[
    const ExperimentCard(),
    const SportCard(),
    // ],
    //const ToolboxCard(),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 实现刷新逻辑

        // 刷新课程表
        await controller.updateData(
          context: context,
          sliderCaptcha: (String cookieStr) async {
            // TODO: 实现验证码逻辑
            return '';
          },
        );
      },
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: [
            _buildBodyContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return Obx(() => Column(
      children: [
        // TODO: 实现通知卡片
        // const NoticeCard(),
        // TODO: 实现研究生通知
        // if (isPostgraduate) ...[
        //   Text('研究生通知').paddingAll(16),
        // ],
        // TODO: 实现课程表卡片
        ClassTableCard(),
        ...children,
        GridView.extent(
          maxCrossAxisExtent: 96,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: smallFunction,
        ),
      ],
    ).paddingSymmetric(vertical: 8, horizontal: 16));
  }
}
