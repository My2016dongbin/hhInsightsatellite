import 'dart:ui';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/pages/common/location/location_binding.dart';
import 'package:insightsatellite/pages/common/location/location_view.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_controller.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class UploadPage extends StatelessWidget {
  final logic = Get.find<UploadController>();
  late double statusBarHeight = 0;
  UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    // 在这里设置状态栏字体为深色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarBrightness: Brightness.light, // 状态栏字体亮度
      statusBarIconBrightness: Brightness.light, // 状态栏图标亮度
    ));
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
    return Stack(
      children: [
        Image.asset('assets/images/common/ic_add_fire_background.png',width:1.sw,height: statusBarHeight+105.w*3,fit: BoxFit.fill,),
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
              child: Text('上报',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)
          ),
        ),
        ///图片视频
        Container(
          margin: EdgeInsets.fromLTRB(12.w*3, statusBarHeight+220.w, 12.w*3, 0),
          height: 100.w*3,
          width: 1.sw,
          decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.circular(10.w*3),
            boxShadow: const [
              BoxShadow(
                color: HhColors.trans_77,
                ///控制阴影的位置
                offset: Offset(0, 3),
                ///控制阴影的大小
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.2,
                onPressed: () {

                },
                child: Container(
                  padding:EdgeInsets.fromLTRB(20.w*3, 5.w*3, 5.w*3, 5.w*3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/common/ic_add_photo.png',width:50.w*3,height: 50.w*3,fit: BoxFit.fill,),
                      SizedBox(height: 2.w*3,),
                      Text('添加图片',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                    ],
                  ),
                ),
              ),
              BouncingWidget(
                duration: const Duration(milliseconds: 100),
                scaleFactor: 0.2,
                onPressed: () {

                },
                child: Container(
                  padding:EdgeInsets.fromLTRB(5.w*3, 5.w*3, 20.w*3, 5.w*3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/common/huaban.png',width:50.w*3,height: 50.w*3,fit: BoxFit.fill,),
                      SizedBox(height: 2.w*3,),
                      Text('添加视频',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ///选项
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, statusBarHeight+177.w*3, 0, 65.w*3),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 0),
                    child: Row(
                      children: [
                        BouncingWidget(
                            duration: const Duration(milliseconds: 100),
                            scaleFactor: 0.2,
                            onPressed: () {

                            },
                            child: Text(logic.province.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3),)
                        ),
                        SizedBox(width: 2.w*3,),
                        Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,),
                        SizedBox(width: 10.w*3,),
                        BouncingWidget(
                            duration: const Duration(milliseconds: 100),
                            scaleFactor: 0.2,
                            onPressed: () {

                            },
                            child: Text(logic.city.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3),)
                        ),
                        SizedBox(width: 2.w*3,),
                        Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,),
                        SizedBox(width: 10.w*3,),
                        BouncingWidget(
                            duration: const Duration(milliseconds: 100),
                            scaleFactor: 0.2,
                            onPressed: () {

                            },
                            child: Text(logic.area.value,style: TextStyle(color: HhColors.gray9TextColor,fontSize: 12.sp*3),)
                        ),
                        SizedBox(width: 2.w*3,),
                        Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,),
                        const Expanded(child: SizedBox()),
                        BouncingWidget(
                          duration: const Duration(milliseconds: 100),
                          scaleFactor: 0.2,
                          onPressed: () {
                            Get.to(() => LocationPage(),
                                binding: LocationBinding());
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.w*3),
                              color: HhColors.trans,
                              child: Image.asset('assets/images/common/ic_tomap.png',width:16.w*3,height: 20.w*3,fit: BoxFit.fill,)
                          ),
                        ),
                        SizedBox(width: 10.w*3,),
                      ],
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 10.w*3, 12.w*3, 0),
                  ),
                  ///地址
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 50,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.addressController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '地址',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                  ///经度
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 20,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '经度',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                  ///纬度
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 20,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '纬度',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                  ///时间
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 50,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.timeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '时间',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                  ///土地类型
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 20,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.landTypeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '土地类型',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                  ///面积(公顷)
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      maxLength: 20,
                      cursorColor: HhColors.titleColor_99,
                      controller: logic.areaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        counterText: '',
                        hintText: '面积(公顷)',
                        hintStyle: TextStyle(
                            color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                      ),
                      style:
                      TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: HhColors.line25Color,
                    height: 1.w,
                    width: 1.sw,
                    margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
        ///保存
        Align(
          alignment: Alignment.bottomCenter,
          child: BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.6,
            onPressed: () {

            },
            child: Container(
              height: 40.w*3,
              width: 1.sw,
              margin: EdgeInsets.all(15.w*3),
              decoration: BoxDecoration(
                  color: HhColors.themeColor,
                  borderRadius: BorderRadius.circular(20.w*3)
              ),
              child: Center(child: Text('保存',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)),
            ),
          ),
        )
      ],
    );
  }

}
