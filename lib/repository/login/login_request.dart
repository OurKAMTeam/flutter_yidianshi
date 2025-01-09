import 'dart:convert';
import 'package:flutter/material.dart';

class XdLoginRequest{
  XdLoginRequest({
    required this.number,
    required this.passwd,
    required this.isYanJiu,
  });

  // factory XdLoginRequest.fromRawJson(String str) =>
  //     XdLoginRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());


  // factory XdLoginRequest.fromJson(Map<String, dynamic> json) => XdLoginRequest(
  //   number: json["email"],
  //   passwd: json["password"],
  //   isYanJiu: json["isYanJiu"],
  // );

  String number;
  String passwd;
  bool isYanJiu;

  Map<String,dynamic> toJson()=>{
    "username": number,
    "password": passwd,
    'rememberMe': 'true',
    'cllt': 'userNameLogin',
    'dllt': 'generalLogin',
    '_eventId': 'submit',
  };




}
