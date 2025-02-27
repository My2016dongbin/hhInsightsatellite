import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/setting/setting_controller.dart';
class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingController());
  }
}
