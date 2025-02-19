import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/device/detail/daozha/daozha_detail_controller.dart';

class DaoZhaDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DaoZhaDetailController());
  }
}
