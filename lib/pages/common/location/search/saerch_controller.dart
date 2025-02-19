import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';

class SearchLocationController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<int> index = 0.obs;
  final Rx<bool> searchStatus = false.obs;
  final Rx<double> longitude = 0.0.obs;
  final Rx<double> latitude = 0.0.obs;
  final Rx<String> locText = ''.obs;
  final Rx<String> locCity = ''.obs;
  late int searchIndex = 0;
  late bool choose = false;
  BMFMapController ?controller;
  late List<BMFPoiInfo> searchList = [];
  TextEditingController ?searchController = TextEditingController();

  @override
  Future<void> onInit() async {
    latitude.value = CommonData.latitude!;
    longitude.value = CommonData.longitude!;
    locSearch(0);
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
          icon: 'assets/images/common/ic_device_online.png');

      /// 添加Marker
      controller?.addMarker(marker);
      locSearch(1);
    });
    controller?.setMapOnClickedMapPoiCallback(callback: (BMFMapPoi mapPoi) {
      controller?.cleanAllMarkers();

      latitude.value = mapPoi.pt!.latitude;
      longitude.value = mapPoi.pt!.longitude;

      userMarker();

      /// 创建BMFMarker
      BMFMarker marker = BMFMarker(
          position: BMFCoordinate(mapPoi.pt!.latitude,mapPoi.pt!.longitude),
          enabled: false,
          visible: true,
          identifier: "location",
          icon: 'assets/images/common/ic_device_online.png');

      /// 添加Marker
      controller?.addMarker(marker);
      locSearch(1);
    });
  }

  Future<void> userEdit() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true, title: '正在保存..'));
    var tenantResult = await HhHttp().request(
      RequestUtils.userEdit,
      method: DioMethod.put,
      data: {}
    );
    HhLog.d("userEdit -- $tenantResult");
    if (tenantResult["code"] == 0 && tenantResult["data"] != null) {

    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(tenantResult["msg"])));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }

  void userMarker() {
    /// 创建BMFMarker
    BMFMarker point = BMFMarker(
        position: BMFCoordinate(CommonData.latitude!,CommonData.longitude!),
        enabled: false,
        visible: true,
        identifier: "location",
        icon: 'assets/images/common/icon_point.png');

    /// 添加Marker
    controller?.addMarker(point);
  }


  Future<void> locSearch(int status) async {
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
      HhLog.d("逆地理编码search  errorCode = $errorCode, result = ${result.toMap()}");

      locCity.value = result.addressDetail!.city!;
      if(status!=0){
        try{
          String s = "";
          List<BMFPoiInfo> ?p = result.poiList;
          if(p!=null && p.isNotEmpty){
            s = CommonUtils().parseNull("${p[0].name}", "定位中..");
          }else{
            s = CommonUtils().parseNull("${result.address}", "定位中..");
          }
          choose = true;
          EventBusUtil.getInstance().fire(LocText(text: s));
        }catch(e){
          //
        }

        List<BMFPoiInfo> ?poiList = result.poiList;
        searchList = poiList??[];
        locText.value = '';
        locText.value = '已搜索';
        try{
          locText.value = searchList[index.value].name!;
          latitude.value = searchList[index.value].pt!.latitude;
          longitude.value = searchList[index.value].pt!.longitude;
        }catch(e){
          //
        }
        /*if(poiList!=null && poiList.isNotEmpty){
          locText.value = CommonUtils().parseNull("${poiList[0].name}", "定位中..");
        }else{
          locText.value = CommonUtils().parseNull("${result.address}", "定位中..");
        }*/

        /*controller?.setCenterCoordinate(
          BMFCoordinate(latitude.value,longitude.value), false,
        );
        controller?.setZoomTo(17);*/
      }
    });
    /// 发起检索
    bool flag = await reverseGeoCodeSearch.reverseGeoCodeSearch(reverseGeoCodeSearchOption);
  }


  Future<void> nameSearch() async {
    HhLog.d("地理编码 ${searchController!.text},${locCity.value}");
    // 构造检索参数
    BMFGeoCodeSearchOption geoCodeSearchOption =
    BMFGeoCodeSearchOption(address: searchController!.text, city: locCity.value);
    // 检索实例
    BMFGeocodeSearch geocodeSearch = BMFGeocodeSearch();
    // 正地理编码回调
    geocodeSearch.onGetGeoCodeSearchResult(callback:
        (BMFGeoCodeSearchResult result, BMFSearchErrorCode errorCode) {
          HhLog.d("地理编码  errorCode = $errorCode");
          HhLog.d("地理编码  errorCode = ${result.location}");
          longitude.value = result.location!.longitude;
          latitude.value = result.location!.latitude;
          locSearch(1);

    });
    // 发起检索
    bool flag = await geocodeSearch.geoCodeSearch(geoCodeSearchOption);
  }
}
