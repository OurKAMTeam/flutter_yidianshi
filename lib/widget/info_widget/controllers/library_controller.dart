// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:get/get.dart';
// import 'package:watermeter/repository/network_session.dart';
// import 'package:watermeter/repository/xidian_ids/library_session.dart' as borrow_info;

// class LibraryController extends GetxController {
//   final _status = Rx<SessionState>(SessionState.none);
//   final _borrowCount = 0.obs;
//   final _duedCount = 0.obs;

//   SessionState get status => _status.value;
//   int get borrowCount => _borrowCount.value;
//   int get duedCount => _duedCount.value;

//   @override
//   void onInit() {
//     super.onInit();
//     // 监听图书馆会话状态
//     ever(borrow_info.state, (value) {
//       _status.value = value;
//     });

//     // 监听借阅数量
//     ever(borrow_info.borrowList, (value) {
//       _borrowCount.value = value.length;
//     });

//     // 监听到期数量
//     ever(borrow_info.dued, (value) {
//       _duedCount.value = value;
//     });
//   }

//   String getInfoText() {
//     switch (_status.value) {
//       case SessionState.fetched:
//         return '当前借阅：$_borrowCount 本';
//       case SessionState.error:
//         return '获取失败';
//       default:
//         return '正在获取...';
//     }
//   }

//   String getBottomText() {
//     switch (_status.value) {
//       case SessionState.fetched:
//         return _duedCount == 0 ? '没有需要归还的图书' : '有 $_duedCount 本图书需要归还';
//       case SessionState.error:
//         return '暂无信息';
//       default:
//         return '正在获取信息...';
//     }
//   }
// }
