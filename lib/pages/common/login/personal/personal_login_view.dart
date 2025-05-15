import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/login/personal/personal_login_controller.dart';
import 'package:insightsatellite/pages/common/web/WebViewPage.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class PersonalLoginPage extends StatelessWidget {
  final logic = Get.find<PersonalLoginController>();

  PersonalLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    CommonData.context = context;
    // 在这里设置状态栏字体为深色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarBrightness: Brightness.light, // 状态栏字体亮度
      statusBarIconBrightness: Brightness.light, // 状态栏图标亮度
    ));
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: HhColors.backColor,
        body: Obx(
              () => Container(
            height: 1.sh,
            width: 1.sw,
            padding: EdgeInsets.zero,
            child: logic.testStatus.value ? loginView() : const SizedBox(),
          ),
        ),
      ),
    );
  }

  loginView() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Image.asset('assets/images/common/ic_login_bj.png',width:1.sw,height: 1.sh,fit: BoxFit.fill,),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(50.w*3, 100.h*3, 50.w*3, 0),
                      child: Image.asset('assets/images/common/ic_loginlogo1.png',width:1.sw,height: 40.w*3,fit: BoxFit.fill,)
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(29.w*3, 59.h*3, 29.w*3, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///账号
                      logic.phoneMode.value?const SizedBox():ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.modulate),
                        child: Container(
                          height: 48.h*3,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              color: HhColors.mainGrayColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  maxLength: 20,
                                  cursorColor: HhColors.titleColor_99,
                                  controller: logic.accountController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.w*3, 0, 0, 0),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    counterText: '',
                                    hintText: '用户名',
                                    hintStyle: TextStyle(
                                        color: HhColors.grayCCTextColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                                  ),
                                  style:
                                  TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.bold),
                                  onChanged: (s){
                                    logic.accountStatus.value = s.isNotEmpty;
                                  },
                                ),
                              ),
                              logic.accountStatus.value? BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  logic.accountController!.clear();
                                  logic.accountStatus.value = false;
                                },
                                child: Container(
                                    padding: EdgeInsets.all(5.w*3),
                                    child: Image.asset('assets/images/common/ic_close_white.png',height:18.w*3,width: 18.w*3,fit: BoxFit.fill,)
                                ),
                              ):const SizedBox(),
                              SizedBox(width: 12.w*3,),
                            ],
                          ),
                        ),
                      ),
                      //手机号
                      logic.phoneMode.value?ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.modulate),
                        child: Container(
                          height: 48.h*3,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              color: HhColors.mainGrayColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  maxLength: 11,
                                  cursorColor: HhColors.titleColor_99,
                                  controller: logic.phoneController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.w*3, 0, 0, 0),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    counterText: '',
                                    hintText: '手机号',
                                    hintStyle: TextStyle(
                                        color: HhColors.grayCCTextColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                                  ),
                                  style:
                                  TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.bold),
                                  onChanged: (s){
                                    logic.phoneStatus.value = s.isNotEmpty;
                                  },
                                ),
                              ),
                              logic.phoneStatus.value? BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  logic.phoneController!.clear();
                                  logic.phoneStatus.value = false;
                                },
                                child: Container(
                                    padding: EdgeInsets.all(5.w*3),
                                    child: Image.asset('assets/images/common/ic_close_white.png',height:18.w*3,width: 18.w*3,fit: BoxFit.fill,)
                                ),
                              ):const SizedBox(),
                              SizedBox(width: 12.w*3,),
                            ],
                          ),
                        ),
                      ):const SizedBox(),
                      SizedBox(height: 19.h*3,),
                      ///密码
                      logic.phoneMode.value?const SizedBox():ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.modulate),
                        child: Container(
                          height: 48.h*3,
                          decoration: BoxDecoration(
                              color: HhColors.mainGrayColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  maxLength: 20,
                                  cursorColor: HhColors.titleColor_99,
                                  controller: logic.passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: !logic.passwordShowStatus.value,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.w*3, 0, 0, 0),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    counterText: '',
                                    hintText: '密码',
                                    hintStyle: TextStyle(
                                        color: HhColors.grayCCTextColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                                  ),
                                  style:
                                  TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.w300),
                                  onChanged: (s){
                                    logic.passwordStatus.value = s.isNotEmpty;
                                  },
                                ),
                              ),
                              logic.passwordStatus.value?
                              BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  logic.passwordController!.clear();
                                  logic.passwordStatus.value = false;
                                },
                                child: Container(
                                    padding: EdgeInsets.all(5.w*3),
                                    child: Image.asset('assets/images/common/ic_close_white.png',height:18.w*3,width: 18.w*3,fit: BoxFit.fill,)
                                ),
                              ):const SizedBox(),
                              SizedBox(width: 2.w*3,),
                              BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  logic.passwordShowStatus.value = !logic.passwordShowStatus.value;
                                },
                                child: Container(
                                    padding: EdgeInsets.all(5.w*3),
                                    child: Image.asset(logic.passwordShowStatus.value?'assets/images/common/icon_bi_white.png':'assets/images/common/icon_zheng_white.png',height:18.w*3,width: 18.w*3,fit: BoxFit.fill,)
                                ),
                              ),
                              SizedBox(width: 12.w*3,),
                            ],
                          ),
                        ),
                      ),
                      //验证码
                      logic.phoneMode.value?ColorFiltered(
                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.modulate),
                        child: Container(
                          height: 48.h*3,
                          decoration: BoxDecoration(
                              color: HhColors.mainGrayColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  maxLength: 6,
                                  cursorColor: HhColors.titleColor_99,
                                  controller: logic.codeController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(20.w*3, 0, 0, 0),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    counterText: '',
                                    hintText: '验证码',
                                    hintStyle: TextStyle(
                                        color: HhColors.grayCCTextColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                                  ),
                                  style:
                                  TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.w300),
                                  onChanged: (s){
                                    logic.codeStatus.value = s.isNotEmpty;
                                  },
                                ),
                              ),
                              logic.codeStatus.value?
                              BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  logic.codeController!.clear();
                                  logic.codeStatus.value = false;
                                },
                                child: Container(
                                    padding: EdgeInsets.all(10.w*3),
                                    child: Image.asset('assets/images/common/ic_close_white.png',height:18.w*3,width: 18.w*3,fit: BoxFit.fill,)
                                ),
                              ):const SizedBox(),
                              ///发送验证码
                              BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1.2,
                                onPressed: (){
                                  if(logic.time.value>0){
                                    return;
                                  }
                                  if(logic.phoneController!.text.length < 11){
                                    EventBusUtil.getInstance().fire(HhToast(title: "请输入正确的手机号"));
                                    return;
                                  }
                                  logic.sendCode();
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 5.w*3, 0),
                                    padding: EdgeInsets.fromLTRB(10.w*3, 5.w*3, 20.w*3, 5.w*3),
                                    color: HhColors.trans,
                                    child: Text(
                                        logic.codeStr.value,
                                      style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),
                                    ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ):const SizedBox(),
                      SizedBox(height: 17.h*3,),
                      ///登录
                      logic.phoneMode.value?const SizedBox():BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 1.2,
                        onPressed: (){
                          //隐藏输入法
                          FocusScope.of(Get.context!).requestFocus(FocusNode());

                          ///登录点击
                          if(logic.accountController!.text.isEmpty){
                            EventBusUtil.getInstance().fire(HhToast(title: '账号不能为空'));
                            return;
                          }
                          if(logic.passwordController!.text.isEmpty){
                            EventBusUtil.getInstance().fire(HhToast(title: '密码不能为空'));
                            return;
                          }
                          if (!logic.confirmStatus.value) {
                            showAgreeDialog();
                            return;
                          }
                          logic.login();
                        },
                        child: Container(
                          width: 1.sw,
                          height: 48.h*3,
                          margin: EdgeInsets.fromLTRB(0, 18.h*3, 0, 12.h*3),
                          decoration: BoxDecoration(
                              color: HhColors.mainBlueColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Center(
                            child: Text(
                              "登录",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                            ),
                          ),
                        ),
                      ),
                      //验证码登录
                      logic.phoneMode.value?BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 1.2,
                        onPressed: (){
                          //隐藏输入法
                          FocusScope.of(Get.context!).requestFocus(FocusNode());

                          ///登录点击
                          if(logic.phoneController!.text.isEmpty){
                            EventBusUtil.getInstance().fire(HhToast(title: '手机号不能为空'));
                            return;
                          }
                          if(logic.codeController!.text.isEmpty){
                            EventBusUtil.getInstance().fire(HhToast(title: '验证码不能为空'));
                            return;
                          }
                          if (!logic.confirmStatus.value) {
                            showAgreeDialog();
                            return;
                          }
                          logic.loginCode();
                        },
                        child: Container(
                          width: 1.sw,
                          height: 48.h*3,
                          margin: EdgeInsets.fromLTRB(0, 18.h*3, 0, 12.h*3),
                          decoration: BoxDecoration(
                              color: HhColors.mainBlueColorTrans,
                              borderRadius: BorderRadius.all(Radius.circular(24.w*3))),
                          child: Center(
                            child: Text(
                              "登录",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: HhColors.whiteColor, fontSize: 15.sp*3,fontWeight: FontWeight.w200),
                            ),
                          ),
                        ),
                      ):const SizedBox(),
                      SizedBox(height: 30.w,),
                      InkWell(
                        onTap: (){
                          logic.phoneMode.value = !logic.phoneMode.value;
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.w*3),
                            child: Text(logic.phoneMode.value?"密码登录":"手机号登录",
                              style: TextStyle(color: HhColors.grayCCTextColor,
                                  fontSize: 13.sp*3),)
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  int timeForExit = 0;
  //复写返回监听
  Future<bool> onBackPressed() {
    bool exit = false;
    int time_ = DateTime.now().millisecondsSinceEpoch;
    if (time_ - timeForExit > 2000) {
      EventBusUtil.getInstance().fire(HhToast(title: '再按一次退出程序'));
      timeForExit = time_;
      exit = false;
    } else {
      exit = true;
    }
    return Future.value(exit);
  }

  void showWebDialog() {
    showCupertinoDialog(context: Get.context!, builder: (context) => Center(
      child: Container(
        width: 1.sw,
        height: 360.w,
        margin: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
        padding: EdgeInsets.fromLTRB(30.w, 25.w, 30.w, 25.w),
        decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(20.w))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(CommonData.info,
                style: TextStyle(color: HhColors.textColor,fontSize: 21.sp),
              ),
            ],
          ),
        ),
      ),
    ));
  }


  void showAgreeDialog() {
    showCupertinoDialog(
        context: Get.context!,
        builder: (context) => Center(
          child: Container(
            width: 315.w*3,
            height: 162.h*3,
            decoration: BoxDecoration(
                color: HhColors.whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(8.w*3))),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 30.h*3, 0, 0),
                        child: Text(
                          '欢迎使用慧眼卫星',
                          style: TextStyle(
                              color: HhColors.textBlackColor,
                              fontSize: 16.sp*3,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold),
                        ))),
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        margin: EdgeInsets.fromLTRB(40.w, 69.h*3, 40.w, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '请您阅读并同意',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: HhColors.grayAATextColor,
                                  fontSize: 13.sp*3,
                              fontWeight: FontWeight.w500),
                            ),
                            BouncingWidget(
                              duration: const Duration(milliseconds: 100),
                              scaleFactor: 1.2,
                              onPressed: () {
                                Get.to(WebViewPage(title: '隐私协议', url: 'http://117.132.5.139:18034/admin-file/insightsatellite-test/public/2024/9/24/haohai_insightsatellite_privacy_agreement.html',));
                              },
                              child: Text(
                                '《慧眼卫星平台隐私政策》',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: HhColors.mainBlueColor,
                                    fontSize: 13.sp*3,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ))),
                Align(
                  alignment: Alignment.topRight,
                  child: BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 1.2,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 15.h*3, 23.w*3, 0),
                        padding: EdgeInsets.all(5.w),
                        child: Image.asset(
                          'assets/images/common/ic_x.png',
                          height: 15.w*3,
                          width: 15.w*3,
                          fit: BoxFit.fill,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 1.2,
                    onPressed: () {
                      logic.confirmStatus.value = true;
                      Navigator.pop(context);
                      //继续
                      logic.login();
                    },
                    child: Container(
                      width: 275.w*3,
                      height: 44.h*3,
                      margin: EdgeInsets.only(bottom:13.h*3),
                      decoration: BoxDecoration(
                          color: HhColors.backBlueOutColor,
                          borderRadius:
                          BorderRadius.all(Radius.circular(8.w*3))),
                      child: Center(
                        child: Text(
                          "同意并继续",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: HhColors.whiteColor,
                              fontSize: 16.sp*3,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),barrierDismissible: true);
  }

}
