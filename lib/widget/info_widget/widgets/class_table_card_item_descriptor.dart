// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_yidianshi/models/class/home_arrangement/home_arrangement.dart';

class ClassTableCardItemDescriptor {
  List<HomeArrangement> displayArrangements = [];
  final String timeLabelPrefix;
  final IconData icon;
  final EdgeInsets padding;
  final bool isTomorrow;
  final bool isMultiArrangementsMode;

  ClassTableCardItemDescriptor({
    required this.timeLabelPrefix,
    required this.icon,
    required this.padding,
    this.isTomorrow = false,
    this.isMultiArrangementsMode = false,
  });

  bool get isNotEmpty => displayArrangements.isNotEmpty;

  void addArrangementIfNotNull(HomeArrangement? arr) {
    if (arr != null) {
      displayArrangements.add(arr);
    }
  }

  void addAllArrangements(Iterable<HomeArrangement> arrs) {
    displayArrangements.addAll(arrs);
  }
}
