// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:get/get.dart';
// import 'package:watermeter/repository/network_session.dart';
// import 'package:watermeter/repository/xidian_ids/school_card_session.dart' as school_card_session;

// class SchoolCardController extends GetxController {
//   final _status = Rx<SessionState>(SessionState.none);
//   final _money = ''.obs;
//   final _error = ''.obs;

//   SessionState get status => _status.value;
//   String get money => _money.value;
//   String get error => _error.value;

//   @override
//   void onInit() {
//     super.onInit();
//     // 监听校园卡会话状态
//     ever(school_card_session.isInit, (value) {
//       _status.value = value;
//     });

//     // 监听余额变化
//     ever(school_card_session.money, (value) {
//       _money.value = value;
//     });

//     // 监听错误信息
//     ever(school_card_session.errorSession, (value) {
//       _error.value = value;
//     });
//   }

//   String getDisplayMoney() {
//     if (!_money.value.contains(RegExp(r'[0-9]'))) {
//       return _money.value;
//     }

//     final amount = double.parse(_money.value);
//     return amount >= 10 ? amount.truncate().toString() : _money.value;
//   }

//   String getInfoText() {
//     switch (_status.value) {
//       case SessionState.fetched:
//         return '余额：¥${getDisplayMoney()}';
//       case SessionState.error:
//         return '获取失败';
//       default:
//         return '正在获取...';
//     }
//   }

//   String getBottomText() {
//     switch (_status.value) {
//       case SessionState.fetched:
//         return '点击查看详情';
//       case SessionState.error:
//         return '暂无信息';
//       default:
//         return '正在获取信息...';
//     }
//   }
// }
