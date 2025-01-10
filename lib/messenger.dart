
import 'dart:collection';

import 'package:bytebeam_flutter_sdk/lib.dart';
import 'package:mqtt_client/mqtt_client.dart';

extension Messenger on BytebeamClient {
  void sendMessage(BytebeamPayload payload) {
    messagesQueue.addLast(payload);
  }

  Future<void> messengerTask() async {
    while (!disconnected) {
      var payload = messagesQueue.firstOrNull;
      if (payload == null) {
        await MqttUtilities.asyncSleep(1);
      } else {
        var mqttMessage = MqttClientPayloadBuilder();
        var message = payload.asMqttPayload();
        String topic;
        if (payload.stream == "action_status") {
          topic = "/tenants/${credentials.project}/devices/${credentials.deviceId}/action/status";
        } else {
          topic = "/tenants/${credentials.project}/devices/${credentials.deviceId}/events/${payload.stream}/jsonarray";
        }
        mqttMessage.addString(message);
        mqttClient.publishMessage(topic, MqttQos.atLeastOnce, mqttMessage.payload!);
        messagesQueue.removeFirst();
      }
    }
  }
}