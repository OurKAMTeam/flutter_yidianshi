// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_yidianshi/models/class/classtable/classtable.dart';
import 'package:flutter_yidianshi/repository/classtable/base_classtable_repository.dart';
import 'package:flutter_yidianshi/repository/classtable/class_change_processor.dart';
import 'package:flutter_yidianshi/repository/classtable/time_arrangement_processor.dart';
import 'package:flutter_yidianshi/xd_api/network_api/xd_api_ehall.dart';
import 'package:flutter_yidianshi/xd_api/network_api/xd_api_yjspt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassTableRepository implements BaseClassTableRepository {
  static const userDefinedClassName = "UserClass.json";
  static const partnerClassName = "darling.erc.json";
  static const decorationName = "decoration.jpg";

  final EhallClassTableApiProvider ehallApi;
  final YjsptClassTableApiProvider yjsptApi;
  final SharedPreferences prefs;
  final String supportPath;

  ClassTableRepository({
    required this.ehallApi,
    required this.yjsptApi,
    required this.prefs,
    required this.supportPath,
  });

  @override
  Future<ClassTableData> getClassTable({required bool isPostgraduate}) async {
    ClassTableData? data;

    try {
      data = await _getClassTableFromCache();
    } catch (e) {
      if (e is NotSameSemesterException) {
        data = await _getClassTableFromNetwork(isPostgraduate);
      }
    }

    if (data == null) {
      data = await _getClassTableFromNetwork(isPostgraduate);
    }

    if (data.classChanges.isNotEmpty) {
      data = ClassChangeProcessor.process(data);
    }

    data.timeArrangement = TimeArrangementProcessor.process(data.timeArrangement);

    return data;
  }

  Future<void> saveClassTableToCache(ClassTableData data) async {
    await prefs.setString("ClassTable.json", jsonEncode(data.toJson()));
  }

  Future<void> clearCache() async {
    await prefs.remove("ClassTable.json");
  }

  Future<ClassTableData?> _getClassTableFromCache() async {
    final jsonStr = prefs.getString("ClassTable.json");
    if (jsonStr == null) return null;

    final data = ClassTableData.fromJson(jsonDecode(jsonStr));
    final currentSemester = await ehallApi.getCurrentSemester();

    if (data.semesterCode != currentSemester) {
      throw NotSameSemesterException(msg: '学期不一致');
    }

    return data;
  }

  Future<ClassTableData> _getClassTableFromNetwork(bool isPostgraduate) async {
    if (isPostgraduate) {
      // 获取学期代码
      final semesterCode = await yjsptApi.getSemesterCode();

      // 获取当前周数
      DateTime now = DateTime.now();
      final weekResponse = await yjsptApi.getCurrentWeek(
        Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd"),
      );
      final currentWeek = RegExp(r'[0-9]+').firstMatch(weekResponse.body["xnxq"])![0]!;

      // 计算学期开始日期
      int weekDay = now.weekday - 1;
      String termStartDay = Jiffy.parseFromDateTime(now)
          .add(weeks: 1 - int.parse(currentWeek), days: -weekDay)
          .startOf(Unit.day)
          .format(pattern: "yyyy-MM-dd HH:mm:ss");

      // 检查是否新学期
      if (prefs.getString('currentStartDay') != termStartDay) {
        prefs.setString('currentStartDay', termStartDay);
        var userClassFile = File("$supportPath/$userDefinedClassName");
        if (userClassFile.existsSync()) userClassFile.deleteSync();
      }

      // 获取课表数据
      final classTableResponse = await yjsptApi.getClassTableInfo(semesterCode);
      final data = classTableResponse.body;

      if (data['code'] != "0") {
        if (data['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
          return ClassTableData(
            semesterCode: semesterCode,
            termStartDay: termStartDay,
          );
        } else {
          throw Exception("${data['extParams']['msg']}");
        }
      }

      // 获取未安排课程
      final notArrangedResponse = await yjsptApi.getNotArrangedInfo(
        semesterCode,
        prefs.getString('idsAccount') ?? '',
      );

      // 整理数据
      Map<String, dynamic> qResult = {
        "rows": data["datas"]["xspkjgcx"]["rows"],
        "notArranged": notArrangedResponse.body['datas']['xswsckbkc']["rows"],
        "semesterCode": semesterCode,
        "termStartDay": termStartDay,
      };

      ClassTableData toReturn = _simplifyData(qResult);
      toReturn.timeArrangement = TimeArrangementProcessor.process(toReturn.timeArrangement);
      return toReturn;
    } else {
      // 获取学期信息
      final semesterResponse = await ehallApi.getCurrentSemester();
      final semesterCode = semesterResponse.body['datas']['dqxnxq']['rows'][0]['DM'];

      // 获取学期开始日期
      final termStartResponse = await ehallApi.getTermStartDay(
        '${semesterCode.split('-')[0]}-${semesterCode.split('-')[1]}',
        semesterCode.split('-')[2],
      );
      final termStartDay = termStartResponse.body['datas']['cxjcs']['rows'][0]["XQKSRQ"];

      // 检查是否新学期
      if (prefs.getString('currentStartDay') != termStartDay) {
        prefs.setString('currentStartDay', termStartDay);
        var userClassFile = File("$supportPath/$userDefinedClassName");
        if (userClassFile.existsSync()) userClassFile.deleteSync();
      }

      // 获取课表数据
      final classTableResponse = await ehallApi.getClassTableInfo(
        semesterCode,
        prefs.getString('idsAccount') ?? '',
      );
      final qResult = classTableResponse.body['datas']['xskcb'];

      if (qResult['extParams']['code'] != 1) {
        if (qResult['extParams']['msg'].toString().contains("查询学年学期的课程未发布")) {
          return ClassTableData(
            semesterCode: semesterCode,
            termStartDay: termStartDay,
          );
        } else {
          throw Exception("${qResult['extParams']['msg']}");
        }
      }

      // 获取未安排课程
      final notArrangedResponse = await ehallApi.getNotArrangedInfo(
        semesterCode,
        prefs.getString('idsAccount') ?? '',
      );

      // 整理数据
      Map<String, dynamic> data = {
        "rows": qResult["rows"],
        "notArranged": notArrangedResponse.body['datas']['cxxsllsywpk']["rows"],
        "semesterCode": semesterCode,
        "termStartDay": termStartDay,
      };

      ClassTableData preliminaryData = _simplifyData(data);
      preliminaryData.timeArrangement = TimeArrangementProcessor.process(preliminaryData.timeArrangement);

      // 处理课程变更
      final classChangesResponse = await ehallApi.getClassChanges(semesterCode);
      final classChanges = classChangesResponse.body['datas']['xsdkkc'];

      if (classChanges['extParams']['code'] != 1) {
        return preliminaryData;
      }

      // 处理变更信息
      if (int.parse(classChanges["totalSize"].toString()) > 0) {
        for (var change in classChanges["rows"]) {
          preliminaryData.classChanges.add(ClassChange(
            type: _getChangeType(change["DKLX"]),
            classCode: change["KCH"],
            classNumber: change["KXH"],
            className: change["KCM"],
            originalAffectedWeeks: _generateWeekList(change["SKZC"]),
            newAffectedWeeks: _generateWeekList(change["XSKZC"]),
            originalTeacherData: change["YSKJS"],
            newTeacherData: change["XSKJS"],
            originalClassRange: [int.parse(change["KSJS"]), int.parse(change["JSJC"])],
            newClassRange: [int.parse(change["XKSJS"]), int.parse(change["XJSJC"])],
            originalWeek: int.parse(change["SKXQ"]),
            newWeek: int.parse(change["XSKXQ"]),
            originalClassroom: change["JASMC"],
            newClassroom: change["XJASMC"],
          ));
        }
      }

      return preliminaryData;
    }
  }

  ClassTableData _simplifyData(Map<String, dynamic> qResult) {
    ClassTableData toReturn = ClassTableData();
    toReturn.semesterCode = qResult["semesterCode"];
    toReturn.termStartDay = qResult["termStartDay"];

    for (var i in qResult["rows"]) {
      var toDeal = ClassDetail(
        name: i["KCM"],
        code: i["KCH"],
        number: i["KXH"],
      );
      if (!toReturn.classDetail.contains(toDeal)) {
        toReturn.classDetail.add(toDeal);
      }
      toReturn.timeArrangement.add(
        TimeArrangement(
          source: Source.school,
          index: toReturn.classDetail.indexOf(toDeal),
          start: int.parse(i["KSJC"]),
          teacher: i["SKJS"],
          stop: int.parse(i["JSJC"]),
          day: int.parse(i["SKXQ"]),
          weekList: List<bool>.generate(
            i["SKZC"].toString().length,
            (index) => i["SKZC"].toString()[index] == "1",
          ),
          classroom: i["JASMC"],
        ),
      );
      if (i["SKZC"].toString().length > toReturn.semesterLength) {
        toReturn.semesterLength = i["SKZC"].toString().length;
      }
    }

    // Deal with the not arranged data.
    for (var i in qResult["notArranged"]) {
      toReturn.notArranged.add(NotArrangementClassDetail(
        name: i["KCM"],
        code: i["KCH"],
        number: i["KXH"],
        teacher: i["SKJS"],
      ));
    }

    return toReturn;
  }

  String _getCourseId(String code, String number) {
    return '$code-$number';
  }

  String _getChangeId(String code, String number, int startWeek, int stopWeek) {
    return '$code-$number-$startWeek-$stopWeek';
  }

  ChangeType _getChangeType(String code) {
    switch (code) {
      case '01':
        return ChangeType.change; //调课
      case '02':
        return ChangeType.stop; //停课
      default:
        return ChangeType.patch; //补课
    }
  }

  List<bool> _generateWeekList(String? weeks) {
    if (weeks == null || weeks.isEmpty) return List.filled(30, true);
    return List<bool>.generate(
      weeks.length,
      (index) => weeks[index] == "1",
    );
  }
}

class NotSameSemesterException implements Exception {
  final String msg;
  NotSameSemesterException({required this.msg});
}
