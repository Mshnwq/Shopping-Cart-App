import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

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
  late String topic;
  late MqttServerClient client;
  var pongCount = 0; // Pong counter

  MQTTClient({
    required this.brokerUrl,
    required this.clientId,
    // required this.topic,
  }) {
    devtools.log('CONNECTTING');
    client = MqttServerClient(brokerUrl, clientId);
    // client.port = 1883;
    client.logging(on: true);
    client.setProtocolV311();
    client.connectTimeoutPeriod = 2000; // milliseconds
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    client.onDisconnected = () => devtools.log('Disconnected');
    // client.setProtocolV311();
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('will-topic')
        .withWillMessage('Connection closed abnormally')
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    connect();
  }

  void connect() async {
    // devtools.log(client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited);
    try {
      await client.connect();
      devtools.log('CONNECT SUCCESS');
    } catch (e) {
      devtools.log('CONNECT FAILED');
      devtools.log(e.toString());
    }
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }

  Future<void> publish(String message) async {
    // var data = mqtt.MqttClientPayloadBuilder().addByte(1).payload;
    // devtools.log('PUBLISHING to $topic, message $message');
    client.publishMessage('/cart', MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(message).payload!);
    // data!);
  }

  Future<void> subscribe(String topic_s) async {
    // if (connectionState == mqtt.MqttConnectionState.connected) {
    topic = topic_s;
    client.subscribe('/cart', MqttQos.exactlyOnce);
    // devtools.log('SUBSCRIPED to $topic');
    // }
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  Future<void> disconnect() async {
    client.disconnect();
  }
}
