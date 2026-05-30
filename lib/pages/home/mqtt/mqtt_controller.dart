import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:insightsatellite/bus/bus_bean.dart';
import 'package:insightsatellite/pages/common/common_data.dart';
import 'package:insightsatellite/utils/EventBusUtils.dart';
import 'package:insightsatellite/utils/HhLog.dart';
import 'package:insightsatellite/utils/SPKeys.dart';
import 'package:insightsatellite/widgets/top_alarm_notification.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttController extends GetxController {
  final Rx<bool> test = true.obs;
  late BuildContext context;
  late MqttServerClient client;
  late String id;
  late String clientId;

  @override
  void onClose() {
    try {
      client.disconnect();
    } catch (_) {
      //
    }
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString(SPKeys().id) ?? '';
    if (id.isEmpty) {
      HhLog.d('mqtt_page user id is empty, skip mqtt init');
      return;
    }
    initMqtt();
  }

  Future<void> initMqtt() async {
    clientId = getRandomId();
    final Uri mqttUri = _parseMqttUri(CommonData.mqttIP);
    final int mqttPort = _parseMqttPort(mqttUri);

    client =
        MqttServerClient(mqttUri.toString(), 'flutter_mqtt-client-$clientId');
    client.port = mqttPort;
    client.useWebSocket = true;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.autoReconnect = true;
    client.setProtocolV311();

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(CommonData.mqttAccount, CommonData.mqttPassword)
        .withWillTopic('${CommonData.alarmTopic}$id')
        .withWillMessage('Disconnected')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      HhLog.d(
          'mqtt_page Connecting... url=${mqttUri.toString()} port=$mqttPort clientId=$clientId');
      await client.connect();
    } on Exception catch (e) {
      HhLog.d('mqtt_page Connection failed: $e   $clientId');
      client.disconnect();
      return;
    }

    client.subscribe('${CommonData.alarmTopic}$id', MqttQos.atLeastOnce);
    // client.subscribe('${CommonData.alarmTopic}310953824250630276', MqttQos.atLeastOnce);

    client.updates
        ?.listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      try {
        final recMessage = messages[0].payload as MqttPublishMessage;
        final payload = utf8.decode(
          recMessage.payload.message,
          allowMalformed: true,
        );
        HhLog.d(
          'mqtt_page Received message: $payload from topic: ${messages[0].topic}   $clientId',
        );

        if (messages[0].topic.contains(CommonData.alarmTopic)) {
          final dynamic model = jsonDecode(payload);
          EventBusUtil.getInstance().fire(Message());
          await _playAlarmAudioIfNeeded();
          _showAlarmNotification(model);
        }
      } catch (e) {
        HhLog.e("mqtt_listen_error ${e.toString()}");
      }
    });
  }

  void onConnected() {
    HhLog.d('mqtt_page Connected successfully $clientId');
  }

  void onDisconnected() {
    HhLog.d('mqtt_page Disconnected $clientId');
  }

  void onSubscribed(String topic) {
    HhLog.d('mqtt_page Subscribed to topic: $topic   $clientId');
  }

  String getRandomId() {
    final Random random = Random();
    return "${random.nextInt(999999)}";
  }

  Uri _parseMqttUri(String url) {
    final Uri uri = Uri.parse(url);
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw ArgumentError('MQTT websocket url must start with ws:// or wss://');
    }
    return uri;
  }

  int _parseMqttPort(Uri uri) {
    if (uri.hasPort) {
      return uri.port;
    }
    if (CommonData.mqttPORT > 0) {
      return CommonData.mqttPORT;
    }
    return uri.scheme == 'wss' ? 443 : 80;
  }

  Future<void> _playAlarmAudioIfNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool voice = prefs.getBool(SPKeys().voice) ?? false;
    if (voice) {
      final AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(AssetSource('audio/common/find_fire.mp3'));
    }
  }

  void _showAlarmNotification(dynamic model) {
    final TopAlarmNotificationService service =
        Get.isRegistered<TopAlarmNotificationService>()
            ? Get.find<TopAlarmNotificationService>()
            : Get.put(TopAlarmNotificationService(), permanent: true);

    final String alarmId = "${model["linkId"] ?? model["id"] ?? ''}".trim();
    final String timeText = _parseAlarmTime(model);
    final String content = _parseAlarmContent(model);
    final String dedupeKey = _parseDedupeKey(model, content, timeText);

    service.showNotification(
      TopAlarmNotificationData(
        title: '卫星报警',
        timeText: timeText,
        message: content,
        dedupeKey: dedupeKey,
        onTap: () {
          if (alarmId.isNotEmpty) {
            EventBusUtil.getInstance().fire(MessageClick(id: alarmId));
          }
        },
      ),
    );
  }

  String _parseAlarmTime(dynamic model) {
    String timeText = "${model["time"]}";
    return timeText;
  }

  String _parseAlarmContent(dynamic model) {
    final String content = "${model["formattedAddress"] ?? ''}发现火警".trim();
    if (content.isNotEmpty && content != 'null') {
      return content;
    }
    return '收到新的火情预警';
  }

  String _parseDedupeKey(dynamic model, String content, String timeText) {
    final String alarmId = "${model["id"] ?? ''}".trim();
    return "alarm_$alarmId";
  }
}
