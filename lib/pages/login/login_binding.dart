import 'package:get/get.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';

import 'login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
            () => LoginController(xdapiRepository: Get.find<XdApiRepository>()));
  }
}
