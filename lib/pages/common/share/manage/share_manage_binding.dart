import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/share/manage/share_manage_controller.dart';

class ShareManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShareManageController());
  }
}
