import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/home/space/manage/edit/edit_controller.dart';
import 'package:insightsatellite/utils/CommonUtils.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhColors.dart';

class EditPage extends StatelessWidget {
  final logic = Get.find<EditController>();

  EditPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    // 在这里设置状态栏字体为深色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarBrightness: Brightness.dark, // 状态栏字体亮度
      statusBarIconBrightness: Brightness.dark, // 状态栏图标亮度
    ));
    return Scaffold(
      backgroundColor: HhColors.backColor,
      body: Obx(
        () => Container(
          height: 1.sh,
          width: 1.sw,
          padding: EdgeInsets.zero,
          child: logic.testStatus.value ? loginView() : const SizedBox(),
        ),
      ),
    );
  }

  loginView() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          ///title
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 54.w * 3),
              color: HhColors.trans,
              child: Text(
                '修改空间',
                style: TextStyle(
                    color: HhColors.blackTextColor,
                    fontSize: 18.sp * 3,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(23.w * 3, 59.h * 3, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 10.w, 20.w, 10.w),
              color: HhColors.trans,
              child: Image.asset(
                "assets/images/common/back.png",
                height: 17.w*3,
                width: 10.w*3,
                fit: BoxFit.fill,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.fromLTRB(14.w*3, 108.w*3, 14.w*3, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///修改内容
                Container(
                  decoration: BoxDecoration(
                      color: HhColors.grayE8BackColor,
                      borderRadius: BorderRadius.circular(8.w*3)
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 18.w*3,),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          maxLength: 10,
                          cursorColor: HhColors.titleColor_99,
                          controller: logic.accountController,
                          keyboardType: logic.pageStatus.value
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            counterText: '',
                            hintText: '请输入新的空间名称',
                            hintStyle: TextStyle(
                                color: HhColors.grayCCTextColor,
                                fontSize: 16.sp*3,
                                fontWeight: FontWeight.w200),
                          ),
                          style: TextStyle(
                              color: HhColors.textBlackColor,
                              fontSize: 16.sp*3,
                              fontWeight: FontWeight.bold),
                          onChanged: (s) {
                            logic.accountStatus.value = s.isNotEmpty;
                          },
                        ),
                      ),
                      logic.accountStatus.value
                          ? BouncingWidget(
                              duration: const Duration(milliseconds: 100),
                              scaleFactor: 1.2,
                              onPressed: () {
                                logic.accountController!.clear();
                                logic.accountStatus.value = false;
                              },
                              child: Container(
                                  padding: EdgeInsets.all(5.w),
                                  child: Image.asset(
                                    'assets/images/common/ic_close.png',
                                    height: 16.w * 3,
                                    width: 16.w * 3,
                                    fit: BoxFit.fill,
                                  )),
                            )
                          : const SizedBox(),
                      SizedBox(
                        width: 16.w * 3,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: HhColors.grayCCTextColor,
                  height: 0.5.w,
                ),
                SizedBox(
                  height: 26.w,
                ),

                ///保存
                BouncingWidget(
                  duration: const Duration(milliseconds: 100),
                  scaleFactor: 1.2,
                  onPressed: () {
                    //隐藏输入法
                    FocusScope.of(logic.context).requestFocus(FocusNode());
                    if (logic.accountController!.text.isEmpty) {
                      EventBusUtil.getInstance()
                          .fire(HhToast(title: '请输入修改内容'));
                      return;
                    }
                    if (!CommonUtils()
                        .validateSpaceName(logic.accountController!.text)) {
                      EventBusUtil.getInstance()
                          .fire(HhToast(title: '空间名称不能包含特殊字符'));
                      return;
                    }
                    Future.delayed(const Duration(milliseconds: 500), () {
                      logic.userEdit();
                    });
                  },
                  child: Container(
                    width: 1.sw,
                    height: 45.w * 3,
                    margin: EdgeInsets.fromLTRB(0, 32.w, 0, 50.w),
                    decoration: BoxDecoration(
                        color: HhColors.mainBlueColor,
                        borderRadius: BorderRadius.all(Radius.circular(16.w))),
                    child: Center(
                      child: Text(
                        "保存",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: HhColors.whiteColor,
                            fontSize: 16.sp * 3,
                            fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
