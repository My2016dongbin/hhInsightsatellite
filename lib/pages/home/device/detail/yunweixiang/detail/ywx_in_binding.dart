import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/device/detail/yunweixiang/detail/ywx_in_controller.dart';
import 'package:insightsatellite/pages/home/my/network/network_controller.dart';


class YWXInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => YWXInController());
  }
}
