// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyClassroomCard extends StatelessWidget {
  const EmptyClassroomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 实现空教室查询页面跳转
        debugPrint('跳转到空教室查询页面');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          const Text(
            '空教室',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
