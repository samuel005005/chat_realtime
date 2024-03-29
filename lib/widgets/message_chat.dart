import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_realtime/services/auth_service.dart';

class MessageChat extends StatelessWidget {
  final String text;
  final String uid;
  final AnimationController animationController;

  const MessageChat({
    Key key,
    @required this.text,
    @required this.uid,
    @required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authservice = Provider.of<AuthService>(context, listen: false);
    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        child: Container(
          child: this.uid == authservice.usuarioConectado.uid
              ? _myMessage()
              : _noMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, left: 50, right: 5),
        decoration: BoxDecoration(
          color: Color(0xff4D9EF6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(8.0),
        child: Text(
          this.text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _noMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 5, left: 5, right: 50),
        decoration: BoxDecoration(
          color: Color(0xffE4E5E8),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(8.0),
        child: Text(
          this.text,
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
