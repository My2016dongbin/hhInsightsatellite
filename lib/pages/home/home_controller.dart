import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_map/src/map/bmf_map_controller.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_binding.dart';
import 'package:insightsatellite/pages/home/feedback/feedback_view.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/ParseLocation.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

import '../../bus/event_class.dart';
import '../../utils/EventBusUtils.dart';

class HomeController extends GetxController {
  final index = 0.obs;
  late BuildContext context;
  final unreadMsgCount = 0.obs;
  final Rx<bool> viewStatus = true.obs;
  final Rx<bool> loading = false.obs;
  final Rx<int> versionStatus = 0.obs;
  final Rx<int> downloadStep = 0.obs;
  final unhandledFriendApplicationCount = 0.obs;
  final unhandledGroupApplicationCount = 0.obs;
  final unhandledCount = 0.obs;
  final LocationFlutterPlugin _myLocPlugin = LocationFlutterPlugin();

  Function()? onScrollToUnreadMessage;
  late StreamSubscription showToastSubscription;
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

  late BMFMapController myMapController;

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

  late dynamic fireInfo = {};
  final Rx<bool> satelliteStatus = true.obs;
  final Rx<bool> skyStatus = true.obs;
  final Rx<bool> landStatus = true.obs;
  final Rx<bool> landTypeStatus = true.obs;
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
  final Rx<String> city = "请选择市".obs;
  late List<dynamic> provinceList = [
    {
      "name":"山东省",
    },
    {
      "name":"吉林省",
    },
    {
      "name":"山西省",
    },
    {
      "name":"河南省",
    },
    {
      "name":"河北省",
    },
    {
      "name":"辽宁省",
    },
  ];
  late List<dynamic> cityList = [
    {
      "name":"青岛",
    },
    {
      "name":"济南",
    },
    {
      "name":"烟台",
    },
    {
      "name":"潍坊",
    },
    {
      "name":"淄博",
    },
    {
      "name":"济宁",
    },
  ];
  late List<dynamic> areaList = [
    {
      "name":"高新区",
    },
    {
      "name":"城阳区",
    },
    {
      "name":"市南区",
    },
    {
      "name":"市北区",
    },
    {
      "name":"崂山区",
    },
    {
      "name":"李沧区",
    },
  ];
  late FixedExtentScrollController scrollControllerP;
  final Rx<int> provinceIndex = 0.obs;
  late FixedExtentScrollController scrollControllerC;
  final Rx<int> cityIndex = 0.obs;
  final Rx<bool> otherOut = false.obs;
  final Rx<bool> otherCache = false.obs;
  final Rx<bool> otherOutShow = true.obs;
  final Rx<bool> otherCacheShow = true.obs;
  late List<BMFMarker> fireMarkerList = [];
  late List<dynamic> newItems = [];
  late List<dynamic> allFireList = [];

  Future<void> requestNotificationPermission() async {
    // 检查是否已经获得通知权限
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // 申请权限
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // 引导用户前往设置开启通知权限
    } else if (status.isDenied) {
      EventBusUtil.getInstance().fire(HhToast(title: '请开启通知权限', type: 0));
      Future.delayed(const Duration(milliseconds: 2000), () {
        openAppSettings(); // 引导用户前往设置开启通知权限
      });
    }
  }

  @override
  void onClose() {
    try {
      versionSubscription!.cancel();
      showToastSubscription.cancel();
      progressSubscription!.cancel();
      downloadProgressSubscription!.cancel();
      showLoadingSubscription.cancel();
    } catch (e) {
      //
    }
  }

  @override
  void onInit() {
    mapLoading();
    localVersion();
    Future.delayed(const Duration(seconds: 1), () {
      showToastSubscription =
          EventBusUtil.getInstance().on<HhToast>().listen((event) {
        if (event.title.isEmpty || event.title == "null") {
          return;
        }

        if (Get.isRegistered<HomeController>()) {
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
            context: context,
            animation: StyledToastAnimation.slideFromBottomFade,
            reverseAnimation: StyledToastAnimation.fade,
            position: StyledToastPosition.center,
            animDuration: const Duration(seconds: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.elasticOut,
            reverseCurve: Curves.linear,
          );
        }
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
          pageNum = 1;
          postFire(false);
    });
    messageClickSubscription =
        EventBusUtil.getInstance().on<MessageClick>().listen((event) {
          pageNum = 1;
          postFire(false);
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
          if (Get.isRegistered<HomeController>()) {
            if (event.show) {
              context.loaderOverlay.show();
            } else {
              context.loaderOverlay.hide();
            }
          }
    });
    getLocation();
    //获取通知权限
    Future.delayed(const Duration(milliseconds: 2000), () {
      requestNotificationPermission();
    });

    startTime.value = CommonUtils().parseLongTimeLong(DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch);
    endTime.value = CommonUtils().parseLongTimeLong(DateTime.now().millisecondsSinceEpoch);
    postType();
    getVersion();
    super.onInit();
  }

  Future<void> getLocation() async {
    if (Platform.isIOS) {
      //接受定位回调
      _myLocPlugin.singleLocationCallback(callback: (BaiduLocation result) {
        //result为定位结果
        HhLog.e("location isIOS ${result.latitude},${result.longitude}");
        CommonData.latitude = result.latitude;
        CommonData.longitude = result.longitude;
      });
    } else if (Platform.isAndroid) {
      //接受定位回调
      _myLocPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
        //result为定位结果
        HhLog.d("location isAndroid ${result.latitude},${result.longitude}");
        CommonData.latitude = result.latitude;
        CommonData.longitude = result.longitude;
        EventBusUtil.getInstance().fire(Location());
      });
    }
    //设置定位参数
    Map iosMap = initIOSOptions().getMap();
    Map androidMap = initAndroidOptions().getMap();
    _myLocPlugin.prepareLoc(androidMap, iosMap);
    //开启定位
    if (Platform.isIOS) {
      _myLocPlugin
          .singleLocation({'isReGeocode': true, 'isNetworkState': true});
    } else if (Platform.isAndroid) {
      _myLocPlugin.startLocation();
    }

    Future.delayed(const Duration(milliseconds: 10000)).then((value) {
      getLocation();
    });
  }

  BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
        // 定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        locationMode: BMFLocationMode.hightAccuracy,
        // 是否需要返回地址信息
        isNeedAddress: true,
        // 是否需要返回海拔高度信息
        isNeedAltitude: true,
        // 是否需要返回周边poi信息
        isNeedLocationPoiList: true,
        // 是否需要返回新版本rgc信息
        isNeedNewVersionRgc: true,
        // 是否需要返回位置描述信息
        isNeedLocationDescribe: true,
        // 是否使用gps
        openGps: true,
        // 可选，设置场景定位参数，包括签到场景、运动场景、出行场景
        locationPurpose: BMFLocationPurpose.sport,
        // 坐标系
        coordType: BMFLocationCoordType.bd09ll,
        // 设置发起定位请求的间隔，int类型，单位ms
        // 如果设置为0，则代表单次定位，即仅定位一次，默认为0
        scanspan: 0);
    return options;
  }

  BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
      // 坐标系
      coordType: BMFLocationCoordType.bd09ll,
      // 位置获取超时时间
      locationTimeout: 10,
      // 获取地址信息超时时间
      reGeocodeTimeout: 10,
      // 应用位置类型 默认为automotiveNavigation
      activityType: BMFActivityType.automotiveNavigation,
      // 设置预期精度参数 默认为best
      desiredAccuracy: BMFDesiredAccuracy.best,
      // 是否需要最新版本rgc数据
      isNeedNewVersionRgc: true,
      // 指定定位是否会被系统自动暂停
      pausesLocationUpdatesAutomatically: false,
      // 指定是否允许后台定位,
      // 允许的话是可以进行后台定位的，但需要项目配置允许后台定位，否则会报错，具体参考开发文档
      allowsBackgroundLocationUpdates: true,
      // 设定定位的最小更新距离
      distanceFilter: 10,
    );
    return options;
  }

  Future<void> getVersion() async {
    Map<String, dynamic> map = {};
    map['operatingSystem'] = "Android";
    map['version'] = buildNumber.value;
    map['type'] = CommonData.test
        ? (CommonData.personal ? 'testPersonal' : 'testCompany')
        : (CommonData.personal ? 'personal' : 'company');
    var result = await HhHttp()
        .request(RequestUtils.versionNew, method: DioMethod.get, params: map);
    HhLog.d("getVersion -- request ${RequestUtils.versionNew}");
    HhLog.d("getVersion -- map $map");
    HhLog.d("getVersion -- $result");
    if (result["code"] == 0 && result["data"] != null) {
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
      int minSupportedVersion = int.parse(update["minSupportedVersion"]);
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
                                          "${CommonData.endpoint}${update["apkUrl"]}";
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
  void onBMFMapCreated(BMFMapController controller) {
    myMapController = controller;

    /// 地图marker点击回调 (Android端SDK存在bug,现区分两端分别设置)
    myMapController.setMapClickedMarkerCallback(
        callback: (BMFMarker marker) async {
      int currentZoom = await myMapController.getZoomLevel() ?? 13;
      if (Platform.isAndroid) {
        HhLog.d("click Android ${marker.id}");
        for(int i = 0; i < fireMarkerList.length;i++){
          if(fireMarkerList[i].id == marker.id){
            //点击Marker详情
            fireInfo = allFireList[i];
            showFireInfo();
            myMapController.setCenterCoordinate(
              BMFCoordinate(double.parse("${allFireList[i]["latitude"]}"),double.parse("${allFireList[i]["longitude"]}")), false,
            );
            myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
            return;
          }
        }
      }
      if (Platform.isIOS) {
        myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
        for(dynamic modelX in allFireList){
          if(marker.identifier!.contains(modelX["id"])){
            //点击Marker详情
            fireInfo = modelX;
            showFireInfo();
            myMapController.setCenterCoordinate(
              BMFCoordinate(double.parse("${modelX["latitude"]}"),double.parse("${modelX["longitude"]}")), false,
            );
            myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
            break;
          }
        }
      }
    });

    ///地图边界
    // if(areaPointsList!=null && areaPointsList.length!=0){
    //   drawAreaLines();
    // }
  }

  void fireListDialog() {
    showModalBottomSheet(context: context, builder: (a){
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
              child: EasyRefresh(
                onRefresh: (){
                  pageNum = 1;
                  postFire(false);
                },
                onLoad: (){
                  pageNum++;
                  postFire(false);
                },
                controller: easyController,
                child: PagedListView<int, dynamic>(
                  padding: EdgeInsets.zero,
                  pagingController: fireController,
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
                          myMapController.setCenterCoordinate(
                            BMFCoordinate(double.parse("${fireInfo["latitude"]}"),double.parse("${fireInfo["longitude"]}")), false,
                          );
                          int currentZoom = await myMapController.getZoomLevel() ?? 13;
                          myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
                          showFireInfo();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10.w*3,),
                            fireTypeByTime.value?Row(
                              children: [
                                SizedBox(width: 10.w*3,),
                                Icon(Icons.access_time_rounded,color: HhColors.titleColor_55,size: 18.w*3,),
                                SizedBox(width: 3.w*3,),
                                Text('${item["observeTimestr"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
                                SizedBox(width: 10.w*3,),
                              ],
                            ): Row(
                              children: [
                                SizedBox(width: 10.w*3,),
                                Icon(Icons.turned_in_not_rounded,color: HhColors.titleColor_55,size: 18.w*3,),
                                SizedBox(width: 3.w*3,),
                                Text('${item["fireNo"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 13.sp*3),),
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
                            Container(
                              height: 1.w,
                              width: 1.sw,
                              color: HhColors.line25Color,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ));
    },isDismissible: true,enableDrag: false,isScrollControlled: true);
  }

  void showListTypeFilter() {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
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
    showModalBottomSheet(context: context, builder: (a){
      return Container(
        width: 1.sw,
        height: 0.6.sh,
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
                BouncingWidget(
                    duration: const Duration(milliseconds: 100),
                    scaleFactor: 0.6,
                    onPressed: (){
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
                ),
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
                        children: [
                          Text('地址：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["formattedAddress"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
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
                        children: [
                          Text('经纬度：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["latitude"]},${fireInfo["longitude"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('可信度：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["reliability"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10.w*3, 10.w*3, 10.w*3, 0),
                      child: Row(
                        children: [
                          Text('明火面积：',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
                          Text('${fireInfo["hotArea"]}',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3),),
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
                          Expanded(child: Text('林地（${fireInfo["woodland"]}）草地（${fireInfo["grassland"]}）农田（${fireInfo["farmland"]}）其他（${fireInfo["otherType"]}）',style: TextStyle(color: HhColors.blackColor,fontSize: 12.sp*3,),)),
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
                              CommonUtils().showPictureDialog(context,url: "${CommonData.fileStart}${fireInfo["visibleLightImgUrl"]}");
                            },
                            child: Image.network("${CommonData.fileStart}${fireInfo["visibleLightImgUrl"]}",width:160.w*3,height: 100.w*3,fit: BoxFit.fill,errorBuilder: (a,b,c){
                              return Image.asset('assets/images/common/ic_no_pic.png',width:160.w*3,height: 100.w*3,fit: BoxFit.fill,);
                            },),
                          ),
                          SizedBox(width: 20.w*3,),
                          InkWell(
                            onTap: (){
                              CommonUtils().showPictureDialog(context,url: "${CommonData.fileStart}${fireInfo["thermalImagingImgUrl"]}");
                            },
                            child: Image.asset("${CommonData.fileStart}${fireInfo["thermalImagingImgUrl"]}",width:160.w*3,height: 100.w*3,fit: BoxFit.fill,errorBuilder: (a,b,c){
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
    },isDismissible: true,enableDrag: false,isScrollControlled: true);
  }

  Future<void> postFire(bool showList) async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
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
    map['provinceCode'] = '37';
    // map['cityCode'] = '04';
    // map['countyCode'] = '27';
    map['satelliteCodeList'] = satelliteStrList;
    map['landType'] = landTypeStrList;
    map['startTime'] = startTime.value;
    map['endTime'] = endTime.value;
    map['bufferArea'] = otherCache.value?"1":"0";
    map['overseasHeatSources'] = otherOut.value?"1":"0";
    var result = await HhHttp().request(RequestUtils.fireSearch,method: DioMethod.get,params:map);
    HhLog.d("fireSearch -- ${RequestUtils.fireSearch} -- $map ");
    HhLog.d("fireSearch -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if(result["code"]==200){
      newItems = result["rows"];
      fireCount.value = result["total"];
      if (pageNum == 1) {
        fireController.itemList = [];
        allFireList = [];
      }else{
        if(newItems.isEmpty){
          easyController.finishLoad(IndicatorResult.noMore,true);
        }
      }
      allFireList.addAll(newItems);
      fireController.appendLastPage(newItems);
      if(showList){
        fireListDialog();
      }

      initMarker();
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString("${result["msg"]}")));
    }
  }

  ///火警打点
  initMarker() async {
    myMapController.cleanAllMarkers();
    fireMarkerList.clear();
    for(dynamic model in allFireList){
      /// 创建BMFMarker
      BMFMarker marker = BMFMarker.icon(
          position: BMFCoordinate(ParseLocation.gps84_To_bd09(double.parse(model["latitude"]),double.parse(model["longitude"]))[0],ParseLocation.gps84_To_bd09(double.parse(model["latitude"]),double.parse(model["longitude"]))[1]),
          title: '${model["formattedAddress"]}',
          enabled: true,
          visible: true,
          identifier: '${model["id"]}',
          icon: 'assets/images/common/ic_fires_red.png');

      /// 添加Marker
      myMapController.addMarker(marker);
      fireMarkerList.add(marker);
    }
    if(allFireList.isNotEmpty){
      ///跳到第一火点
      myMapController.setCenterCoordinate(
          BMFCoordinate(double.parse(allFireList[0]["latitude"]),double.parse(allFireList[0]["longitude"])), true,animateDurationMs: 200
      );
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

  mapOptions() {
    return BMFMapOptions(
        center: BMFCoordinate(CommonData.latitude ?? 36.30865,
            CommonData.longitude ?? 120.314037),
        zoomLevel: 6,
        showDEMLayer: true,
        //地图是否展示地形图层默认false，since 3.6.0
        overlookEnabled: mapChangeTag.value == 3 ? true : false,
        // 设定地图View能否支持俯仰角
        buildingsEnabled: mapChangeTag.value == 3 ? true : false,
        // 设定地图是否现显示3D楼块效果
        overlooking: mapChangeTag.value == 3 ? -45 : 0,
        // 地图俯视角度，在手机上当前可使用的范围为－45～0度 (ios取int值)
        mapType:
            mapTypeTag.value == 3 ? BMFMapType.Standard : BMFMapType.Satellite,
        mapPadding: BMFEdgeInsets(left: 30.w, top: 0, right: 30.w, bottom: 0));
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
    // HhLog.d("satelliteType -- ${RequestUtils.satelliteType} -- $map ");
    // HhLog.d("satelliteType -- $result");
    if(result["code"]==200){
      List<dynamic> list = result["data"];
      for(dynamic model in list){
        model["choose"] = true;
      }
      satelliteList = list;

      ///2。获取地类列表
      Map<String, dynamic> map2 = {};
      var result2 = await HhHttp().request(RequestUtils.landType,method: DioMethod.get,params:map2);
      // HhLog.d("landType -- ${RequestUtils.landType} -- $map ");
      // HhLog.d("landType -- $result2");
      if(result2["code"]==200){
        List<dynamic> list = result2["data"];
        for(dynamic model in list){
          model["choose"] = true;
        }
        landTypeList = list;

        ///3。获取用户权限映射
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String tenantId = prefs.getString(SPKeys().tenantId)??"000000";
        String userId = prefs.getString(SPKeys().id)??"1";
        dynamic dataS = {
          "tenantId":tenantId,
          "userId":userId
        };
        // HhLog.d("typePermission -- ${RequestUtils.typePermission} -- $dataS ");
        var resultS = await HhHttp().request(RequestUtils.typePermission,method: DioMethod.post,data: dataS);
        // HhLog.d("typePermission -- $resultS");
        if(resultS["code"]==200 && resultS["data"] != null){
          otherOutShow.value = resultS["data"]["overseasHeatSources"] == 1;
          otherCacheShow.value = resultS["data"]["bufferArea"] == 1;
          otherOut.value = resultS["data"]["overseasHeatSources"] == 1;
          otherCache.value = resultS["data"]["bufferArea"] == 1;
          String satelliteCodes = resultS["data"]["satelliteCodes"];
          List<String> satelliteCodeList = satelliteCodes.split(',');
          List<dynamic> array = [];
          for(int i = 0;i < satelliteList.length;i++){
            dynamic model = satelliteList[i];
            if(satelliteCodeList.contains("${model["code"]}")){
              array.add(model);
            }
          }
          satelliteList = [];
          satelliteList.add({
            "name":"全部",
            "code":8888,
            "choose":true,
          });
          satelliteList.addAll(array);
          String landType = resultS["data"]["landType"];
          List<String> landTypeCodeList = landType.split(',');
          List<dynamic> rows = [];
          for(int i = 0;i < landTypeList.length;i++){
            dynamic model = landTypeList[i];
            if(landTypeCodeList.contains("${model["code"]}")){
              rows.add(model);
            }
          }
          landTypeList = [];
          landTypeList.add({
            "name":"全部",
            "code":8888,
            "choose":true,
          });
          landTypeList.addAll(rows);


          ///获取火警数据
          postFire(false);
        }else{
          EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(resultS["msg"])));
        }
      }else{
        EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result2["msg"])));
      }
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }

  }
}
