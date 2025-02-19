import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/login/personal/forget/password/personal_password_binding.dart';
import 'package:insightsatellite/pages/common/login/personal/forget/password/personal_password_view.dart';
import 'package:insightsatellite/pages/home/home_binding.dart';
import 'package:insightsatellite/pages/home/home_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalCodeController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  late String code = '';
  late BuildContext context;
  late String mobile;
  final Rx<int> time = 60.obs;

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 1),(){
      // sendCode();
      time.value = 60;
      runCode();
    });
    super.onInit();
  }

  Future<void> sendCode() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true,title: '正在发送短信..'));
    var result = await HhHttp().request(
      RequestUtils.codeSend,
      method: DioMethod.post,
      data: {'mobile':mobile,'scene':24},
    );
    HhLog.d("sendCode -- $result");
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
  Future<void> codeCheck() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var result = await HhHttp().request(
      RequestUtils.codeCheckCommon,
      method: DioMethod.post,
      data: {'mobile':mobile,'code':code},
    );
    HhLog.d("codeCheck -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result["code"] == 0 && result["data"] != null) {

      Get.off(()=>PersonalPasswordPage(),binding: PersonalPasswordBinding(),arguments:{"mobile":mobile});
    } else {
      EventBusUtil.getInstance().fire(HhToast(title: '验证码错误'));
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
