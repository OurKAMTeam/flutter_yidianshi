// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../captcha/captcha_input_dialog.dart';
import './dialogs/electricity_account_dialog.dart';
import './controllers/electricity_controller.dart';
import '../tools/main_page_card.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/constants/storage.dart';

class ElectricityCard extends GetView<ElectricityController> {
  const ElectricityCard({super.key});

  Future<void> _showElectricityDialog(BuildContext context) async {
    Get.dialog(
      AlertDialog(
        title: const Text('电费信息'),
        content: Obx(
          () => Text.rich(
            TextSpan(children: [
              if (controller.isCache)
                TextSpan(
                  text: '注意：这是缓存数据\n更新时间：${Jiffy.parseFromDateTime(controller.electricityInfo.fetchDay).format( pattern:'yyyy-MM-dd HH:mm:ss')}\n\n',
                ),
              TextSpan(
                text: '''房间号：${Get.find<StorageService>().getString(StorageConstants.dorm)}
                        剩余电量：${controller.electricityInfo.remain} kWh
                        上次充值：${controller.electricityInfo.lastCharge} kWh
                        充值金额：${controller.electricityInfo.lastChargeAmount} 元
                        充值时间：${Jiffy.parseFromDateTime(controller.electricityInfo.lastChargeTime).format( pattern:'yyyy-MM-dd HH:mm:ss')}
                        充值后余额：${controller.electricityInfo.lastChargeBalance} kWh
                        本月用电：${controller.electricityInfo.monthUsage} kWh''',
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccountDialog(BuildContext context) async {
    final result = await Get.dialog<bool>(
      const ElectricityAccountDialog(),
    );

    if (result == true && controller.hasDormInfo) {
      await controller.updateElectricityInfo(
        captchaFunction: (image) => Get.dialog<String>(
          CaptchaInputDialog(image: image),
        ).then((value) => value ?? ""),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => MainPageCard(
          isLoad: controller.isLoading,
          icon: MingCuteIcons.mgc_flash_line,
          text: '电费',
          infoText: Text(
            controller.electricityInfo.remain.contains(RegExp(r'[0-9]'))
                ? '剩余电量：${controller.electricityInfo.remain} kWh'
                : controller.electricityInfo.remain,
            style: const TextStyle(fontSize: 20),
          ),
          bottomText: Builder(builder: (context) {
            if (controller.isCache) {
              return Text(
                '缓存数据 - ${Jiffy.parseFromDateTime(controller.electricityInfo.fetchDay).format(pattern:'yyyy-MM-dd HH:mm:ss')}',
                overflow: TextOverflow.ellipsis,
              );
            }

            if (controller.electricityInfo.monthUsage.contains(RegExp(r'[0-9]'))) {
              return Text(
                '本月用电：${controller.electricityInfo.monthUsage} kWh',
                overflow: TextOverflow.ellipsis,
              );
            }
            return Text(
              controller.electricityInfo.monthUsage,
              overflow: TextOverflow.ellipsis,
            );
          }),
          onTap: () async {
            if (!controller.hasDormInfo) {
              await _showAccountDialog(context);
            } else {
              await _showElectricityDialog(context);
            }
          },
          onLongPress: () => controller.updateElectricityInfo(
            force: true,
            captchaFunction: (image) => Get.dialog<String>(
              CaptchaInputDialog(
                image: image,
              ),
            ).then((value) => value ?? ""),
          ),
        ));
  }
}
