import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/models/models.dart';
import 'package:flutter_yidianshi/routes/app_pages.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';


class LoginController extends GetxController {
  final XdApiRepository xdapiRepository;
  LoginController({required this.xdapiRepository});

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
    await xdapiRepository.login(
      data: XdLoginRequest(
        number: loginEmailController.text,
        passwd: loginPasswordController.text,
        isYanJiu: true,
      ),
    );

    final prefs = Get.find<SharedPreferences>();
    prefs.setString(StorageConstants.number, loginEmailController.text);
    prefs.setString(StorageConstants.passwd, loginPasswordController.text);


  }

  @override
  void onClose() {
    super.onClose();

    loginEmailController.dispose();
    loginPasswordController.dispose();
  }
}
