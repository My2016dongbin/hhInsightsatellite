import 'dart:io';

import 'package:flutter/cupertino.dart';

//去除滑动控件滑动意图效果
class HhBehavior  extends ScrollBehavior{
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if(Platform.isAndroid||Platform.isFuchsia){
      return child;
    }else{
      // return super.buildViewportChrome(context,child,axisDirection);
      return Container();
    }
  }
}