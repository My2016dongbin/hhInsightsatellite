import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_controller.dart';
class UploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UploadController());
  }
}
