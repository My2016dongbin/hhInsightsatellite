import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/model/model_class.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/ParseLocation.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  final Rx<String> province = ''.obs;
  final Rx<String> city = ''.obs;
  final Rx<String> area = ''.obs;
  late String areaStr = "";
  late String areaCode = "";
  final Rx<String> time = ''.obs;
  final Rx<String> landType = ''.obs;
  late BuildContext context;
  late TextEditingController addressController = TextEditingController();
  late TextEditingController latitudeController = TextEditingController();
  late TextEditingController longitudeController = TextEditingController();
  late TextEditingController areaController = TextEditingController();
  late XFile picture;
  late XFile video;
  late String imageUrl;
  late String videoUrl;
  late int maxVideoTimes = 10000;
  StreamSubscription? versionSubscription;
  late List<dynamic> provinceList = [];
  late List<dynamic> cityList = [];
  late List<dynamic> areaList = [];
  late FixedExtentScrollController scrollControllerP;
  final Rx<int> provinceIndex = 0.obs;
  late FixedExtentScrollController scrollControllerC;
  final Rx<int> cityIndex = 0.obs;
  late FixedExtentScrollController scrollControllerA;
  final Rx<int> areaIndex = 0.obs;
  late FixedExtentScrollController scrollControllerT;
  late List<dynamic> pictureList = [];
  late int pictureMaxValue = 3;
  final Rx<bool> pictureStatus = true.obs;
  late List<dynamic> landTypeList = [];
  final Rx<int> landTypeIndex = 0.obs;
  late List<String> pictureUrlList = [];
  late int picturePostIndex = 0;
  late String thumbnailPath = "";

  @override
  Future<void> onInit() async {
    super.onInit();
    versionSubscription =
        EventBusUtil.getInstance().on<LocResult>().listen((event) {
          addressController.text = event.detail;
          List<double> parse = ParseLocation.gcj02_To_Gps84(event.lat,event.lng);
          latitudeController.text = CommonUtils().latLngCount("${parse[0]}");
          longitudeController.text = CommonUtils().latLngCount("${parse[1]}");
          ///省市区
          for(int i = 0; i < provinceList.length; i++){
            dynamic model = provinceList[i];
            if(model["name"] == event.province){
              provinceIndex.value = i;
              province.value = event.province;
              copyProCity(model["areaCode"],event.city,event.district);
              return;
            }
          }

        });

    getProvince(CommonData.china);
    getLandType();
  }

  Future<void> copyProCity(String provinceCode,String cityStr,String districtStr) async {
    Map<String, dynamic> map = {};
    map['parentCode'] = provinceCode;
    var result = await HhHttp().request(RequestUtils.gridSearchAll,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      cityList = result["data"];

      for(int i = 0; i < cityList.length; i++){
        dynamic model = cityList[i];
        if(model["name"] == cityStr){
          cityIndex.value = i;
          city.value = cityStr;
          copyProArea(model["areaCode"],districtStr);
          return;
        }
      }
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  Future<void> copyProArea(String cityCode,String districtStr) async {
    Map<String, dynamic> map = {};
    map['parentCode'] = cityCode;
    var result = await HhHttp().request(RequestUtils.gridSearchAll,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      areaList = result["data"];

      for(int i = 0; i < areaList.length; i++){
        dynamic model = areaList[i];
        if(model["name"] == districtStr){
          areaIndex.value = i;
          area.value = districtStr;
          return;
        }
      }
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  Future<void> getLandType() async {
    ///2。获取地类列表
    Map<String, dynamic> map2 = {};
    var result2 = await HhHttp().request(RequestUtils.landType,method: DioMethod.get,params:map2);
    HhLog.d("landType -- ${RequestUtils.landType} -- $map2 ");
    HhLog.d("landType -- $result2");
    if(result2["code"]==200){
      List<dynamic> list = result2["data"];
      for(dynamic model in list){
        model["choose"] = true;
      }
      landTypeList = list;

      ///3。获取用户权限映射
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String tenantId = prefs.getString(SPKeys().tenantId)??"000000";
      String userId = prefs.getString(SPKeys().id)??"1";
      dynamic dataS = {
        "tenantId":tenantId,
        "userId":userId
      };
      HhLog.d("typePermission -- ${RequestUtils.typePermission} -- $dataS ");
      var resultS = await HhHttp().request(RequestUtils.typePermission,method: DioMethod.post,data: dataS);
      HhLog.d("typePermission -- $resultS");
      if(resultS["code"]==200 && resultS["data"] != null){
        String landType = resultS["data"]["landType"];
        List<String> landTypeCodeList = landType.split(',');
        List<dynamic> rows = [];
        for(int i = 0;i < landTypeList.length;i++){
          dynamic model = landTypeList[i];
          if(landTypeCodeList.contains("${model["code"]}")){
            model["choose"] = true;
            rows.add(model);
          }
        }
        landTypeList = rows;

      }else{
        EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultS["msg"])));
      }
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result2["msg"])));
    }
  }

  void getProvince(String code) async {
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    var result = await HhHttp().request(RequestUtils.gridSearchAll,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- ${RequestUtils.gridSearchAll}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      provinceList = result["data"];
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getCity(String code) async {
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    var result = await HhHttp().request(RequestUtils.gridSearchAll,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      cityList = result["data"];
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getArea(String code) async {
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    var result = await HhHttp().request(RequestUtils.gridSearchAll,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      areaList = result["data"];
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  void uploadImage() async {
    var dio = dios.Dio();
    dios.FormData formData = dios.FormData.fromMap({
      "file": await dios.MultipartFile.fromFile(pictureList[picturePostIndex]["file"].path,
          filename: "fire.png"),
    });

    try {
      var response = await dio.post(
        RequestUtils.fileUpload,
        data: formData,
        options: dios.Options(
          headers: HhHttp().getHeaders(),
        ),
      );
      if(response.data.toString().contains("401")){
        CommonUtils().tokenDown();
      }
      pictureUrlList.add(response.data["data"]["url"]);
      if(picturePostIndex < pictureList.length-1){
        picturePostIndex++;
        if(pictureList[picturePostIndex]["file"].path.contains("png")||pictureList[picturePostIndex]["file"].path.contains("jpg")){
          uploadImage();
        }else{
          uploadVideo();
        }
      }else{
        upload();
      }

    } catch (e) {
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }
  void uploadVideo() async {
    var dio = dios.Dio();
    dios.FormData formData = dios.FormData.fromMap({
      "file": await dios.MultipartFile.fromFile(pictureList[picturePostIndex]["file"].path,
          filename: "fire.mp4"),
    });

    try {
      var response = await dio.post(
        RequestUtils.fileUpload,
        data: formData,
        options: dios.Options(
          headers: HhHttp().getHeaders(),
        ),
      );
      if(response.data.toString().contains("401")){
        CommonUtils().tokenDown();
      }
      pictureUrlList.add(response.data["data"]["url"]);
      if(picturePostIndex < pictureList.length-1){
        picturePostIndex++;
        if(pictureList[picturePostIndex]["file"].path.contains("png")||pictureList[picturePostIndex]["file"].path.contains("jpg")){
          uploadImage();
        }else{
          uploadVideo();
        }
      }else{
        upload();
      }

    } catch (e) {
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }


  Future<void> upload() async {
    imageUrl = "";
    videoUrl = "";
    for(String url in pictureUrlList){
      if(url.contains("png")||url.contains("jpg")){
        ///图片
        if(imageUrl.isEmpty){
          imageUrl = url;
        }else{
          imageUrl = "$imageUrl,$url";
        }
      }else{
        ///视频
        if(videoUrl.isEmpty){
          videoUrl = url;
        }else{
          videoUrl = "$videoUrl,$url";
        }
      }
    }
    ///处理省市区
    if(area.value.isNotEmpty){
      areaStr = area.value;
      areaCode = areaList[areaIndex.value]["areaCode"];
    }else{
      if(city.value.isNotEmpty){
        areaStr = city.value;
        areaCode = cityList[cityIndex.value]["areaCode"];
      }else{
        if(province.value.isNotEmpty){
          areaStr = province.value;
          areaCode = provinceList[provinceIndex.value]["areaCode"];
        }
      }
    }
    dynamic data = {
      "address":addressController.text,
      "area":areaController.text,
      "areaCode":areaCode,
      "landType":landTypeList[landTypeIndex.value]["code"],
      "reportTime":time.value,
      "longitude":CommonUtils().latLngCount(longitudeController.text),
      "latitude":CommonUtils().latLngCount(latitudeController.text),
      "imageUrl":imageUrl,
      "videoUrl":videoUrl,
    };
    var result = await HhHttp().request(RequestUtils.fireReport,method: DioMethod.post,data:data);
    HhLog.d("fireReport -- ${RequestUtils.fireReport} $data");
    HhLog.d("fireReport -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if(result["code"]==200){
      EventBusUtil.getInstance().fire(HhToast(title: "上报成功",type: 0));
      Get.back();
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }




}
