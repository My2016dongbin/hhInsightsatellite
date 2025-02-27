import 'dart:ui';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/location/location_controller.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class LocationPage extends StatelessWidget {
  final logic = Get.find<LocationController>();
  late double statusBarHeight = 0;

  LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    // 在这里设置状态栏字体为深色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarBrightness: Brightness.dark, // 状态栏字体亮度
      statusBarIconBrightness: Brightness.dark, // 状态栏图标亮度
    ));
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: HhColors.backColor,
      body: Obx(
            () => Container(
          height: 1.sh,
          width: 1.sw,
          padding: EdgeInsets.zero,
          child: logic.testStatus.value ? loginView() : const SizedBox(),
        ),
      ),
    );
  }

  loginView() {
    return Stack(
      children: [
        Container(color: HhColors.themeColor,width: 1.sw,height: statusBarHeight+50.w*3,),
        ///title
        Align(
          alignment: Alignment.topLeft,
          child: InkWell(
            onTap: (){
              Get.back();
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(10.w*3, statusBarHeight + 12.w*3, 0, 0),
                padding: EdgeInsets.all(5.w*3),
                child: Image.asset('assets/images/common/ic_back.png',width:20.w*3,height: 20.w*3,fit: BoxFit.fill,)
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
              margin: EdgeInsets.fromLTRB(0, statusBarHeight + 12.w*3, 0, 0),
              padding: EdgeInsets.all(5.w*3),
              child: Text('地图',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 77.w*3),
          child: BMFMapWidget(
            onBMFMapCreated: (controller) {
              logic.onBMFMapCreated(controller);
            },
            mapOptions: BMFMapOptions(
                center: BMFCoordinate(CommonData.latitude ?? 36.30865,
                    CommonData.longitude ?? 120.314037),
                zoomLevel: 14,
                mapType: BMFMapType.Standard,
                mapPadding:
                BMFEdgeInsets(left: 30.w, top: 0, right: 30.w, bottom: 0)),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 1.sw,
            padding: EdgeInsets.fromLTRB(40.w, 30.w, 40.w, 30.w),
            decoration: BoxDecoration(
              color: HhColors.whiteColor,
              borderRadius: BorderRadius.all(Radius.circular(10.w))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    logic.longitude.value==0.0?"点击地图以获取经纬度和地图状态":logic.locText.value,style: TextStyle(
                    color: HhColors.blackColor,
                    fontSize: 14.sp*3
                )
                ),
                SizedBox(height: 20.w,),
                Text(
                  logic.longitude.value==0.0?"点击地图以获取经纬度和地图状态":'(${logic.longitude.value},${logic.latitude.value})',style: TextStyle(
                  color: HhColors.gray9TextColor,
                  fontSize: 10.sp*3
                ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20.w,),
                ///确认选择
                BouncingWidget(
                  duration: const Duration(milliseconds: 100),
                  scaleFactor: 0.2,
                  onPressed: () {
                    Get.back();
                  },
                  child: Container(
                    height: 40.w*3,
                    width: 1.sw,
                    decoration: BoxDecoration(
                        color: HhColors.themeColor,
                        borderRadius: BorderRadius.circular(20.w*3)
                    ),
                    child: Center(child: Text('确认选择',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

}
