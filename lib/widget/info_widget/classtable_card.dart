// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_yidianshi/models/class/class.dart';
import './controllers/classtable_controller.dart';
import './widgets/class_table_card_item.dart';
import './widgets/class_table_card_item_descriptor.dart';

class ClassTableCard extends GetView<ClassTableController> {
  const ClassTableCard({super.key});

  List<ClassTableCardItemDescriptor> _getItemDescriptors(BuildContext context) {
    var currItem = ClassTableCardItemDescriptor(
      timeLabelPrefix: '当前',
      icon: Icons.timelapse_outlined,
      padding: const EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
    );
    currItem.addArrangementIfNotNull(controller.current);

    var nextItem = ClassTableCardItemDescriptor(
      timeLabelPrefix: controller.isTomorrow ? '明天' : '接下来',
      icon: Icons.schedule_outlined,
      padding: const EdgeInsets.fromLTRB(5, 0.5, 0, 10.0),
      isTomorrow: controller.isTomorrow,
    );
    nextItem.addArrangementIfNotNull(controller.next);

    var moreItem = ClassTableCardItemDescriptor(
      timeLabelPrefix: '更多',
      icon: Icons.more_time_outlined,
      padding: const EdgeInsets.fromLTRB(5, 1.5, 0, 10.0),
      isMultiArrangementsMode: true,
    );
    if (controller.arrangements.length > 2) {
      moreItem.addAllArrangements(
        controller.arrangements.skip(controller.arrangements.length - controller.remaining),
      );
    }

    if (!ClassTableController.simplifiedMode.value) {
      return [currItem, nextItem, moreItem];
    }

    List<ClassTableCardItemDescriptor> results = [];
    results.addIf(currItem.isNotEmpty, currItem);
    results.addIf(nextItem.isNotEmpty, nextItem);
    results.addIf(moreItem.isNotEmpty, moreItem);

    if (results.isEmpty) {
      results.add(currItem);
    }
    return results;
  }

  void _handleCardTap(BuildContext context) {
    switch (controller.state) {
      case ClassTableState.fetched:
      
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ClassTableScreen(
        //       currentWeek: controller.getCurrentWeek(DateTime.now()),
        //     ),
        //   ),
        // );
      case ClassTableState.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取课表失败：${controller.error}'),
          ),
        );
      case ClassTableState.fetching:
      case ClassTableState.none:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在获取课表信息...'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _handleCardTap(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () {
              final items = _getItemDescriptors(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  items.length,
                  (index) => TimelineTile(
                    isFirst: index == 0,
                    isLast: index == items.length - 1,
                    alignment: TimelineAlign.start,
                    indicatorStyle: IndicatorStyle(
                      width: 24,
                      color: Theme.of(context).colorScheme.primary,
                      iconStyle: IconStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        iconData: items[index].icon,
                      ),
                    ),
                    beforeLineStyle: LineStyle(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 3,
                    ),
                    afterLineStyle: (index + 1 < items.length && items[index + 1].isTomorrow)
                        ? LineStyle(
                            color: Theme.of(context).colorScheme.primary,
                            thickness: 3,
                          )
                        : LineStyle(
                            color: Theme.of(context).colorScheme.primary,
                            thickness: 3,
                          ),
                    endChild: Padding(
                      padding: items[index].padding,
                      child: ClassTableCardItem(items[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
