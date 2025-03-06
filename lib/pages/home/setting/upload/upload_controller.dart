import 'package:dio/dio.dart' as dios;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  late List<dynamic> provinceList = [
    {
      "name":"山东省",
    },
    {
      "name":"吉林省",
    },
    {
      "name":"山西省",
    },
    {
      "name":"河南省",
    },
    {
      "name":"河北省",
    },
    {
      "name":"辽宁省",
    },
  ];
  late List<dynamic> cityList = [
    {
      "name":"青岛",
    },
    {
      "name":"济南",
    },
    {
      "name":"烟台",
    },
    {
      "name":"潍坊",
    },
    {
      "name":"淄博",
    },
    {
      "name":"济宁",
    },
  ];
  late List<dynamic> areaList = [
    {
      "name":"高新区",
    },
    {
      "name":"城阳区",
    },
    {
      "name":"市南区",
    },
    {
      "name":"市北区",
    },
    {
      "name":"崂山区",
    },
    {
      "name":"李沧区",
    },
  ];
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
