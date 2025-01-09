// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter_yidianshi/models/class/classtable/classtable.dart';

/// Process class changes
class ClassChangeProcessor {
  /// Process class changes
  static ClassTableData process(ClassTableData data) {
    List<ClassChange> cache = [];
    List<ClassChange> toDeal = List<ClassChange>.from(data.classChanges);

    while (toDeal.isNotEmpty) {
      List<int> toBeRemovedIndex = [];
      for (var change in toDeal) {
        // Find related courses
        List<int> indexClassDetailList = [];
        for (int i = 0; i < data.classDetail.length; ++i) {
          if (data.classDetail[i].code == change.classCode &&
              data.classDetail[i].number == change.classNumber) {
            indexClassDetailList.add(i);
          }
        }

        // If it's a patch, directly add new time arrangement
        if (change.type == ChangeType.patch) {
          _applyPatchChange(data, change, indexClassDetailList);
          toBeRemovedIndex.add(toDeal.indexOf(change));
          continue;
        }

        // Find all related time arrangements
        List<int> indexOriginalTimeArrangementList = [];
        for (var currentClassIndex in indexClassDetailList) {
          for (int i = 0; i < data.timeArrangement.length; ++i) {
            if (data.timeArrangement[i].index == currentClassIndex &&
                data.timeArrangement[i].day == change.originalWeek &&
                data.timeArrangement[i].start == change.originalClassRange[0] &&
                data.timeArrangement[i].stop == change.originalClassRange[1]) {
              indexOriginalTimeArrangementList.add(i);
            }
          }
        }

        // If original time arrangement not found, wait for next round
        if (indexOriginalTimeArrangementList.isEmpty) continue;

        if (change.type == ChangeType.change) {
          _applyChangeType(data, change, indexOriginalTimeArrangementList, cache);
        } else if (change.type == ChangeType.stop) {
          _applyStopType(data, change, indexOriginalTimeArrangementList);
        }
        toBeRemovedIndex.add(toDeal.indexOf(change));
      }
      toDeal = [
        for (var i = 0; i < toDeal.length; ++i)
          if (!toBeRemovedIndex.contains(i)) toDeal[i]
      ];
    }
    return data;
  }

  static void _applyPatchChange(
    ClassTableData data,
    ClassChange change,
    List<int> indexClassDetailList,
  ) {
    if (indexClassDetailList.isEmpty) return;
    if (change.newAffectedWeeks == null) return;

    data.timeArrangement.add(TimeArrangement(
      source: Source.school,
      index: indexClassDetailList.first,
      weekList: List<bool>.from(change.newAffectedWeeks!),
      day: change.newWeek!,
      start: change.newClassRange[0],
      stop: change.newClassRange[1],
      classroom: change.newClassroom ?? change.originalClassroom,
      teacher: change.isTeacherChanged ? change.newTeacher : change.originalTeacher,
    ));
  }

  static void _applyChangeType(
    ClassTableData data,
    ClassChange change,
    List<int> indexOriginalTimeArrangementList,
    List<ClassChange> cache,
  ) {
    if (indexOriginalTimeArrangementList.isEmpty) return;
    if (change.newAffectedWeeks == null || change.originalAffectedWeeks == null) return;

    int timeArrangementIndex = indexOriginalTimeArrangementList.first;

    // Process original time arrangements
    for (int indexOriginalTimeArrangement in indexOriginalTimeArrangementList) {
      for (int i = 0; i < change.originalAffectedWeeks!.length; i++) {
        if (change.originalAffectedWeeks![i] &&
            data.timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
          data.timeArrangement[indexOriginalTimeArrangement].weekList[i] = false;
          timeArrangementIndex = data.timeArrangement[indexOriginalTimeArrangement].index;
        }
      }
    }

    if (timeArrangementIndex == indexOriginalTimeArrangementList.first) {
      cache.add(change);
      timeArrangementIndex = data.timeArrangement[indexOriginalTimeArrangementList.first].index;
    }

    // Check for duplicate changes
    if (_isDuplicateChange(change, cache)) {
      _removeDuplicateChange(change, cache);
      return;
    }

    // Add new time arrangement
    data.timeArrangement.add(TimeArrangement(
      source: Source.school,
      index: timeArrangementIndex,
      weekList: List<bool>.from(change.newAffectedWeeks!),
      day: change.newWeek!,
      start: change.newClassRange[0],
      stop: change.newClassRange[1],
      classroom: change.newClassroom ?? change.originalClassroom,
      teacher: change.isTeacherChanged ? change.newTeacher : change.originalTeacher,
    ));
  }

  static void _applyStopType(
    ClassTableData data,
    ClassChange change,
    List<int> indexOriginalTimeArrangementList,
  ) {
    if (indexOriginalTimeArrangementList.isEmpty) return;
    if (change.originalAffectedWeeks == null) return;

    // Process stop class
    for (int indexOriginalTimeArrangement in indexOriginalTimeArrangementList) {
      for (int i = 0; i < change.originalAffectedWeeks!.length; i++) {
        if (change.originalAffectedWeeks![i] &&
            data.timeArrangement[indexOriginalTimeArrangement].weekList[i]) {
          data.timeArrangement[indexOriginalTimeArrangement].weekList[i] = false;
        }
      }
    }
  }

  static bool _isDuplicateChange(ClassChange change, List<ClassChange> cache) {
    return cache.any((element) =>
        element.classCode == change.classCode &&
        element.classNumber == change.classNumber &&
        _areListsEqual(element.originalClassRange, change.newClassRange) &&
        _areListsEqual(element.originalAffectedWeeks, change.newAffectedWeeks) &&
        element.originalWeek == change.newWeek &&
        element.originalTeacherData == change.newTeacherData);
  }

  static void _removeDuplicateChange(ClassChange change, List<ClassChange> cache) {
    cache.removeWhere((cached) =>
        cached.className == change.className &&
        cached.classCode == change.classCode &&
        _areListsEqual(cached.originalClassRange, change.newClassRange) &&
        _areListsEqual(cached.originalAffectedWeeks, change.newAffectedWeeks) &&
        cached.originalWeek == change.newWeek &&
        cached.originalTeacherData == change.newTeacherData);
  }

  static bool _areListsEqual<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null) return list2 == null;
    if (list2 == null) return false;
    return listEquals(list1, list2);
  }
}
