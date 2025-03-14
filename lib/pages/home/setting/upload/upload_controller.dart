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
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  final Rx<String> province = ''.obs;
  final Rx<String> city = ''.obs;
  final Rx<String> area = ''.obs;
  final Rx<String> time = ''.obs;
  final Rx<String> landType = ''.obs;
  late BuildContext context;
  late TextEditingController addressController = TextEditingController();
  late TextEditingController latitudeController = TextEditingController();
  late TextEditingController longitudeController = TextEditingController();
  late TextEditingController timeController = TextEditingController();
  late TextEditingController landTypeController = TextEditingController();
  late TextEditingController areaController = TextEditingController();
  late XFile picture;
  late XFile video;
  late String pictureUrl;
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
  late List<XFile> pictureList = [];
  late int pictureMaxValue = 3;
  final Rx<bool> pictureStatus = true.obs;
  late List<dynamic> landTypeList = [];
  final Rx<int> landTypeIndex = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    versionSubscription =
        EventBusUtil.getInstance().on<LocationSearch>().listen((event) {
          addressController.text = event.address;
          latitudeController.text = "${event.latitude}";
          longitudeController.text = "${event.longitude}";
        });

    getProvince("010");
    getLandType();
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
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
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
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
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
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      areaList = result["data"];
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  void uploadImage(String filePath) async {
    var dio = dios.Dio();
    dios.FormData formData = dios.FormData.fromMap({
      "file": await dios.MultipartFile.fromFile(filePath,
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
      HhLog.d("上传成功: ${response.data}");
      pictureUrl = response.data["data"]["url"];
      uploadVideo(video.path);
    } catch (e) {
      HhLog.d("上传失败: $e");
    }
  }
  void uploadVideo(String filePath) async {
    var dio = dios.Dio();
    dios.FormData formData = dios.FormData.fromMap({
      "file": await dios.MultipartFile.fromFile(filePath,
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
      HhLog.d("上传成功: ${response.data}");
      videoUrl = response.data["data"]["url"];
    } catch (e) {
      HhLog.d("上传失败: $e");
    }
  }




}
