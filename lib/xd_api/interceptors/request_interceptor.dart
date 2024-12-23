import 'dart:async';
import 'dart:io';


import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:flutter_yidianshi/shared/shared.dart';




FutureOr<Request> requestInterceptor(request) async {
  // final token = StorageService.box.pull(StorageItems.accessToken);

  // request.headers['X-Requested-With'] = 'XMLHttpRequest';
  // request.headers['Authorization'] = 'Bearer $token';

  // request.headers['Cookie'] = cookieJar;

  // 设置请求的内容类型为表单URL编码
  request.headers['Content-Type'] = 'application/x-www-form-urlencoded';

  // 添加User-Agent头字段
  request.headers[HttpHeaders.userAgentHeader] =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
      "AppleWebKit/537.36 (KHTML, like Gecko) "
      "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0";


  EasyLoading.show(status: 'loading...');
  requestlLogger(request);
  return request;
}

void requestlLogger(Request request) {
  log.info('Url: ${request.method} ${request.url}\n');
}
