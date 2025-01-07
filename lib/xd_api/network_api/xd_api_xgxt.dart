import 'package:jiffy/jiffy.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'dart:io';

import '../base_provider.dart';
import '../api_constants.dart';


class ApiProviderPersonalxgxt extends LoginProvider{

  @override
  void onInit(){
    super.onInit();
    httpClient.baseUrl =
        ApiConstants.xgxtUrl;
  }

  Future<dynamic> personalbase(String path) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    final prefs = Get.find<SharedPreferences>();
    var res = prefs.getString(StorageConstants.number);
    //prefs.setString(StorageConstants.number, loginEmailController.text);

    return post(
      path,
        {
          "requestParamStr={\"XSBH\":\"${res}\"}"
        },
      headers: {
        HttpHeaders.refererHeader: "https://xgxt.xidian.edu.cn/xsfw/sys/jbxxapp/*default/index.do",
        HttpHeaders.hostHeader: "xgxt.xidian.edu.cn",
      }
    ).then((onValue)=>onValue.body);
  }




  Future<dynamic> semesterCode(String path) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return post(
        path,
        {},
    ).then((onValue)=>onValue.body);
  }

  Future<dynamic> currentWeeks(String path,String semesterCodes) async{
    return post(
        path,
        {
          'XN': '${semesterCodes.split('-')[0]}-${semesterCodes.split('-')[1]}',
          'XQ': semesterCodes.split('-')[2]
        }
    ).then((onValue)=>onValue.body);
  }

}



