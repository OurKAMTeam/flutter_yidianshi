// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

late Directory supportPath;

final _setCookieReg = RegExp('(?<=)(,)(?=[^;]+?=)');

// 拦截器定义，因为涉及到cookie的处理，函数之间的传递过于麻烦，因此删去拦截器文件，把所有逻辑放在这里
class LoginProvider extends BaseProvider {
  final prefs = Get.find<SharedPreferences>();
  final _storageService = Get.find<StorageService>();
  late final PersistCookieJar cookieJar;

  @override
  void onInit() async {
    super.onInit();

    // 初始化 Cookie 存储路径
    cookieJar = PersistCookieJar(
      persistSession: true,
      storage: FileStorage("${supportPath.path}/cookie/general"),
    );

    // 添加请求拦截器
    httpClient.addRequestModifier((Request request) async {
      final cookies = await cookieJar.loadForRequest(request.url); // 确保请求的 URL 被转换为 Uri 类型
      if (cookies.isNotEmpty) {
        // 拼接所有 cookies 并加入请求头
        final cookieHeader = getCookies(cookies);
        request.headers[HttpHeaders.cookieHeader] = cookieHeader;
      }

      // 设置请求的内容类型为表单URL编码
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      // 添加User-Agent头字段
      request.headers[HttpHeaders.userAgentHeader] =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
          "AppleWebKit/537.36 (KHTML, like Gecko) "
          "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0";
      EasyLoading.show(status: 'loading...');
      requestLogger(request);

      return request;
    });

    // 添加响应拦截器
    httpClient.addResponseModifier((request, response) async {
      responseLogger(response);
      await _saveCookies(response);
      if(response.statusCode == 200){
        if(response.headers!=null){
          return response;
        }
      }
    });
  }

  Future<void> _saveCookies(Response response) async {
    // Get the Set-Cookie header from the response
    final setCookiess = response.headers?[HttpHeaders.setCookieHeader];
    if (setCookiess != null) {
      List<String> setCookies = setCookiess.split(';');
      // If no Set-Cookie headers, return early
      if (setCookies == [] || setCookies.isEmpty) {
        return;
      }

      // Process each cookie string into Cookie objects
      final List<Cookie> cookies = setCookies
          .map((str) => str.split(_setCookieReg))
          .expand((cookie) => cookie)
          .where((cookie) => cookie.isNotEmpty)
          .map((str) => Cookie.fromSetCookieValue(str))
          .toList();

      // Handle potential redirects
      final originalUri = response.request?.url ?? Uri.parse('');
      // 使用 resolveUri 解析响应的实际 URI
      await cookieJar.saveFromResponse(originalUri, cookies);

      // Save cookies for the original response URI
      final statusCode = response.statusCode ?? 0;
      final locationss = response.headers?[HttpHeaders.locationHeader];
      if (locationss != null) {
        var locations = locationss.split(';');

        final isRedirectRequest = statusCode >= 300 && statusCode < 400;

        // Handle cookies in case of redirection (handling 3xx responses)
        if (isRedirectRequest && locations.isNotEmpty) {
          await Future.wait(
            locations.map(
                  (location) =>
                  cookieJar.saveFromResponse(
                    originalUri.resolve(location), // 根据原始 URI 解析位置 URI
                    cookies,
                  ),
            ),
          );
        }
      }
    }
  }

  // 清空所有 Cookies
  Future<void> clearCookieJar() => cookieJar.deleteAll();

  void requestLogger(Request request) async{
    // 初始化日志字符串
    String logMessage = '--- Request Info ---\n';

    // 添加请求方法和URL
    logMessage += 'Method: ${request.method}\n';
    logMessage += 'URL: ${request.url}\n';

    // 添加请求头
    logMessage += 'Headers: ${request.headers}\n';

    // 打印请求体
    if (request.method == 'POST' || request.method == 'PUT' || request.method == 'PATCH') {
      if (request.bodyBytes != null) {
        try {
          // 将 bodyBytes 转为字节数组并解码为字符串
          String requestBody = await request.bodyBytes.bytesToString();
          logMessage += 'Body: $requestBody\n';
        } catch (e) {
          logMessage += 'Failed to decode body: $e\n';
        }
      }
    }

    // 结束分隔符
    logMessage += '---------------------\n';

    // 输出最终日志
    log.info(logMessage);
  }

  void responseLogger(Response response) async {
    // 打印响应信息
    String logMessage = '--- Response Info ---\n';
    logMessage += 'Status Code: ${response.statusCode}\n';
    logMessage += 'Headers: ${response.headers}\n';

    // 打印响应体（如果存在）
    if (response.body != null) {
      try {
        // 将响应体转换为字符串并打印
        String responseBody = response.body.toString();
        logMessage += 'Body: $responseBody\n';
      } catch (e) {
        logMessage += 'Failed to decode response body: $e\n';
      }
    }

    // 打印完整响应信息
    print(logMessage);
  }

  String getCookies(List<Cookie> cookies) {
    // 按路径长度降序排序 cookies
    cookies.sort((a, b) {
      if (a.path == null && b.path == null) {
        return 0;
      } else if (a.path == null) {
        return -1;
      } else if (b.path == null) {
        return 1;
      } else {
        return b.path!.length.compareTo(a.path!.length);
      }
    });

    // 返回拼接后的 cookies 字符串
    return cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }
}

enum SessionState {
  fetching,
  fetched,
  error,
  none,
}

abstract class BaseProvider extends GetConnect {
  GetHttpClient get httpClient => GetHttpClient();
  final _storageService = Get.find<StorageService>();
  final cookieJar = PersistCookieJar(
    persistSession: true,
    storage: FileStorage("${supportPath.path}/cookie/general"),
  );

  Future<void> clearCookieJar() => cookieJar.deleteAll();

  @override
  void onInit() {
    super.onInit();
    httpClient.timeout = const Duration(seconds: 30);
    httpClient.defaultDecoder = (data) => data;
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['User-Agent'] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
          "AppleWebKit/537.36 (KHTML, like Gecko) "
          "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0";
      return request;
    });
  }

  Future<Response<T>> safeRequest<T>(
    Future<Response<T>> Function() request, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await request();
      if (response.status.isOk) {
        return response;
      } else {
        throw 'Request failed with status: ${response.status.code}';
      }
    } catch (e) {
      if (requiresAuth && e.toString().contains('401')) {
        throw NotAuthenticatedException();
      }
      rethrow;
    }
  }

  String? getCookie(String name) {
    final cookies = _storageService.getString(StorageConstants.cookie);
    if (cookies.isEmpty) return null;
    
    final cookieList = cookies.split(';').map((c) => c.trim()).toList();
    for (var cookie in cookieList) {
      if (cookie.startsWith('$name=')) {
        return cookie.substring(name.length + 1);
      }
    }
    return null;
  }

  Future<void> saveCookie(String cookies) async {
    await _storageService.setString(StorageConstants.cookie, cookies);
  }

  static Future<bool> isInSchool() async {
    try {
      final response = await GetConnect(timeout: const Duration(seconds: 5))
          .get("http://linux.xidian.edu.cn");
      return response.status.isOk;
    } catch (_) {
      return false;
    }
  }
}

class NotAuthenticatedException implements Exception {
  final String message;
  NotAuthenticatedException([this.message = '未登录或登录已过期']);

  @override
  String toString() => message;
}

class NotSchoolNetworkException implements Exception {
  final msg = "没有在校园网环境";

  @override
  String toString() => msg;
}
