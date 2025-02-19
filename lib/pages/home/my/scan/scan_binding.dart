import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/my/scan/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScanController());
  }
}
