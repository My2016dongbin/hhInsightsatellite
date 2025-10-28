class HhToast{
  String title;
  int ?type;//1 success 2 error 3 warn
  int ?color;//0 white

  HhToast({required this.title,this.type,this.color});
}
class HhLoading{
  bool show;
  String ?title;

  HhLoading({required this.show,this.title});
}
class LocResult{
  String title;
  String detail;
  double lat;
  double lng;
  String province;
  String city;
  String district;

  LocResult(this.title,this.detail,this.lat,this.lng,this.province,this.city,this.district);
}
class LocText{
  String ?text;

  LocText({required this.text});
}
class CatchRefresh{
  CatchRefresh();
}
class Version{
  Version();
}
class DownProgress{
  int progress;
  DownProgress({required this.progress});
}
class SpaceList{
  SpaceList();
}
class DeviceList{
  DeviceList();
}
class UserInfo{
  UserInfo();
}
class Message{
  Message();
}
class MessageClick{
  String id;
  MessageClick({required this.id,});
}
class Move{
  int action;
  String code;
  Move({required this.action,required this.code,});
}
class Scale{
  double scale;
  double dx;
  double dy;
  Scale({required this.scale,required this.dx,required this.dy});
}
class DeviceInfo{
  DeviceInfo();
}
class Record{
  Record();
}
class SatelliteConfig{
  SatelliteConfig();
}
class Share{
  dynamic model;
  Share({required this.model});
}