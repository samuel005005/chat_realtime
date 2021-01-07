import 'package:chat_realtime/models/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:chat_realtime/global/environment.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/models/usuario.dart';
import 'package:chat_realtime/models/messages_response.dart';

class ChatServices with ChangeNotifier {
  Usuario _usuarioTo;

  Usuario get usuarioTo => this._usuarioTo;
  set usuarioTo(Usuario usuario) {
    this._usuarioTo = usuario;
  }

  Future<List<Message>> getChat(String usuarioId) async {
    final resp = await http.get('${Environment.apiUrl}/messages/$usuarioId',
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken()
        });

    final messageResponse = messagesResponseFromJson(resp.body);

    return messageResponse.messages;
  }
}
