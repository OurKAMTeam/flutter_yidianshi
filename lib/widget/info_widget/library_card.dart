// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ming_cute_icons/ming_cute_icons.dart';
// import 'package:watermeter/repository/network_session.dart';
// import 'package:watermeter/repository/xidian_ids/ids_session.dart';
// import 'package:watermeter/widget/public/toast.dart';
// import 'package:watermeter/widget/public/context_extension.dart';
// import 'package:watermeter/page/library/library_window.dart';
// import './controllers/library_controller.dart';
// import '../tools/main_page_card.dart';

// class LibraryCard extends GetView<LibraryController> {
//   const LibraryCard({super.key});

//   void _handleCardTap(BuildContext context) {
//     if (offline) {
//       showToast(context: context, msg: '当前处于离线模式');
//       return;
//     }
//     context.pushReplacement(const LibraryWindow());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => MainPageCard(
//           isLoad: controller.status == SessionState.fetching,
//           icon: MingCuteIcons.mgc_book_2_line,
//           text: '图书馆',
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
