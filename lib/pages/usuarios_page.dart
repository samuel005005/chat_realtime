import 'package:chat_realtime/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:chat_realtime/models/usuario.dart';
import 'package:chat_realtime/pages/login_page.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/services/socket_service.dart';
import 'package:chat_realtime/services/usuarios_service.dart';
import 'package:chat_realtime/services/chat_services.dart';

class UsuariosPage extends StatefulWidget {
  static final routeName = 'usuarios';

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuariosService = UsuariosService();
  List<Usuario> usuarios = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  SocketService socketService;
  @override
  void initState() {
    this._cargarUsuarios();
    socketService = Provider.of<SocketService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: _appBarChat(authService, socketService, context),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _cargarUsuarios,
        header: WaterDropHeader(
          complete: Icon(Icons.check_circle_outline, color: Colors.blue[400]),
          waterDropColor: Colors.blue[400],
        ),
        child: _listViewUsuarios(),
      ),
    );
  }

  AppBar _appBarChat(AuthService authService, SocketService socketService,
      BuildContext context) {
    return AppBar(
      title: Text(
        '${authService.usuarioConectado.nombre}',
        style: TextStyle(color: Colors.black54),
      ),
      elevation: 1,
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Colors.black54,
        icon: Icon(Icons.exit_to_app),
        onPressed: () {
          socketService.disconnect();
          AuthService.deleteToken();
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        },
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 10),
          child: socketService.getServerStatus == ServetStatus.Online
              ? Icon(Icons.check_circle, color: Colors.blue[400])
              : Icon(Icons.offline_bolt, color: Colors.red[400]),
        )
      ],
    );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_, index) => _usuarioListTile((usuarios[index])),
      separatorBuilder: (_, index) => Divider(),
      itemCount: usuarios.length,
    );
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      leading: CircleAvatar(
        child: Text(
          usuario.nombre.substring(0, 2),
          // style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[100],
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: usuario.online ? Colors.green : Colors.red,
        ),
      ),
      onTap: () {
        final chatService = Provider.of<ChatServices>(context, listen: false);
        chatService.usuarioTo = usuario;
        Navigator.pushNamed(context, ChatPage.routeName);
      },
    );
  }

  void _cargarUsuarios() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    this.usuarios = await usuariosService.getUsuarios();
    setState(() {});
    _refreshController.refreshCompleted();
  }
}
