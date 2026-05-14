import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/mqtt/mqtt_controller.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class MqttPage extends StatelessWidget {
  final logic = Get.find<MqttController>();

  MqttPage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    CommonData.context = context;
    final overlayStyle = Platform.isAndroid
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
          );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    return Obx(() => Scaffold(
          backgroundColor: HhColors.backColor,
          body: Container(
            height: 1.sh,
            width: 1.sw,
            color: HhColors.backColorF5,
            padding: EdgeInsets.zero,
            child: logic.test.value
                ? Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 54.w * 3),
                          color: HhColors.trans,
                          child: Text(
                            "MQTT",
                            style: TextStyle(
                              color: HhColors.blackTextColor,
                              fontSize: 18.sp * 3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: Get.back,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(23.w * 3, 59.h * 3, 0, 0),
                          padding: EdgeInsets.fromLTRB(0, 10.w, 20.w, 10.w),
                          color: HhColors.trans,
                          child: Image.asset(
                            "assets/images/common/back.png",
                            height: 17.w * 3,
                            width: 10.w * 3,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ));
  }
}
