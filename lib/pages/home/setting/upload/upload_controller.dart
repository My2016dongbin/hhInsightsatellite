import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhLog.dart';

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

  @override
  Future<void> onInit() async {
    super.onInit();
  }

}
