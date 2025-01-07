import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../base_provider.dart';

import 'dart:convert';
import 'dart:io';

class ApiProviderEhall extends LoginProvider{

  Map<String, String> headers  = {
    HttpHeaders.refererHeader: "http://ehall.xidian.edu.cn/new/index_xd.html",
    HttpHeaders.hostHeader: "ehall.xidian.edu.cn",
    HttpHeaders.acceptHeader: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    HttpHeaders.acceptEncodingHeader: 'identity',
    HttpHeaders.connectionHeader: 'Keep-Alive',
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded; charset=UTF-8",
  };

  Future<Response> login(String location) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return get(location);
  }

  Future<Response> loginheaders(String location) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return get(location,headers: headers);
  }



}



