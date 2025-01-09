// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'me_controller.dart';

class MeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeController>(() => MeController());
  }
}
