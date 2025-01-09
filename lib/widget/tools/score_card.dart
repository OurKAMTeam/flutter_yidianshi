// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:watermeter/widget/public/toast.dart';
// import 'package:watermeter/widget/public/context_extension.dart';
// import 'package:watermeter/page/score/score.dart';
// import './controllers/score_controller.dart';
// import './small_function_card.dart';

// class ScoreCard extends GetView<ScoreController> {
//   const ScoreCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return SmallFunctionCard(
//         icon: Icons.grading_rounded,
//         title: '成绩',
//         onTap: () {
//           if (controller.canAccessScore) {
//             context.pushReplacement(const ScoreWindow());
//           } else {
//             showToast(
//               context: context,
//               msg: '无法连接到服务器，且本地没有缓存数据',
//             );
//           }
//         },
//       );
//     });
//   }
// }
