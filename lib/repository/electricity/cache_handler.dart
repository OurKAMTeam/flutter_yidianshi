// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import '../../models/electricity/electricity.dart';

class CacheHandler {
  final Directory supportPath;

  CacheHandler(this.supportPath);

  Future<ElectricityInfo?> loadFromCache() async {
    final file = File('${supportPath.path}/electricity_cache.json');
    if (!file.existsSync()) return null;

    final content = await file.readAsString();
    final json = jsonDecode(content);
    final info = ElectricityInfo.fromJson(json);

    // 检查缓存是否过期
    if (info.fetchDay.day != DateTime.now().day) {
      return null;
    }

    return info;
  }

  Future<void> saveToCache(ElectricityInfo info) async {
    final file = File('${supportPath.path}/electricity_cache.json');
    await file.writeAsString(jsonEncode(info.toJson()));
  }
}
