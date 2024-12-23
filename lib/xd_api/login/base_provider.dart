import 'package:get/get.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../xd_api.dart';

// import 'dart:io';
//
// late Directory supportPath;

class LoginProvider extends GetConnect {
  // prefs.setString(StorageConstants.number, loginEmailController.text);
  // prefs.setString(StorageConstants.passwd, loginPasswordController.text);


  final PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    //storage: FileStorage("${supportPath.path}/cookie/general"),
  );

  Future<void> clearCookieJar() => cookieJar.deleteAll();

  @override
  void onInit() {
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
  }
}
