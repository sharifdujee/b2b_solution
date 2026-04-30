import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:b2b_solution/core/service/auth_service.dart';

class SocketService {
  WebSocket? _socket;

  Function(String)? onMessageReceived;

  Timer? _reconnectTimer;
  String? _socketUrl;
  String? _authToken;
  bool _isReconnecting = false;
  bool _isManualDisconnect = false;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  Completer<void>? _connectionCompleter;

  String? _lastJoinedBookingId;

  bool get isConnected{
    try{
      return _socket != null && _socket!.readyState == WebSocket.open && !_isReconnecting;
    }catch(e){
      return false;
    }
  }

  Future<void> get whenConnected {
    if (isConnected) return Future.value();
    _connectionCompleter ??= Completer<void>();
    return _connectionCompleter!.future;
  }


  void _handleDisconnect() {
    if (_isManualDisconnect) {
      log("Manual disconnect, not reconnecting");
      return;
    }

    if (_isReconnecting) {
      log("⏳ Already reconnecting, skipping…");
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      log("Max reconnection attempts reached");
      _isReconnecting = false;
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    _connectionCompleter = Completer<void>();

    final delay = Duration(seconds: math.pow(2, _reconnectAttempts).toInt());
    log("Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)");

    _reconnectTimer = Timer(delay, () {
      if (_socketUrl != null && _authToken != null && !_isManualDisconnect) {
        connect(_socketUrl!, _authToken!);
      }
    });
  }


  Future<void> connect(String socketUrl, String authToken) async {
    _socketUrl = socketUrl;
    _authToken = authToken;
    _reconnectAttempts = 0;
    _isManualDisconnect = false;

    if(_connectionCompleter != null){
      _connectionCompleter = null;
    }
    try{
      await _socket?.close();
      _reconnectTimer?.cancel();

      log("Attempting to connect to socket... $socketUrl");
      log("x-Token : ${AuthService.token}");
      _socket = await WebSocket.connect(socketUrl, headers: {
        'token': AuthService.token,
        'content-type': 'application/json'
      }).timeout(const Duration(seconds: 10),
        onTimeout: (){
        throw TimeoutException("Connection Timeout");
        }
      );

      log("Connected to socket: $socketUrl");

      _isReconnecting =false;
      _reconnectAttempts = 0;

      if(_connectionCompleter != null && !_connectionCompleter!.isCompleted){
        _connectionCompleter!.complete();
      }
      _socket?.listen(
            (message) {
          log("WebSocket message received: $message");

          try {
            final decoded = jsonDecode(message);
            if (decoded['type'] == 'connected' || decoded['type'] == 'authenticated') {
              log("WebSocket authenticated successfully");
            } else if (decoded['type'] == 'error') {
              log("Server error: ${decoded['message']}");
            }
          } catch (e) {
            // Not JSON – ignore
          }

          // FIX 1: use corrected name
          onMessageReceived?.call(message);
        },
        onError: (error) {
          log("WebSocket error: $error");
          if (!_isManualDisconnect) _handleDisconnect();
        },
        onDone: () {
          log("WebSocket connection closed");
          if (!_isManualDisconnect) _handleDisconnect();
        },
        cancelOnError: false,
      );


    }catch(e){
      _connectionCompleter?.completeError(e);
      _connectionCompleter = null;
      log("Error connecting to socket: $e");
    }
  }

  void viewMessage(String chatroomId, String userId) {
    if (_socket == null || !isConnected) {
      log("Cannot view message: WebSocket not connected");
      return;
    }

    final message = jsonEncode({
      "type": "viewMessage",
      "chatroomId": chatroomId,
      "userId": userId,
    });

    try {
      _socket?.add(message);
      log("View message sent for room: $chatroomId");
    } catch (e) {
      log("Error viewing message: $e");
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_socket == null || !isConnected) {
      log("Cannot send message: WebSocket not connected");
      return;
    }

    try {
      final encodedMessage = jsonEncode(message);
      _socket?.add(encodedMessage);
      log("📤 Message sent: $encodedMessage");
    } catch (e) {
      log("Error sending message: $e");
    }
  }

  void disconnect() {
    try {
      _isManualDisconnect = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _isReconnecting = false;
      _reconnectAttempts = 0;
      _lastJoinedBookingId = null;
      _socket?.close(1000);
      _socket = null;
      log("🔌 WebSocket disconnected gracefully");
    } catch (e) {
      log("Error closing WebSocket: $e");
    }
  }

  void joinRoom(String connectedUserId) {
    if (_socket == null || !isConnected) {
      log("Cannot join room: WebSocket not connected");
      return;
    }

    // remember for reconnect replay
    _lastJoinedBookingId = connectedUserId;

    final message = jsonEncode({
      "type": "start-conversation",
      "targetUserId": connectedUserId,
    });

    try {
      _socket?.add(message);
      log("📤 [joinRoom] Sent: $message");
    } catch (e) {
      log("Error joining room: $e");
    }
  }

  final Set<String> _activeSubscriptions = {};
  void subscribeToRoom(String roomId) {
    if (_socket == null || !isConnected) return;

    // Logic: If already subscribed, don't send the message again
    if (_activeSubscriptions.contains(roomId)) {
      log("ℹ️ Already subscribed to room $roomId. Skipping...");
      return;
    }

    final message = jsonEncode({
      "type": "subscribe-room",
      "roomId": roomId,
    });

    if (_sendMessage(message)) {
      _activeSubscriptions.add(roomId);
    }
  }

  bool _sendMessage(String message) {
    try {
      _socket?.add(message);
      log("📤 Sent: $message");
      return true;
    } catch (e) {
      log("❌ Error sending message: $e");
      return false;
    }
  }

  void clearSubscriptions() => _activeSubscriptions.clear();


  void resetReconnection() {
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _isManualDisconnect = false;
  }

  void setOnMessageReceived(Function(String) callback) {
    onMessageReceived = callback;
  }

}


///