import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/code/code_controller.dart';
import 'package:insightsatellite/pages/common/login/company/company_login_controller.dart';
import 'package:insightsatellite/pages/home/main/main_controller.dart';
import 'package:insightsatellite/pages/home/message/message_controller.dart';
import 'package:insightsatellite/pages/home/my/my_controller.dart';

class CompanyLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompanyLoginController());
    Get.lazyPut(() => MainController());
  }
}
