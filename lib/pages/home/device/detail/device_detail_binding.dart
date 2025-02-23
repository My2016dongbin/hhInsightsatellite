import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/device/detail/device_detail_controller.dart';
import 'package:insightsatellite/pages/home/device/status/device_status_controller.dart';

class DeviceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeviceDetailController());
  }
}
