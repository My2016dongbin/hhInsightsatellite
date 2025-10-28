import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';

class LocationController extends GetxController {
  final index = 0.obs;
  final Rx<bool> testStatus = true.obs;
  final Rx<String> locTitle = '点击地图选择地址'.obs;
  final Rx<String> locDetail = '点击地图选择地址'.obs;
  final Rx<double> locLat = 0.0.obs;
  final Rx<double> locLng = 0.0.obs;
  late String province = '';
  late String city = '';
  late String district = '';
  late BuildContext context;
  late AMapController gdMapController;
  final RxSet<Marker> aMapMarkers = <Marker>{}.obs;

  @override
  Future<void> onInit() async {

    super.onInit();
  }

  /// 创建完成回调
  void onGDMapCreated(AMapController controller) {
    gdMapController = controller;

    if(CommonData.latitude!=0){
      gdMapController.moveCamera(CameraUpdate.newLatLngZoom(LatLng(CommonData.latitude!,CommonData.longitude!), 14));
    }
  }

  Future<void> postModel() async {
    Map<String, dynamic> map = {};
    var result = await HhHttp().request(RequestUtils.fireSearch,method: DioMethod.put,params: map,data: {
      "id":""
    });

    HhLog.d("postModel -- $result");
    if(result["code"]==0 && result["data"]!=null){

    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }


  Future<void> searchLocation(lng,lat) async {
    var result = await HhHttp().request(
        "https://restapi.amap.com/v3/geocode/regeo?key=a94a9e0e144b7a5cf77c229713275500&location=$lng,$lat&extensions=all&radius=1000",
        method: DioMethod.get);

    HhLog.d("searchLocation -- $result");
    locDetail.value = result["regeocode"]["formatted_address"];
    locTitle.value = "${result["regeocode"]["addressComponent"]["province"]??""}${result["regeocode"]["addressComponent"]["city"]??""}${result["regeocode"]["addressComponent"]["district"]??""}".replaceAll("[", "").replaceAll("]", "");
    locLat.value = lat;
    locLng.value = lng;
    province = "${result["regeocode"]["addressComponent"]["province"]??""}";
    city = "${result["regeocode"]["addressComponent"]["city"]??""}";
    district = "${result["regeocode"]["addressComponent"]["district"]??""}";
  }

  void updateMarker(latLng){
    aMapMarkers.clear();
    Marker mk = Marker(
        anchor: const Offset(0.5,0.5),
        position: latLng,
        icon: BitmapDescriptor.fromIconPath('assets/images/common/icon_blue_loc.png'),
        onTap: (v){
        }
    );
    aMapMarkers.add(mk);
  }

}
