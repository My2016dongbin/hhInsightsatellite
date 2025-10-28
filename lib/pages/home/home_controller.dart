import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/common/location/location_service.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_binding.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/ParseLocation.dart';
import 'package:insightsatellite/utils/Point.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import '../../utils/EventBusUtils.dart';

class HomeController extends GetxController {
  final index = 0.obs;
  final unreadMsgCount = 0.obs;
  final Rx<bool> viewStatus = true.obs;
  final Rx<bool> loading = false.obs;
  final Rx<bool> pageStatus = true.obs;
  final Rx<bool> feedBackStatus = false.obs;
  final Rx<int> versionStatus = 0.obs;
  final Rx<int> downloadStep = 0.obs;
  final unhandledFriendApplicationCount = 0.obs;
  final unhandledGroupApplicationCount = 0.obs;
  final unhandledCount = 0.obs;

  Function()? onScrollToUnreadMessage;
  late StreamSubscription? showToastSubscription;
  StreamSubscription? versionSubscription;
  StreamSubscription? messageSubscription;
  StreamSubscription? messageClickSubscription;
  StreamSubscription? satelliteConfigClickSubscription;
  StreamSubscription? progressSubscription;
  StreamSubscription? downloadProgressSubscription;
  late StreamSubscription showLoadingSubscription;
  final Rx<String> version = ''.obs;
  final Rx<String> buildNumber = ''.obs;

  final Rx<int> totalSize = (65 * 1000 * 1000).obs;
  final Rx<int> currentSize = 0.obs;
  late Dio dio = Dio();
  late String downloadUrl =
      'http://192.168.1.88:9000/resource/fireRebuild-2.1.1.apk';
  late String savePath = '';
  late bool isFromPush = false;

  late AMapController gdMapController;

  ///图层类型 1谷歌影像 2谷歌高程 3天地图矢量 4天地图影像
  final Rx<int> mapTypeTag = 4.obs;

  ///二维三维切换 2二维 3三维
  final Rx<int> mapChangeTag = 2.obs;

  final Rx<int> fireCount = 0.obs;
  final Rx<bool> fireTypeByTime = true.obs;
  late int pageNum = 1;
  late int pageSize = 15;
  late EasyRefreshController easyController = EasyRefreshController();
  final PagingController<int, dynamic> fireController = PagingController(firstPageKey: 1);
  final ScrollController fireScrollController = ScrollController();

  late dynamic fireInfo = {};
  final Rx<bool> satelliteStatus = true.obs;
  final Rx<bool> skyStatus = true.obs;
  final Rx<bool> landStatus = true.obs;
  final Rx<bool> landTypeStatus = true.obs;
  final Rx<bool> gridMoreStatus = true.obs;
  late List<dynamic> satelliteList = [];
  late List<dynamic> skyList = [
    {
      "title":"全部",
      "choose":false,
    },
    {
      "title":"无人机",
      "choose":false,
    },
    {
      "title":"悬浮器",
      "choose":false,
    }
  ];
  late List<dynamic> landList = [
    {
      "title":"全部",
      "choose":false,
    },
    {
      "title":"摄像机",
      "choose":false,
    },
    {
      "title":"护林员",
      "choose":false,
    },
    {
      "title":"瞭望员",
      "choose":false,
    },
    {
      "title":"群众",
      "choose":false,
    }
  ];
  late List<dynamic> landTypeList = [];
  final Rx<String> startTime = "请输入开始时间".obs;
  final Rx<String> endTime = "请输入结束时间".obs;
  final Rx<String> province = "请选择省".obs;
  late String provinceCode = "";
  final Rx<String> city = "请选择市".obs;
  late String cityCode = "";
  final Rx<String> area = "请选择区".obs;
  late String areaCode = "";
  final Rx<String> street = "请选择街道".obs;
  late String streetCode = "";
  late List<dynamic> provinceList = [];
  late List<dynamic> cityList = [];
  late List<dynamic> areaList = [];
  late List<dynamic> streetList = [];
  late FixedExtentScrollController scrollControllerP;
  final Rx<int> provinceIndex = 0.obs;
  late FixedExtentScrollController scrollControllerC;
  final Rx<int> cityIndex = 0.obs;
  late FixedExtentScrollController scrollControllerA;
  final Rx<int> areaIndex = 0.obs;
  late FixedExtentScrollController scrollControllerS;
  final Rx<int> streetIndex = 0.obs;
  final Rx<bool> otherOut = false.obs;
  final Rx<bool> otherCache = false.obs;
  final Rx<bool> otherOutShow = true.obs;
  final Rx<bool> otherCacheShow = true.obs;
  late List<dynamic> newItems = [];
  late List<dynamic> allFireList = [];
  late List<String> filterTimeList = [];
  late List<String> filterNoList = [];
  late int postFireLong = 0;
  late List<dynamic> bridgeData = [];
  late int bridgeTimes = 0;

  //多区域选择（第一条固定，后面的为列表数据）
  final RxList<dynamic> gridSearchList = [].obs;
  final Rx<int> gridSearchIndex = 0.obs;
  final Rx<int> mapTypeIndex = 0.obs;//0：卫星图；1：矢量图

  final RxSet<Marker> aMapMarkers = <Marker>{}.obs;
  final RxSet<Polygon> aMapPolygons = <Polygon>{}.obs;

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      return;
    }

    // 是否首次提示标记
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPrompted = prefs.getBool("hasPromptedNotificationPermission") ?? false;

    if (!hasPrompted) {
      prefs.setBool("hasPromptedNotificationPermission", true);
      EventBusUtil.getInstance().fire(HhToast(title: '请开启通知权限', type: 0));
      Future.delayed(const Duration(milliseconds: 2000), () {
        openAppSettings();
      });
    }
  }

  @override
  void onClose() {
    try {
      versionSubscription!.cancel();
      showToastSubscription!.cancel();
      progressSubscription!.cancel();
      downloadProgressSubscription!.cancel();
      showLoadingSubscription.cancel();
    } catch (e) {
      //
    }
  }

  @override
  Future<void> onInit() async {
    mapLoading();
    localVersion();
    Future.delayed(const Duration(seconds: 1), () {
      showToastSubscription =
          EventBusUtil.getInstance().on<HhToast>().listen((event) {
        if (event.title.isEmpty || event.title == "null") {
          return;
        }

        showToastWidget(
          Container(
            margin: EdgeInsets.fromLTRB(
                20.w * 3, 15.w * 3, 20.w * 3, 25.w * 3),
            padding: EdgeInsets.fromLTRB(30.w * 3,
                event.type == 0 ? 12.h * 3 : 25.h * 3, 30.w * 3, 12.h * 3),
            decoration: BoxDecoration(
                color: HhColors.blackColor.withAlpha(200),
                borderRadius: BorderRadius.all(Radius.circular(8.w * 3))),
            constraints: BoxConstraints(minWidth: 117.w * 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // event.type==0?const SizedBox():SizedBox(height: 16.w*3,),
                event.type == 0
                    ? const SizedBox()
                    : Image.asset(
                  event.type == 1
                      ? 'assets/images/common/icon_success.png'
                      : event.type == 2
                      ? 'assets/images/common/icon_error.png'
                      : event.type == 3
                      ? 'assets/images/common/icon_lock.png'
                      : 'assets/images/common/icon_warn.png',
                  height: 20.w * 3,
                  width: 20.w * 3,
                  fit: BoxFit.fill,
                ),
                event.type == 0
                    ? const SizedBox()
                    : SizedBox(
                  height: 16.h * 3,
                ),
                // SizedBox(height: 16.h*3,),
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: HhColors.whiteColor, fontSize: 14.sp * 3),
                ),
                // SizedBox(height: 10.h*3,)
                // event.type==0?SizedBox(height: 10.h*3,):SizedBox(height: 10.h*3,),
              ],
            ),
          ),
          context: CommonData.context!,
          animation: StyledToastAnimation.slideFromBottomFade,
          reverseAnimation: StyledToastAnimation.fade,
          position: StyledToastPosition.center,
          animDuration: const Duration(seconds: 1),
          duration: const Duration(seconds: 2),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear,
        );
      });
    });
    versionSubscription =
        EventBusUtil.getInstance().on<Version>().listen((event) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - CommonData.time > 1000) {
        CommonData.time = now;
        getVersion();
      }
    });
    messageSubscription =
        EventBusUtil.getInstance().on<Message>().listen((event) {
          isFromPush = true;
          pageNum = 1;
          postFire(false);
    });
    messageClickSubscription =
        EventBusUtil.getInstance().on<MessageClick>().listen((event) async {
          pushSearchInfo(event.id);
    });
    satelliteConfigClickSubscription =
        EventBusUtil.getInstance().on<SatelliteConfig>().listen((event) {
          postType();
    });
    progressSubscription =
        EventBusUtil.getInstance().on<DownProgress>().listen((event) {
      downloadStep.value = event.progress;
    });
    showLoadingSubscription =
        EventBusUtil.getInstance().on<HhLoading>().listen((event) {
          if (event.show) {
            CommonData.context!.loaderOverlay.show();
          } else {
            CommonData.context!.loaderOverlay.hide();
          }
    });
    //获取通知权限
    Future.delayed(const Duration(milliseconds: 2000), () {
      requestNotificationPermission();
    });

    startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch);
    endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
    Future.delayed(const Duration(milliseconds: 1000),(){
      postBridgeBuffer();//缓冲区区域边界
      getCenter();//中心点显示范围
      postDays();
      postType();
    });
    Future.delayed(const Duration(milliseconds: 2000),(){
      getVersion();
    });
    // getProvince(CommonData.china);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //satellite:fireReport:add火情上报
    //satellite:fireFeedback:add火情反馈
    feedBackStatus.value = await CommonUtils().hasPermission("fireFeedback");
    super.onInit();

    ///定位服务
    checkLocation();
  }

  void checkLocation(){
    ///处理原生定位初始化延时问题
    AmapLocationService().dispose();
    AmapLocationService().init();
    AmapLocationService().startLocation();
    if(!AmapLocationService().hasResult){
      Future.delayed(const Duration(milliseconds: 10000),(){
        checkLocation();
      });
    }
  }

  Future<void> getVersion() async {
    Map<String, dynamic> map = {};
    map['operatingSystem'] = Platform.isIOS?"IOS":"Android";
    map['version'] = buildNumber.value;
    map['type'] = "personal";
    var result = await HhHttp()
        .request(RequestUtils.versionNew, method: DioMethod.get, params: map);
    HhLog.d("getVersion -- request ${RequestUtils.versionNew}");
    HhLog.d("getVersion -- map $map");
    HhLog.d("getVersion -- $result");
    if (result["code"] == 200 && result["data"] != null) {
      dynamic update = result["data"];
      showVersionDialog(update);
    } else {
      // EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  void showVersionDialog(dynamic update) {
    versionStatus.value = 0;
    bool force = false;
    try {
      int minSupportedVersion = int.parse(update["minSupportedVersion"]??"1");
      if (minSupportedVersion > (int.parse(buildNumber.value)) ||
          minSupportedVersion == -1) {
        force = true;
      }
      showCupertinoDialog(
          context: CommonData.context!,
          builder: (context) => WillPopScope(
                onWillPop: () async {
                  // 阻止返回键关闭对话框
                  return false;
                },
                child: Center(
                  child: Obx(
                    () => Container(
                      width: 281.w * 3,
                      height: 320.w * 3,
                      decoration: BoxDecoration(
                          color: HhColors.whiteColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(8.w * 3))),
                      child: Stack(
                        children: [
                          Image.asset('assets/images/common/icon_up_top.png'),
                          /*"${update["isForce"]}"=="true"?const SizedBox():*/
                          Align(
                            alignment: Alignment.topRight,
                            child: BouncingWidget(
                              duration: const Duration(milliseconds: 100),
                              scaleFactor: 1.2,
                              onPressed: () {
                                if (force) {
                                  EventBusUtil.getInstance()
                                      .fire(HhToast(title: '请更新版本后使用'));
                                  Future.delayed(
                                      const Duration(milliseconds: 1600), () {
                                    SystemNavigator.pop();
                                  });
                                } else {
                                  Get.back();
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    0, 16.w * 3, 16.w * 3, 0),
                                padding: EdgeInsets.all(20.w),
                                child: Image.asset(
                                  "assets/images/common/icon_up_x.png",
                                  width: 40.w,
                                  height: 40.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 113.w * 3, 0, 0),
                              child: Text(
                                "发现新版本",
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: HhColors.blackColor,
                                    fontSize: 16.sp * 3,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 138.w * 3, 0, 0),
                              child: Text(
                                "V${update["versionName"]}",
                                style: TextStyle(
                                    letterSpacing: -3.w,
                                    decoration: TextDecoration.none,
                                    color: HhColors.gray9TextColor,
                                    fontSize: 14.sp * 3,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                          versionStatus.value == 0
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin:
                                        EdgeInsets.fromLTRB(0, 162.w * 3, 0, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "更新内容:",
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: HhColors.blackColor,
                                              fontSize: 14.sp * 3,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 5.w * 3,
                                        ),
                                        SizedBox(
                                          width: 243.w * 3,
                                          height: 63.w * 3,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${update["versionDescription"]}"
                                                      .replaceAll("\\n", "\n"),
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color:
                                                          HhColors.blackColor,
                                                      fontSize: 13.sp * 3,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                        15.w * 3, 182.w * 3, 15.w * 3, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "更新中...",
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: HhColors.blackColor,
                                              fontSize: 14.sp * 3,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 5.w * 3,
                                        ),
                                        StepProgressIndicator(
                                          totalSteps: 100,
                                          currentStep: downloadStep.value,
                                          size: 12,
                                          padding: 0,
                                          selectedColor: HhColors.mainBlueColor,
                                          unselectedColor:
                                              HhColors.mainBlueColorUn,
                                          roundedEdges:
                                              Radius.circular(10.w * 3),
                                          selectedGradientColor:
                                              const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              HhColors.mainBlueColor,
                                              HhColors.mainBlueColor
                                            ],
                                          ),
                                          unselectedGradientColor:
                                              const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              HhColors.mainBlueColorUn,
                                              HhColors.mainBlueColorUn
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.w * 3,
                                        ),
                                        Text(
                                            "${CommonUtils().parseCache(currentSize.value * 1.0)}/${CommonUtils().parseCache(totalSize.value * 1.0)}",
                                            style: TextStyle(
                                                letterSpacing: -1.w,
                                                decoration: TextDecoration.none,
                                                color: HhColors.gray9TextColor,
                                                fontSize: 14.sp * 3,
                                                fontWeight: FontWeight.w300))
                                      ],
                                    ),
                                  ),
                                ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: BouncingWidget(
                              duration: const Duration(milliseconds: 100),
                              scaleFactor: 0.1,
                              onPressed: () async {
                                if (versionStatus.value == 0) {
                                  ///立即更新
                                  //请求安装未知应用权限 (Android 8.0及以上)
                                  if (Platform.isAndroid) {
                                    if (await Permission
                                        .requestInstallPackages.isGranted) {
                                      versionStatus.value = 1;
                                      downloadStep.value = 0;
                                      downloadUrl =
                                          "${update["apkUrl"]}";
                                      HhLog.d("downloadUrl $downloadUrl");
                                      downloadDir();
                                    } else {
                                      EventBusUtil.getInstance().fire(HhToast(
                                          title: '请先开启安装权限，开启后请重新打开应用'));
                                      Future.delayed(
                                          const Duration(milliseconds: 1600),
                                          () async {
                                        try {
                                          await Permission
                                              .requestInstallPackages
                                              .request();
                                        } catch (e) {
                                          //
                                        }
                                      });
                                    }
                                  }
                                } else {
                                  ///确定
                                  if (currentSize.value == totalSize.value) {
                                    uploadAPK();
                                  }
                                }
                              },
                              child: Container(
                                width: 248.w * 3,
                                height: 44.w * 3,
                                margin: EdgeInsets.fromLTRB(0, 260.w * 3, 0, 0),
                                decoration: BoxDecoration(
                                    color: (versionStatus.value == 0 ||
                                            currentSize.value ==
                                                totalSize.value)
                                        ? HhColors.mainBlueColor
                                        : HhColors.mainBlueColorUn,
                                    borderRadius:
                                        BorderRadius.circular(8.w * 3)),
                                child: Center(
                                  child: Text(
                                    versionStatus.value == 0 ? "立即更新" : "确定",
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: HhColors.whiteColor,
                                        fontSize: 16.sp * 3,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          useRootNavigator: true,
          barrierDismissible: false);
    } catch (e) {
      HhLog.e("getVersion error  $e");
    }
  }

  Future<void> downloadDir() async {
    try {
      // 获取设备的存储目录
      final directory = await getApplicationCacheDirectory();
      savePath = '${directory.path}/insightsatellite.apk';

      // 开始下载文件
      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // 计算下载进度
            currentSize.value = received;
            totalSize.value = total;
            downloadStep.value =
                int.parse(((received / total) * 100).toStringAsFixed(0));
          }
        },
      );
      HhLog.d('文件下载成功: $savePath');
      uploadAPK();
    } catch (e) {
      HhLog.d('下载失败: $e');
    }
  }

  Future<void> localVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
    HhLog.d('localVersion ${buildNumber.value},${version.value}');
  }

  uploadAPK() async {
    await OpenFile.open(savePath,
        type: "application/vnd.android.package-archive");
  }

  /// 创建完成回调
  void onGDMapCreated(AMapController controller) {
    gdMapController = controller;

    //aMapMarkers.add(Marker(position: const LatLng(35.66,126.88),icon: BitmapDescriptor.fromIconPath('assets/images/common/ic_fires_red.png')));
  }

  void fireListDialog() {
    showModalBottomSheet(context: Get.context!, builder: (a){
      return Obx(() =>Container(
        width: 1.sw,
        height: 0.8.sh,
        decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.w))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 10.w*3,),
            Row(
              children: [
                SizedBox(width: 10.w*3,),
                Text('报警信息列表',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                const Expanded(child: SizedBox()),
                InkWell(
                    onTap: (){
                      showListTypeFilter();
                    },
                    child: Text(fireTypeByTime.value?"按时间分类":"按编号分类",style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),)),
                SizedBox(width: 5.w*3,),
                Image.asset('assets/images/common/ic_down.png',width:6.w*3,height: 6.w*3,fit: BoxFit.fill,),
                SizedBox(width: 10.w*3,),
              ],
            ),
            Container(
              width: 1.sw,
              color: HhColors.red,
              margin: EdgeInsets.only(top: 10.w*3),
              padding: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 10.w*3),
              child: Row(
                children: [
                  Text('查询完毕,查询时间内共',style: TextStyle(color: HhColors.whiteColor,fontSize: 12.sp*3),),
                  Text(' ${fireCount.value} ',style: TextStyle(color: HhColors.yellow,fontSize: 14.sp*3),),
                  Text('条报警数据',style: TextStyle(color: HhColors.whiteColor,fontSize: 12.sp*3),),
                ],
              ),
            ),
            SizedBox(height: 5.w*3,),
            Expanded(
              child: pageStatus.value?EasyRefresh(
                onRefresh: (){
                  pageNum = 1;
                  postFire(false);
                },
                onLoad: () async {
                  int now = DateTime.now().millisecondsSinceEpoch;
                  HhLog.d("loadMore now ${now - postFireLong}");
                  if(now - postFireLong > 500){
                    postFireLong = now;
                    pageNum++;
                    HhLog.d(" loadMore load $pageNum");
                    int success = await postFire(false);
                    safeFinishLoad(success, fireScrollController);
                  }else{
                    HhLog.d(" loadMore wait");
                    easyController.finishLoad(IndicatorResult.none,true);
                  }
                },
                controller: easyController,
                child: PagedListView<int, dynamic>(
                  padding: EdgeInsets.zero,
                  pagingController: fireController,
                  scrollController: fireScrollController,
                  builderDelegate: PagedChildBuilderDelegate<dynamic>(
                    noItemsFoundIndicatorBuilder: (context) => CommonUtils().noneWidget(image:'assets/images/common/icon_no_message.png',info: '暂无报警信息',mid: 10.w,top: 0.2.sw,
                      height: 0.3.sw,
                      width: 0.3.sw,),
                    firstPageProgressIndicatorBuilder: (context) => Container(),
                    itemBuilder: (context, item, index) {
                      return InkWell(
                        onTap: () async {
                          Get.back();
                          fireInfo = item;
                          initMarker();
                          final gcj = ParseLocation.gps84_To_Gcj02(double.parse("${fireInfo["latitude"]}"),double.parse("${fireInfo["longitude"]}"));
                          LatLng latLng = LatLng(gcj[0],gcj[1]);
                          gdMapController.moveCamera(
                              CameraUpdate.newLatLngZoom(latLng,15.0)
                          );
                          showFireInfo();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            index==0?const SizedBox():Container(
                              height: 1.w,
                              width: 1.sw,
                              color: HhColors.line25Color,
                            ),
                            !item["showTime"] || !item["showNo"]?const SizedBox():SizedBox(height: 10.w*3,),
                            fireTypeByTime.value?(!item["showTime"]?const SizedBox():Row(
                              children: [
                                SizedBox(width: 10.w*3,),
                                Icon(Icons.access_time_rounded,color: HhColors.titleColor_55,size: 18.w*3,),
                                SizedBox(width: 3.w*3,),
                                Text('${item["observeTimestr"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                                SizedBox(width: 10.w*3,),
                              ],
                            )): !item["showNo"]?const SizedBox():Row(
                              children: [
                                SizedBox(width: 10.w*3,),
                                Icon(Icons.turned_in_not_rounded,color: HhColors.titleColor_55,size: 18.w*3,),
                                SizedBox(width: 3.w*3,),
                                Text('${item["fireNo"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                                SizedBox(width: 20.w*3,),
                                Text('监测次数 ${item["frequency"]}次',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                                SizedBox(width: 10.w*3,),
                              ],
                            ),
                            SizedBox(height: 5.w*3,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 10.w*3,),
                                Icon(Icons.location_on,color: HhColors.titleColor_55,size: 18.w*3,),
                                SizedBox(width: 3.w*3,),
                                Expanded(child: Text('${item["formattedAddress"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),)),
                                SizedBox(width: 10.w*3,),
                              ],
                            ),
                            SizedBox(height: 10.w*3,),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ):const SizedBox(),
            )
          ],
        ),
      ));
    },isDismissible: true,enableDrag: false,isScrollControlled: true);
  }

  void showListTypeFilter() {
    showCupertinoDialog(context: Get.context!, builder: (BuildContext context) {
      return Obx(() =>Material(
        color: HhColors.trans,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 0.7.sw,
                height: 0.4.sw,
                decoration: BoxDecoration(
                    color: HhColors.whiteColor,
                    borderRadius: BorderRadius.circular(16.w)
                ),
                child: Stack(
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(20.w*3, 20.w*3, 0, 0),
                        child: Text("选择分类",style: TextStyle(color: HhColors.blackColor,fontSize: 16.sp*3,height: 1.2),)
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Container(
                              color: HhColors.trans,
                              padding: EdgeInsets.fromLTRB(0, 20.w*3, 0, 10.w*3),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(width: 20.w*3,),
                                  Icon(fireTypeByTime.value?Icons.radio_button_checked:Icons.radio_button_off,color: fireTypeByTime.value?HhColors.blackColor:HhColors.titleColor_88,size: 16.w*3,),
                                  SizedBox(width: 10.w*3,),
                                  Text("按时间分类",style: TextStyle(color: fireTypeByTime.value?HhColors.blackColor:HhColors.titleColor_88,fontSize: 14.sp*3,height: 1.2),)
                                ],
                              ),
                            ),
                            onTap: (){
                              fireTypeByTime.value = true;
                              parseData();
                            },
                          ),
                          InkWell(
                            child: Container(
                              color: HhColors.trans,
                              padding: EdgeInsets.fromLTRB(0, 5.w*3, 0, 10.w*3),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(width: 20.w*3,),
                                  Icon(!fireTypeByTime.value?Icons.radio_button_checked:Icons.radio_button_off,color: !fireTypeByTime.value?HhColors.blackColor:HhColors.titleColor_88,size: 16.w*3,),
                                  SizedBox(width: 10.w*3,),
                                  Text("按编号分类",style: TextStyle(color: !fireTypeByTime.value?HhColors.blackColor:HhColors.titleColor_88,fontSize: 14.sp*3,height: 1.2),)
                                ],
                              ),
                            ),
                            onTap: (){
                              fireTypeByTime.value = false;
                              parseData();
                            },
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CommonButton(
                        text: "确定",
                        width: 80.w*3,
                        height: 40.w*3,
                        margin: EdgeInsets.fromLTRB(0, 0, 10.w*3, 10.w*3),
                        solid: true,
                        elevation: 0,
                        fontSize: 14.sp*3,
                        textColor: HhColors.blackColor,
                        backgroundColor: HhColors.whiteColor,
                        solidColor: HhColors.whiteColor,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
    },barrierDismissible: true);
  }

  void showFireInfo() {
    CommonUtils().closeAllOverlays();
    showModalBottomSheet(context: Get.context!, builder: (a){
      return Container(
        width: 1.sw,
        height: 0.62.sh,
        decoration: BoxDecoration(
            color: HhColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(0.w))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 10.w*3,),
            Row(
              children: [
                SizedBox(width: 10.w*3,),
                Text('火点详情',style: TextStyle(color: HhColors.blackColor,fontSize: 14.sp*3),),
                SizedBox(width: 20.w*3,),
                feedBackStatus.value?BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
                      CommonData.fireInfo = fireInfo;
                      Get.to(() => FeedBackPage(),
                          binding: FeedBackBinding(),preventDuplicates: false);
                    },
                    child: Container(
                        padding: EdgeInsets.fromLTRB(8.w*3, 2.w*3, 8.w*3, 2.w*3),
                        decoration: BoxDecoration(
                            color: HhColors.red2.withAlpha(185),
                            borderRadius: BorderRadius.circular(2.w*3)
                        ),
                        child: Text("反馈",style: TextStyle(color: HhColors.whiteColor,fontSize: 12.sp*3),))
                ):const SizedBox(),
                SizedBox(width: 10.w*3,),
              ],
            ),
            SizedBox(height: 5.w*3,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('地址：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Expanded(child: Text('${fireInfo["formattedAddress"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('观测时间：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["observeTimestr"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('经纬度：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Expanded(child: Text('${fireInfo["longitude"]} , ${fireInfo["latitude"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('可信度：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["reliability"]}%',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('明火面积：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["hotArea"]}公顷',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('像元面积：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["pixelArea"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('像元数：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["pixelNum"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('观测频次：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["frequency"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('土地类型：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Expanded(child: Text('林地（${fireInfo["woodland"]}%）草地（${fireInfo["grassland"]}%）农田（${fireInfo["farmland"]}%）其他（${fireInfo["otherType"]}%）',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3,),)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('数据源：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["satelliteCode"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('火点编号：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["fireNo"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 15.w*3, 10.w*3, 15.w*3),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: (){
                              CommonUtils().showPictureDialog(Get.context!,url: "${fireInfo["visibleLightImgUrl"]}");
                            },
                            child: Image.network("${fireInfo["visibleLightImgUrl"]}",width:160.w*3,height: 100.w*3,fit: BoxFit.fill,errorBuilder: (a,b,c){
                              return Image.asset('assets/images/common/ic_no_pic.png',width:160.w*3,height: 100.w*3,fit: BoxFit.fill,);
                            },),
                          ),
                          SizedBox(width: 20.w*3,),
                          InkWell(
                            onTap: (){
                              CommonUtils().showPictureDialog(Get.context!,url: "${fireInfo["thermalImagingImgUrl"]}");
                            },
                            child: Image.network("${fireInfo["thermalImagingImgUrl"]}",width:160.w*3,height: 100.w*3,fit: BoxFit.fill,errorBuilder: (a,b,c){
                              return Image.asset('assets/images/common/ic_no_pic.png',width:160.w*3,height: 100.w*3,fit: BoxFit.fill,);
                            },),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },isDismissible: true,enableDrag: false,isScrollControlled: true,);
  }


  Future<int> postFire(bool showList) async {
    if(!isFromPush){
      EventBusUtil.getInstance().fire(HhLoading(show: true));
    }
    isFromPush = false;
    List<String> satelliteStrList = [];
    List<String> landTypeStrList = [];
    for(dynamic model in satelliteList){
      if(model["choose"] && "${model["code"]}"!="8888"){
        satelliteStrList.add("${model["code"]}");
      }
    }
    for(dynamic model in landTypeList){
      if(model["choose"] && "${model["code"]}"!="8888"){
        landTypeStrList.add("${model["code"]}");
      }
    }
    Map<String, dynamic> map = {};
    map['pageNum'] = '$pageNum';
    map['pageSize'] = '$pageSize';
    if(streetCode.isNotEmpty){
      map['areaCode'] = streetCode;
    }else{
      if(areaCode.isNotEmpty){
        map['areaCode'] = areaCode;
      }else{
        if(cityCode.isNotEmpty){
          map['areaCode'] = cityCode;
        }else{
          if(provinceCode.isNotEmpty){
            map['areaCode'] = provinceCode;
          }
        }
      }
    }
    for(int i = 0; i < gridSearchList.length; i++){
      dynamic gridModel = gridSearchList[i];
      HhLog.d("gridTest $gridModel");
      if(gridModel["streetCode"].isNotEmpty){
        if(map['areaCode']==null||map['areaCode']==""){
          map['areaCode'] = gridModel["streetCode"];
        }else{
          map['areaCode'] += ",${gridModel["streetCode"]}";
        }
      }else{
        if(gridModel["areaCode"].isNotEmpty){
          if(map['areaCode']==null||map['areaCode']==""){
            map['areaCode'] = gridModel["areaCode"];
          }else{
            map['areaCode'] += ",${gridModel["areaCode"]}";
          }
        }else{
          if(gridModel["cityCode"].isNotEmpty){
            if(map['areaCode']==null||map['areaCode']==""){
              map['areaCode'] = gridModel["cityCode"];
            }else{
              map['areaCode'] += ",${gridModel["cityCode"]}";
            }
          }else{
            if(gridModel["provinceCode"].isNotEmpty){
              if(map['areaCode']==null||map['areaCode']==""){
                map['areaCode'] = gridModel["provinceCode"];
              }else{
                map['areaCode'] += ",${gridModel["provinceCode"]}";
              }
            }
          }
        }
      }
    }

    HhLog.d("gridTest map ${map['areaCode']}");
    map['satelliteSeriesList'] = satelliteStrList.toString().replaceAll(" ", "").replaceAll("[", "").replaceAll("]", "");
    map['landTypeList'] = landTypeStrList.toString().replaceAll(" ", "").replaceAll("[", "").replaceAll("]", "");
    map['startTime'] = startTime.value;
    map['endTime'] = endTime.value;
    map['sortField'] = "observeTimestr";
    map['sortType'] = "desc";
    if(otherCacheShow.value){
      map['bufferArea'] = otherCache.value?"1":"0";
    }
    if(otherOutShow.value){
      map['overseasHeatSources'] = otherOut.value?"1":"0";
    }
    try{
      var result = await HhHttp().request(RequestUtils.fireSearch,method: DioMethod.get,params:map);
      HhLog.d("fireSearch -- ${RequestUtils.fireSearch} -- $map ");
      HhLog.d("fireSearch -- $result");
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      if(result["code"]==200){
        newItems = result["rows"];
        fireCount.value = result["total"];
        if(/*newItems.isEmpty && */pageNum == 1){
          fireController.itemList = [];
          clearAllCircles();
          allFireList = [];
        }
        //处理页数
        try{
          double pageAll = fireCount.value/pageSize;
          bool isLastPage = (pageNum * 1.0) >= pageAll;
          if(isLastPage && newItems.isNotEmpty){
            if(pageNum ==1){
              allFireList.addAll(newItems);
              //处理数据
              parseData();
              fireInfo = {};
              initMarker();
            }
            if(showList){
              fireListDialog();
            }
            return 2;
          }
        }catch(e){
          HhLog.d("fireSearch catch -- $result");
        }

        if (pageNum == 1) {
          fireController.itemList = [];
          allFireList = [];
        }else{
          if(newItems.isEmpty){
            return 2;
          }
        }
        allFireList.addAll(newItems);

        //处理数据
        parseData();

        if(showList){
          fireListDialog();
        }

        fireInfo = {};
        initMarker();
        return 1;
      }else{
        EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString("${result["msg"]}")));
        return 0;
      }
    }catch(e){
      HhLog.e("postFire error: $e");
      EventBusUtil.getInstance().fire(HhToast(title: "加载失败"));
      return 0;
    }
  }


  /// 把圆(半径: 米)近似成多边形顶点
  List<LatLng> _circleAsPolygon(LatLng center,
      {double radiusMeter = 5000, int segments = 72}) {
    const double R = 6378137.0; // 地球半径
    final double lat = center.latitude * pi / 180;
    final double lng = center.longitude * pi / 180;
    final double d = radiusMeter / R;

    final pts = <LatLng>[];
    for (int i = 0; i <= segments; i++) {
      final brng = 2 * pi * i / segments;
      final lat2 = asin(sin(lat) * cos(d) + cos(lat) * sin(d) * cos(brng));
      final lng2 = lng +
          atan2(sin(brng) * sin(d) * cos(lat), cos(d) - sin(lat) * sin(lat2));
      pts.add(LatLng(lat2 * 180 / pi, lng2 * 180 / pi));
    }
    return pts;
  }

  /// 以 center 为圆心新增一个圆(用Polygon拟合)
  void addCirclePolygon({
    required LatLng center,
    double radiusMeter = 5000,
    Color strokeColor = Colors.red,
    double strokeWidth = 1.5,
    Color fillColor = const Color(0x00000000),
  }) {
    final polygon = Polygon(
      points: _circleAsPolygon(center, radiusMeter: radiusMeter),
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      fillColor: fillColor,
    );

    final s = {...aMapPolygons.value};
    s.add(polygon);

    aMapPolygons.value = s; // 用新Set赋值，确保地图刷新
  }

  final List<String> circleIds = [];
  ///火警打点
  initMarker() async {
    aMapMarkers.clear();
    aMapPolygons.removeWhere((element){
      return !element.id.contains("bridge");
    });
    clearAllCircles();
    ///刷新地图
    viewStatus.value = false;
    viewStatus.value = true;
    for(dynamic model in allFireList){
      /// 创建BMFMarker
      final gcj = ParseLocation.gps84_To_Gcj02(double.parse("${model["latitude"]}"),double.parse("${model["longitude"]}"));
      LatLng position = LatLng(gcj[0],gcj[1]);
      Marker mk = Marker(
        anchor: const Offset(0.5,0.5),
          position: position,
          icon: ("${fireInfo["id"]}" == "${model["id"]}")?BitmapDescriptor.fromIconPath('assets/images/common/ic_fire.png'):BitmapDescriptor.fromIconPath('assets/images/common/ic_fires_red.png'),
          onTap: (v){
            ///点击Marker详情
            fireInfo = model;
            showFireInfo();
            initMarker();

            gdMapController.moveCamera(
                CameraUpdate.newLatLngZoom(position,15.0)
            );
          }
      );
      ///画范围以该 marker 为中心画 1km 圆
      addCirclePolygon(center: position, radiusMeter: 1000);
      aMapMarkers.add(mk);
    }
    /*if(allFireList.isNotEmpty && (fireInfo==null || fireInfo["latitude"]==null)){
      ///跳到第一火点
      final gcj = ParseLocation.gps84_To_Gcj02(double.parse("${allFireList[0]["latitude"]}"),double.parse("${allFireList[0]["longitude"]}"));
      LatLng position = LatLng(gcj[0],gcj[1]);
      gdMapController.moveCamera(CameraUpdate.newLatLng(position));
    }*/
  }

  /// 清除所有圆形
  void clearAllCircles() {
    if(circleIds.isNotEmpty){
      for (final circleId in circleIds) {
        //gdMapController.removeOverlay(circleId); TODO
      }
      circleIds.clear();
    }
  }

  ///获取区域边界
  Future<void> postBridge() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var resultS = await HhHttp().request(RequestUtils.bridge,method: DioMethod.get);
    HhLog.d("postBridge -- $resultS");
    if(resultS["code"]==200 && resultS["data"] != null){
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      bridgeData = resultS["data"];
      drawBridge();
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultS["msg"])));
    }

  }

  ///获取中心点
  Future<void> getCenter() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var resultS = await HhHttp().request(RequestUtils.center,method: DioMethod.get);
    HhLog.d("center -- $resultS");
    if(resultS["code"]==200 && resultS["data"] != null){
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      dynamic data = resultS["data"];
      if(data!=null){
        dynamic coordinates = data["coordinates"];
        if(coordinates!=null){
          try{
            dynamic listOut = coordinates[0];
            dynamic listA = listOut[0];
            dynamic listB = listOut[2];
            double centerZoom = 3.6;
                LatLng centerLatLng = CommonUtils().midpointGreatCircle(LatLng(listA[1], listA[0]),LatLng(listB[1], listB[0]));
            centerZoom = CommonUtils().zoomForSquareByDiagonal(LatLng(listA[1], listA[0]),LatLng(listB[1], listB[0]),sidePx: 1.sh);

            ///跳转中心点
            gdMapController.moveCamera(CameraUpdate.newLatLngZoom(centerLatLng,centerZoom-0.7));
          }catch(e){
            gdMapController.moveCamera(CameraUpdate.newLatLngZoom(const LatLng(36.629094,104.755542),3.6));
          }
        }else{
          gdMapController.moveCamera(CameraUpdate.newLatLngZoom(const LatLng(36.629094,104.755542),3.6));
        }
      }else{
        gdMapController.moveCamera(CameraUpdate.newLatLngZoom(const LatLng(36.629094,104.755542),3.6));
      }
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultS["msg"])));
    }

  }

  ///获取缓冲区边界
  Future<void> postBridgeBuffer() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    var resultS = await HhHttp().request(RequestUtils.bridgeBuffer,method: DioMethod.get);
    HhLog.d("bridgeBuffer -- $resultS");
    if(resultS["code"]==200 && resultS["data"] != null){
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      bridgeData = resultS["data"];
      drawBridgeBuffer();
    }else{
      postBridge();
    }

  }

  void mapLoading() {
    loading.value = true;
    Future.delayed(const Duration(milliseconds: 2000), () {
      loading.value = false;
      viewStatus.value = false;
      viewStatus.value = true;
    });
  }

  void parseSatelliteChoose(int index) {
    ///全部-选中
    if(satelliteList[0]['choose'] && index == 0){
      for(int i = 0; i < satelliteList.length; i++){
        satelliteList[i]['choose'] = true;
      }
    }
    ///全部-取消
    if(!satelliteList[0]['choose'] && index == 0){
      for(int i = 0; i < satelliteList.length; i++){
        satelliteList[i]['choose'] = false;
      }
    }
    ///其他
    if(index != 0){
      int number = 0;
      for(int i = 1; i < satelliteList.length; i++){
        if(satelliteList[i]['choose']){
          number++;
        }
      }
      if(number == satelliteList.length-1){
        ///（其他）都选中
        satelliteList[0]['choose'] = true;
      }else{
        ///（其他）没有都选中
        satelliteList[0]['choose'] = false;
      }
    }
    satelliteStatus.value = false;
    satelliteStatus.value = true;
  }

  void parseSkyChoose(int index) {
    ///全部-选中
    if(skyList[0]['choose'] && index == 0){
      for(int i = 0; i < skyList.length; i++){
        skyList[i]['choose'] = true;
      }
    }
    ///全部-取消
    if(!skyList[0]['choose'] && index == 0){
      for(int i = 0; i < skyList.length; i++){
        skyList[i]['choose'] = false;
      }
    }
    ///其他
    if(index != 0){
      int number = 0;
      for(int i = 1; i < skyList.length; i++){
        if(skyList[i]['choose']){
          number++;
        }
      }
      if(number == skyList.length-1){
        ///（其他）都选中
        skyList[0]['choose'] = true;
      }else{
        ///（其他）没有都选中
        skyList[0]['choose'] = false;
      }
    }
    skyStatus.value = false;
    skyStatus.value = true;
  }

  void parseLandChoose(int index) {
    ///全部-选中
    if(landList[0]['choose'] && index == 0){
      for(int i = 0; i < landList.length; i++){
        landList[i]['choose'] = true;
      }
    }
    ///全部-取消
    if(!landList[0]['choose'] && index == 0){
      for(int i = 0; i < landList.length; i++){
        landList[i]['choose'] = false;
      }
    }
    ///其他
    if(index != 0){
      int number = 0;
      for(int i = 1; i < landList.length; i++){
        if(landList[i]['choose']){
          number++;
        }
      }
      if(number == landList.length-1){
        ///（其他）都选中
        landList[0]['choose'] = true;
      }else{
        ///（其他）没有都选中
        landList[0]['choose'] = false;
      }
    }
    landStatus.value = false;
    landStatus.value = true;
  }

  void parseLandTypeChoose(int index) {
    ///全部-选中
    if(landTypeList[0]['choose'] && index == 0){
      for(int i = 0; i < landTypeList.length; i++){
        landTypeList[i]['choose'] = true;
      }
    }
    ///全部-取消
    if(!landTypeList[0]['choose'] && index == 0){
      for(int i = 0; i < landTypeList.length; i++){
        landTypeList[i]['choose'] = false;
      }
    }
    ///其他
    if(index != 0){
      int number = 0;
      for(int i = 1; i < landTypeList.length; i++){
        if(landTypeList[i]['choose']){
          number++;
        }
      }
      if(number == landTypeList.length-1){
        ///（其他）都选中
        landTypeList[0]['choose'] = true;
      }else{
        ///（其他）没有都选中
        landTypeList[0]['choose'] = false;
      }
    }
    landTypeStatus.value = false;
    landTypeStatus.value = true;
  }

  Future<void> postType() async {
    ///1。获取卫星类型列表
    Map<String, dynamic> map = {};
    var result = await HhHttp().request(RequestUtils.satelliteType,method: DioMethod.get,params:map);
    HhLog.d("satelliteType -- ${RequestUtils.satelliteType} -- $map ");
    HhLog.d("satelliteType -- $result");
    if(result["code"]==200){
      List<dynamic> list = result["data"];
      for(dynamic model in list){
        model["choose"] = true;
      }
      satelliteList = list;

      ///2。获取地类列表
      Map<String, dynamic> map2 = {};
      var result2 = await HhHttp().request(RequestUtils.landType,method: DioMethod.get,params:map2);
      HhLog.d("landType -- ${RequestUtils.landType} -- $map ");
      HhLog.d("landType -- $result2");
      if(result2["code"]==200){
        List<dynamic> list = result2["data"];
        for(dynamic model in list){
          model["choose"] = true;
        }
        landTypeList = list;


        ///2.5。获取卫星类型列表-租户筛选
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String tenantId = prefs.getString(SPKeys().tenantId)??"000000";
        String userId = prefs.getString(SPKeys().id)??"1";
        dynamic dataT = {
          "tenantId":tenantId,
          "userId":userId
        };
        HhLog.d("typePermissionOut -- ${RequestUtils.satelliteTypeTenant} -- $dataT ");
        var resultT = await HhHttp().request(RequestUtils.satelliteTypeTenant,method: DioMethod.post,data: dataT);
        HhLog.d("typePermissionOut -- $resultT");
        otherOutShow.value = resultT["data"]["overseasHeatSources"] == 1;
        otherCacheShow.value = resultT["data"]["bufferArea"] == 1;
        if(resultT["code"]==200 && resultT["data"] != null){
          List<dynamic> satelliteCodeList = resultT["data"]["satelliteSeriesList"];
          List<dynamic> arrayT = [];
          for(int i = 0;i < satelliteList.length;i++){
            dynamic model = satelliteList[i];
            if(satelliteCodeList.contains("${model["code"]}")){
              arrayT.add(model);
            }
          }
          satelliteList = arrayT;

          List<dynamic> landTypeCodeList = resultT["data"]["landTypeList"];
          List<dynamic> rowsT = [];
          for(int i = 0;i < landTypeList.length;i++){
            dynamic model = landTypeList[i];
            if(landTypeCodeList.contains("${model["code"]}")){
              rowsT.add(model);
            }
          }
          landTypeList = rowsT;


          ///3。获取用户权限映射
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String tenantId = prefs.getString(SPKeys().tenantId)??"000000";
          String userId = prefs.getString(SPKeys().id)??"1";
          dynamic dataS = {
            "tenantId":tenantId,
            "userId":userId
          };
          HhLog.d("typePermission -- ${RequestUtils.typePermission} -- $dataS ");
          var resultS = await HhHttp().request(RequestUtils.typePermission,method: DioMethod.post,data: dataS);
          HhLog.d("typePermission -- $resultS");
          if(resultS["code"]==200 && resultS["data"] != null){
            otherOut.value = resultS["data"]["overseasHeatSources"] == 1;
            otherCache.value = resultS["data"]["bufferArea"] == 1;

            if(resultS["data"]["overseasHeatSources"] != 1){
              otherOut.value = false;
            }
            if(resultS["data"]["bufferArea"] != 1){
              otherCacheShow.value = false;
            }
            // String satelliteCodes = resultS["data"]["satelliteSeriesList"];
            // List<String> satelliteCodeList = satelliteCodes.split(',');
            List<dynamic> satelliteCodeList = resultS["data"]["satelliteSeriesList"];
            List<dynamic> array = [];
            array.add({
              "name":"全部",
              "code":8888,
              "choose":true,
            });
            for(int i = 0;i < satelliteList.length;i++){
              dynamic model = satelliteList[i];
              if(satelliteCodeList.contains("${model["code"]}")){
                array.add(model);
              }
            }
            satelliteList = array;
            String landType = resultS["data"]["landType"];
            List<String> landTypeCodeList = landType.split(',');
            List<dynamic> rows = [];
            rows.add({
              "name":"全部",
              "code":8888,
              "choose":true,
            });
            for(int i = 0;i < landTypeList.length;i++){
              dynamic model = landTypeList[i];
              if(landTypeCodeList.contains("${model["code"]}")){
                rows.add(model);
              }
            }
            landTypeList = rows;

            pageNum = 1;
            postFire(false);
          }else{
            EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultS["msg"])));
          }


        }else{
          EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultT["msg"])));
        }

      }else{
        EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result2["msg"])));
      }

    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }

  }


  void postDays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString(SPKeys().id)??"";
    dynamic data = {
      "userId":userId
    };
    var result = await HhHttp().request(RequestUtils.userDays,method: DioMethod.post,data:data);
    HhLog.d("postDays -- $result");
    if(result["code"]==200 && result["data"]!=null){
      try{
        int days = int.parse("${result["data"]["extValue"]}");
        if(days < 30){
          Future.delayed(const Duration(milliseconds: 3000),(){
            EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString("该账号还有$days天到期，为了不影响使用，请及时续期！")));
          });
        }
      }catch(e){
        HhLog.e("postDays $e");
      }
    }else{
      // EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getCountry(String code) async {
    provinceIndex.value = 0;
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    provinceList = [];
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    // map['level'] = 0;
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      provinceList = [];
      provinceList.add({
        "areaCode":"999",
        "name":"请选择省",
        "level":"1",
      });
      provinceList.addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getCountryMore(String code,int indexMore) async {
    gridSearchList[indexMore]["provinceIndex"] = 0;
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    gridSearchList[indexMore]["provinceList"] = [];
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    // map['level'] = 0;
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      gridSearchList[indexMore]["provinceList"] = [];
      gridSearchList[indexMore]["provinceList"].add({
        "areaCode":"999",
        "name":"请选择省",
        "level":"1",
      });
      gridSearchList[indexMore]["provinceList"].addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getProvince(String code) async {
    provinceIndex.value = 0;
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = "";
    map['level'] = 0;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      provinceList = [];
      provinceList.add({
        "areaCode":"999",
        "name":"请选择省",
        "level":"1",
      });
      provinceList.addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getProvinceMore(String code, int indexMore) async {
    gridSearchList[indexMore]["provinceIndex"] = 0;
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = "";
    map['level'] = 0;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      gridSearchList[indexMore]["provinceList"] = [];
      gridSearchList[indexMore]["provinceList"].add({
        "areaCode":"999",
        "name":"请选择省",
        "level":"1",
      });
      gridSearchList[indexMore]["provinceList"].addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getCity(String code) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      cityList = [];
      cityList.add({
        "areaCode":"999",
        "name":"请选择市",
        "level":"2",
      });
      cityList.addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getCityMore(String code,int indexMore) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- ${RequestUtils.gridSearch}");
    HhLog.d("gridSearch -- $map");
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      gridSearchList[indexMore]["cityList"] = [];
      gridSearchList[indexMore]["cityList"].add({
        "areaCode":"999",
        "name":"请选择市",
        "level":"2",
      });
      gridSearchList[indexMore]["cityList"].addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getArea(String code) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      areaList = [];
      areaList.add({
        "areaCode":"999",
        "name":"请选择区",
        "level":"3",
      });
      areaList.addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getAreaMore(String code,int indexMore) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      gridSearchList[indexMore]["areaList"] = [];
      gridSearchList[indexMore]["areaList"].add({
        "areaCode":"999",
        "name":"请选择区",
        "level":"3",
      });
      gridSearchList[indexMore]["areaList"].addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getStreet(String code) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      streetList = [];
      streetList.add({
        "areaCode":"999",
        "name":"请选择街道",
        "level":"4",
      });
      streetList.addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
  void getStreetMore(String code,int indexMore) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['parentCode'] = code;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    map['tenantId'] = prefs.getString(SPKeys().tenantId)??"000000";
    map['userId'] = prefs.getString(SPKeys().id)??"1";
    var result = await HhHttp().request(RequestUtils.gridSearch,method: DioMethod.get,params:map);
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    HhLog.d("gridSearch -- $result");
    if(result["code"]==200 && result["data"]!=null){
      gridSearchList[indexMore]["streetList"] = [];
      gridSearchList[indexMore]["streetList"].add({
        "areaCode":"999",
        "name":"请选择街道",
        "level":"4",
      });
      gridSearchList[indexMore]["streetList"].addAll(result["data"]);
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

  void drawBridge2() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if(now - bridgeTimes < 2000){
      return;
    }
    bridgeTimes = now;
    for(dynamic model in bridgeData){
      List<dynamic> coordinates = model["areaPolygon"]["coordinates"];
      for(int m = 0; m < coordinates.length; m++){
        List<dynamic> mid = coordinates[m];
        for(int i = 0; i < mid.length; i++){
          List<dynamic> ins = mid[i];
          Future.delayed(Duration(milliseconds: ins.length ~/ 2),(){
            putDrawBridgeQueue(ins);
          });
        }
      }
    }
  }

  void drawBridge() {
    aMapPolygons.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    if(now - bridgeTimes < 2000){
      return;
    }
    bridgeTimes = now;
    for(dynamic model in bridgeData){
      HhLog.d("buffer $model");
      String type = model["areaPolygon"]["type"];
      if(type == "MultiPolygon"){
        List<dynamic> coordinates = model["areaPolygon"]["coordinates"];
        for(int m = 0; m < coordinates.length; m++){
          List<dynamic> mid = coordinates[m];
          for(int i = 0; i < mid.length; i++){
            List<dynamic> ins = mid[i];
            Future.delayed(Duration(milliseconds: ins.length ~/ 2),(){
              putDrawBridgeQueue(ins,lineColor:HhColors.yellow);
            });
          }
        }
      }
      if(type == "Polygon"){
        List<dynamic> coordinates = model["areaCodeBuffer"]["coordinates"];
        for(int m = 0; m < coordinates.length; m++){
          List<dynamic> mid = coordinates[m];
          Future.delayed(Duration(milliseconds: mid.length ~/ 2),(){
            putDrawBridgeQueue(mid,lineColor:HhColors.yellow);
          });
        }
      }
    }
  }
  void drawBridgeBuffer() {
    aMapPolygons.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    if(now - bridgeTimes < 2000){
      return;
    }
    bridgeTimes = now;
    for(dynamic model in bridgeData){
      HhLog.d("buffer $model");
      String type = model["areaCodeBuffer"]["type"];
      if(type == "MultiPolygon"){
        List<dynamic> coordinates = model["areaCodeBuffer"]["coordinates"];
        for(int m = 0; m < coordinates.length; m++){
          List<dynamic> mid = coordinates[m];
          for(int i = 0; i < mid.length; i++){
            List<dynamic> ins = mid[i];
            Future.delayed(Duration(milliseconds: ins.length ~/ 2),(){
              putDrawBridgeQueue(ins,lineColor:HhColors.whiteColor);
            });
          }
        }
      }
      if(type == "Polygon"){
        List<dynamic> coordinates = model["areaCodeBuffer"]["coordinates"];
        for(int m = 0; m < coordinates.length; m++){
          List<dynamic> mid = coordinates[m];
          Future.delayed(Duration(milliseconds: mid.length ~/ 2),(){
            putDrawBridgeQueue(mid,lineColor:HhColors.whiteColor);
          });
        }
      }
    }
  }

  void putDrawBridgeQueue(List<dynamic> ins,{dynamic lineColor}) {
    List<LatLng> points = [];
    for(int p = 0; p < ins.length; p++){
      List<dynamic> point = ins[p];//[124.143026, 50.566138]
      //1.转成 LatLng
      points.add(LatLng(point[1], point[0]));
    }
    //简化多边形
    List<LatLng> pointsOut = douglasPeucker(points, 0.00005);
    points = pointsOut;
    ///2.创建多边形添加到地图 && 添加id标记
    final id = 'bridge_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000)}';
    aMapPolygons.add(Polygon(points: points,
      visible:true,
      joinType:JoinType.bevel,
      strokeWidth: 3,
      strokeColor: lineColor??Colors.blue,
      fillColor: HhColors.trans,)..setIdForCopy(id));
  }

  ///处理数据-分组排序by time or fireNo
  void parseData() {
    // 1. 分组
    Map<String, List<dynamic>> groupedData = {};
    for (var item in allFireList) {
      String fireNo = fireTypeByTime.value?item["observeTimestr"]:item["fireNo"];
      if (!groupedData.containsKey(fireNo)) {
        groupedData[fireNo] = [];
      }
      groupedData[fireNo]!.add(item);
    }
    // 2. （可选）对分组后的 key 进行排序
    List<String> sortedKeys = groupedData.keys.toList();
      // ..sort(); // 默认按字母升序，如果想自定义可以改这里
    // 3. 遍历输出
    List<dynamic> list = [];
    for (var fireNo in sortedKeys) {
      for (var item in groupedData[fireNo]!) {
        list.add(item);
      }
    }
    allFireList = list;

    String lastTagTime = "";
    String lastTagNo = "";
    for(int i = 0; i < allFireList.length;i++){
      dynamic model = allFireList[i];
      if(lastTagTime==model["observeTimestr"]){//observeTimestr fireNo
        model["showTime"] = false;
      }else{
        model["showTime"] = true;
        lastTagTime = model["observeTimestr"];
      }
      if(lastTagNo==model["fireNo"]){//observeTimestr fireNo
        model["showNo"] = false;
      }else{
        model["showNo"] = true;
        lastTagNo = model["fireNo"];
      }
    }


    fireController.itemList = allFireList;
    fireController.appendLastPage([]);
  }

  int time = 0;
  Future<void> pushSearchInfo(String eventId) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    if(now - time < 2000){
      return;
    }
    time = now;
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    Map<String, dynamic> map = {};
    map['id'] = eventId;
    var result = await HhHttp().request(RequestUtils.fireSearchInfo,method: DioMethod.get,params:map);
    HhLog.d("fireSearch info -- ${RequestUtils.fireSearchInfo} -- $map ");
    HhLog.d("fireSearch info -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    easyController.finishLoad(IndicatorResult.success,true);
    if(result["code"]==200){
      fireInfo = result["data"];
      showFireInfo();
      initMarker();
      final gcj = ParseLocation.gps84_To_Gcj02(double.parse("${fireInfo["latitude"]}"),double.parse("${fireInfo["longitude"]}"));
      LatLng position = LatLng(gcj[0],gcj[1]);
      gdMapController.moveCamera(
          CameraUpdate.newLatLngZoom(position,15.0)
      );
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString("${result["msg"]}")));
    }
  }
  void safeFinishLoad(int result, ScrollController scrollController) {
    Future.delayed(const Duration(milliseconds: 50), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (result) {
          case 1:
            easyController.finishLoad(IndicatorResult.success, true);
            break;
          case 2:
            easyController.finishLoad(IndicatorResult.noMore, true);

            ///滚动触发 UI 重建（避免 noMore 卡菊花）
            if (scrollController.hasClients) {
              try {
                scrollController.animateTo(
                  scrollController.offset - 10, // 滚动极小距离
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                );
              } catch (_) {}
            }
            break;
          default:
            easyController.finishLoad(IndicatorResult.fail, true);
        }
      });
    });
  }


}
