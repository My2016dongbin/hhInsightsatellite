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

class RegisterController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> tenantStatus = false.obs;
  final Rx<bool> accountStatus = false.obs;
  final Rx<bool> codeStatus = false.obs;
  final Rx<bool> phoneStatus = false.obs;
  final Rx<bool> passwordStatus = false.obs;
  final Rx<bool> passwordShowStatus = false.obs;
  final Rx<bool> confirmStatus = false.obs;
  TextEditingController? tenantController = TextEditingController();
  TextEditingController? accountController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();
  TextEditingController? codeController = TextEditingController();
  late String? account;
  late String? password;
  late String? tenantId;
  final Rx<int> time = 0.obs;

  @override
  Future<void> onInit() async {
    tenantController!.text = 'haohai';
    super.onInit();
  }

  Future<void> sendCode() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true,title: '正在发送短信..'));
    var result = await HhHttp().request(
      RequestUtils.codeRegisterSend,
      method: DioMethod.post,
      data: {'mobile':phoneController!.text,'scene':22},
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
  Future<void> register() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true,title: '正在注册..'));
    dynamic data = {
      'username':accountController!.text,
      'password':passwordController!.text,
      'mobile':phoneController!.text,
      'code':codeController!.text,
      'captchaVerification':'',
      'accountType':'person',
    };
    var result = await HhHttp().request(
      RequestUtils.codeRegister,
      method: DioMethod.post,
      data: data,
    );
    HhLog.d("register -- $data");
    HhLog.d("register -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result["code"] == 0 && result["data"] != null) {
      EventBusUtil.getInstance().fire(HhToast(title: '注册成功',type: 1));
      Get.back();
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(result["msg"])));
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
}
