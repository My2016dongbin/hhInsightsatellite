import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/code/code_controller.dart';

class CodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CodeController());
  }
}
