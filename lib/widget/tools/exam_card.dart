// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ming_cute_icons/ming_cute_icons.dart';
// import 'package:watermeter/controller/exam_controller.dart';
// import 'package:watermeter/page/exam/exam_info_window.dart';
// import 'package:watermeter/page/homepage/refresh.dart';
// import 'package:watermeter/widget/public/toast.dart';
// import 'package:watermeter/widget/public/context_extension.dart';
// import 'package:watermeter/repository/xidian_ids/ids_session.dart';
// import './small_function_card.dart';

// class ExamCard extends GetView<ExamController> {
//   const ExamCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return SmallFunctionCard(
//         icon: MingCuteIcons.mgc_calendar_line,
//         title: '考试',
//         onTap: () {
//           switch (controller.status) {
//             case ExamStatus.cache:
//             case ExamStatus.fetched:
//               Get.to(() => ExamInfoWindow(time: updateTime));
//               break;
            
//             case ExamStatus.error:
//               if (controller.error != null) {
//                 String errorMsg = controller.error.toString();
//                 if (errorMsg.length > 120) {
//                   errorMsg = '${errorMsg.substring(0, 120)}...';
//                 }
                
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(errorMsg)),
//                 );
                
//                 showToast(
//                   context: context,
//                   msg: '获取考试信息失败',
//                 );
//               }
//               break;
              
//             default:
//               showToast(
//                 context: context,
//                 msg: '正在获取考试信息...',
//               );
//           }
//         },
//       );
//     });
//   }
// }
