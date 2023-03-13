import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as devtools;
import 'env.dart' as env;

// final mqttProvider = ChangeNotifierProvider.autoDispose((ref) => MQTT());

class MQTTClient {
  final String brokerUrl;
  final String clientId;
  final String topic;
  late mqtt.MqttClient client;

  MQTTClient({
    required this.brokerUrl,
    required this.clientId,
    required this.topic,
  }) {
    client = mqtt.MqttClient(brokerUrl, clientId);
    client.logging(on: true);
    client.onDisconnected = () => devtools.log('Disconnected');
    final connMessage = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('will-topic')
        .withWillMessage('Connection closed abnormally')
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    client.connect();
  }

  Future<void> publish(String message) async {
    // var data = mqtt.MqttClientPayloadBuilder().addByte(1).payload;
    client.publishMessage(topic, mqtt.MqttQos.atLeastOnce,
        mqtt.MqttClientPayloadBuilder().addString(message).payload!);
    // data!);
  }

  Future<void> subscribe() async {
    client.subscribe(topic, mqtt.MqttQos.atMostOnce);
  }

  Future<void> disconnect() async {
    client.disconnect();
  }
}
