import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SportCard extends StatelessWidget {
  const SportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 实现体育查询页面跳转
        debugPrint('跳转到体育查询页面');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          const Text(
            '体育查询',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}