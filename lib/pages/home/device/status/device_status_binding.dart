import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/device/add/device_add_controller.dart';
import 'package:insightsatellite/pages/home/device/status/device_status_controller.dart';

class DeviceStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeviceStatusController());
    Get.lazyPut(() => DeviceAddController());
  }
}
