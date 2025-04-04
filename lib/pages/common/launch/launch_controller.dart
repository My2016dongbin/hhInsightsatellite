import 'dart:convert';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/home_binding.dart';
import 'package:insightsatellite/pages/home/home_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class LaunchController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> secondStatus = true.obs;
  late BuildContext? context;

  @override
  Future<void> onInit() async {
    permission();
    super.onInit();
  }

  Future<void> info2() async {
    String? xgToken = await XgFlutterPlugin.xgToken;
    Map<String, dynamic> map = {};
    map['Token'] = CommonData.token;
    map['xgToken'] = xgToken;
    EventBusUtil.getInstance().fire(HhLoading(show: true, title: '自动登录中..'));
    var result = await HhHttp().request(
      RequestUtils.userInfo,
      method: DioMethod.get,
      params: map,
    );
    HhLog.d("info -- $result");

    EventBusUtil.getInstance().fire(HhLoading(show: false));
    EventBusUtil.getInstance()
        .fire(HhToast(title: CommonUtils().msgString('用户信息获取失败')));
    CommonUtils().tokenDown();
    // if (result != null && result["code"] == 200) {
    //   final SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.setString(SPKeys().id, '${result["UserId"]}');
    //   await prefs.setString(SPKeys().username, '${result["UserName"]}');
    //   await prefs.setString(SPKeys().companyName, '${result["CompanyName"]}');
    //   await prefs.setString(SPKeys().provinceNo, '${result["ProvinceNo"]}');
    //   await prefs.setString(SPKeys().provinceName, '${result["ProvinceName"]}');
    //   await prefs.setString(SPKeys().cityNo, '${result["CityNo"]}');
    //   await prefs.setString(SPKeys().cityName, '${result["CityName"]}');
    //   await prefs.setString(SPKeys().countyNo, '${result["CountyNo"]}');
    //   await prefs.setString(SPKeys().countyName, '${result["CountyName"]}');
    //   await prefs.setString(SPKeys().endTime, '${result["EndTime"]}');
    //
    //   Future.delayed(const Duration(seconds: 2), () {
    //     Get.off(() => HomePage(), binding: HomeBinding(),
    //         transition: Transition.fadeIn,
    //         duration: const Duration(milliseconds: 1000));
    //   });
    // } else {
    //   EventBusUtil.getInstance()
    //       .fire(HhToast(title: CommonUtils().msgString('用户信息获取失败')));
    //   CommonUtils().tokenDown();
    // }
  }

  Future<void> info() async {
    Map<String, dynamic> map = {};
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var result = await HhHttp().request(
      RequestUtils.userInfo,
      method: DioMethod.get,
      params: map,
    );
    HhLog.d("userInfo -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    try{
      if (result != null && result["code"]==200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SPKeys().id, '${result["data"]["user"]["userId"]}');
        prefs.setString(SPKeys().tenantId, '${result["data"]["user"]["tenantId"]}');
        prefs.setString(SPKeys().username, '${result["data"]["user"]["userName"]}');
        prefs.setString(SPKeys().nickname, '${result["data"]["user"]["nickName"]}');
        prefs.setString(SPKeys().email, '${result["data"]["user"]["email"]}');
        prefs.setString(SPKeys().sex, '${result["data"]["user"]["sex"]}');
        prefs.setString(SPKeys().avatar, '${result["data"]["user"]["avatar"]}');
        prefs.setString(SPKeys().remark, '${result["data"]["user"]["remark"]}');
        prefs.setString(SPKeys().userType, '${result["data"]["user"]["userType"]}');
        prefs.setString(SPKeys().deptName, '${result["data"]["user"]["deptName"]}');
        prefs.setString(SPKeys().mobile, '${result["data"]["user"]["phonenumber"]}');
        prefs.setBool(SPKeys().voice, true);

        Future.delayed(const Duration(seconds: 1), () {
          Get.off(() => HomePage(), binding: HomeBinding(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 1000));
        });

      } else {
        EventBusUtil.getInstance()
            .fire(HhToast(title: CommonUtils().msgString('用户信息获取失败')));
        CommonUtils().tokenDown();
      }
    }catch(e){
      EventBusUtil.getInstance()
          .fire(HhToast(title: CommonUtils().msgString('用户信息获取失败')));
      CommonUtils().tokenDown();
    }
  }

  Future<void> next() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(SPKeys().token);
    String? tenant = prefs.getString(SPKeys().tenant);
    String? tenantUserType = prefs.getString(SPKeys().tenantUserType);
    String? tenantName = prefs.getString(SPKeys().tenantName);
    bool? second = prefs.getBool(SPKeys().second);
    secondStatus.value = second == true;
    if (token != null) {
      //获取个人信息
      CommonData.token = token;
      CommonData.tenant = tenant;
      CommonData.tenantUserType = tenantUserType;
      CommonData.tenantName = tenantName;
      info();
    } else {
      /*if(second == true){
        Future.delayed(const Duration(seconds: 2), () {
          CommonUtils().toLogin();
        });
      }else{
        ///首次进入

      }*/
      Future.delayed(const Duration(seconds: 2), () {
        CommonUtils().toLogin();
      });
    }
  }

  Future<void> permission() async {
    /*if (await Permission.contacts.request().isGranted) {

    }*/
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      /*Permission.microphone,*/
    ].request();
    if(statuses[Permission.location] != PermissionStatus.denied && statuses[Permission.storage] != PermissionStatus.denied && statuses[Permission.camera] != PermissionStatus.denied/*&& statuses[Permission.microphone] != PermissionStatus.denied*/){
      next();
    }else{

      showToastWidget(
        Container(
          margin: EdgeInsets.fromLTRB(20.w*3, 15.w*3, 20.w*3, 25.w*3),
          padding: EdgeInsets.fromLTRB(30.w*3, 25.h*3, 30.w*3, 18.h*3),
          decoration: BoxDecoration(
              color: HhColors.blackColor.withAlpha(200),
              borderRadius: BorderRadius.all(Radius.circular(8.w*3))),
          constraints: BoxConstraints(
              minWidth: 117.w*3
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/common/icon_warn.png',
                height: 20.w*3,
                width: 20.w*3,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 16.h*3,),
              // SizedBox(height: 16.h*3,),
              Text(
                '请授权',
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
      Future.delayed(const Duration(seconds: 1),(){
        SystemNavigator.pop();
      });
    }
  }
}
