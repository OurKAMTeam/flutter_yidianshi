// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_yidianshi/xd_api/network_api/xd_api_xgxt.dart';
import 'package:flutter_yidianshi/xd_api/network_api/xd_api_yjspt.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/shared/shared.dart';

class PersonalRepository {
  final ApiProviderPersonalxgxt apiProviderPersonalxgxt;
  final ApiProviderPersonalyjs apiProviderPersonalyjs;
  final SharedPreferences prefs;

  PersonalRepository({
    required this.apiProviderPersonalxgxt,
    required this.apiProviderPersonalyjs,
    required this.prefs,
  });

  /// Get personal information based on student type
  Future<void> getPersonalInfo({required bool isPostgraduate}) async {
    if (isPostgraduate) {
      await _getPostgraduateInfo();
    } else {
      await _getUndergraduateInfo();
    }
  }

  /// Get undergraduate student information
  Future<void> _getUndergraduateInfo() async {
    final response = await apiProviderPersonalxgxt.personalbase(
      "/xsfw/sys/jbxxapp/modules/infoStudent/getStuBatchInfo.do",
    );
    
    // Parse and save response data
    if (response != null) {
      await _savePersonalInfo(response);
    }
  }

  /// Get postgraduate student information
  Future<void> _getPostgraduateInfo() async {
    final response = await apiProviderPersonalyjs.personalbase("/student/getInfo");
    
    // Parse and save response data
    if (response != null) {
      await _savePersonalInfo(response);
    }
  }

  /// Save personal information to SharedPreferences
  Future<void> _savePersonalInfo(Map<String, dynamic> data) async {
    // Save basic info
    await prefs.setString(StorageConstants.name, data['name'] ?? '');
    await prefs.setString(StorageConstants.institutes, data['institutes'] ?? '');
    await prefs.setString(StorageConstants.subject, data['subject'] ?? '');
    await prefs.setString(StorageConstants.execution, data['execution'] ?? '');
    await prefs.setString(StorageConstants.dorm, data['dorm'] ?? '');
    
    // Save semester info if available
    if (data.containsKey('currentSemester')) {
      await prefs.setString(StorageConstants.currentSemester, data['currentSemester']);
    }
    
    // Save start day if available
    if (data.containsKey('startDay')) {
      await prefs.setString(StorageConstants.currentStartDay, data['startDay']);
    }
  }
}
