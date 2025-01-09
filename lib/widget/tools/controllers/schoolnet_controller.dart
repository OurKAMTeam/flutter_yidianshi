// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:watermeter/repository/preference.dart' as preference;
// import 'package:watermeter/repository/schoolnet_session.dart';
// import 'package:watermeter/widget/public/captcha_input_dialog.dart';
// import 'package:watermeter/widget/setting/dialogs/schoolnet_password_dialog.dart';

// class SchoolnetController extends GetxController {
//   final _isLoading = false.obs;
//   final _error = Rxn<String>();
//   final _networkUsage = Rxn<NetworkUsage>();

//   bool get isLoading => _isLoading.value;
//   String? get error => _error.value;
//   NetworkUsage? get networkUsage => _networkUsage.value;

//   Future<void> showPasswordDialog(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (context) => const SchoolNetPasswordDialog(),
//     );
//   }

//   Future<void> fetchNetworkUsage(BuildContext context) async {
//     if (_isLoading.value) return;

//     try {
//       _isLoading.value = true;
//       _error.value = null;

//       // 检查密码
//       if (preference.getString(preference.Preference.schoolNetQueryPassword).isEmpty) {
//         await showPasswordDialog(context);
//         if (preference.getString(preference.Preference.schoolNetQueryPassword).isEmpty) {
//           throw EmptyPasswordException();
//         }
//       }

//       // 获取网络使用情况
//       final usage = await SchoolnetSession().getNetworkUsage(
//         captchaFunction: (memoryImage) => showDialog<String>(
//           context: context,
//           builder: (context) => CaptchaInputDialog(image: memoryImage),
//         ).then((value) => value ?? ""),
//       );

//       _networkUsage.value = usage;
//     } on EmptyPasswordException {
//       _error.value = '请先设置校园网密码';
//     } on NotInitalizedException catch (e) {
//       _error.value = '获取数据失败：${e.msg ?? "未知错误"}';
//     } catch (e) {
//       _error.value = '发生错误：${e.toString()}';
//     } finally {
//       _isLoading.value = false;
//     }
//   }
// }

// class NetworkUsage {
//   final String used;
//   final String rest;
//   final String charged;
//   final List<(String, String, String)> ipList;

//   NetworkUsage({
//     required this.used,
//     required this.rest,
//     required this.charged,
//     required this.ipList,
//   });
// }
