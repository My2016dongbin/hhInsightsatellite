
class RequestUtils{
  static const base = 'http://192.168.1.10:9900';//debug 外网
  // static const base = 'http://192.168.1.165:10003/insightsatellite-api';//debug 内网

  static const login = '$base/auth/login';//密码登录-
  static const fireSearch = '$base/haohai-satellite/SatelliteFireAlarm/page';//火警分页查询-
  static const satelliteType = '$base/system/satelliteConfig/satelliteCodeList';//卫星类型查询-
  static const landType = '$base/system/satelliteConfig/landTypeList';//地址类型查询-
  static const typePermission = '$base/system/satelliteConfig/permissionSelect';//用户查询各类型权限-
  static const logout = '$base/admin-api/system/auth/logout';//登出
  static const userInfo = '$base/Account/GetUserMsg';//个人信息查询
  static const versionNew = '$base/admin-api/system/android-upgrade/getAndroidUpgradeVersionNew';//查询版本新版


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