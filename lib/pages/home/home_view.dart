import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/home_controller.dart';
import 'package:insightsatellite/pages/home/setting/setting_binding.dart';
import 'package:insightsatellite/pages/home/setting/setting_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhBehavior.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhLog.dart';
class HomePage extends StatelessWidget {
  final logic = Get.find<HomeController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    CommonData.context = context;
    // 在这里设置状态栏字体为深色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarBrightness: Brightness.dark, // 状态栏字体亮度
      statusBarIconBrightness: Brightness.dark, // 状态栏图标亮度
    ));

    return Obx(() => WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: HhColors.backColor,
        body: logic.viewStatus.value?Builder(builder: (BuildContext context) {
          return home(context);
        },):const SizedBox(),
        endDrawer: mapDrawer(),
        endDrawerEnableOpenDragGesture: false,
        drawerEdgeDragWidth: 0.7.sw,
      ),
    ));
  }

  int timeForExit = 0;
  //复写返回监听
  Future<bool> onBackPressed() {
    bool exit = false;
    int time_ = DateTime.now().millisecondsSinceEpoch;
    if(logic.index.value == 0){
      if (time_ - timeForExit > 2000) {
        EventBusUtil.getInstance().fire(HhToast(title: '再按一次退出程序',type: 0));
        timeForExit = time_;
        exit = false;
      } else {
        exit = true;
      }
    }else{
      logic.index.value = 0;
    }
    return Future.value(exit);
  }

  home(context) {
    double statusBarHeight = MediaQuery.of(Get.context!).padding.top;
    return Stack(
      children: [
        Container(
          color: HhColors.mainBlueColorTrans,
          height: statusBarHeight,
          width: 1.sw,
        ),
        Container(
          margin: EdgeInsets.only(top: statusBarHeight),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),//禁用滑动
            child: SizedBox(
              height: 1.2.sh,//遮盖水印
              width: 1.sw,
              child: BMFMapWidget(
                onBMFMapCreated: (controller) {
                  logic.onBMFMapCreated(controller);
                },
                mapOptions: logic.mapOptions(),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 100.h*3, 20.w*3, 0),
            child: Column(
              children: [
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      Get.to(() => SettingPage(),
                          binding: SettingBinding());
                    },
                    child: Image.asset('assets/images/common/ic_set.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      logic.fireListDialog();
                    },
                    child: Image.asset('assets/images/common/ic_list.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      fireSearchDialog();
                    },
                    child: Image.asset('assets/images/common/ic_search.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Image.asset('assets/images/common/ic_tuceng.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      logic.postType();
                      logic.getVersion();
                    },
                    child: Image.asset('assets/images/common/ic_refresh.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
              ],
            ),
          ),
        ),

        ///地图加载
        logic.loading.value?Container(
          height: 1.sh,
          width: 1.sw,
          color: HhColors.blackRealColor,
          margin: EdgeInsets.only(top: statusBarHeight),
          child: Center(child: Image.asset("assets/images/common/loading.gif")),
        ):const SizedBox(),
      ],
    );
  }

  mapDrawer(){
    return Container(
      color: HhColors.whiteColor,
      width: 0.7.sw,
      height: 1.sh,
      margin: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///图层切换
          Container(
            margin: EdgeInsets.fromLTRB(10.w*3, 20.w*3, 0, 0),
            child: Text("图层切换",style: TextStyle(color: HhColors.titleColor_33,fontSize: 14.sp*3),),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.pop(Get.context!);
                    logic.mapTypeTag.value = 3;
                    logic.myMapController.updateMapOptions(logic.mapOptions());
                    logic.mapLoading();
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10.w*3, 16.w*3, 5.w*3, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(logic.mapTypeTag.value==3?"assets/images/common/ic_tdt_sl_select.png":"assets/images/common/ic_tdt_sl.png",height: 0.16.sw,fit: BoxFit.fill,),
                        SizedBox(height: 16.w*3,),
                        Text("天地图矢量",style: TextStyle(color: logic.mapTypeTag.value==3?HhColors.themeColor:HhColors.titleColor_33,fontSize: 12.sp*3),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.pop(Get.context!);
                    logic.mapTypeTag.value = 4;
                    logic.myMapController.updateMapOptions(logic.mapOptions());
                    logic.mapLoading();
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.w*3, 16.w*3, 10.w*3, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(logic.mapTypeTag.value==4?"assets/images/common/ic_tdt_yx_select.png":"assets/images/common/ic_tdt_yx.png",height: 0.16.sw,fit: BoxFit.fill,),
                        SizedBox(height: 16.w*3,),
                        Text("天地图影像",style: TextStyle(color: logic.mapTypeTag.value==4?HhColors.themeColor:HhColors.titleColor_33,fontSize: 12.sp*3),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ///二维三维切换
          Container(
            margin: EdgeInsets.fromLTRB(10.w*3, 20.w*3, 0, 0),
            child: Text("二维三维切换",style: TextStyle(color: HhColors.titleColor_33,fontSize: 14.sp*3),),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.pop(Get.context!);
                    logic.mapChangeTag.value = 2;
                    logic.mapLoading();
                    Future.delayed(const Duration(milliseconds: 2300),(){
                      logic.myMapController.updateMapOptions(logic.mapOptions());
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10.w*3, 16.w*3, 5.w*3, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(logic.mapChangeTag.value==2?"assets/images/common/ic_2d_select.png":"assets/images/common/ic_2d.png",height: 0.16.sw,fit: BoxFit.fill,),
                        SizedBox(height: 16.w*3,),
                        Text("二维地图",style: TextStyle(color: logic.mapChangeTag.value==2?HhColors.themeColor:HhColors.titleColor_33,fontSize: 12.sp*3),)
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.pop(Get.context!);
                    logic.mapChangeTag.value = 3;
                    logic.mapLoading();
                    Future.delayed(const Duration(milliseconds: 2300),(){
                      logic.myMapController.updateMapOptions(logic.mapOptions());
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.w*3, 16.w*3, 10.w*3, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(logic.mapChangeTag.value==3?"assets/images/common/ic_3d_select.png":"assets/images/common/ic_3d.png",height: 0.16.sw,fit: BoxFit.fill,),
                        SizedBox(height: 16.w*3,),
                        Text("三维地图",style: TextStyle(color: logic.mapChangeTag.value==3?HhColors.themeColor:HhColors.titleColor_33,fontSize: 12.sp*3),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  void fireSearchDialog() {
    showModalBottomSheet(context: Get.context!, builder: (a){
      return Container(
        width: 1.sw,
        height: 0.55.sh,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.w*3))
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 5.w*3,),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('当前时间',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('1小时内',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('3小时内',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('1天内',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('3天内',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch);
                  logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                  logic.pageNum = 1;
                  logic.postFire(true);
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('5天内',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              Container(width: 1.sw,height: 2.w,color: HhColors.line25Color,margin: EdgeInsets.fromLTRB(10.w*3, 0, 10.w*3, 0),),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.6,
                onPressed: (){
                  Get.back();
                  showAdvancedFilterDialog();
                },
                child: Container(
                  width: 1.sw,
                  height: 60.w*3,
                  color: HhColors.whiteColor,
                  child: Center(child: Text('高级',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                ),
              ),
              SizedBox(height: 5.w*3,),
            ],
          ),
        ),
      );
    },isDismissible: true,enableDrag: false,isScrollControlled: true);
  }

  void showAdvancedFilterDialog() {
    showModalBottomSheet(context: Get.context!, builder: (a){
      return Obx(() =>Container(
        width: 1.sw,
        height: 0.7.sh,
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
              /*Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('天空监测：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.skyStatus.value?Expanded(child: Wrap(children: buildSkyItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 10.w*3,),*/
              ///地面监测
              /*Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('地面监测：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 5.w*3,),
                  logic.landStatus.value?Expanded(child: Wrap(children: buildLandItems(),)):const SizedBox()
                ],
              ),
              SizedBox(height: 10.w*3,),*/
              ///时间段
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('时间段：    ',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 10.w*3,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.w*3,),
                      InkWell(
                        onTap: (){
                          DatePicker.showDatePicker(Get.context!,
                              showTitleActions: true,
                              minTime: DateTime.now().subtract(const Duration(days: 1000)),
                              maxTime:DateTime.now().add(const Duration(days: 1000)),
                              onConfirm: (date) {
                                DatePicker.showTimePicker(Get.context!,
                                    showTitleActions: true, onConfirm: (date) {
                                      logic.startTime.value = CommonUtils().parseLongTime("${date.millisecondsSinceEpoch}");
                                    }, currentTime: date, locale: LocaleType.zh);
                              }, currentTime: DateTime.now(), locale: LocaleType.zh);
                        },
                        child: Container(
                          color: HhColors.trans,
                          child: Row(
                            children: [
                              Icon(Icons.access_time,color: HhColors.titleColor_88,size: 16.w*3,),
                              SizedBox(width: 2.w*3,),
                              Text(logic.startTime.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3,height: 1.2),)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.w*3,),
                      InkWell(
                      onTap: (){
                        DatePicker.showDatePicker(Get.context!,
                            showTitleActions: true,
                            minTime: DateTime.now().subtract(const Duration(days: 1000)),
                            maxTime:DateTime.now().add(const Duration(days: 1000)),
                            onConfirm: (date) {
                              DatePicker.showTimePicker(Get.context!,
                                  showTitleActions: true, onConfirm: (date) {
                                    logic.endTime.value = CommonUtils().parseLongTime("${date.millisecondsSinceEpoch}");
                                  }, currentTime: date, locale: LocaleType.zh);
                            }, currentTime: DateTime.now(), locale: LocaleType.zh);
                      },
                        child: Container(
                          color: HhColors.trans,
                          child: Row(
                            children: [
                              Icon(Icons.access_time,color: HhColors.titleColor_88,size: 16.w*3,),
                              SizedBox(width: 2.w*3,),
                              Text(logic.endTime.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3,height: 1.2),)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
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
              SizedBox(height: 10.w*3,),
              ///区域查询
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('区域查询：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 10.w*3,),
                  BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      chooseProvince();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 3.w*3),
                      child: Row(
                        children: [
                          Text(logic.province.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3,height: 1.2),),
                          SizedBox(width: 2.w*3,),
                          Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w*3,),
                  BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      chooseCity();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 3.w*3),
                      child: Row(
                        children: [
                          Text(logic.city.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3,height: 1.2),),
                          SizedBox(width: 2.w*3,),
                          Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w*3,),
                  BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      chooseArea();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 3.w*3),
                      child: Row(
                        children: [
                          Text(logic.area.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3,height: 1.2),),
                          SizedBox(width: 2.w*3,),
                          Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ((!logic.otherOutShow.value) && (!logic.otherCacheShow.value))?const SizedBox():SizedBox(height: 15.w*3,),
              ///其他选项
              ((!logic.otherOutShow.value) && (!logic.otherCacheShow.value))?const SizedBox():Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('其他选项：',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                  SizedBox(width: 10.w*3,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      logic.otherOutShow.value?BouncingWidget(
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
                      ):const SizedBox(),
                      logic.otherCacheShow.value?BouncingWidget(
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
                      ):const SizedBox(),
                      logic.otherCacheShow.value?Text("（含权限外10公里范围数据，会延长查询时间）",style: TextStyle(color: HhColors.gray9TextColor,fontSize: 8.sp*3),):const SizedBox()
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
                      for(dynamic model in logic.satelliteList){
                        model["choose"] = true;
                      }
                      for(dynamic model in logic.landTypeList){
                        model["choose"] = true;
                      }
                      logic.startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch);
                      logic.endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
                      logic.province.value = "请选择省";
                      logic.provinceCode = "";
                      logic.provinceIndex.value = 0;
                      logic.city.value = "请选择市";
                      logic.cityCode = "";
                      logic.cityIndex.value = 0;
                      logic.otherOut.value = true;
                      logic.otherCache.value = true;
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
                      logic.pageNum = 1;
                      logic.postFire(true);
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
            child: Text("${model['name']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
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
            child: Text("${model['name']}",style: TextStyle(color: model["choose"]?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
          ),
        )
      );
    }
    return widgets;
  }


  void chooseProvince() {
    if(logic.provinceList.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: '网格数据加载中,请稍后重试',type: 0));
      return;
    }
    showModalBottomSheet(context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w*3),
          topRight: Radius.circular(12.w*3),
        ),
      ), builder: (BuildContext context) {
        logic.scrollControllerP = FixedExtentScrollController(initialItem: logic.provinceIndex.value);
        int index = logic.provinceIndex.value;
        return Container(
          decoration: BoxDecoration(
              color: HhColors.whiteColor,
              borderRadius: BorderRadius.circular(16.w*3)
          ),
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 10.w*3),
                      child: Text("请选择省",style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20.w*3),
                  child: ScrollConfiguration(
                    behavior: HhBehavior(),
                    child: CupertinoPicker(
                      scrollController: logic.scrollControllerP,
                      itemExtent: 45,
                      children: getProvince(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                        logic.getCity(logic.provinceList[index]["areaCode"]);
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15.w*3,10.w*3,0,15.w*3),child: Icon(Icons.clear,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10.w*3,15.w*3,15.w*3),child: Icon(Icons.check,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      logic.provinceIndex.value = index;
                      logic.province.value = logic.provinceList[logic.provinceIndex.value]["name"];
                      logic.provinceCode = logic.provinceList[logic.provinceIndex.value]["areaCode"];
                      ///更新市数据
                      logic.cityIndex.value = 0;
                      logic.city.value = "请选择市";
                      logic.cityCode = "";
                      ///更新区数据
                      logic.areaIndex.value = 0;
                      logic.area.value = "请选择区";
                      logic.areaCode = "";
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }

  void chooseCity() {
    if(logic.cityList.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: '网格数据加载中,请稍后重试',type: 0));
      return;
    }
    showModalBottomSheet(context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w*3),
          topRight: Radius.circular(12.w*3),
        ),
      ), builder: (BuildContext context) {
        logic.scrollControllerC = FixedExtentScrollController(initialItem: logic.cityIndex.value);
        int index = logic.cityIndex.value;
        return Container(
          decoration: BoxDecoration(
              color: HhColors.whiteColor,
              borderRadius: BorderRadius.circular(16.w*3)
          ),
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 10.w*3),
                      child: Text("请选择市",style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20.w*3),
                  child: ScrollConfiguration(
                    behavior: HhBehavior(),
                    child: CupertinoPicker(
                      scrollController: logic.scrollControllerC,
                      itemExtent: 45,
                      children: getCity(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                        logic.getArea(logic.cityList[index]["areaCode"]);
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15.w*3,10.w*3,0,15.w*3),child: Icon(Icons.clear,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10.w*3,15.w*3,15.w*3),child: Icon(Icons.check,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      logic.cityIndex.value = index;
                      logic.city.value = logic.cityList[logic.cityIndex.value]["name"];
                      logic.cityCode = logic.cityList[logic.cityIndex.value]["areaCode"];
                      ///更新区数据
                      logic.areaIndex.value = 0;
                      logic.area.value = "请选择区";
                      logic.areaCode = "";
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }

  void chooseArea() {
    if(logic.areaList.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: '网格数据加载中,请稍后重试',type: 0));
      return;
    }
    showModalBottomSheet(context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w*3),
          topRight: Radius.circular(12.w*3),
        ),
      ), builder: (BuildContext context) {
        logic.scrollControllerC = FixedExtentScrollController(initialItem: logic.areaIndex.value);
        int index = logic.areaIndex.value;
        return Container(
          decoration: BoxDecoration(
              color: HhColors.whiteColor,
              borderRadius: BorderRadius.circular(16.w*3)
          ),
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 10.w*3),
                      child: Text("请选择区",style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20.w*3),
                  child: ScrollConfiguration(
                    behavior: HhBehavior(),
                    child: CupertinoPicker(
                      scrollController: logic.scrollControllerC,
                      itemExtent: 45,
                      children: getArea(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15.w*3,10.w*3,0,15.w*3),child: Icon(Icons.clear,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10.w*3,15.w*3,15.w*3),child: Icon(Icons.check,color: HhColors.titleColor_99,size: 20.w*3,)),
                    onTap: (){
                      logic.areaIndex.value = index;
                      logic.area.value = logic.areaList[logic.areaIndex.value]["name"];
                      logic.areaCode = logic.areaList[logic.areaIndex.value]["areaCode"];
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }

  getProvince() {
    List<Widget> list = [];
    for(int i = 0;i < logic.provinceList.length;i++){
      list.add(
          Container(
            color: HhColors.trans,
            child: Center(child: Text(logic.provinceList[i]["name"],style: TextStyle(color: HhColors.blackColor,fontSize: logic.provinceList[i]["name"].length>3?14.sp*3:15.sp*3),)),
          )
      );
    }
    return list;
  }

  getCity() {
    List<Widget> list = [];
    for(int i = 0;i < logic.cityList.length;i++){
      list.add(
          Container(
            color: HhColors.trans,
            child: Center(child: Text(logic.cityList[i]["name"],style: TextStyle(color: HhColors.blackColor,fontSize: logic.cityList[i]["name"].length>3?14.sp*3:15.sp*3),)),
          )
      );
    }
    return list;
  }

  getArea() {
    List<Widget> list = [];
    for(int i = 0;i < logic.areaList.length;i++){
      list.add(
          Container(
            color: HhColors.trans,
            child: Center(child: Text(logic.areaList[i]["name"],style: TextStyle(color: HhColors.blackColor,fontSize: logic.areaList[i]["name"].length>3?14.sp*3:15.sp*3),)),
          )
      );
    }
    return list;
  }
}
