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
    await xdapiRepository.login(
      data: XdLoginRequest(
        number: loginEmailController.text,
        passwd: loginPasswordController.text,
        isYanJiu: true,
      ),
    );

    // 如果上面没有报错则证明是正常登录的，
    final prefs = Get.find<SharedPreferences>();
    prefs.setString(StorageConstants.number, loginEmailController.text);
    prefs.setString(StorageConstants.passwd, loginPasswordController.text);


    if(selectedOption.value == "undergraduate"){
      // 本科生基本信息
      await xdapiRepository.xdxtPersonal();
    }else{
      // 研究生基本信息
      await xdapiRepository.yjsPersonal();
    }


  }

  @override
  void onClose() {
    super.onClose();

    loginEmailController.dispose();
    loginPasswordController.dispose();
  }
}
