import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/personal/forget/code/personal_code_controller.dart';

class PersonalCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalCodeController());
  }
}
