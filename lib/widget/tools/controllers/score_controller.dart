// // Copyright 2024 BenderBlog Rodriguez and contributors.
// // SPDX-License-Identifier: MPL-2.0

// import 'package:get/get.dart';
// import 'package:watermeter/repository/xidian_ids/score_session.dart';
// import 'package:watermeter/repository/xidian_ids/ids_session.dart';

// class ScoreController extends GetxController {
//   final _isLoading = false.obs;
//   final _error = Rxn<String>();
//   final _hasCacheData = false.obs;

//   bool get isLoading => _isLoading.value;
//   String? get error => _error.value;
//   bool get hasCacheData => _hasCacheData.value;
//   bool get canAccessScore => !offline || ScoreSession.isCacheExist;

//   @override
//   void onInit() {
//     super.onInit();
//     checkCacheStatus();
//   }

//   Future<void> checkCacheStatus() async {
//     _hasCacheData.value = ScoreSession.isCacheExist;
//   }

//   void clearError() {
//     _error.value = null;
//   }
// }
