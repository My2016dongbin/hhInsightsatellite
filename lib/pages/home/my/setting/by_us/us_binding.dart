import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/my/setting/by_us/us_controller.dart';

class UsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UsController());
  }
}
