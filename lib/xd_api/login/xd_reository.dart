import 'dart:async';
import 'dart:io';

import 'package:flutter_yidianshi/models/models.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'package:html/parser.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';


class XdApiRepository{

  final prefs = Get.find<SharedPreferences>();

  final ApiProvider apiProvider;

  final ApiProviderEhall apiProviderEhall;

  final ApiProviderPersonalyjs apiProviderPersonalyjs;

  final ApiProviderPersonalxgxt apiProviderPersonalxgxt;

  XdApiRepository({
    required this.apiProvider,
    required this.apiProviderEhall,
    required this.apiProviderPersonalyjs,
    required this.apiProviderPersonalxgxt
  });

  Future<void> login({
    required XdLoginRequest data,
  }) async {

    final response = await apiProvider.testlogin("/authserver/login");
    log.info(
      "[XdApiRepository][login]"
          "response: ${response}",
    );
    var page = parse(response ?? "");
    var form = page.getElementsByTagName("input")
      ..removeWhere(
            (element) => element.attributes["type"] != "hidden",
      );

    Map<String, dynamic> head = data.toJson();

    final cookieStr = await apiProvider.getcookie();

    const _header = [
      "lt",
      "execution",
    ];

    for (var i in _header) {
      head[i] = form
          .firstWhere(
            (element) => element.attributes["name"] == i || element.id == i,
      )
          .attributes["value"]!;
    }
    apiProvider.getTime("https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl");

    // 开始验证码验证
    //final response = await apiProvider.login('https://ids.xidian.edu.cn/authserver/login', data);


    await apiProvider.solve();

    try {
      var datas = await apiProvider.login(head);
      if (datas.statusCode == 301 || datas.statusCode == 302) {
        String? location = datas.headers?[HttpHeaders.locationHeader];
        if (location != null) {
          var response = await apiProviderEhall.login(location);
          while (response.headers?[HttpHeaders.locationHeader] != null) {
            location = response.headers![HttpHeaders
                .locationHeader]![0];
            log.info(
              "[ehall_session][loginEhall] "
                  "Received location: $location",
            );
            response = await apiProviderEhall.loginheaders(location);

          }
        }
      }
    }on Exception catch (e){
    }
  }

  Future<void>yjsPersonal() async{
    // 请求基本信息
    final res =  await apiProviderPersonalyjs.personalbase("/gsapp/sys/yjsemaphome/modules/pubWork/getUserInfo.do");
    if (res["code"] != "0") {
      //throw GetInformationFailedException(detailed["msg"].toString());
    }
    prefs.setString(StorageConstants.name, res["data"]["userName"]);
    prefs.setString(StorageConstants.currentSemester, res["data"]["xnxqdm"]);

    // 获取学院等信息
    final ress = await apiProviderPersonalyjs.personal("/gsapp/sys/yjsemaphome/homeAppendPerson/getXsjcxx.do");

    prefs.setString(StorageConstants.execution, ress["performance"][0]["CONTENT"][4]["CAPTION"]);
    prefs.setString(StorageConstants.institutes, ress["performance"][0]["CONTENT"][2]["CAPTION"]);
    prefs.setString(StorageConstants.subject, ress["performance"][0]["CONTENT"][3]["CAPTION"]);
    prefs.setString(StorageConstants.dorm, ""); // not return, use false data

    // 获取当前周？
    final resss = await apiProviderPersonalyjs.personal("/gsapp/sys/yjsemaphome/portal/queryRcap.do");
    prefs.setString(StorageConstants.currentStartDay, resss); // not return, use false data
  }

  Future<void>xdxtPersonal() async{
    // 本科生信息基本接口
    final res = await apiProviderPersonalxgxt.personalbase("/xsfw/sys/jbxxapp/modules/infoStudent/getStuBaseInfo.do");
    prefs.setString(StorageConstants.name, res["data"]["XM"]);
    prefs.setString(StorageConstants.execution, res["data"]["SYDM_DISPLAY"].toString().replaceAll("·", ""));
    prefs.setString(StorageConstants.institutes, res["data"]["DWDM_DISPLAY"]);
    prefs.setString(StorageConstants.subject, res["data"]["ZYDM_DISPLAY"]);
    prefs.setString(StorageConstants.dorm, res["data"]["ZSDZ"]);
    // 学期代码获取
    final ress = await apiProviderPersonalxgxt.semesterCode("/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do");
    prefs.setString(StorageConstants.currentSemester, ress['datas']['dqxnxq']['rows'][0]['DM']);
    // currentWeeks获取
    final resss = await apiProviderPersonalxgxt.currentWeeks("/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do",ress['datas']['dqxnxq']['rows'][0]['DM']);
    prefs.setString(StorageConstants.currentStartDay, resss['datas']['cxjcs']['rows'][0]["XQKSRQ"]);



  }




}
