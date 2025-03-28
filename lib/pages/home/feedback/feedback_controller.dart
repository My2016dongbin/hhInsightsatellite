import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:dio/dio.dart' as dios;
import 'package:insightsatellite/utils/RequestUtils.dart';

class FeedBackController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> realState = true.obs;
  late TextEditingController addressController = TextEditingController();
  late TextEditingController descController = TextEditingController();
  late TextEditingController latitudeController = TextEditingController();
  late TextEditingController longitudeController = TextEditingController();
  late List<XFile> pictureList = [];
  late List<String> pictureUrlList = [];
  late int pictureMaxValue = 3;
  late int picturePostIndex = 0;
  final Rx<bool> pictureStatus = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    if(CommonData.fireInfo!=null){
      addressController.text = "${CommonData.fireInfo["formattedAddress"]}";
      latitudeController.text = "${CommonData.fireInfo["latitude"]}";
      longitudeController.text = "${CommonData.fireInfo["longitude"]}";
    }
  }

  void uploadImage() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var dio = dios.Dio();
    dios.FormData formData = dios.FormData.fromMap({
      "file": await dios.MultipartFile.fromFile(pictureList[picturePostIndex].path,
          filename: "fire$picturePostIndex.png"),
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
        uploadImage();
      }else{
        upload();
      }
    } catch (e) {
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }

  Future<void> upload() async {
    dynamic data = {
      "fireId":"${CommonData.fireInfo["id"]}",
      "detailedAddress":addressController.text,
      "fireDescription":descController.text,
      "longitude":longitudeController.text,
      "latitude":latitudeController.text,
      "isRealFire":realState.value,
    };
    if(pictureUrlList.isNotEmpty){
      data["image1"] = pictureUrlList[0];
    }
    if(pictureUrlList.length > 1){
      data["image2"] = pictureUrlList[1];
    }
    if(pictureUrlList.length > 2){
      data["image3"] = pictureUrlList[2];
    }
    var result = await HhHttp().request(RequestUtils.fireFeedback,method: DioMethod.post,data:data);
    HhLog.d("fireFeedback -- ${RequestUtils.fireFeedback} $data");
    HhLog.d("fireFeedback -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if(result["code"]==200){
      EventBusUtil.getInstance().fire(HhToast(title: "反馈成功",type: 0));
      Get.back();
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

}
