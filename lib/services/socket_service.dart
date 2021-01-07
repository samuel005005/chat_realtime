import 'package:chat_realtime/global/environment.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServetStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServetStatus _serverStatus = ServetStatus.Connecting;
  final _url = '${Environment.socketUrl}';
  IO.Socket _socket;

  void connect() async {
    // if (this._socket != null) return;

    final token = await AuthService.getToken();

    this._socket = IO.io(
      this._url,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'extraHeaders': {
          'x-token': token,
        }
      },
    );
    this._socket.connect();
    this._socket.on('connect', (_) {
      _serverStatus = ServetStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      _serverStatus = ServetStatus.Offline;
      notifyListeners();
    });
  }

  void disconnect() {
    this._socket?.disconnect();
  }

  ServetStatus get getServerStatus => _serverStatus;

  void emit(String event, {dynamic arguments}) =>
      this._socket.emit(event, arguments ?? {});

  void subscribe(String event, Function function) =>
      this._socket.on(event, function);

  void unsubscribe(String event) => this._socket.off(event);
}
