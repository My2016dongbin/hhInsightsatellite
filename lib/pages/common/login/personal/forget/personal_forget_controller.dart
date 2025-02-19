import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/login/personal/forget/code/personal_code_binding.dart';
import 'package:insightsatellite/pages/common/login/personal/forget/code/personal_code_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalForgetController extends GetxController {
  late BuildContext context;
  final Rx<bool> accountStatus = false.obs;
  final Rx<bool> confirmStatus = false.obs;
  final Rx<bool> testStatus = true.obs;
  TextEditingController? accountController = TextEditingController();
  late String? account;

  @override
  Future<void> onInit() async {

    super.onInit();
  }

  Future<void> getTenantId() async {
    Map<String, dynamic> map = {};
    map['name'] = CommonData.tenantName;
    var tenantResult = await HhHttp().request(
      RequestUtils.tenantId,
      method: DioMethod.get,
      params: map,
    );
    HhLog.d("tenant -- $tenantResult");
    if (tenantResult["code"] == 0 && tenantResult["data"] != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SPKeys().tenant, '${tenantResult["data"]['id']}');
      await prefs.setString(SPKeys().tenantName, CommonData.tenantName!);
      CommonData.tenant = '${tenantResult["data"]['id']}';
      CommonData.tenantName = CommonData.tenantName;
      CommonData.tenantUserType = '${tenantResult["data"]['userType']}';
      await prefs.setString(SPKeys().tenantUserType, CommonData.tenantUserType!);
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString("租户信息不存在"/*tenantResult["msg"]*/),type: 2));
    }
  }

  Future<void> sendCode() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var result = await HhHttp().request(
      RequestUtils.codeSend,
      method: DioMethod.post,
      data: {'mobile':accountController!.text,'scene':24},
    );
    HhLog.d("sendCode -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result["code"] == 0 && result["data"] != null) {
      Get.to(()=>PersonalCodePage(accountController!.text),binding: PersonalCodeBinding());
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(result["msg"]),type: 2));
    }
  }
}
