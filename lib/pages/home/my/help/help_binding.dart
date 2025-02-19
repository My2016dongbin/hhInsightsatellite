import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/my/help/help_controller.dart';

class HelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HelpController());
  }
}
