import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/share/share_controller.dart';

class ShareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShareController());
  }
}
