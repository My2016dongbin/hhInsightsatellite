import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/home_controller.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
class HomePage extends StatelessWidget {
  final logic = Get.find<HomeController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.context = context;
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
        EventBusUtil.getInstance().fire(HhToast(title: '再按一次退出程序'));
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
    double statusBarHeight = MediaQuery.of(logic.context).padding.top;
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

                    },
                    child: Image.asset('assets/images/common/ic_set.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){

                    },
                    child: Image.asset('assets/images/common/ic_list.png',width:55.w*3,height: 55.w*3,fit: BoxFit.fill,)
                ),
                SizedBox(height: 3.w*3,),
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){

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
                      logic.postFire();
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
      margin: EdgeInsets.only(top: MediaQuery.of(logic.context).padding.top),
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
                    Navigator.pop(logic.context);
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
                    Navigator.pop(logic.context);
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
                    Navigator.pop(logic.context);
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
                    Navigator.pop(logic.context);
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
}
