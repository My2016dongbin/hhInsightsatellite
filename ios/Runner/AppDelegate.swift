import UIKit
import Flutter
import AMapFoundationKit
import AMapLocationKit  // ← 一定要加这一行

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 通知高德 SDK：隐私弹窗已展示 & 用户已同意
//      AMapLocationClient.updatePrivacyShow(true, privacyInfo: true)
      // 2. 通知定位 SDK：用户已经同意隐私协议
//      AMapLocationClient.updatePrivacyAgree(true)

      // 再去设置地图 key
      AMapServices.shared().apiKey = "72e1128c23436206d31ee09897c3dd3c"


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
