import 'package:get/get.dart';
import 'package:insightsatellite/pages/home/main/search/search_controller.dart';


class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchedController());
  }
}
