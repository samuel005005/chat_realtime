import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_realtime/widgets/message_chat.dart';
import 'package:chat_realtime/services/socket_service.dart';
import 'package:chat_realtime/services/chat_services.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/models/message.dart';

class ChatPage extends StatefulWidget {
  static final routeName = 'chat';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();
  bool _writing = false;
  ChatServices chatService;
  SocketService socketService;
  AuthService authService;

  final List<MessageChat> _messages = [];

  @override
  void initState() {
    super.initState();
    this.chatService = Provider.of<ChatServices>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.subscribe('mensaje-personal', this._listenMessage);
    _cargarMessage(this.chatService.usuarioTo.uid);
  }

  void _cargarMessage(String uid) async {
    List<Message> chat = await this.chatService.getChat(uid);

    final history = chat.map((his) => new MessageChat(
          uid: his.from,
          text: his.message,
          animationController: AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 400),
          )..forward(),
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic payload) {
    final newMessage = new MessageChat(
      uid: payload['From'],
      text: payload['Message'],
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );

    setState(() {
      _messages.insert(0, newMessage);
    });
    newMessage.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, index) => _messages[index],
                reverse: true,
                itemCount: _messages.length,
              ),
            ),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    final usuarioTo = this.chatService.usuarioTo;
    return AppBar(
      backgroundColor: Colors.white,
      title: Column(
        children: <Widget>[
          CircleAvatar(
            child: Text(usuarioTo.nombre.substring(0, 2),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue[100],
            maxRadius: 14,
          ),
          SizedBox(height: 3),
          Text(
            usuarioTo.nombre,
            style: TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 1,
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String text) {
                  setState(() {
                    if (text.trim().length > 0) {
                      _writing = true;
                    } else {
                      _writing = false;
                    }
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: "Enviar Mensaje",
                ),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text("Enviar",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _writing
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(
                          color: Colors.blue[400],
                        ),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.send),
                          onPressed: _writing
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (text.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new MessageChat(
      uid: this.authService.usuarioConectado.uid,
      text: text,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();
    setState(() {
      _writing = false;
    });
    print(this.authService.usuarioConectado.uid);
    print(this.chatService.usuarioTo.uid);

    this.socketService.emit('mensaje-personal', arguments: {
      'From': this.authService.usuarioConectado.uid,
      'To': this.chatService.usuarioTo.uid,
      'Message': text
    });
  }

  @override
  void dispose() {
    for (MessageChat menssage in _messages) {
      menssage.animationController.dispose();
    }
    this.socketService.unsubscribe('mensaje-personal');
    super.dispose();
  }
}
