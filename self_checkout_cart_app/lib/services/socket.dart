import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as devtools show log;
import 'env.dart' as env;

// final socketProvider = ChangeNotifierProvider((ref) => SocketClient());

// class SocketClient with ChangeNotifier {
class SocketClient {
  // static SocketClient _instance;
  late final WebSocketChannel _channel;
  bool _isConnected = false;
  final _reconnectIntervalMs = 5000;
  int _reconnectCount = 120;
  final _sendBuffer = Queue();
  // Timer heartBeatTimer, _reconnectTimer;

  // static SocketClient getInstance() {
  // if (_instance == null) {
  // _instance = SocketClient();
  // }
  // return _instance;
  // }
  // SocketClient() {
  //   establishWebSocket();
  // }

  establishWebSocket() {
    // SocketClient() {
    if (!_isConnected) {
      final uri = Uri.parse(env.sock);
      devtools.log("Constructing, WebSocket!");
      _channel = WebSocketChannel.connect(uri);
      // _reconnectCount = 120; // restart count
      // _reconnectTimer.cancel();
      devtools.log("Hello, WebSocket!");
      _channel.sink.add("Hello, WebSocket!");
      _isConnected = true;
      while (_sendBuffer.isNotEmpty) {
        String text = _sendBuffer.first;
        _sendBuffer.remove(text);
        pushSocket(text);
      }
      _listenToMessage();
    } else {
      devtools.log("Already connected, WebSocket!");
      // disconnectSocket();
      // _reconnectSocket();
    }
    // }).onError((error, stackTrace) {
    // });
    // }
  }
  // _channel = WebSocketChannel.connect(uri);

  //   _channel.stream.listen(
  //     (dynamic message) {
  //       devtools.log('message $message');
  //     },
  //     onDone: () {
  //       devtools.log('ws channel closed');
  //     },
  //     onError: (error, stackTrace) {
  //       devtools.log('ws error $error');
  //       devtools.log('ws trace $stackTrace');
  //       // disconnect();
  //       // _reconnect();
  //     },
  //   );

  //   _channel.sink.add("Hello, WebSocket!");
  // }
  // }

  // static SocketClient getInstance() {
  //   if (_instance == null) {
  //     _instance = SocketClient();
  //   }
  //   return _instance;
  // }

  // void _reconnectSocket() async {
  //   if (_reconnectCount > 0) {
  //     _reconnectTimer = Timer.periodic(Duration(seconds: _reconnectIntervalMs),
  //         (Timer timer) async {
  //       if (_reconnectCount == 0) {
  //         _reconnectTimer.cancel();
  //         return;
  //       }
  //       await establishWebSocket();
  //       _reconnectCount--;
  //     });
  //   }
  // }

  void _listenToMessage() {
    _channel.stream.listen(
      (dynamic message) {
        // TODO parsing
        devtools.log('message $message');
      },
    );
  }

  void pushSocket(String text) {
    if (_isConnected) {
      devtools.log("pushing: $text");
      _channel.sink.add(text);
    } else {
      devtools.log("queueing: $text");
      _sendBuffer.add(text);
    }
  }

  void disconnectSocket() {
    try {
      _channel.sink.close(status.goingAway);
      _isConnected = false;
      devtools.log("Disconnected, WebSocket!");
    } catch (e) {
      devtools.log("close error: $e");
      return;
    }
  }

  void checkWebSocketStatus(WebSocket socket) {
    switch (socket.readyState) {
      case WebSocket.connecting:
        devtools.log('WebSocket is connecting');
        break;
      case WebSocket.open:
        devtools.log('WebSocket is open');
        break;
      case WebSocket.closing:
        devtools.log('WebSocket is closing');
        break;
      case WebSocket.closed:
        devtools.log('WebSocket is closed');
        break;
    }
  }

  int _fromBytesToInt32(List<int> elements) {
    ByteBuffer buffer = new Int8List.fromList(elements).buffer;
    ByteData byteData = new ByteData.view(buffer);
    return byteData.getInt32(0);
  }

  int _fromBytesToInt64(List<int> elements) {
    ByteBuffer buffer = new Int8List.fromList(elements).buffer;
    ByteData byteData = new ByteData.view(buffer);
    return byteData.getInt64(0);
  }
}
