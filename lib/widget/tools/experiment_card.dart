// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExperimentCard extends StatelessWidget {
  const ExperimentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 实现实验查询页面跳转
        debugPrint('跳转到实验查询页面');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          const Text(
            '实验查询',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
