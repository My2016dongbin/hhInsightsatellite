import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/my/setting/password/new/new_password_controller.dart';
import 'package:insightsatellite/pages/home/my/setting/password/password_controller.dart';

class NewPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewPasswordController());
  }
}
