//import 'package:flutter_getx_boilerplate/xd_api/xd_api.dart';
import 'package:get/get.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';

class AppBinding extends Bindings {
  @override
  void dependencies()   async {
    Get.put(ApiProvider(), permanent: true);
    Get.put(ApiProviderEhall(), permanent: true);
    Get.put(ApiProviderPersonalyjs(), permanent: true);
    Get.put(ApiProviderPersonalxgxt(), permanent: true);

    Get.put(XdApiRepository(apiProvider: Get.find<ApiProvider>(),
        apiProviderEhall: Get.find<ApiProviderEhall>(),
        apiProviderPersonalyjs: Get.find<ApiProviderPersonalyjs>(),
        apiProviderPersonalxgxt: Get.find<ApiProviderPersonalxgxt>(),
    ), permanent: true);
  }
}
