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
import 'package:shared_preferences/shared_preferences.dart';

class PhoneController extends GetxController {
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
  late String? account;
  late String? password;
  late String? tenantName;
  late String? keys;
  late String? values;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> sendCode() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true,title: '正在发送短信..'));
    var result = await HhHttp().request(
      RequestUtils.codeSend,
      method: DioMethod.post,
      data: {'mobile':phoneController!.text,'scene':23},
    );
    HhLog.d("codeRegisterSend -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result["code"] == 0 && result["data"] != null) {
      time.value = 60;
      runCode();
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(result["msg"])));
      time.value = 0;
    }
  }

  void runCode() {
    Future.delayed(const Duration(seconds: 1),(){
      time.value--;
      if(time.value > 0){
        runCode();
      }else{

      }
    });
  }

  Future<void> codeCheck() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true, title: '正在保存..'));
    var tenantResult = await HhHttp().request(
      RequestUtils.codeCheckChangePhone,
      method: DioMethod.put,
      data:{
        "mobile":phoneController!.text,
        "code":codeController!.text,
      }
    );
    HhLog.d("codeCheck -- $tenantResult");
    if (tenantResult["code"] == 0 && tenantResult["data"] != null) {
      info();
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(tenantResult["msg"])));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }

  Future<void> userEdit() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true, title: '正在保存..'));
    var tenantResult = await HhHttp().request(
      RequestUtils.userEdit,
      method: DioMethod.put,
      data: {
        "mobile":values
      }
    );
    HhLog.d("userEdit -- $tenantResult");
    if (tenantResult["code"] == 0 && tenantResult["data"] != null) {
      info();
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(tenantResult["msg"])));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }


  Future<void> info() async {
    var result = await HhHttp().request(
      RequestUtils.userInfo,
      method: DioMethod.get,
      data: {},
    );
    HhLog.d("info -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result["code"] == 0 && result["data"] != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SPKeys().endpoint, '${result["data"]["endpoint"]}');
      await prefs.setString(SPKeys().id, '${result["data"]["id"]}');
      await prefs.setString(SPKeys().username, '${result["data"]["username"]}');
      await prefs.setString(SPKeys().nickname, '${result["data"]["nickname"]}');
      await prefs.setString(SPKeys().email, '${result["data"]["email"]}');
      await prefs.setString(SPKeys().mobile, '${result["data"]["mobile"]}');
      await prefs.setString(SPKeys().sex, '${result["data"]["sex"]}');
      await prefs.setString(SPKeys().avatar, '${result["data"]["avatar"]}');
      await prefs.setString(SPKeys().roles, '${result["data"]["roles"]}');
      await prefs.setString(
          SPKeys().socialUsers, '${result["data"]["socialUsers"]}');
      await prefs.setString(SPKeys().posts, '${result["data"]["posts"]}');

      EventBusUtil.getInstance().fire(UserInfo());

      EventBusUtil.getInstance().fire(HhToast(title: '修改成功',type: 1));
      Get.back();
    } else {
      // EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
}
