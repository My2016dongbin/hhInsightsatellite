import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/login/personal/personal_login_binding.dart';
import 'package:insightsatellite/pages/common/login/personal/personal_login_view.dart';
import 'package:insightsatellite/pages/home/setting/setting_controller.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_binding.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class SettingPage extends StatelessWidget {
  final logic = Get.find<SettingController>();
  late double statusBarHeight = 0;
  SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: HhColors.whiteColor,
      body: Obx(
            () => Container(
          height: 1.sh,
          width: 1.sw,
          padding: EdgeInsets.zero,
          child: logic.testStatus.value ? settingView() : const SizedBox(),
        ),
      ),
    );
  }

  settingView() {
    return Column(
      children: [
        Container(
          color: HhColors.themeColor,
          height: statusBarHeight+5.w*3,
        ),
        Container(
          color: HhColors.themeColor,
          width: 1.sw,
          height: 45.w*3,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10.w*3),
                    padding: EdgeInsets.all(5.w*3),
                      child: Image.asset('assets/images/common/ic_back.png',width:20.w*3,height: 20.w*3,fit: BoxFit.fill,)
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(5.w*3),
                    child: Text('设置',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ///菜单列表
              Container(
                margin: EdgeInsets.only(bottom: 65.w*3),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ///语音播报
                      Container(
                        height:50.w*3,
                        margin: EdgeInsets.fromLTRB(20.w*3, 0, 20.w*3, 0),
                        child: Row(
                          children: [
                            Text('语音播报',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                            const Expanded(child: SizedBox()),
                            FlutterSwitch(
                              width: 120.w,
                              height: 66.w,
                              activeColor: HhColors.themeColor,
                              valueFontSize: 25.w,
                              toggleSize: 45.w,
                              value: logic.voiceStatus.value,
                              borderRadius: 36.w,
                              padding: 8.w,
                              onToggle: (val) {
                                logic.voiceStatus.value = val;
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: HhColors.line25Color,
                        height: 1.w,
                        width: 1.sw,
                        margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                      ),
                      ///报警设置
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.2,
                        onPressed: (){
                          showAdvancedDialog();
                        },
                        child: Container(
                          height:50.w*3,
                          color: HhColors.whiteColor,
                          margin: EdgeInsets.fromLTRB(20.w*3, 0, 20.w*3, 0),
                          child: Row(
                            children: [
                              Text('报警设置',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: HhColors.line25Color,
                        height: 1.w,
                        width: 1.sw,
                        margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                      ),
                      ///报警上报
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.2,
                        onPressed: (){
                          Get.to(()=>UploadPage(),binding: UploadBinding());
                        },
                        child: Container(
                          height:50.w*3,
                          color: HhColors.whiteColor,
                          margin: EdgeInsets.fromLTRB(20.w*3, 0, 20.w*3, 0),
                          child: Row(
                            children: [
                              Text('报警上报',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: HhColors.line25Color,
                        height: 1.w,
                        width: 1.sw,
                        margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                      ),
                    ],
                  ),
                ),
              ),
              ///退出登录
              Align(
                alignment: Alignment.bottomCenter,
                child: BouncingWidget(
                  duration: const Duration(milliseconds: 100),
                  scaleFactor: 0.6,
                  onPressed: () {
                    CommonUtils().showCommonDialog(logic.context, '退出后将不能接收信息，确定要退出？', (){
                      Get.back();
                    }, () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? id = prefs.getString(SPKeys().id);
                      String? token = prefs.getString(SPKeys().token);
                      XgFlutterPlugin().deleteAccount(id!, AccountType.UNKNOWN);
                      XgFlutterPlugin().deleteAccount(token!, AccountType.UNKNOWN);
                      XgFlutterPlugin().deleteTags([id,"test"]);
                      prefs.remove(SPKeys().token);
                      CommonData.token = null;
                      Get.off(() => PersonalLoginPage(), binding: PersonalLoginBinding());
                    });
                  },
                  child: Container(
                    height: 40.w*3,
                    width: 1.sw,
                    margin: EdgeInsets.all(15.w*3),
                    decoration: BoxDecoration(
                      color: HhColors.themeColor,
                      borderRadius: BorderRadius.circular(20.w*3)
                    ),
                    child: Center(child: Text('退出登录',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)),
                  ),
                ),
              )
            ],
          ),
        )

      ],
    );
  }

  void showAdvancedDialog() {
    showModalBottomSheet(context: logic.context, builder: (a){
      return Obx(() =>Container(
        width: 1.sw,
        height: 0.8.sh,
        padding: EdgeInsets.fromLTRB(15.w*3, 10.w*3, 15.w*3, 10.w*3),
        decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.w))
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 10.w*3,),
              ///卫星监测
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('卫星监测：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.satelliteStatus.value?Expanded(child: Wrap(children: buildSatelliteItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 10.w*3,),
              ///天空监测
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('天空监测：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.skyStatus.value?Expanded(child: Wrap(children: buildSkyItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 10.w*3,),
              ///地面监测
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('地面监测：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.landStatus.value?Expanded(child: Wrap(children: buildLandItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 15.w*3,),
              ///地貌类型
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('地貌类型：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.landTypeStatus.value?Expanded(child: Wrap(children: buildLandTypeItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 15.w*3,),
              ///火警数量
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('火警数量：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.fireCountStatus.value?Expanded(child: Wrap(children: buildFireCountItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 15.w*3,),
              ///其他选项
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('其他选项：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 10.w*3,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.6,
                        onPressed: (){
                          logic.otherOut.value = !logic.otherOut.value;
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5.w*3, 10.w*3),
                          padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
                          decoration: BoxDecoration(
                              color: logic.otherOut.value?HhColors.themeColor:HhColors.blueEAColor,
                              borderRadius: BorderRadius.circular(12.w*3)
                          ),
                          child: Text("查询境外热源",style: TextStyle(color: logic.otherOut.value?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
                        ),
                      ),
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.6,
                        onPressed: (){
                          logic.otherCache.value = !logic.otherCache.value;
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5.w*3, 5.w*3),
                          padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
                          decoration: BoxDecoration(
                              color: logic.otherCache.value?HhColors.themeColor:HhColors.blueEAColor,
                              borderRadius: BorderRadius.circular(12.w*3)
                          ),
                          child: Text("包含缓冲区",style: TextStyle(color: logic.otherCache.value?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
                        ),
                      ),
                      Text("（含权限外10公里范围数据，会延长查询时间）",style: TextStyle(color: HhColors.gray9TextColor,fontSize: 8.sp*3),)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30.w*3,),
              ///按钮
              Row(
                children: [
                  const Expanded(child: SizedBox()),
                  BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      Get.back();
                      EventBusUtil.getInstance().fire(HhToast(title: '已重置',type: 0));
                    },
                    child: Container(
                      width: 100.w*3,
                      height: 36.w*3,
                      color: HhColors.red,
                      child: Center(child: Text('重置',style: TextStyle(color: HhColors.whiteColor,fontSize: 13.sp*3),)),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      Get.back();
                      EventBusUtil.getInstance().fire(HhToast(title: '已保存',type: 0));
                    },
                    child: Container(
                      width: 100.w*3,
                      height: 36.w*3,
                      color: HhColors.themeColor,
                      child: Center(child: Text('确定',style: TextStyle(color: HhColors.whiteColor,fontSize: 13.sp*3),)),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              )
            ],
          ),
        ),
      ));
    },isDismissible: true,enableDrag: true,isScrollControlled: true);
  }



  buildSatelliteItems() {
    List<Widget> widgets = [];
    for(int i = 0; i < logic.satelliteList.length; i++){
      dynamic model = logic.satelliteList[i];
      widgets.add(
          BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: (){
              model["choose"] = !model["choose"];
              logic.parseSatelliteChoose(i);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(5.w*3, 0, 5.w*3, 10.w*3),
              padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
              decoration: BoxDecoration(
                  color: model["choose"]?HhColors.themeColor:HhColors.blueEAColor,
                  borderRadius: BorderRadius.circular(12.w*3)
              ),
              child: Text("${model['title']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
            ),
          )
      );
    }
    return widgets;
  }
  buildSkyItems() {
    List<Widget> widgets = [];
    for(int i = 0; i < logic.skyList.length; i++){
      dynamic model = logic.skyList[i];
      widgets.add(
          BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: (){
              model["choose"] = !model["choose"];
              logic.parseSkyChoose(i);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(5.w*3, 0, 5.w*3, 10.w*3),
              padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
              decoration: BoxDecoration(
                  color: model["choose"]?HhColors.themeColor:HhColors.blueEAColor,
                  borderRadius: BorderRadius.circular(12.w*3)
              ),
              child: Text("${model['title']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
            ),
          )
      );
    }
    return widgets;
  }
  buildLandItems() {
    List<Widget> widgets = [];
    for(int i = 0; i < logic.landList.length; i++){
      dynamic model = logic.landList[i];
      widgets.add(
          BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: (){
              model["choose"] = !model["choose"];
              logic.parseLandChoose(i);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(5.w*3, 0, 5.w*3, 10.w*3),
              padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
              decoration: BoxDecoration(
                  color: model["choose"]?HhColors.themeColor:HhColors.blueEAColor,
                  borderRadius: BorderRadius.circular(12.w*3)
              ),
              child: Text("${model['title']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
            ),
          )
      );
    }
    return widgets;
  }
  buildLandTypeItems() {
    List<Widget> widgets = [];
    for(int i = 0; i < logic.landTypeList.length; i++){
      dynamic model = logic.landTypeList[i];
      widgets.add(
          BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: (){
              model["choose"] = !model["choose"];
              logic.parseLandTypeChoose(i);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(5.w*3, 0, 5.w*3, 10.w*3),
              padding: EdgeInsets.fromLTRB(8.w*3, 3.w*3, 8.w*3, 3.w*3),
              decoration: BoxDecoration(
                  color: model["choose"]?HhColors.themeColor:HhColors.blueEAColor,
                  borderRadius: BorderRadius.circular(12.w*3)
              ),
              child: Text("${model['title']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
            ),
          )
      );
    }
    return widgets;
  }
  buildFireCountItems() {
    List<Widget> widgets = [];
    for(int i = 0; i < logic.fireCountList.length; i++){
      dynamic model = logic.fireCountList[i];
      widgets.add(
          BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: (){
              model["choose"] = !model["choose"];
              logic.parseFireCountChoose(i);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(5.w*3, 0, 5.w*3, 10.w*3),
              padding: EdgeInsets.fromLTRB(18.w*3, 3.w*3, 18.w*3, 2.w*3),
              decoration: BoxDecoration(
                  color: model["choose"]?HhColors.themeColor:HhColors.blueEAColor,
                  borderRadius: BorderRadius.circular(12.w*3)
              ),
              child: Text("${model['title']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
            ),
          )
      );
    }
    return widgets;
  }

}
