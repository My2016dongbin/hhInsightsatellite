import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/device/detail/call/call_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CallController());
  }
}
