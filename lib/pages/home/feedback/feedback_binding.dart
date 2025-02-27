import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_controller.dart';

class FeedBackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedBackController());
  }
}
