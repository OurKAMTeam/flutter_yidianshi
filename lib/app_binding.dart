import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_yidianshi/shared/services/storage_service.dart';
import 'package:flutter_yidianshi/xd_api/xd_api.dart';
import 'package:flutter_yidianshi/widget/info_widget/controllers/electricity_controller.dart';
import 'package:flutter_yidianshi/widget/info_widget/controllers/classtable_controller.dart';
import 'package:flutter_yidianshi/xd_api/network_api/electricity_api.dart';
import 'package:flutter_yidianshi/repository/electricity/electricity_repository.dart';
import 'package:flutter_yidianshi/repository/personal/personal_repository.dart';

class AppBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // Storage Service
    Get.put(StorageService(), permanent: true);

    // API Providers
    Get.put(ApiProviderIds(), permanent: true);
    Get.put(ApiProviderEhall(), permanent: true);
    Get.put(ApiProviderPersonalyjs(), permanent: true);
    Get.put(ApiProviderPersonalxgxt(), permanent: true);

    // APIs
    Get.put(ElectricityApi());

    // Repositories
    Get.put(ElectricityRepository());
    Get.put(PersonalRepository(
      apiProviderPersonalxgxt: Get.find(),
      apiProviderPersonalyjs: Get.find(),
      prefs: Get.find(),
    ));

    // Info Widget Controllers
    //Get.lazyPut(() => SchoolCardController(), fenix: true);
    //Get.lazyPut(() => LibraryController(), fenix: true);
    Get.lazyPut(() => ElectricityController(), fenix: true);
    Get.lazyPut(() => ClassTableController(), fenix: true);

    // Tools Controllers
    //Get.lazyPut(() => SchoolnetController(), fenix: true);
    //Get.lazyPut(() => ScoreController(), fenix: true);
  }
}
