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
import 'package:insightsatellite/pages/common/location/location_controller.dart';
import 'package:insightsatellite/pages/common/location/location_view.dart';
import 'package:insightsatellite/pages/home/setting/upload/upload_controller.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhBehavior.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class UploadPage extends StatelessWidget {
  final logic = Get.find<UploadController>();
  final logicLocation = Get.find<LocationController>();
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
                  showChoosePictureTypeDialog();
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
                  showChooseVideoTypeDialog();
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
                  ///省市区
                  Container(
                    margin: EdgeInsets.fromLTRB(15.w*3, 15.w*3, 15.w*3, 0),
                    child: Row(
                      children: [
                        BouncingWidget(
                            duration: const Duration(milliseconds: 100),
                            scaleFactor: 0.2,
                            onPressed: () {
                              chooseProvince();
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
                              chooseCity();
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
                              chooseArea();
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
                  InkWell(
                    onTap: (){
                      DatePicker.showDatePicker(logic.context,
                          showTitleActions: true,
                          minTime: DateTime.now().subtract(const Duration(days: 365)),
                          maxTime:DateTime.now().add(const Duration(days: 365)), onConfirm: (date) {
                            DatePicker.showTimePicker(logic.context,
                                showTitleActions: true, onConfirm: (date) {
                                  logic.timeController.text = CommonUtils().parseLongTime("${date.millisecondsSinceEpoch}");
                                }, currentTime: DateTime.now(), locale: LocaleType.zh);
                          }, currentTime: DateTime.now(), locale: LocaleType.zh);
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15.w*3, 0, 15.w*3, 0),
                      child: TextField(
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        maxLength: 50,
                        cursorColor: HhColors.titleColor_99,
                        controller: logic.timeController,
                        keyboardType: TextInputType.text,
                        enabled: false,
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
    final List<XFile> pickedFileList = await ImagePicker().pickMultiImage(
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 1,
    );
    if (pickedFileList.isNotEmpty) {
      logic.picture = pickedFileList[0];
    }
  }

  Future<void> getImageFromCamera() async {
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo != null) {
      logic.picture = photo;
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
      logic.video = video;
    }
  }

  Future<void> getVideoFromCamera() async {
    final XFile ?video = await ImagePicker().pickVideo(source: ImageSource.camera,maxDuration: Duration(milliseconds: logic.maxVideoTimes));
    if (video != null) {
      logic.video = video;
    }
  }

  void chooseProvince() {
    if(logic.provinceList==null || logic.provinceList.isEmpty){
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
          color: HhColors.trans,
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
                      Navigator.pop(context);
                      ///更新市区数据
                      // logic.cityList.clear();
                      logic.cityIndex.value = 0;
                      logic.city.value = "请选择市";
                      //getCityList();
                      // logic.areaList.clear();
                      logic.areaIndex.value = 0;
                      logic.area.value = "请选择区";
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
    if(logic.cityList==null || logic.cityList.isEmpty){
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
        logic.scrollControllerP = FixedExtentScrollController(initialItem: logic.cityIndex.value);
        int index = logic.cityIndex.value;
        return Container(
          color: HhColors.trans,
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
                      children: getCity(),
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
                      logic.cityIndex.value = index;
                      logic.city.value = logic.cityList[logic.cityIndex.value]["name"];
                      Navigator.pop(context);
                      ///更新区数据
                      // logic.areaList.clear();
                      logic.areaIndex.value = 0;
                      logic.area.value = "请选择区";
                      //getAreaList();
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
    if(logic.areaList==null || logic.areaList.isEmpty){
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
        logic.scrollControllerP = FixedExtentScrollController(initialItem: logic.areaIndex.value);
        int index = logic.areaIndex.value;
        return Container(
          color: HhColors.trans,
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
