import 'dart:io';
import 'dart:ui';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_controller.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class FeedBackPage extends StatelessWidget {
  final logic = Get.find<FeedBackController>();
  late double statusBarHeight = 0;

  FeedBackPage({super.key});

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
          color: HhColors.whiteColor,
          child: logic.testStatus.value ? loginView() : const SizedBox(),
        ),
      ),
    );
  }

  loginView() {
    return Stack(
      children: [
        Container(color: HhColors.themeColor,width: 1.sw,height: statusBarHeight+150.w,),
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
              child: Text('反馈',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)
          ),
        ),
        ///内容
        Container(
          margin: EdgeInsets.fromLTRB(15.w*3, statusBarHeight+66.w*3, 15.w*3, 60.w*3),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///详细地址
                Text('详细地址：',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                SizedBox(height: 2.w*3,),
                TextField(
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
                    hintText: '请输入详细地址',
                    hintStyle: TextStyle(
                        color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                  ),
                  style:
                  TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 2.w,
                  width: 2.sw,
                ),
                SizedBox(height: 10.w*3,),
                ///火情描述
                Text('火情描述：',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                SizedBox(height: 2.w*3,),
                TextField(
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  maxLength: 50,
                  cursorColor: HhColors.titleColor_99,
                  controller: logic.descController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    counterText: '',
                    hintText: '请输入火情描述',
                    hintStyle: TextStyle(
                        color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                  ),
                  style:
                  TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 2.w,
                  width: 2.sw,
                ),
                SizedBox(height: 10.w*3,),
                ///经度
                Text('经度：',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                SizedBox(height: 2.w*3,),
                TextField(
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  maxLength: 50,
                  cursorColor: HhColors.titleColor_99,
                  controller: logic.longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    counterText: '',
                    hintText: '请输入经度',
                    hintStyle: TextStyle(
                        color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                  ),
                  style:
                  TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 2.w,
                  width: 2.sw,
                ),
                SizedBox(height: 10.w*3,),
                ///纬度
                Text('纬度：',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                SizedBox(height: 2.w*3,),
                TextField(
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  maxLength: 50,
                  cursorColor: HhColors.titleColor_99,
                  controller: logic.latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    counterText: '',
                    hintText: '请输入纬度',
                    hintStyle: TextStyle(
                        color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                  ),
                  style:
                  TextStyle(color: HhColors.gray6TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 2.w,
                  width: 2.sw,
                ),
                ///真实误报
                Container(
                  margin: EdgeInsets.only(top: 10.w*3),
                  child: Row(
                    children: [
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.2,
                        onPressed: () {
                          logic.realState.value = true;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: logic.realState.value?HhColors.themeColor:HhColors.grayEEBackColor,
                            borderRadius: BorderRadius.circular(12.w*3)
                          ),
                          padding: EdgeInsets.fromLTRB(12.w*3, 2.w*3, 12.w*3, 2.w*3),
                          child: Text('真实火点',style: TextStyle(color: logic.realState.value?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
                        ),
                      ),
                      SizedBox(width: 10.w*3,),
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.2,
                        onPressed: () {
                          logic.realState.value = false;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !logic.realState.value?HhColors.themeColor:HhColors.grayEEBackColor,
                            borderRadius: BorderRadius.circular(12.w*3)
                          ),
                          padding: EdgeInsets.fromLTRB(12.w*3, 2.w*3, 12.w*3, 2.w*3),
                          child: Text('误报火点',style: TextStyle(color: !logic.realState.value?HhColors.whiteColor:HhColors.gray9TextColor,fontSize: 12.sp*3),),
                        ),
                      ),
                    ],
                  ),
                ),
                ///添加图片
                logic.pictureStatus.value?Container(
                  margin: EdgeInsets.only(top: 20.w*3),
                  child: SingleChildScrollView(
                    child: Row(
                      children: getPictureChildren(),
                    ),
                  ),
                ):const SizedBox(),
              ],
            ),
          ),
        ),

        ///保存
        Align(
          alignment: Alignment.bottomCenter,
          child: BouncingWidget(
            duration: const Duration(milliseconds: 100),
            scaleFactor: 0.2,
            onPressed: () {

            },
            child: Container(
              height: 40.w*3,
              width: 1.sw,
              margin: EdgeInsets.fromLTRB(40.w, 30.w, 40.w, 30.w),
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

  void showChooseTypeDialog() {
    showModalBottomSheet(context: logic.context, builder: (a){
      return Container(
        width: 1.sw,
        decoration: BoxDecoration(
            color: HhColors.trans,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.w*3))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BouncingWidget(
              duration: const Duration(milliseconds: 100),
              scaleFactor: 0,
              child: Container(
                width: 1.sw,
                height: 50.w*3,
                margin: EdgeInsets.fromLTRB(0, 20.w*3, 0, 0),
                decoration: BoxDecoration(
                    color: HhColors.whiteColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.w*3))
                ),
                child: Center(
                  child: Text(
                    "拍摄",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HhColors.blackColor, fontSize: 15.sp*3),
                  ),
                ),
              ),
              onPressed: () {
                getImageFromCamera();
                Get.back();
              },
            ),
            Container(
              color: HhColors.grayLineColor,
              height: 2.w,
              width: 1.sw,
            ),
            BouncingWidget(
              duration: const Duration(milliseconds: 100),
              scaleFactor: 0,
              child: Container(
                width: 1.sw,
                height: 50.w*3,
                color: HhColors.whiteColor,
                child: Center(
                  child: Text(
                    "从相册选择",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HhColors.blackColor, fontSize: 15.sp*3),
                  ),
                ),
              ),
              onPressed: () {
                getImageFromGallery();
                Get.back();
              },
            ),
            Container(
              color: HhColors.grayLineColor,
              height: 2.w,
              width: 1.sw,
            ),
            BouncingWidget(
              duration: const Duration(milliseconds: 100),
              scaleFactor: 0,
              child: Container(
                width: 1.sw,
                height: 60.w*3,
                color: HhColors.whiteColor,
                padding: EdgeInsets.only(bottom: 10.w*3),
                child: Center(
                  child: Text(
                    "取消",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HhColors.blackColor, fontSize: 15.sp*3),
                  ),
                ),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
    },isDismissible: true,enableDrag: false,backgroundColor: HhColors.trans);
  }

  Future getImageFromGallery() async {
    final List<XFile> pickedFileList = await ImagePicker().pickMultiImage(
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 1,
    );
    if (pickedFileList.isNotEmpty) {
      logic.pictureList.add(pickedFileList[0]);
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
  }

  Future<void> getImageFromCamera() async {
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo != null) {
      logic.pictureList.add(photo);
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
  }

  getPictureChildren() {
    List<Widget> listW = [];
    if(logic.pictureList.isNotEmpty){
      for(int i = 0; i < logic.pictureList.length;i++){
        XFile file = logic.pictureList[i];
        listW.add(
          InkWell(
            onTap: (){
              CommonUtils().showPictureFileDialog(logic.context, file:File(file.path));
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 20.w*3, 10.w*3, 0),
                width:80.w*3,height: 80.w*3,
                child: Stack(
                  children: [
                    Image.file(File(file.path),width:80.w*3,height: 80.w*3,fit: BoxFit.cover,),
                    Align(alignment: Alignment.topRight,child: InkWell(
                      onTap: (){
                        logic.pictureList.removeAt(i);
                        logic.pictureStatus.value = false;
                        logic.pictureStatus.value = true;
                      },
                        child: Image.asset('assets/images/common/ic_delete.png',width:16.w*3,height: 16.w*3,fit: BoxFit.fill,))
                    ),
                  ],
                )
            ),
          )
        );
      }
      if(logic.pictureList.length < logic.pictureMaxValue){
        listW.add(
          InkWell(
            onTap: (){
              showChooseTypeDialog();
            },
            child: Container(
              margin: EdgeInsets.only(top: 20.w*3),
              child: Image.asset('assets/images/common/ic_add_pic.png',width:80.w*3,height: 80.w*3,fit: BoxFit.fill,),
            ),
          ),
        );
      }
    }else{
      listW.add(
        InkWell(
          onTap: (){
            showChooseTypeDialog();
          },
          child: Container(
            margin: EdgeInsets.only(top: 20.w*3),
            child: Image.asset('assets/images/common/ic_add_pic.png',width:80.w*3,height: 80.w*3,fit: BoxFit.fill,),
          ),
        ),
      );
    }
    return listW;
  }

}
