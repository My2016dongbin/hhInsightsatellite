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

class UploadController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  final Rx<String> province = '请选择省'.obs;
  final Rx<String> city = '请选择市'.obs;
  final Rx<String> area = '请选择区'.obs;
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
