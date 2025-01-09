import 'package:get/get.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';
import "package:flutter_yidianshi/repository/personal/personal_repository.dart";

import 'login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        apiProviderIds: Get.find<ApiProviderIds>(),
        apiProviderEhall: Get.find<ApiProviderEhall>(),
        personalRepository: Get.find<PersonalRepository>(),
      ),
    );
  }
}
