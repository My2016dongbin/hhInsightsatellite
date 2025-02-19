import 'package:flutter/cupertino.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/home_binding.dart';
import 'package:insightsatellite/pages/home/home_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> pageStatus = false.obs;
  final Rx<bool> tenantStatus = false.obs;
  final Rx<bool> accountStatus = false.obs;
  final Rx<bool> passwordStatus = false.obs;
  final Rx<bool> passwordShowStatus = false.obs;
  final Rx<bool> confirmStatus = false.obs;
  final Rx<bool> codeStatus = false.obs;
  final Rx<bool> phoneStatus = false.obs;
  final Rx<int> time = 0.obs;
  final Rx<String> titles = ''.obs;
  TextEditingController? tenantController = TextEditingController();
  TextEditingController? accountController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();
  TextEditingController? codeController = TextEditingController();
  late StreamSubscription showToastSubscription;
  late StreamSubscription showLoadingSubscription;
  final Rx<String> version = ''.obs;
  final Rx<String> appName = ''.obs;
  late String? account;
  late String? password;
  late String? tenantName;
  late String? keys;
  late String? values;

  @override
  Future<void> onInit() async {
    getVersion();
    super.onInit();
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    appName.value = packageInfo.appName;
    HhLog.d('getVersion ${appName.value},${version.value}');
  }
}
