import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/repository/repository.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';

class LoginController extends GetxController {
  final ApiProviderIds apiProviderIds;
  final ApiProviderEhall apiProviderEhall;
  final PersonalRepository personalRepository;

  LoginController({
    required this.apiProviderIds,
    required this.apiProviderEhall,
    required this.personalRepository,
  });

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  var selectedOption = 'undergraduate'.obs;

  void updateOption(String value) {
    selectedOption.value = value;
    log.info("here:$selectedOption");
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void login(BuildContext context) async {
    // 登录接口，网络IO部分写在xdapiRepository.login里面
    await apiProviderIds.login(
      username: loginEmailController.text,
      password: loginPasswordController.text,
      sliderCaptcha: (String captchaUrl) async {
        // Handle slider captcha here if needed
      },
    );

    // 如果上面没有报错则证明是正常登录的，
    final prefs = Get.find<SharedPreferences>();
    prefs.setString(StorageConstants.number, loginEmailController.text);
    prefs.setString(StorageConstants.passwd, loginPasswordController.text);

    if(selectedOption.value == "undergraduate"){
      // 本科生基本信息
      await personalRepository.getPersonalInfo(isPostgraduate: false);
    }else{
      // 研究生基本信息
      await personalRepository.getPersonalInfo(isPostgraduate: true);
    }
  }

  @override
  void onClose() {
    super.onClose();

    loginEmailController.dispose();
    loginPasswordController.dispose();
  }
}
