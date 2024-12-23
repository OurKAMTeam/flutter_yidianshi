import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:html/parser.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:flutter_yidianshi/shared/shared.dart';


FutureOr<dynamic> responseInterceptor(
    Request request, Response response) async {
  EasyLoading.dismiss();
  responseLogger(response);
  if(response.statusCode == 401){
    passwdWrongMsg(response);
  }
  // if (response.statusCode != 200) {
  //   handleErrorStatus(response);
  //   return;
  // }

  if(response.statusCode == 200){
    if(response.headers!=null){
      return response;
    }
  }

}

void passwdWrongMsg(Response response){
  var form = parse(response).getElementsByClassName("span")
    ..removeWhere((element) => element.id != "showErrorTip");
  var msg = form.firstOrNull?.children[0].innerHtml ?? "登录遇到问题";

  if (msg.contains(RegExp(r"(用户名|密码).*误", unicode: true, dotAll: true))) {
    msg = "用户名或密码有误。";
  }
  throw PasswordWrongException(msg: msg);
}

// void handleErrorStatus(Response response) {
//   switch (response.statusCode) {
//     case 400:
//       final message = ErrorResponse.fromJson(response.body);
//       CommonWidget.toast(message.error);
//       break;
//     default:
//   }
//
//   return;
// }

void responseLogger(Response response) {
  //log.info('Status Code: ${response.statusCode}\n'
  //         'Data: ${response.bodyString?.toString() ?? ''}'
  //);
}


class PasswordWrongException implements Exception {
  final String msg;
  const PasswordWrongException({required this.msg});
  @override
  String toString() => msg;
}