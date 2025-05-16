class RegexUtils {
  /// 校验中国大陆手机号（支持13x、14x、15x、16x、17x、18x、19x号段）
  static bool isMobile(String input) {
    final RegExp mobile = RegExp(r'^1[3-9]\d{9}$');
    return mobile.hasMatch(input);
  }
}
