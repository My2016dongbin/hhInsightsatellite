import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhLog.dart';

class LocationController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> pageStatus = false.obs;
  final Rx<double> longitude = 0.0.obs;
  final Rx<double> latitude = 0.0.obs;
  final Rx<String> locText = ''.obs;
  BMFMapController ?controller;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void onBMFMapCreated(BMFMapController controller_) {
    controller = controller_;
    userMarker();
    controller?.setCenterCoordinate(BMFCoordinate(CommonData.latitude!,CommonData.longitude!),false);
    controller?.setZoomTo(17);
    controller?.setMapOnClickedMapBlankCallback(callback: (BMFCoordinate coordinate) {
      controller?.cleanAllMarkers();

      latitude.value = coordinate.latitude;
      longitude.value = coordinate.longitude;

      userMarker();

      /// 创建BMFMarker
      BMFMarker marker = BMFMarker(
          position: BMFCoordinate(coordinate.latitude,coordinate.longitude),
          enabled: false,
          visible: true,
          identifier: "location",
          icon: 'assets/images/common/icon_point.png');

      /// 添加Marker
      controller?.addMarker(marker);
      locSearch();
    });
  }

  void userMarker() {
    /// 创建BMFMarker
    BMFMarker point = BMFMarker(
        position: BMFCoordinate(CommonData.latitude!,CommonData.longitude!),
        enabled: false,
        visible: true,
        identifier: "location",
        icon: 'assets/images/common/icon_blue_loc.png');

    /// 添加Marker
    controller?.addMarker(point);
  }


  Future<void> locSearch() async {
    // 构造检索参数
    BMFReverseGeoCodeSearchOption reverseGeoCodeSearchOption =
    BMFReverseGeoCodeSearchOption(
        location: BMFCoordinate(latitude.value!, longitude.value!));
    // 检索实例
    BMFReverseGeoCodeSearch reverseGeoCodeSearch = BMFReverseGeoCodeSearch();
    // 逆地理编码回调
    reverseGeoCodeSearch.onGetReverseGeoCodeSearchResult(callback:
        (BMFReverseGeoCodeSearchResult result,
        BMFSearchErrorCode errorCode) {
      HhLog.d("逆地理编码  errorCode = $errorCode, result = ${result.toMap()}");
      List<BMFPoiInfo> ?poiList = result.poiList;
      if(poiList!=null && poiList.isNotEmpty){
        locText.value = CommonUtils().parseNull("${poiList[0].name}", "定位中..");
      }else{
        locText.value = CommonUtils().parseNull("${result.address}", "定位中..");
      }
    });
    /// 发起检索
    bool flag = await reverseGeoCodeSearch.reverseGeoCodeSearch(reverseGeoCodeSearchOption);
  }
}
