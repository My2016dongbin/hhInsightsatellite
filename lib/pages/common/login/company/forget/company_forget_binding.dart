import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/company/forget/company_forget_controller.dart';

class CompanyForgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompanyForgetController());
  }
}
