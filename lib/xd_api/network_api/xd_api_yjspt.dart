import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../base_provider.dart';
import '../api_constants.dart';

import 'dart:convert';
import 'dart:io';

class ApiProviderPersonalyjs extends LoginProvider{

  @override
  void onInit(){
    super.onInit();
    httpClient.baseUrl =
        ApiConstants.yjslUrl;
  }

  Future<dynamic> personalbase(String path) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return post(
      path,
      {},
    ).then((onValue)=>onValue.body);
  }

  Future<dynamic> personal(String path) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return post(
      path,
      {"datas": '{"wdxysysfaxq":"1","concurrency":"main"}'},
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      }
    ).then((onValue)=>onValue.body);
  }

  Future<String> currentWeeks(String path) async{
    DateTime now = DateTime.now();
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    var currentWeek = await post(
        path,
        {'day': Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")},
    ).then((onValue)=>onValue.body);

    currentWeek = RegExp(r'[0-9]+').firstMatch(currentWeek["xnxq"])![0]!;
    int weekDay = now.weekday - 1;

    String termStartDay = Jiffy.parseFromDateTime(now)
        .add(weeks: 1 - int.parse(currentWeek), days: -weekDay)
        .format(pattern: "yyyy-MM-dd");

    return termStartDay;

  }





}



