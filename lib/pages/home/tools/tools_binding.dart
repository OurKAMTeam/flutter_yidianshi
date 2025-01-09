// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'tools_controller.dart';

class ToolsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ToolsController>(() => ToolsController());
  }
}