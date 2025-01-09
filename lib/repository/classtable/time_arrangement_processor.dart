// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter_yidianshi/models/class/classtable/classtable.dart';

/// Process time arrangements
class TimeArrangementProcessor {
  /// Process time arrangements
  static List<TimeArrangement> process(List<TimeArrangement> timeData) {
    List<TimeArrangement> newStuff = [];

    if (timeData.isNotEmpty) {
      Map<int, List<TimeArrangement>> arrangementsMap = {};

      // Group by index
      for (var arrangement in timeData) {
        if (!arrangementsMap.containsKey(arrangement.index)) {
          arrangementsMap[arrangement.index] = [];
        }
        arrangementsMap[arrangement.index]!.add(arrangement);
      }

      // Process each group
      for (var arrangements in arrangementsMap.values) {
        if (arrangements.isEmpty) continue;

        // Sort by start time
        arrangements.sort((a, b) => a.start - b.start);

        // Get all time points that need to be processed
        List<int> timePoints = {
          for (var arrangement in arrangements)
            if (arrangement.start == arrangement.stop)
              arrangement.start
            else ...[arrangement.start, arrangement.stop]
        }.toList()
          ..sort();

        // Create new time arrangement for each time point
        for (var timePoint in timePoints) {
          List<TimeArrangement> currentArrangements = arrangements
              .where((element) =>
                  element.start == timePoint ||
                  (element.start < timePoint && element.stop > timePoint))
              .toList();

          if (currentArrangements.isEmpty) continue;

          TimeArrangement first = currentArrangements.first;
          newStuff.add(TimeArrangement(
            source: first.source,
            index: first.index,
            weekList: List<bool>.from(first.weekList),
            day: first.day,
            start: timePoint,
            stop: timePoint,
            classroom: first.classroom,
            teacher: first.teacher,
          ));
        }
      }
    }

    return newStuff;
  }
}
