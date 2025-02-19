import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/regist/regist_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController());
  }
}
