import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/location/location_binding.dart';
import 'package:insightsatellite/pages/common/location/location_view.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_controller.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhBehavior.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
              child: Text('报警上报',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)
          ),
        ),
        ///选项
        Container(
          margin: EdgeInsets.fromLTRB(0, statusBarHeight+50.w*3, 0, 65.w*3),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ///省市区
                BouncingWidget(
                  duration: const Duration(milliseconds: 100),
                  scaleFactor: 0.2,
                  onPressed: () {
                    chooseProvince();
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 0),
                    color: HhColors.trans,
                    child: Row(
                      children: [
                        Text("地区",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        const Expanded(child: SizedBox()),
                        Text("${logic.province.value}${logic.city.value}${logic.area.value}",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        Image.asset('assets/images/common/ic_more.png',width:10.w*3,height: 10.w*3,fit: BoxFit.fill,),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 1.w,
                  width: 1.sw,
                  margin: EdgeInsets.fromLTRB(12.w*3, 10.w*3, 12.w*3, 0),
                ),
                Container(
                  width: 1.sw,
                  margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 0),
                  child: Row(
                    children: [
                      Text("地址",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                      const Expanded(child: SizedBox()),
                      BouncingWidget(
                        duration: const Duration(milliseconds: 100),
                        scaleFactor: 0.2,
                        onPressed: () {
                          Get.to(() => LocationPage(),
                              binding: LocationBinding());
                        },
                        child: Row(
                          children: [
                            Image.asset('assets/images/common/ic_tomap.png',width:8.w*3,height: 10.w*3,fit: BoxFit.fill,),
                            SizedBox(width: 3.w*3,),
                            Text("定位",style: TextStyle(color: HhColors.themeColor,fontSize: 12.sp*3),),
                          ],
                        ),
                      )
                    ],
                  ),
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
                      hintText: '请输入或选择地址',
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
                  child: Row(
                    children: [
                      Text("经度",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          maxLength: 10,
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
                          TextStyle(color: HhColors.gray6TextColor, fontSize: 13.sp*3,fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
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
                  child: Row(
                    children: [
                      Text("纬度",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          maxLength: 10,
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
                          TextStyle(color: HhColors.gray6TextColor, fontSize: 13.sp*3,fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 1.w,
                  width: 1.sw,
                  margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                ),
                ///时间
                InkWell(
                  onTap: (){
                    DatePicker.showDatePicker(logic.context,
                        showTitleActions: true,
                        minTime: DateTime.now().subtract(const Duration(days: 365)),
                        maxTime:DateTime.now().add(const Duration(days: 365)), onConfirm: (date) {
                          logic.time.value = CommonUtils().parseLongTime("${date.millisecondsSinceEpoch}");
                          DatePicker.showTimePicker(logic.context,
                              showTitleActions: true, onConfirm: (date) {
                                logic.time.value = CommonUtils().parseLongTime("${date.millisecondsSinceEpoch}");
                              }, currentTime: date, locale: LocaleType.zh);
                        }, currentTime: DateTime.now(), locale: LocaleType.zh);
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 15.w*3),
                    child: Row(
                      children: [
                        Text("时间",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        const Expanded(child: SizedBox()),
                        Text(logic.time.value,style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        SizedBox(width: 3.w*3,),
                        Image.asset('assets/images/common/ic_more.png',width:10.w*3,height: 10.w*3,fit: BoxFit.fill,),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: HhColors.line25Color,
                  height: 1.w,
                  width: 1.sw,
                  margin: EdgeInsets.fromLTRB(12.w*3, 0, 12.w*3, 0),
                ),
                ///土地类型
                InkWell(
                  onTap: (){
                    chooseLandType();
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 15.w*3),
                    child: Row(
                      children: [
                        Text("土地类型",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        const Expanded(child: SizedBox()),
                        Text(logic.landType.value,style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                        SizedBox(width: 3.w*3,),
                        Image.asset('assets/images/common/ic_more.png',width:10.w*3,height: 10.w*3,fit: BoxFit.fill,),
                      ],
                    ),
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
                  child: Row(
                    children: [
                      Text("面积(公顷)",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          maxLength: 5,
                          cursorColor: HhColors.titleColor_99,
                          controller: logic.areaController,
                          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none
                            ),
                            counterText: '',
                            hintText: '请输入面积',
                            hintStyle: TextStyle(
                                color: HhColors.gray9TextColor, fontSize: 12.sp*3,fontWeight: FontWeight.w500),
                          ),
                          style:
                          TextStyle(color: HhColors.gray6TextColor, fontSize: 13.sp*3,fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: HhColors.line252Color,
                  height: 5.w*3,
                  width: 1.sw,
                  margin: EdgeInsets.only(top: 5.w*3),
                ),
                ///图片视频
                Container(
                  width: 1.sw,
                  margin: EdgeInsets.fromLTRB(15.w*3, 10.w*3, 15.w*3, 0),
                  child: Text("添加图片视频",style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                ),
                ///添加图片
                logic.pictureStatus.value?Container(
                  margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
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
            scaleFactor: 0.6,
            onPressed: () {
              if(logic.province.value.isEmpty && logic.city.value.isEmpty && logic.area.value.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请选择地区"));
                return;
              }
              if(logic.addressController.text.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入或选择地址"));
                return;
              }
              if(logic.latitudeController.text.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入纬度"));
                return;
              }
              try{
                double parse = double.parse(logic.latitudeController.text);
                logic.latitudeController.text = "$parse";
              }catch(e){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入正确的纬度"));
                return;
              }
              if(logic.longitudeController.text.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入经度"));
                return;
              }
              try{
                double parse = double.parse(logic.longitudeController.text);
                logic.longitudeController.text = "$parse";
              }catch(e){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入正确的经度"));
                return;
              }
              if(logic.time.value.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请选择时间"));
                return;
              }
              if(logic.landType.value.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请选择土地类型"));
                return;
              }
              if(logic.areaController.text.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入面积"));
                return;
              }
              try{
                double parse = double.parse(logic.areaController.text);
                logic.areaController.text = "$parse";
              }catch(e){
                EventBusUtil.getInstance().fire(HhToast(title: "请输入正确的面积"));
                return;
              }
              if(logic.pictureList.isEmpty){
                EventBusUtil.getInstance().fire(HhToast(title: "请至少选择一张图片或视频"));
                return;
              }

              logic.pictureUrlList = [];
              logic.picturePostIndex = 0;
              EventBusUtil.getInstance().fire(HhLoading(show: true));
              if(logic.pictureList[logic.picturePostIndex]["file"].path.contains("png")||logic.pictureList[logic.picturePostIndex]["file"].path.contains("jpg")){
                logic.uploadImage();
              }else{
                logic.uploadVideo();
              }
            },
            child: Container(
              height: 40.w*3,
              width: 1.sw,
              margin: EdgeInsets.all(15.w*3),
              decoration: BoxDecoration(
                  color: HhColors.themeColor,
                  borderRadius: BorderRadius.circular(5.w*3)
              ),
              child: Center(child: Text('保存',style: TextStyle(color: HhColors.whiteColor,fontSize: 14.sp*3),)),
            ),
          ),
        )
      ],
    );
  }

  getPictureChildren() {
    List<Widget> listW = [];
    if(logic.pictureList.isNotEmpty){
      for(int i = 0; i < logic.pictureList.length;i++){
        XFile file = logic.pictureList[i]["file"];
        XFile catchFile = logic.pictureList[i]["catch"];
        listW.add(
            BouncingWidget(
              duration: const Duration(milliseconds: 100),
              scaleFactor: 0.2,
              onPressed: (){
                if(file.path.contains("jpg")||file.path.contains("png")){
                  CommonUtils().showPictureFileDialog(logic.context, file:File(file.path));
                }else{
                  CommonUtils().showVideoFileDialog(logic.context, file:File(file.path));
                }
              },
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 20.w*3, 10.w*3, 0),
                  width:80.w*3,height: 80.w*3,
                  child: Stack(
                    children: [
                      Image.file(File(catchFile.path),width:80.w*3,height: 80.w*3,fit: BoxFit.cover,errorBuilder: (a,b,c){
                        return Image.asset('assets/images/common/ic_no_pic.png',width:80.w*3,height: 80.w*3,fit: BoxFit.fill,);
                      },),
                      Align(alignment: Alignment.topRight,child: InkWell(
                          onTap: (){
                            logic.pictureList.removeAt(i);
                            logic.pictureStatus.value = false;
                            logic.pictureStatus.value = true;
                          },
                          child: Image.asset('assets/images/common/ic_delete.png',width:16.w*3,height: 16.w*3,fit: BoxFit.fill,))
                      ),
                      file.path.contains("jpg")||file.path.contains("png")?const SizedBox():Align(alignment: Alignment.center,child: Icon(Icons.play_circle,size: 26.w*3,color: HhColors.gray9TextColor,)
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
                    "图片",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HhColors.blackColor, fontSize: 15.sp*3),
                  ),
                ),
              ),
              onPressed: () {
                Get.back();
                showChoosePictureTypeDialog();
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
                    "视频",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HhColors.blackColor, fontSize: 15.sp*3),
                  ),
                ),
              ),
              onPressed: () {
                Get.back();
                showChooseVideoTypeDialog();
              },
            ),
          ],
        ),
      );
    },isDismissible: true,enableDrag: false,backgroundColor: HhColors.trans);
  }

  void showChoosePictureTypeDialog() {
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
    // final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery,
    //   maxWidth: 3000,
    //   maxHeight: 3000,
    //   imageQuality: 20,
    // );
    final List<XFile> photo = await ImagePicker().pickMultiImage(
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 20,
    );
    if (photo.isNotEmpty) {
      for(int i = 0;i < photo.length; i++){
        XFile fileModel = photo[i];
        if((logic.pictureList.length + 1) <= logic.pictureMaxValue){
          logic.pictureList.add(
              {
                "file":fileModel,
                "catch":fileModel
              });
        }else{
          EventBusUtil.getInstance().fire(HhToast(title: "最多选择${logic.pictureMaxValue}张图片"));
          logic.pictureStatus.value = false;
          logic.pictureStatus.value = true;
          return;
        }
      }
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
    // if (photo != null) {
    //   logic.pictureList.add(
    //       {
    //         "file":photo,
    //         "catch":photo
    //       }
    //   );
    //   logic.pictureStatus.value = false;
    //   logic.pictureStatus.value = true;
    // }
  }

  Future<void> getImageFromCamera() async {
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera,
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 20,);
    if (photo != null) {
      logic.pictureList.add(
          {
            "file":photo,
            "catch":photo
          }
      );
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
  }

  void showChooseVideoTypeDialog() {
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
                getVideoFromCamera();
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
                getVideoFromGallery();
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

  Future getVideoFromGallery() async {
    final XFile ?video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      File videoFile = File(video.path);
      int fileSize = videoFile.lengthSync(); // 获取文件大小（字节）
      double fileSizeMB = fileSize / (1024 * 1024); // 转换成 MB
      if(fileSizeMB > 50){
        EventBusUtil.getInstance().fire(HhToast(title: '上传视频不能超过50M'));
        return;
      }

      final String thumb = await VideoThumbnail.thumbnailFile(
        video: video.path, // 本地路径或网络视频URL
        thumbnailPath: (await getTemporaryDirectory()).path, // 存储缩略图的路径
        imageFormat: ImageFormat.PNG,
        maxHeight: 500, // 生成的缩略图高度
        quality: 95, // 图片质量
      )??"";
      HhLog.d("thumb $thumb");
      logic.pictureList.add(
        {
          "file":video,
          "catch":XFile(thumb)
        }
      );
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
  }

  Future<void> getVideoFromCamera() async {
    final XFile ?video = await ImagePicker().pickVideo(source: ImageSource.camera,maxDuration: Duration(milliseconds: logic.maxVideoTimes),);
    if (video != null) {
      File videoFile = File(video.path);
      int fileSize = videoFile.lengthSync(); // 获取文件大小（字节）
      double fileSizeMB = fileSize / (1024 * 1024); // 转换成 MB
      if(fileSizeMB > 50){
        EventBusUtil.getInstance().fire(HhToast(title: '上传视频不能超过50M'));
        return;
      }
      final String thumb = await VideoThumbnail.thumbnailFile(
        video: video.path, // 本地路径或网络视频URL
        thumbnailPath: (await getTemporaryDirectory()).path, // 存储缩略图的路径
        imageFormat: ImageFormat.PNG,
        maxHeight: 500, // 生成的缩略图高度
        quality: 95, // 图片质量
      )??"";
      logic.pictureList.add(
          {
            "file":video,
            "catch":XFile(thumb)
          }
      );
      logic.pictureStatus.value = false;
      logic.pictureStatus.value = true;
    }
  }

  void chooseProvince() {
    if(logic.provinceList.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: '网格数据加载中,请稍后重试',type: 0));
      return;
    }
    showModalBottomSheet(context: logic.context,
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
                        // logic.getCity(logic.provinceList[index]["areaCode"]);
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
                      logic.getCity(logic.provinceList[index]["areaCode"]);

                      logic.provinceIndex.value = index;
                      logic.province.value = logic.provinceList[logic.provinceIndex.value]["name"];
                      Navigator.pop(context);
                      ///更新市区数据
                      // logic.cityList.clear();
                      logic.cityIndex.value = 0;
                      logic.city.value = "";
                      //getCityList();
                      // logic.areaList.clear();
                      logic.areaIndex.value = 0;
                      logic.area.value = "";

                      delayChooseCity();
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
    showModalBottomSheet(context: logic.context,
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
                        // logic.getArea(logic.cityList[index]["areaCode"]);
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
                      logic.getArea(logic.cityList[index]["areaCode"]);

                      logic.cityIndex.value = index;
                      logic.city.value = logic.cityList[logic.cityIndex.value]["name"];
                      Navigator.pop(context);
                      ///更新区数据
                      logic.areaIndex.value = 0;
                      logic.area.value = "";

                      delayChooseArea();
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
    showModalBottomSheet(context: logic.context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w*3),
          topRight: Radius.circular(12.w*3),
        ),
      ), builder: (BuildContext context) {
        logic.scrollControllerA = FixedExtentScrollController(initialItem: logic.areaIndex.value);
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
                      scrollController: logic.scrollControllerA,
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


  void chooseLandType() {
    if(logic.landTypeList.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: '数据加载中,请稍后重试',type: 0));
      return;
    }
    showModalBottomSheet(context: logic.context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.w*3),
          topRight: Radius.circular(12.w*3),
        ),
      ), builder: (BuildContext context) {
        logic.scrollControllerT = FixedExtentScrollController(initialItem: logic.landTypeIndex.value);
        int index = logic.landTypeIndex.value;
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
                      child: Text("请选择土地类型",style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20.w*3),
                  child: ScrollConfiguration(
                    behavior: HhBehavior(),
                    child: CupertinoPicker(
                      scrollController: logic.scrollControllerT,
                      itemExtent: 45,
                      children: getLandType(),
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
                      logic.landTypeIndex.value = index;
                      logic.landType.value = logic.landTypeList[logic.landTypeIndex.value]["name"];
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

  getLandType() {
    List<Widget> list = [];
    for(int i = 0;i < logic.landTypeList.length;i++){
      list.add(
          Container(
            color: HhColors.trans,
            child: Center(child: Text(logic.landTypeList[i]["name"],style: TextStyle(color: HhColors.blackColor,fontSize: logic.landTypeList[i]["name"].length>3?14.sp*3:15.sp*3),)),
          )
      );
    }
    return list;
  }

  void delayChooseCity() {
    Future.delayed(const Duration(milliseconds: 1000),(){
      if(logic.cityList.isNotEmpty){
        chooseCity();
      }else{
        delayChooseCity();
      }
    });
  }

  void delayChooseArea() {
    Future.delayed(const Duration(milliseconds: 1000),(){
      if(logic.areaList.isNotEmpty){
        chooseArea();
      }else{
        delayChooseArea();
      }
    });
  }
}
