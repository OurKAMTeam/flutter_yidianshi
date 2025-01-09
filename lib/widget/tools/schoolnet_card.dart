// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:ming_cute_icons/ming_cute_icons.dart';
// import 'package:watermeter/repository/preference.dart' as preference;
// import 'package:watermeter/repository/schoolnet_session.dart';
// import 'package:watermeter/widget/public/context_extension.dart';
// import 'package:watermeter/widget/public/captcha_input_dialog.dart';
// import 'package:watermeter/widget/setting/dialogs/schoolnet_password_dialog.dart';
// import './small_function_card.dart';
// import './controllers/schoolnet_controller.dart';

// class SchoolnetCard extends GetView<SchoolnetController> {
//   const SchoolnetCard({super.key});

//   void _showNetworkUsageDialog(BuildContext context, NetworkUsage usage) {
//     String message = '已用流量：${usage.used}\n'
//         '剩余流量：${usage.rest}\n'
//         '计费流量：${usage.charged}';

//     for (var i in usage.ipList) {
//       message += '\nIP地址：${i.$1}\n'
//           '登录时间：${i.$3}\n'
//           '使用流量：${i.$2}';
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('校园网使用情况'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('确定'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SmallFunctionCard(
//       icon: MingCuteIcons.mgc_wifi_line,
//       title: '校园网',
//       onTap: () async {
//         // 检查是否设置了密码
//         if (preference.getString(preference.Preference.schoolNetQueryPassword).isEmpty) {
//           await showDialog(
//             context: context,
//             builder: (context) => const SchoolNetPasswordDialog(),
//           );
//         }

//         await controller.fetchNetworkUsage(context);
        
//         if (controller.error != null) {
//           if (context.mounted) {
//             Fluttertoast.showToast(msg: controller.error!);
//           }
//         } else if (controller.networkUsage != null && context.mounted) {
//           _showNetworkUsageDialog(context, controller.networkUsage!);
//         }
//       },
//     );
//   }
// }
