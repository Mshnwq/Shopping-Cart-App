import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools;
import '../services/env.dart' as env;

final mqttProvider = ChangeNotifierProvider.autoDispose((ref) => MQTT());

class MQTT extends ChangeNotifier {
  // class variables
  final String _brokerUrl = env.brokerURL;
  late String _clientId;
  late String _topic;
  late MqttServerClient _client;
  int _pongCount = 0; // Pong counter
  late mqtt.MqttConnectionState _connectionState;

  late StreamController<String> _messageController;
  Stream<String> get onMessage => _messageController.stream;

  String get clientId => _clientId;
  String get topic => _topic;

  Future<bool> establish(
    String clientId,
    String topic,
  ) async {
    _clientId = 'user-$clientId';
    _topic = '/cart/$topic';

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
    _client = MqttServerClient(_brokerUrl, _clientId);

    /// Set logging on if needed, defaults to off
    _client.logging(on: false);

    /// Set the correct MQTT protocol for mosquito
    _client.setProtocolV311();

    /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
    _client.keepAlivePeriod = 20;

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    _client.connectTimeoutPeriod = 2000; // milliseconds
    _client.autoReconnect = true;

    /// Add the unsolicited disconnection callback
    _client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    _client.onConnected = onConnected;

    /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
    /// You can add these before connection or change them dynamically after connection if
    /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
    /// can fail either because you have tried to subscribe to an invalid topic or the broker
    /// rejects the subscribe request.
    _client.onSubscribed = onSubscribed;

    /// Set a ping received callback if needed, called whenever a ping response(pong) is received from the broker.
    _client.pongCallback = pong;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.

    final connMessage = mqtt.MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .withWillTopic('will-topic')
        .withWillMessage('Connection closed abnormally')
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    _client.connectionMessage = connMessage;
    devtools.log('Mosquitto client connecting....');

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await _client.connect();
      devtools.log('CONNECT SUCCESS');
      _connectionState = _client.connectionStatus!.state;
      await subscribe();
      // create message stream controller
      _messageController = StreamController<String>.broadcast();
      return true;
    } on mqtt.NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      devtools.log('client exception');
      devtools.log(e.toString());
      await disconnect();
      return false;
    } on SocketException catch (e) {
      // Raised by the socket layer
      devtools.log('Socket exception');
      devtools.log(e.toString());
      await disconnect();
      return false;
    } catch (e) {
      devtools.log('CONNECT FAILED');
      devtools.log(e.toString());
      await disconnect();
      return false;
    }
  }

  /// The unsolicited disconnect callback
  Future<void> disconnect() async {
    if (_connectionState == mqtt.MqttConnectionState.connected) {
      _client.disconnect();
      _messageController.close();
    } else {
      devtools.log('Already disconnected');
    }
  }

  /// The unsolicited disconnect callback
  Future<void> publish(String message) async {
    // devtools.log('PUBLISHING $message');
    int id = _client.publishMessage(_topic, mqtt.MqttQos.atLeastOnce,
        mqtt.MqttClientPayloadBuilder().addString(message).payload!);
    // devtools.log('it got id $id');
  }

  /// Subscribe to the topic of interest
  Future<void> subscribe() async {
    if (_connectionState == mqtt.MqttConnectionState.connected) {
      _client.subscribe(_topic, mqtt.MqttQos.exactlyOnce);
      // devtools.log('SUBSCRIPED to $_topic');

      /// listen to subscribed topic
      _client.updates!
          .listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages) {
        final mqtt.MqttPublishMessage recMess =
            messages[0].payload as mqtt.MqttPublishMessage;
        final String payload = mqtt.MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message);

        // devtools.log('topic is <${messages[0].topic}>, payload is <$payload>');
        try {
          // devtools.log('DECODING RESPONSE');
          var res = jsonDecode(payload);
          if (res['mqtt_type'] == "response_add_item") {
            // add message to stream
            // devtools.log('ADDING TO STREAM');
            _messageController.add(payload);
          } else {
            devtools.log('');
            // devtools.log("NOT FOR US");
          }
        } on FormatException catch (e) {
          devtools.log('');
        } catch (e) {
          devtools.log(e.toString());
        }
      });
    } else {
      devtools.log('NOT SUBSCRIBED to $_topic');
    }
  }

  /// #CALLBACK FUNCTIONS# ///

  /// The subscribed callback
  void onSubscribed(String topic) {
    devtools.log('Subscription confirmed for topic $topic');
  }

  /// The successful connect callback
  void onConnected() {
    devtools.log('Client connection was sucessful callback');
  }

  /// Pong callback
  void pong() {
    devtools.log('Ping response client callback invoked');
    _pongCount++;
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    devtools.log('Client disconnection callback');
    if (_client.connectionStatus!.disconnectionOrigin ==
        mqtt.MqttDisconnectionOrigin.solicited) {
      devtools.log('solicited, this is correct');
    }
    if (_pongCount == 3) {
      devtools.log('Pong count is correct');
    } else {
      devtools.log('Pong count is incorrect, expected 3. actual $_pongCount');
    }
  }

  @override
  void dispose() {
    devtools.log('Disconnecting MQTT');
    super.dispose();
  }
}
