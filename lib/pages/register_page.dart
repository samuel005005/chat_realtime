import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_realtime/widgets/custom_button.dart';
import 'package:chat_realtime/widgets/labels.dart';
import 'package:chat_realtime/widgets/custom_input.dart';
import 'package:chat_realtime/widgets/logo.dart';
import 'package:chat_realtime/pages/login_page.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/helpers/mostrar_alerta.dart';
import 'package:chat_realtime/pages/usuarios_page.dart';
import 'package:chat_realtime/services/socket_service.dart';

class RegisterPage extends StatelessWidget {
  static final routeName = 'register';
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
                Logo(titulo: "Registro"),
                _Form(),
                SizedBox(height: 30),
                Labels(
                  route: LoginPage.routeName,
                  titulo: 'No tienes cuenta?',
                  subTitulo: 'Ingresa ahora!!',
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Terminos y condiciones de uso',
                    style: TextStyle(fontWeight: FontWeight.w200),
                  ),
                )
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
  final nameCtrl = TextEditingController();
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
            icon: Icons.perm_identity,
            placeholder: "Nombre",
            keyboardType: TextInputType.text,
            textController: nameCtrl,
          ),
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
            text: "Registrarse",
            color: Colors.blue,
            onPressed: authService.autenticando
                ? null
                : () async {
                    final registerOk = await authService.register(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passwordCtrl.text.trim());
                    if (registerOk == true) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(
                          context, UsuariosPage.routeName);
                    } else {
                      // Mostara alerta
                      mostrarAlerta(
                        context,
                        'Registro incorrecto',
                        registerOk,
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}
