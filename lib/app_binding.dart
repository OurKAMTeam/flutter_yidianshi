//import 'package:flutter_getx_boilerplate/xd_api/xd_api.dart';
import 'package:get/get.dart';
import 'package:flutter_base/api/api.dart';

class AppBinding extends Bindings {
  @override
  void dependencies()   async {
    Get.put(ApiProvider(), permanent: true);
    Get.put(ApiRepository(apiProvider: Get.find<ApiProvider>()));
  }
}
