import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/login/company/forget/code/company_code_controller.dart';

class CompanyCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompanyCodeController());
  }
}
