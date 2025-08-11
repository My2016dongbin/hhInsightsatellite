package com.ehaohai.insightsatellite;

import android.os.Bundle;
import com.amap.api.location.AMapLocationClient;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // ——— 隐私合规：弹窗已展示 & 用户已同意
        // 第一个参数：this（Activity）；第二个参数 true = 已经展示过隐私弹窗；第三个参数 true = 用户已同意
        AMapLocationClient.updatePrivacyShow(this, true, true);
        // 用户同意隐私协议
        AMapLocationClient.updatePrivacyAgree(this,true);
    }
}
