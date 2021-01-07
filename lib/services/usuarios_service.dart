import 'package:http/http.dart' as http;
import 'package:chat_realtime/models/usuario.dart';
import 'package:chat_realtime/global/environment.dart';
import 'package:chat_realtime/services/auth_service.dart';
import 'package:chat_realtime/models/usuarios_response.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final resp = await http.get('${Environment.apiUrl}/users', headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      });
      final usuariosResponse = usuariosResponseFromJson(resp.body);
      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
