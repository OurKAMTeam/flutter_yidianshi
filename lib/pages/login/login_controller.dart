import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_base/models/models.dart';
import 'package:flutter_base/routes/app_pages.dart';
import 'package:flutter_base/shared/shared.dart';
import 'package:flutter_base/api/api.dart';


class LoginController extends GetxController {
  final ApiRepository apiRepository;
  LoginController({required this.apiRepository});

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }


  void login(BuildContext context) async {
    // final res = await apiRepository.login(
    //   LoginRequest(
    //     email: loginEmailController.text,
    //     password: loginPasswordController.text,
    //   ),
    // );
    //
    // final prefs = Get.find<SharedPreferences>();
    // if (res!.token.isNotEmpty) {
    //   prefs.setString(StorageConstants.cookie, res.token);
    //   Get.toNamed(Routes.HOME);
    // }
    Get.toNamed(Routes.HOME);
  }

  @override
  void onClose() {
    super.onClose();

    loginEmailController.dispose();
    loginPasswordController.dispose();
  }
}
