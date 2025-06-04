
class RequestUtils{
  // static const base = 'http://192.168.1.88:51158';//app
  // static const base = 'http://192.168.1.88:9528/api';//web
  // static const base = 'http://192.168.1.88:8011/api';//out
  // static const base = 'http://192.168.1.102:9900';//release
  static const base = 'http://wechattestfront.ehaohai.com/api';//域名外网

  static const login = '$base/auth/login';//密码登录-
  static const userInfo = '$base/system/user/getInfo/app';//个人信息查询-
  // static const userInfo = '$base/system/user/getInfo';//web个人信息查询-
  static const userDays = '$base/system/user/checkStatus';//个人期限查询-
  static const fireSearch = '$base/haohai-satellite/SatelliteFireAlarm/page';//火警分页查询-
  static const fireSearchInfo = '$base/haohai-satellite/SatelliteFireAlarm/getById';//火警详情查询-
  static const satelliteType = '$base/system/satelliteConfig/satelliteSeriesList';//'$base/system/satelliteConfig/satelliteCodeList';//卫星类型查询-
  static const satelliteTypeTenant = '$base/system/satelliteConfig/permissionSelectTenantId';//卫星类型查询-租户内类型查询-
  static const landType = '$base/system/satelliteConfig/landTypeList';//地址类型查询-
  static const bridge = '$base/system/areaPolygon/queryUserAreaList';//'$base/satellite/areaPolygon/queryUserAreaList';//获取区域边界-
  static const bridgeBuffer = '$base/system/areaPolygon/queryUserAreaBufferList';//'$base/satellite/areaPolygon/queryUserAreaList';//获取区域边界-
  static const typePermission = '$base/system/satelliteConfig/permissionSelectUserId';//'$base/system/satelliteConfig/permissionSelect';//用户查询各类型权限-
  static const typePermissionEdit = '$base/system/satelliteConfig/permissionEditUserId';//'$base/system/satelliteConfig/permissionEdit';//用户修改各类型权限-
  static const fileUpload = '$base/resource/oss/upload';//文件上传-
  static const fireFeedback = '$base/satellite/fireFeedback';//火警反馈-
  static const fireReport = '$base/satellite/fireReport';//火警上报-
  static const gridSearchAll = '$base/satellite/fireReport/getListForManage';//'$base/system/area/listAll';//省市区查询-全部
  static const gridSearch = '$base/system/area/userList';//'$base/system/area/listAll';//省市区查询-用户权限
  static const logout = '$base/admin-api/system/auth/logout';//登出
  static const versionNew = '$base/system/androidUpgrade/getAndroidUpgradeVersionNew';//查询版本新版-

  static const sendCode = '$base/resource/sms/code';//发送验证码-


  static const codeSend = '$base/codeSend';//发短信
  static const putBackPassword = '$base/putBackPassword';//修改密码提交
  static const codeRegisterSend = '$base/codeRegisterSend';//注册验证码
  static const codeRegister = '$base/codeRegister';//注册
  static const codeCheckCommon = '$base/codeCheckCommon';//校验验证码
  static const codeLogin = '$base/codeLogin';//验证码登录
  static const userEdit = '$base/userEdit';//修改用户信息
  /*
    Map<String, dynamic> map = {};
    map['pageNo'] = '$pageKey';
    var result = await HhHttp().request(RequestUtils.unReadCount,method: DioMethod.get,params:map);
    HhLog.d("getUnRead -- $result");
    if(result["code"]==0 && result["data"]!=null){
      count.value = '${result["data"]}';
    }else{
      EventBusUtil.getInstance().fire(HhToast(title: CommonUtils().msgString(result["msg"])));
    }
  */
}