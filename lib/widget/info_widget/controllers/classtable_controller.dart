// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter_yidianshi/bridge/save_to_groupid.g.dart';
import 'package:flutter_yidianshi/models/models.dart';
import 'package:flutter_yidianshi/repository/classtable/classtable_repository.dart';
import 'package:flutter_yidianshi/repository/classtable/base_classtable_repository.dart';
import 'package:flutter_yidianshi/shared/utils/logger.dart';
import 'package:flutter_yidianshi/shared/constants/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/models/class/home_arrangement/home_arrangement.dart';

enum ClassTableState {
  fetching,
  fetched,
  error,
  none,
}

class ClassTableController extends GetxController {
  // 课程时间表
  static const time = [
    "08:30", "09:15", // 第1节
    "09:25", "10:10", // 第2节
    "10:30", "11:15", // 第3节
    "11:25", "12:10", // 第4节
    "14:30", "15:15", // 第5节
    "15:25", "16:10", // 第6节
    "16:20", "17:05", // 第7节
    "17:15", "18:00", // 第8节
    "19:30", "20:15", // 第9节
    "20:25", "21:10", // 第10节
    "21:20", "22:05", // 第11节
  ];

  final _repository = Get.find<ClassTableRepository>();
  late Directory supportPath;
  
  // 课表状态
  String? error;
  ClassTableState state = ClassTableState.none;

  // 课表数据
  late File classTableFile;
  late File userDefinedFile;
  late ClassTableData classTableData;
  late UserDefinedClassData userDefinedClassData;

  // 简化模式开关
  static final simplifiedMode = true.obs;

  // 当前和下一节课
  HomeArrangement? get current => _current.value;
  HomeArrangement? get next => _next.value;
  List<HomeArrangement> get arrangements => _arrangements;
  int get remaining => _remaining.value;
  bool get isTomorrow => _isTomorrow.value;

  final _current = Rxn<HomeArrangement>();
  final _next = Rxn<HomeArrangement>();
  final _arrangements = <HomeArrangement>[].obs;
  final _remaining = 0.obs;
  final _isTomorrow = false.obs;

  // 获取课程详情
  ClassDetail getClassDetail(TimeArrangement timeArrangementIndex) =>
      classTableData.getClassDetail(timeArrangementIndex);

  bool checkIfTomorrow(DateTime updateTime) =>
      updateTime.hour * 60 + updateTime.minute > 21 * 60 + 25;

  int getCurrentWeek(DateTime now) {
    int delta = Jiffy.parseFromDateTime(now)
        .diff(Jiffy.parseFromDateTime(startDay), unit: Unit.day)
        .toInt();
    if (delta < 0) delta = -7;
    return delta ~/ 7;
  }

  /// 获取指定日期的所有课程安排
  List<HomeArrangement> getArrangementOfDay(DateTime timeToQuery) {
    Jiffy updateTime = Jiffy.parseFromDateTime(timeToQuery);
    int currentWeek = getCurrentWeek(timeToQuery);
    Set<HomeArrangement> getArrangement = {};
    
    if (currentWeek >= 0 && currentWeek < classTableData.semesterLength) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > currentWeek &&
            i.weekList[currentWeek] &&
            i.day == updateTime.dateTime.weekday) {
          getArrangement.add(HomeArrangement(
            name: getClassDetail(i).name,
            teacher: i.teacher,
            place: i.classroom,
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.start - 1) * 2].split(':')[0]),
              int.parse(time[(i.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          ));
        }
      }
    }

    return getArrangement.toList();
  }

  // 更新课程安排
  void updateArrangements() {
    final now = DateTime.now();
    final currentWeek = getCurrentWeek(now);
    final currentDay = now.weekday;
    final currentTime = now.hour * 60 + now.minute;

    _arrangements.clear();
    _current.value = null;
    _next.value = null;
    _remaining.value = 0;
    _isTomorrow.value = false;

    // 获取今天的课程
    var todayArrangements = classTableData.timeArrangement
        .where((arrangement) => 
          arrangement.day == currentDay && 
          arrangement.weekList[currentWeek])
        .toList();

    // 如果今天没有课或者已经过了最后一节课
    if (todayArrangements.isEmpty || 
        currentTime > todayArrangements.last.stop * 45 + 510) {
      // 检查明天的课程
      final tomorrowDay = currentDay == 7 ? 1 : currentDay + 1;
      final tomorrowWeek = tomorrowDay == 1 ? currentWeek + 1 : currentWeek;
      
      if (tomorrowWeek < classTableData.timeArrangement[0].weekList.length) {
        var tomorrowArrangements = classTableData.timeArrangement
            .where((arrangement) => 
              arrangement.day == tomorrowDay && 
              arrangement.weekList[tomorrowWeek])
            .toList();

        if (tomorrowArrangements.isNotEmpty) {
          _arrangements.addAll(tomorrowArrangements.map((e) => HomeArrangement(
            name: getClassDetail(e).name,
            teacher: e.teacher,
            place: e.classroom,
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(time[(e.start - 1) * 2].split(':')[0]),
              int.parse(time[(e.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(time[(e.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(e.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          )));
          _next.value = _arrangements.first;
          _remaining.value = _arrangements.length - 1;
          _isTomorrow.value = true;
        }
      }
      return;
    }

    // 对今天的课程进行排序
    todayArrangements.sort((a, b) => a.start.compareTo(b.start));
    _arrangements.addAll(todayArrangements.map((e) => HomeArrangement(
      name: getClassDetail(e).name,
      teacher: e.teacher,
      place: e.classroom,
      startTimeStr: Jiffy.parseFromDateTime(DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(time[(e.start - 1) * 2].split(':')[0]),
        int.parse(time[(e.start - 1) * 2].split(':')[1]),
      )).format(pattern: HomeArrangement.format),
      endTimeStr: Jiffy.parseFromDateTime(DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(time[(e.stop - 1) * 2 + 1].split(':')[0]),
        int.parse(time[(e.stop - 1) * 2 + 1].split(':')[1]),
      )).format(pattern: HomeArrangement.format),
    )));

    // 找到当前课程和下一节课
    for (var i = 0; i < todayArrangements.length; i++) {
      var arrangement = todayArrangements[i];
      var startTime = arrangement.start * 45 + 510; // 8:30 = 510分钟
      var endTime = arrangement.stop * 45 + 510;

      if (currentTime >= startTime && currentTime <= endTime) {
        _current.value = _arrangements[i];
        if (i < todayArrangements.length - 1) {
          _next.value = _arrangements[i + 1];
          _remaining.value = todayArrangements.length - i - 2;
        }
        break;
      } else if (currentTime < startTime) {
        _next.value = _arrangements[i];
        _remaining.value = todayArrangements.length - i - 1;
        break;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    final prefs = Get.find<SharedPreferences>();
    supportPath = Directory('${prefs.getString('appDocDir')}/class');
    if (!supportPath.existsSync()) {
      supportPath.createSync(recursive: true);
    }
    
    log.info("[ClassTableController][onInit] Init classtable file.");
    
    // 初始化课表文件
    classTableFile = File("${supportPath.path}/${BaseClassTableRepository.schoolClassName}");
    if (classTableFile.existsSync()) {
      log.info("[ClassTableController][onInit] Init from cache.");
      classTableData = ClassTableData.fromJson(jsonDecode(classTableFile.readAsStringSync()));
      state = ClassTableState.fetched;
    } else {
      log.info("[ClassTableController][onInit] Init from empty.");
      classTableData = ClassTableData();
    }

    log.info("[ClassTableController][onInit] Init user defined file.");
    refreshUserDefinedClass();
  }

  @override
  void onReady() async {
    await updateClassTable();
  }

  void refreshUserDefinedClass() {
    userDefinedFile = File("${supportPath.path}/${BaseClassTableRepository.userDefinedClassName}");
    if (!userDefinedFile.existsSync()) {
      userDefinedFile.writeAsStringSync(jsonEncode(UserDefinedClassData.empty()));
    }
    userDefinedClassData = UserDefinedClassData.fromJson(
      jsonDecode(userDefinedFile.readAsStringSync()),
    );
  }

  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) async {
    userDefinedClassData.userDefinedDetail.add(classDetail);
    timeArrangement.index = userDefinedClassData.userDefinedDetail.length - 1;
    userDefinedClassData.timeArrangement.add(timeArrangement);
    userDefinedFile.writeAsStringSync(jsonEncode(userDefinedClassData.toJson()));
    await updateClassTable(isUserDefinedChanged: true);
  }

  Future<void> editUserDefinedClass(
    TimeArrangement originalTimeArrangement,
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) async {
    if (originalTimeArrangement.source != Source.user ||
        originalTimeArrangement.index != timeArrangement.index) return;
        
    int timeArrangementIndex = userDefinedClassData.timeArrangement.indexOf(originalTimeArrangement);
    userDefinedClassData.timeArrangement[timeArrangementIndex]
      ..weekList = timeArrangement.weekList
      ..teacher = timeArrangement.teacher
      ..day = timeArrangement.day
      ..start = timeArrangement.start
      ..stop = timeArrangement.stop
      ..classroom = timeArrangement.classroom;

    // 更新课程详情
    int classDetailIndex = originalTimeArrangement.index;
    userDefinedClassData.userDefinedDetail[classDetailIndex]
      ..name = classDetail.name
      ..code = classDetail.code
      ..number = classDetail.number;

    userDefinedFile.writeAsStringSync(jsonEncode(userDefinedClassData.toJson()));
    await updateClassTable(isUserDefinedChanged: true);
  }

  Future<void> deleteUserDefinedClass(TimeArrangement timeArrangement) async {
    if (timeArrangement.source != Source.user) return;
    
    int tempIndex = timeArrangement.index;
    userDefinedClassData.timeArrangement.remove(timeArrangement);
    userDefinedClassData.userDefinedDetail.removeAt(timeArrangement.index);
    
    for (var i in userDefinedClassData.timeArrangement) {
      if (i.index >= tempIndex) i.index -= 1;
    }
    
    userDefinedFile.writeAsStringSync(jsonEncode(userDefinedClassData.toJson()));
    await updateClassTable(isUserDefinedChanged: true);
  }

  /// 学期开始日期
  DateTime get startDay => DateTime.parse(classTableData.termStartDay)
      .add(Duration(days: 7 * (Get.find<SharedPreferences>().getInt(StorageConstants.swift) ?? 0)));

  Future<void> updateClassTable({
    bool isForce = false,
    bool isUserDefinedChanged = false,
  }) async {
    if (state == ClassTableState.fetching) {
      return;
    }

    state = ClassTableState.fetching;
    error = null;
    update();

    if (isUserDefinedChanged) {
      userDefinedFile.writeAsStringSync(jsonEncode(userDefinedClassData.toJson()));
      classTableData.userDefinedDetail = userDefinedClassData.userDefinedDetail;
      classTableData.timeArrangement.addAll(userDefinedClassData.timeArrangement);
    } else {
      try {
        final prefs = Get.find<SharedPreferences>();
        bool isPostGraduate = prefs.getBool(StorageConstants.role) ?? false;
        var toUse = await _repository.getClassTable(isPostgraduate: isPostGraduate);
        classTableFile.writeAsStringSync(jsonEncode(toUse.toJson()));
        toUse.userDefinedDetail = userDefinedClassData.userDefinedDetail;
        toUse.timeArrangement.addAll(userDefinedClassData.timeArrangement);
        classTableData = toUse;
        state = ClassTableState.fetched;
      } catch (e) {
        error = e.toString();
        state = ClassTableState.error;
      }
    }

    update();

    // iOS 小组件更新
    if (Platform.isIOS) {
      final widgetApi = SaveToGroupIdSwiftApi();
      final prefs = Get.find<SharedPreferences>();
      try {
        bool data = await widgetApi.saveToGroupId(FileToGroupID(
          appid: prefs.getString(StorageConstants.appId) ?? '',
          fileName: "ClassTable.json",
          data: jsonEncode(classTableData.toJson()),
        ));
        log.info(
          "[ClassTableController][updateClassTable] "
          "ios ClassTable.json save to public place status: $data.",
        );
      } catch (e) {
        log.warning("[ClassTableController][updateClassTable] Update ClassTable.json failed: $e");
      }
      
      try {
        bool data = await widgetApi.saveToGroupId(FileToGroupID(
          appid: prefs.getString(StorageConstants.appId) ?? '',
          fileName: "WeekSwift.txt",
          data: (prefs.getInt(StorageConstants.swift) ?? 0).toString(),
        ));
        log.info(
          "[ClassTableController][updateClassTable] "
          "ios WeekSwift.txt save to public place status: $data.",
        );
      } catch (e) {
        log.warning("[ClassTableController][updateClassTable] Update WeekSwift.txt failed: $e");
      }

      await HomeWidget.updateWidget(
        iOSName: "ClasstableWidget",
        qualifiedAndroidName: "io.github.benderblog.traintime_pda."
            "widget.classtable.ClassTableWidgetProvider",
      );
    }
  }
}
