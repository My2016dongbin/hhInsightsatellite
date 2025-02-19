import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/location/search/saerch_controller.dart';
import 'package:insightsatellite/pages/home/device/add/device_add_controller.dart';

class DeviceAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeviceAddController());
    Get.lazyPut(() => SearchLocationController());
  }
}
