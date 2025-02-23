import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/home_controller.dart';
import 'package:insightsatellite/pages/home/message/message_controller.dart';

import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => MessageController());
  }
}
