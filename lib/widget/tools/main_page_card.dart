// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import './home_card_padding.dart';

class MainPageCard extends StatelessWidget {
  final bool isLoad;
  final IconData icon;
  final String text;
  final double? progress;
  final Widget infoText;
  final Widget bottomText;
  final Widget? rightButton;
  final bool? isBold;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MainPageCard({
    super.key,
    required this.icon,
    required this.text,
    required this.infoText,
    required this.bottomText,
    required this.isLoad,
    this.rightButton,
    this.progress,
    this.isBold,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isBold == true ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                  if (rightButton != null) rightButton!,
                ],
              ),
              const SizedBox(height: 16),
              if (isLoad || (progress != null && progress! >= 0 && progress! <= 1))
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: isLoad ? null : progress,
                    minHeight: 4,
                  ),
                )
              else
                infoText,
              const SizedBox(height: 8),
              bottomText,
            ],
          ),
        ),
      ),
    ).withHomeCardStyle(context);
  }
}
