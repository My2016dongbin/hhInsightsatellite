import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingController extends GetxController {
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> voiceStatus = false.obs;
  final Rx<bool> uploadStatus = false.obs;
  late BuildContext context;
  final Rx<bool> satelliteStatus = true.obs;
  final Rx<bool> skyStatus = true.obs;
  final Rx<bool> landStatus = true.obs;
  final Rx<bool> landTypeStatus = true.obs;
  final Rx<bool> warnFilterStatus = true.obs;
  final Rx<double> warnFilterNumber = 1.0.obs;
  late bool warnFilter = false;
  final Rx<bool> fireCountStatus = true.obs;
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
  late List<dynamic> fireCountList = [
    {
      "title":"100",
      "choose":true,
    },
    {
      "title":"500",
      "choose":false,
    },
    {
      "title":"1000",
      "choose":false,
    },
    {
      "title":"2000",
      "choose":false,
    },
    {
      "title":"5000",
      "choose":false,
    }
  ];
  final Rx<bool> otherOut = false.obs;
  final Rx<bool> otherCache = false.obs;
  final Rx<bool> otherOutT = false.obs;
  final Rx<bool> otherCacheT = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    postType();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    voiceStatus.value = prefs.getBool(SPKeys().voice)??false;
    //satellite:fireReport:add火情上报
    //satellite:fireFeedback:add火情反馈
    uploadStatus.value = (prefs.getString(SPKeys().permissions)??"000000").contains("fireReport");
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

  void parseFireCountChoose(int index) {
    ///全部-选中
    for(int i = 0; i < fireCountList.length; i++){
      if(index != i){
        fireCountList[i]['choose'] = false;
      }
    }
    fireCountStatus.value = false;
    fireCountStatus.value = true;
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
        HhLog.d("typePermission -- ${RequestUtils.satelliteTypeTenant} -- $dataT ");
        var resultT = await HhHttp().request(RequestUtils.satelliteTypeTenant,method: DioMethod.post,data: dataT);
        HhLog.d("typePermission -- $resultT");
        otherOutT.value = resultT["data"]["overseasHeatSources"] == 1;
        otherCacheT.value = resultT["data"]["bufferArea"] == 1;
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
            // String satelliteCodes = resultS["data"]["satelliteSeriesList"];
            // List<String> satelliteCodeList = satelliteCodes.split(',');
            List<dynamic> satelliteCodeList = resultS["data"]["satelliteSeriesList"];
            List<dynamic> array = [];
            int arrayCount = 0;
            for(int i = 0;i < satelliteList.length;i++){
              dynamic model = satelliteList[i];
              if(satelliteCodeList.contains("${model["code"]}")){
                model["choose"] = true;
                arrayCount++;
              }else{
                model["choose"] = false;
              }
            }
            array.add({
              "name":"全部",
              "code":8888,
              "choose":arrayCount==satelliteList.length,
            });
            array.addAll(satelliteList);
            satelliteList = array;
            String landType = resultS["data"]["landType"];
            List<String> landTypeCodeList = landType.split(',');
            List<dynamic> rows = [];
            int rowsCount = 0;
            for(int i = 0;i < landTypeList.length;i++){
              dynamic model = landTypeList[i];
              //土地类型数值初始化
              if("${model["code"]}"=="woodland"){
                model["number"] = resultS["data"]["woodlandNumerical"]*1.0;
              }
              if("${model["code"]}"=="grassland"){
                model["number"] = resultS["data"]["grasslandNumerical"]*1.0;
              }
              if("${model["code"]}"=="farmland"){
                model["number"] = resultS["data"]["farmlandNumerical"]*1.0;
              }
              if("${model["code"]}"=="otherType"){
                model["number"] = resultS["data"]["otherTypeNumerical"]*1.0;
              }
              //筛选选中状态
              if(landTypeCodeList.contains("${model["code"]}")){
                model["choose"] = true;
                rowsCount++;
              }else{
                model["choose"] = false;
              }
            }
            warnFilter = "${resultS["data"]["alarmTimeFilter"]}"=="1";
            warnFilterNumber.value = resultS["data"]["alarmTimeFilterNumerical"]==0?1.0:resultS["data"]["alarmTimeFilterNumerical"]*1.0;
            rows.add({
              "name":"全部",
              "code":8888,
              "choose":rowsCount==landTypeList.length,
            });
            rows.addAll(landTypeList);
            landTypeList = rows;

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

  Future<void> editPermission() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String tenantId = prefs.getString(SPKeys().tenantId)??"000000";
    String userId = prefs.getString(SPKeys().id)??"1";
    List<String> listSatelliteStr = [];
    for(dynamic model in satelliteList){
      if("${model['code']}" != "8888" && model["choose"] == true){
        listSatelliteStr.add("${model["code"]}");
      }
    }
    List<dynamic> listLandTypeStr = [];
    double woodlandNumerical = 0;
    double grasslandNumerical = 0;
    double farmlandNumerical = 0;
    double otherTypeNumerical = 0;
    for(dynamic model in landTypeList){
      //类型选中状态
      if("${model['code']}" != "8888" && model["choose"] == true){
        listLandTypeStr.add("${model["code"]}");
      }
      //类型数值修改
      if("${model["code"]}"=="woodland"){
        woodlandNumerical = model["number"];
      }
      if("${model["code"]}"=="grassland"){
        grasslandNumerical = model["number"];
      }
      if("${model["code"]}"=="farmland"){
        farmlandNumerical = model["number"];
      }
      if("${model["code"]}"=="otherType"){
        otherTypeNumerical = model["number"];
      }
    }
    if(listSatelliteStr.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: "请至少选择一个卫星监测"));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      return;
    }
    if(listLandTypeStr.isEmpty){
      EventBusUtil.getInstance().fire(HhToast(title: "请至少选择一个地貌类型"));
      EventBusUtil.getInstance().fire(HhLoading(show: false));
      return;
    }
    dynamic data = {
      "tenantId": tenantId,
      "userId":userId,
      "satelliteSeriesList":listSatelliteStr,
      "landTypeList":listLandTypeStr,
      "overseasHeatSources": otherOut.value?"1":"0",
      "bufferArea": otherCache.value?"1":"0",
      "woodlandNumerical":woodlandNumerical,
      "grasslandNumerical":grasslandNumerical,
      "farmlandNumerical":farmlandNumerical,
      "otherTypeNumerical":otherTypeNumerical,
      "alarmTimeFilter":warnFilter?1:0,
      "alarmTimeFilterNumerical":warnFilterNumber.value,
    };
    var result = await HhHttp().request(RequestUtils.typePermissionEdit,method: DioMethod.post,data: data);
    HhLog.d("typePermissionEdit -- ${RequestUtils.typePermissionEdit} $data");
    HhLog.d("typePermissionEdit -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if(result["code"]==200){
      EventBusUtil.getInstance().fire(HhToast(title: '已保存',type: 0));
      EventBusUtil.getInstance().fire(SatelliteConfig());
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }

}
