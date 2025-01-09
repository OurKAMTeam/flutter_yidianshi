// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_yidianshi/models/class/home_arrangement/home_arrangement.dart';

class ClassTableCardArrangementDetail extends StatelessWidget {
  final HomeArrangement displayArrangement;

  const ClassTableCardArrangementDetail({required this.displayArrangement, super.key});

  bool get isContentEmpty =>
      displayArrangement.place == null &&
      displayArrangement.seat == null &&
      displayArrangement.teacher == null;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (displayArrangement.place != null) {
      items.add(_buildIconText(
        context,
        Icons.room,
        displayArrangement.place!,
      ));
    }

    if (displayArrangement.seat != null) {
      items.add(_buildIconText(
        context,
        Icons.chair,
        displayArrangement.seat!.toString(),
      ));
    }

    if (displayArrangement.teacher != null) {
      items.add(_buildIconText(
        context,
        Icons.person,
        displayArrangement.teacher!,
      ));
    }

    return Row(
      children: List.generate(items.length * 2 - 1, (index) {
        if (index.isEven) {
          return items[index ~/ 2];
        }
        return const SizedBox(width: 6);
      }),
    );
  }

  Widget _buildIconText(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? null
              : Theme.of(context).colorScheme.onPrimaryFixedVariant,
          size: 18,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
