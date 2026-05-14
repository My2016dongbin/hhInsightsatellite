import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/mqtt/mqtt_controller.dart';

class MqttBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MqttController());
  }
}
