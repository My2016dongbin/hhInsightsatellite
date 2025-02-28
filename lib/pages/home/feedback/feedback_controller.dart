import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhLog.dart';

class FeedBackController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> realState = true.obs;
  late TextEditingController addressController = TextEditingController();
  late TextEditingController descController = TextEditingController();
  late TextEditingController latitudeController = TextEditingController();
  late TextEditingController longitudeController = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();
  }

}
