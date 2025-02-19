import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhHttp.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/RequestUtils.dart';

class SearchedController extends GetxController {
  final index = 0.obs;
  final Rx<bool> testStatus = true.obs;
  final Rx<bool> listStatus = true.obs;
  late BuildContext context;
  late List<dynamic> messageList = [];
  late List<dynamic> deviceList = [];
  late List<dynamic> spaceList = [];
  TextEditingController ?searchController = TextEditingController();

  @override
  void onInit() {

    super.onInit();
  }


  Future<void> mainSearch() async {
    EventBusUtil.getInstance().fire(HhLoading(show: true,title: '加载中..'));
    Map<String, dynamic> map = {};
    map['keyWord'] = searchController!.text;
    var result = await HhHttp().request(RequestUtils.mainSearch,method: DioMethod.get,params: map);
    HhLog.d("mainSearch -- $result");
    EventBusUtil.getInstance().fire(HhLoading(show: false));
    if(result["code"]==0 && result["data"]!=null){
      messageList = result["data"]["message"];
      deviceList = result["data"]["device"];
      spaceList = result["data"]["space"];
      HhLog.d('message ${result["data"]["message"]}');
      HhLog.d('device ${result["data"]["device"]}');
      HhLog.d('space ${result["data"]["space"]}');
      listStatus.value = false;
      listStatus.value = true;
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  }
}
