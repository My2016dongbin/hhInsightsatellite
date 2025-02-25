import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/location/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocationController());
  }
}
