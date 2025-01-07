import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_yidianshi/shared/shared.dart';
import 'package:get/get.dart';
import 'xd_api/base_provider.dart' as repo_general;
import 'package:path_provider/path_provider.dart';

import 'app_binding.dart';
import 'di.dart';
import 'routes/routes.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DenpendencyInjection.init();

  repo_general.supportPath = await getApplicationSupportDirectory();

  runApp(App());
  configLoading();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialBinding: AppBinding(),
      initialRoute: Routes.SPLASH,
      defaultTransition: Transition.fade,
      getPages: AppPages.routes,
      smartManagement: SmartManagement.keepFactory,
      title: 'Flutter GetX Boilerplate',
      theme: ThemeConfig.lightTheme,
      // locale: TranslationService.locale,
      // fallbackLocale: TranslationService.fallbackLocale,
      // translations: TranslationService(),
      builder: EasyLoading.init(),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.custom
  // ..indicatorSize = 45.0
    ..radius = 10.0
  // ..progressColor = Colors.yellow
    ..backgroundColor = ColorConstants.lightGray
    ..indicatorColor = hexToColor('#64DEE0')
    ..textColor = hexToColor('#64DEE0')
  // ..maskColor = Colors.red
    ..userInteractions = false
    ..dismissOnTap = false;
  //..animationStyle = EasyLoadingAnimationStyle.scale;
}
