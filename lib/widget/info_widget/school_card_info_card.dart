// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ming_cute_icons/ming_cute_icons.dart';
// import 'package:watermeter/repository/network_session.dart';
// import 'package:watermeter/repository/xidian_ids/ids_session.dart';
// import 'package:watermeter/widget/public/toast.dart';
// import 'package:watermeter/widget/public/context_extension.dart';
// import 'package:watermeter/page/schoolcard/school_card_window.dart';
// import './controllers/school_card_controller.dart';
// import '../tools/main_page_card.dart';

// class SchoolCardInfoCard extends GetView<SchoolCardController> {
//   const SchoolCardInfoCard({super.key});

//   void _handleCardTap(BuildContext context) async {
//     if (offline) {
//       showToast(context: context, msg: '当前处于离线模式');
//       return;
//     }

//     switch (controller.status) {
//       case SessionState.fetched:
//         context.pushReplacement(const SchoolCardWindow());
//         break;
//       case SessionState.error:
//         if (controller.error.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 controller.error.length > 120
//                     ? '${controller.error.substring(0, 120)}...'
//                     : controller.error,
//               ),
//             ),
//           );
//         }
//         showToast(context: context, msg: '获取校园卡信息失败');
//         break;
//       default:
//         showToast(context: context, msg: '正在获取校园卡信息...');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => MainPageCard(
//           isLoad: controller.status == SessionState.fetching,
//           icon: MingCuteIcons.mgc_wallet_4_line,
//           text: '校园卡',
//           infoText: Text(
//             controller.getInfoText(),
//             style: const TextStyle(fontSize: 20),
//           ),
//           bottomText: Text(
//             controller.getBottomText(),
//             overflow: TextOverflow.ellipsis,
//           ),
//           onTap: () => _handleCardTap(context),
//         ));
//   }
// }
