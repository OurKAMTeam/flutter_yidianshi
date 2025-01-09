// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_yidianshi/models/class/home_arrangement/home_arrangement.dart';
import '../controllers/classtable_controller.dart';
import './class_table_card_item_descriptor.dart';
import './class_table_card_arrangement_detail.dart';

class ClassTableCardItem extends GetView<ClassTableController> {
  final ClassTableCardItemDescriptor descriptor;

  const ClassTableCardItem(this.descriptor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getTimeText(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...descriptor.isMultiArrangementsMode
            ? _buildMultiArrangements(context)
            : _buildSingleArrangement(context),
      ],
    );
  }

  String _getTimeText() {
    String timeText = descriptor.timeLabelPrefix;
    if (!descriptor.isMultiArrangementsMode && descriptor.isNotEmpty) {
      HomeArrangement arr = descriptor.displayArrangements[0];
      timeText += " "
          "${Jiffy.parseFromDateTime(arr.startTime).format(pattern: "HH:mm")} - "
          "${Jiffy.parseFromDateTime(arr.endTime).format(pattern: "HH:mm")}";
    }
    return timeText;
  }

  List<Widget> _buildSingleArrangement(BuildContext context) {
    HomeArrangement? arr = descriptor.displayArrangements.firstOrNull;
    List<Widget> widgets = [];

    String infoText;
    if (arr != null) {
      infoText = arr.name;
    } else {
      if (controller.state == ClassTableState.error) {
        infoText = '获取失败';
      } else if (controller.state == ClassTableState.fetching) {
        infoText = '正在获取...';
      } else {
        infoText = '暂无课程';
      }
    }

    widgets.add(
      Text(
        infoText,
        style: const TextStyle(
          height: 1.1,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

    if (arr != null) {
      widgets.add(const SizedBox(height: 4));
      widgets.add(ClassTableCardArrangementDetail(displayArrangement: arr));
    }

    return widgets;
  }

  List<Widget> _buildMultiArrangements(BuildContext context) {
    return descriptor.displayArrangements.map((arr) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Jiffy.parseFromDateTime(arr.startTime).format(pattern: "HH:mm"),
            style: const TextStyle(
              height: 1.2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              arr.name,
              style: const TextStyle(
                height: 1.1,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
