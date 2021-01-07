import 'package:flutter/material.dart';

import 'package:chat_realtime/pages/chat_page.dart';
import 'package:chat_realtime/pages/loading_page.dart';
import 'package:chat_realtime/pages/login_page.dart';
import 'package:chat_realtime/pages/register_page.dart';
import 'package:chat_realtime/pages/usuarios_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  UsuariosPage.routeName: (_) => UsuariosPage(),
  ChatPage.routeName: (_) => ChatPage(),
  LoginPage.routeName: (_) => LoginPage(),
  RegisterPage.routeName: (_) => RegisterPage(),
  LoadingPage.routeName: (_) => LoadingPage(),
};
