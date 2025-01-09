// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter_yidianshi/models/class/classtable/classtable.dart';

/// Base class for class table repository
abstract class BaseClassTableRepository {
  /// Cache file name for class table data
  static const schoolClassName = "ClassTable.json";

  /// Cache file name for user defined class data
  static const userDefinedClassName = "UserClass.json";

  /// Cache file name for partner class data
  static const partnerClassName = "darling.erc.json";

  /// Cache file name for decoration data
  static const decorationName = "decoration.jpg";

  /// Get class table data
  Future<ClassTableData> getClassTable({required bool isPostgraduate});

  /// Save class table data to cache
  Future<void> saveClassTableToCache(ClassTableData data);

  /// Clear class table cache
  Future<void> clearCache();
}

/// Exception thrown when semester is not the same
class NotSameSemesterException implements Exception {
  final String msg;
  NotSameSemesterException({required this.msg});

  @override
  String toString() => msg;
}
