import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as devtools;
import 'env.dart' as env;

class MQTTClient {
  // class variables
  final String brokerUrl;
  final String clientId;
  final String topic;
  late MqttServerClient client;
  var pongCount = 0; // Pong counter
  late mqtt.MqttConnectionState connectionState;

  MQTTClient({
    required this.brokerUrl,
    required this.clientId,
    required this.topic,
  }) {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    // devtools.log('Client $clientId');
    client = MqttServerClient(brokerUrl, clientId);

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    client.keepAlivePeriod = 20;

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds
    client.autoReconnect = true;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    client.onSubscribed = onSubscribed;

    // client. = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received from the broker.
    client.pongCallback = pong;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.

    final connMessage = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('will-topic')
        .withWillMessage('Connection closed abnormally')
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    devtools.log('Mosquitto client connecting....');
    connect();
  }

  void connect() async {
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
      devtools.log('CONNECT SUCCESS');
      connectionState = client.connectionStatus!.state;
      subscribe();
    } on mqtt.NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      devtools.log('client exception');
      devtools.log(e.toString());
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      devtools.log('Socket exception');
      devtools.log(e.toString());
      client.disconnect();
    } catch (e) {
      devtools.log('CONNECT FAILED');
      devtools.log(e.toString());
      client.disconnect();
    }
  }

  Future<void> publish(String message) async {
    // devtools.log('PUBLISHING to $topic, message $message');
    // devtools.log('PUBLISHING to $topic, message $message');
    int id = client.publishMessage(topic, mqtt.MqttQos.atLeastOnce,
        mqtt.MqttClientPayloadBuilder().addString(message).payload!);
    devtools.log('it got id $id');
  }

  // void listen() {
  //   client.updates!
  //       .listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages) {
  //     messages.forEach((message) {
  //       var message;
  //       final payload = mqtt.MqttPublishPayload.bytesToStringAsString(
  //           message.payload.message);
  //       // final topic = message.topic;
  //       devtools.log('Received message: $payload from topic: $topic');
  //       // handle the received message here
  //     });
  //   });
  // }

  // void onMessage(List<mqtt.MqttReceivedMessage> event) {
  //   devtools.log('Received message: from topic: $topic');
  //   client.updates!
  //       .listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages) {
  //     final mqtt.MqttPublishMessage recMess =
  //         messages[0].payload as mqtt.MqttPublishMessage;
  //     final message = mqtt.MqttPublishPayload.bytesToStringAsString(
  //         recMess.payload.message);
  //     devtools.log('Received message: $message from topic: $topic');
  //   });
  // }

  // void setupUpdatesListener() {
  //   client
  //       .getMessagesStream()!
  //       .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final recMess = c![0].payload as MqttPublishMessage;
  //     final pt =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //     print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
  //   });
  // }

  // Stream<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>>>?
  //     getMessagesStream() {
  //   devtools.log('Received message: from topic: ${client.updates}');
  //   return client.updates;
  // }

  Future<void> subscribe() async {
    // if (connectionState == mqtt.MqttConnectionState.connected) {
    // topic = '/cart/$_topic';
    // devtools.log('SUBSCRIPED to $topic');
    client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
    devtools.log('SUBSCRIPED to $topic');
    // }
    // devtools.log('NOT SUBSCRIPED to $topic');
    /// Subscribe to the topic of interest
    client.updates!
        .listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> c) {
      final mqtt.MqttPublishMessage recMess =
          c[0].payload as mqtt.MqttPublishMessage;
      final String pt = mqtt.MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message);
      devtools.log(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    });
  }

  /// #CALLBACK FUNCTIONS# ///

  /// The subscribed callback
  void onSubscribed(String topic) {
    devtools.log('Subscription confirmed for topic $topic');
  }

  /// The successful connect callback
  void onConnected() {
    devtools
        .log('OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    devtools.log('Ping response client callback invoked');
    pongCount++;
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    devtools.log('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        mqtt.MqttDisconnectionOrigin.solicited) {
      devtools.log('OnDisconnected callback is solicited, this is correct');
    }
    if (pongCount == 3) {
      devtools.log('Pong count is correct');
    } else {
      devtools.log('Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  /// The unsolicited disconnect callback
  Future<void> disconnect() async {
    client.disconnect();
  }
}
