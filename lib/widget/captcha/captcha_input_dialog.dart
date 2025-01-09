// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  final List<int> image;

  CaptchaInputDialog({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('请输入验证码'),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(Uint8List.fromList(image)),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            controller: _captchaController,
            decoration: const InputDecoration(
              hintText: '请输入验证码',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('确认'),
          onPressed: () async {
            if (_captchaController.text.isEmpty) {
              Get.snackbar(
                '提示',
                '请输入验证码',
                snackPosition: SnackPosition.BOTTOM,
              );
            } else {
              Get.back(result: _captchaController.text);
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
