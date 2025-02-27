import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/login/code/code_binding.dart';
import 'package:insightsatellite/pages/common/login/code/code_view.dart';
import 'package:insightsatellite/pages/home/home_binding.dart';
import 'package:insightsatellite/pages/home/home_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class PersonalLoginController extends GetxController {
  late BuildContext context;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> pageStatus = false.obs;
  final Rx<bool> tenantStatus = false.obs;
  final Rx<bool> accountStatus = false.obs;
  final Rx<bool> passwordStatus = false.obs;
  final Rx<bool> passwordShowStatus = false.obs;
  final Rx<bool> confirmStatus = false.obs;
  TextEditingController? accountController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  late StreamSubscription showToastSubscription;
  late StreamSubscription showLoadingSubscription;
  late String? account;
  late String? password;

  @override
  Future<void> onInit() async {

    showToastSubscription =
        EventBusUtil.getInstance().on<HhToast>().listen((event) {
          if(event.title.isEmpty || event.title == "null"){
            return;
          }

          showToastWidget(
            Container(
              margin: EdgeInsets.fromLTRB(20.w*3, 15.w*3, 20.w*3, 25.w*3),
              padding: EdgeInsets.fromLTRB(30.w*3, event.type==0?13.h*3:25.h*3, 30.w*3, 13.h*3),
              decoration: BoxDecoration(
                  color: HhColors.blackColor.withAlpha(200),
                  borderRadius: BorderRadius.all(Radius.circular(8.w*3))),
              constraints: BoxConstraints(
                  minWidth: 117.w*3
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // event.type==0?const SizedBox():SizedBox(height: 16.w*3,),
                  event.type==0?const SizedBox():Image.asset(
                    event.type==1?'assets/images/common/icon_success.png':event.type==2?'assets/images/common/icon_error.png':event.type==3?'assets/images/common/icon_lock.png':'assets/images/common/icon_warn.png',
                    height: 20.w*3,
                    width: 20.w*3,
                    fit: BoxFit.fill,
                  ),
                  event.type==0?const SizedBox():SizedBox(height: 16.h*3,),
                  // SizedBox(height: 16.h*3,),
                  Text(
                    event.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: HhColors.whiteColor,
                        fontSize: 14.sp*3),
                  ),
                  // SizedBox(height: 10.h*3,)
                  // event.type==0?SizedBox(height: 10.h*3,):SizedBox(height: 10.h*3,),
                ],
              ),
            ),
            context: context,
            animation: StyledToastAnimation.slideFromBottomFade,
            reverseAnimation: StyledToastAnimation.fade,
            position: StyledToastPosition.center,
            animDuration: const Duration(seconds: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.elasticOut,
            reverseCurve: Curves.linear,
          );
    });
    showLoadingSubscription =
        EventBusUtil.getInstance().on<HhLoading>().listen((event) {
          if (event.show) {
            context.loaderOverlay.show();
          } else {
            context.loaderOverlay.hide();
          }
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(SPKeys().token);
    account = prefs.getString(SPKeys().account);
    password = prefs.getString(SPKeys().password);
    if (account != null && password != null) {
      accountController?.text = account!;
      passwordController?.text = password!;
    }

    super.onInit();
  }

  Future<void> login() async {
    Map<String, dynamic> map = {};
    map['username'] = accountController?.text;
    map['password'] = passwordController?.text;
    var result = await HhHttp().request(
      RequestUtils.login,
      method: DioMethod.get,
      params: map
    );
    HhLog.d("login -- $result");
    if (result["type"] == 1 && result["message"] != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SPKeys().token, result["message"]);
      await prefs.setString(SPKeys().account, accountController!.text);
      await prefs.setString(SPKeys().password, passwordController!.text);
      CommonData.token = result["message"];

      info();

    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString(result["message"]),type: 2));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
    }
  }

  Future<void> info() async {
    String? xgToken = await XgFlutterPlugin.xgToken;
    Map<String, dynamic> map = {};
    map['Token'] = CommonData.token;
    map['xgToken'] = xgToken;
    var result = await HhHttp().request(
      RequestUtils.userInfo,
      method: DioMethod.get,
      params: map,
    );
    HhLog.d("info -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if (result != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SPKeys().id, '${result["UserId"]}');
      await prefs.setString(SPKeys().username, '${result["UserName"]}');
      await prefs.setString(SPKeys().companyName, '${result["CompanyName"]}');
      await prefs.setString(SPKeys().provinceNo, '${result["ProvinceNo"]}');
      await prefs.setString(SPKeys().provinceName, '${result["ProvinceName"]}');
      await prefs.setString(SPKeys().cityNo, '${result["CityNo"]}');
      await prefs.setString(SPKeys().cityName, '${result["CityName"]}');
      await prefs.setString(SPKeys().countyNo, '${result["CountyNo"]}');
      await prefs.setString(SPKeys().countyName, '${result["CountyName"]}');
      await prefs.setString(SPKeys().endTime, '${result["EndTime"]}');


      XgFlutterPlugin().deleteAccount('${result["id"]}',AccountType.UNKNOWN);
      XgFlutterPlugin().deleteAccount("${CommonData.token}", AccountType.UNKNOWN);
      XgFlutterPlugin().deleteTags(["${CommonData.token}","test"]);
      EventBusUtil.getInstance().fire(HhToast(title: '登录成功',type: 1));

      Future.delayed(const Duration(seconds: 1), () {
        XgFlutterPlugin().setAccount("${CommonData.token}",AccountType.UNKNOWN);
        XgFlutterPlugin().setTags(["${CommonData.token}"]);
        Get.offAll(() => HomePage(), binding: HomeBinding(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 1000));
      });
    } else {
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString('用户信息获取失败')));
    }
  }
}
