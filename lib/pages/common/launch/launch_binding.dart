import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/launch/launch_controller.dart';

class LaunchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LaunchController());
    // Get.lazyPut(() => MainController());
  }
}
