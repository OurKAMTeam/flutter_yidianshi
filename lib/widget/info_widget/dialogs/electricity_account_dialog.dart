// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElectricityAccountDialog extends StatelessWidget {
  const ElectricityAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Get.find<SharedPreferences>();
    final controller = TextEditingController(
      text: prefs.getString('dorm') ?? '',
    );

    return AlertDialog(
      title: const Text('电费账户设置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(
              labelText: '宿舍号',
              hintText: '例如：C12-123',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请输入正确的宿舍号，否则可能无法查询电费',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              Get.snackbar(
                '提示',
                '请输入宿舍号',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            // 验证宿舍号格式
            final regex = RegExp(r'^[A-Z]\d{1,2}-\d{3}$');
            if (!regex.hasMatch(controller.text)) {
              Get.snackbar(
                '提示',
                '宿舍号格式不正确，请使用如 C12-123 的格式',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            prefs.setString('dorm', controller.text);
            Get.back(result: true);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
