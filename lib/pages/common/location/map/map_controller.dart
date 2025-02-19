import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/home_binding.dart';
import 'package:insightsatellite/pages/home/home_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> pageStatus = false.obs;
  final Rx<bool> mapStatus = true.obs;
  final Rx<double> longitude = 0.0.obs;
  final Rx<double> latitude = 0.0.obs;
  // BMFMapController ?controller;

  @override
  Future<void> onInit() async {
    // runToast();
    super.onInit();
  }

  void onBMFMapCreated(BMFMapController controller_) {
    // controller = controller_;
  }

  @override
  void dispose() {
    // controller!
    mapStatus.value = false;
    super.dispose();
  }

  @override
  void onClose() {
    // 在这里释放资源
    print("DetailController 被释放");
    super.onClose();
  }

  void runToast() {
    EventBusUtil.getInstance().fire(HhToast(title: 'map'));
    Future.delayed(const Duration(milliseconds: 2000),(){
      runToast();
    });
  }
}
