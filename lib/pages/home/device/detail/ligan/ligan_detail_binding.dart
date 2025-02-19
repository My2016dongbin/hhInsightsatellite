import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/location/location_controller.dart';
import 'package:insightsatellite/pages/common/socket/socket_page/socket_controller.dart';
import 'package:insightsatellite/pages/home/device/detail/ligan/ligan_detail_controller.dart';
import 'package:insightsatellite/pages/home/my/setting/edit_user/edit_controller.dart';

class LiGanDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiGanDetailController());
  }
}
