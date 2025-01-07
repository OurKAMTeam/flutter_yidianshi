
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../login/jc_captcha.dart';
import 'dart:typed_data';
import '../api_constants.dart';


import 'dart:convert';
import 'dart:io';

class ApiProvider extends SliderCaptchaClientProvider{

  @override
  void onInit(){
    super.onInit();
    httpClient.baseUrl =
        ApiConstants.idsUrl;
  }


  Future<Response> login(Map<String, dynamic> data) {
    //final response = testlogin("https://ids.xidian.edu.cn/authserver/login");
    return post(
      "/authserver/login",
      data,
    );
  }

  Future<String> getcookie() async{
    var cookies = await cookieJar
        .loadForRequest(Uri.parse("https://ids.xidian.edu.cn/authserver"));
    for (var i in cookies) {
      cookie += "${i.name}=${i.value}; ";
    }
    return cookie;
  }


  Future<String?> testlogin(String path) {
    return get(path,query: {
      'service': "https://ehall.xidian.edu.cn/new/index.html",},
    ).then( (onValue) => onValue.bodyString );
  }

  Future<Response> getTime(String path) {
    return get(
        path,
        // "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
        query: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
        headers: {
          "Cookie": cookie,
        }
    );
  }





  @override
  Future<void> solve() async {
    int retryCount = 20;
    for (int i = 0; i < retryCount; i++) {
      await updatePuzzle();
      double? answer = trySolve(puzzleData!, pieceData!);
      if (answer != null && await verify(answer)) {
        //log.info("Parse captcha $i time(s), success.");
        return;
      }else {

      }
      //log.info("Parse captcha $i time(s), failure.");
    }
  }


  String get cookie => super.cookie;

  Uint8List? get puzzleData => super.puzzleData;
  Uint8List? get pieceData => super.pieceData;
  Lazy<Image>? get puzzleImage => super.puzzleImage;
  Lazy<Image>? get pieceImage => super.pieceImage;
  double get puzzleWidth => super.puzzleWidth;
  double get puzzleHeight => super.puzzleHeight;
  double get pieceWidth => super.pieceWidth;
  double get pieceHeight => super.pieceHeight;

  @override
  double? trySolve(Uint8List puzzleData, Uint8List pieceData,
      {int border = 24}) {
    double? baseResult = super.trySolve(puzzleData, pieceData, border: border);
    return baseResult;
  }


  // 更新图片
  @override
  Future<void> updatePuzzle() async {
    var rsp = await getTime("/authserver/common/openSliderCaptcha.htl");

    String puzzleBase64 = rsp.body["bigImage"];
    String pieceBase64 = rsp.body["smallImage"];
    // double coordinatesY = double.parse(rsp.data["tagWidth"].toString());

    puzzleData = const Base64Decoder().convert(puzzleBase64);
    pieceData = const Base64Decoder().convert(pieceBase64);

    puzzleImage = Lazy(() => Image.memory(puzzleData!,
        width: puzzleWidth, height: puzzleHeight, fit: BoxFit.fitWidth));
    pieceImage = Lazy(() => Image.memory(pieceData!,
        width: pieceWidth, height: pieceHeight, fit: BoxFit.fitWidth));
  }

  @override
  Future<bool> verify(double answer) async {
    var res = await post(
        "/authserver/common/verifySliderCaptcha.htl",
        "canvasLength=${(puzzleWidth)}&moveLength=${(answer * puzzleWidth).toInt()}",
        headers: {
          "Cookie": cookie,
          HttpHeaders.contentTypeHeader:
          "application/x-www-form-urlencoded;charset=utf-8",
          HttpHeaders.accessControlAllowOriginHeader:
          "https://ids.xidian.edu.cn",
        }
    );
    return res.body["errorCode"] == 1;
  }

}

