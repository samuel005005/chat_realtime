import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_realtime/widgets/custom_button.dart';
import 'package:chat_realtime/widgets/labels.dart';
import 'package:chat_realtime/widgets/custom_input.dart';
import 'package:chat_realtime/widgets/logo.dart';
import 'package:chat_realtime/pages/register_page.dart';
import 'package:chat_realtime/helpers/mostrar_alerta.dart';
import 'package:chat_realtime/pages/usuarios_page.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/services/socket_service.dart';

class LoginPage extends StatelessWidget {
  static final routeName = 'login';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Logo(titulo: "Menssage"),
                _Form(),
                SizedBox(height: 30),
                Labels(
                  route: RegisterPage.routeName,
                  titulo: 'No tienes cuenta?',
                  subTitulo: 'Crea una ahora!!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          CustomInput(
            icon: Icons.email_outlined,
            placeholder: "Correo Electronico",
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: "Password",
            keyboardType: TextInputType.text,
            textController: passwordCtrl,
            isPassword: true,
          ),
          CustomButton(
            text: "Ingrese",
            color: Colors.blue,
            onPressed: authService.autenticando
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final loginOk = await authService.login(
                        emailCtrl.text.trim(), passwordCtrl.text.trim());
                    if (loginOk) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(
                          context, UsuariosPage.routeName);
                    } else {
                      // Mostara alerta
                      mostrarAlerta(
                        context,
                        'Login incorrecto',
                        'Revise sus credenciales nuevamente',
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}
