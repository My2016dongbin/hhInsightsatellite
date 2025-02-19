import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/space/manage/edit/edit_controller.dart';

class EditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditController());
  }
}
