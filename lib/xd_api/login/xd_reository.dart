import 'dart:async';
import 'dart:io';

import 'package:flutter_yidianshi/models/models.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'xd_api_ehall.dart';
import 'xd_api_login.dart';
import 'package:html/parser.dart';


class XdApiRepository{

  final ApiProvider apiProvider;

  final ApiProviderEhall apiProviderEhall;

  XdApiRepository({required this.apiProvider,required this.apiProviderEhall});

  Future<void> login({
    required XdLoginRequest data,
  }) async {

    final response = await apiProvider.testlogin("/authserver/login");
    log.info(
      "[XdApiRepository][login]"
          "response: ${response}",
    );
    var page = parse(response);
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
}
