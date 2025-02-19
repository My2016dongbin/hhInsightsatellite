import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class CommonData{
  static int time = 0;
  static double ?latitude;
  static double ?longitude;
  static String ?token;
  ///false企业 true个人
  static bool personal = true;
  ///false正式版 true测试版
  static bool test = false;
  static String ?tenantName = personal?'haohai':null;
  static String ?tenant = personal?'1':null;
  static String ?tenantTitle = '';
  static String ?tenantUserType;
  static String ?tenantNameDef = personal?'haohai':null;
  static String ?tenantDef = personal?'1':null;
  static String ?deviceNo;
  static String ?sessionId;
  static String ?endpoint;
  static String info = "";
  static int versionTime = 0;
  static BuildContext? context;
}