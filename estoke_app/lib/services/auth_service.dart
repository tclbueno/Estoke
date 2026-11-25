import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  // Endereço do backend Spring Boot.
  static const String baseUrl = 'http://localhost:8080/api';

  // Token disponível durante a sessão atual do aplicativo.
  static String? token;

  // Dados do usuário autenticado.
  static Map<String, dynamic>? usuario;

  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'senha': senha}),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : {};

      if (response.statusCode == 200) {
        token = data['token'] as String?;
        usuario = data;

        if (token == null || token!.isEmpty) {
          throw Exception('O servidor não retornou o token de acesso.');
        }

        return data;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('E-mail ou senha inválidos.');
      }

      throw Exception(
        data['message']?.toString() ??
            'Não foi possível realizar o login. Código: ${response.statusCode}',
      );
    } on http.ClientException {
      throw Exception(
        'Não foi possível conectar ao servidor. Verifique se a API está funcionando.',
      );
    } on FormatException {
      throw Exception('O servidor retornou uma resposta inválida.');
    } on Exception {
      rethrow;
    }
  }

  void logout() {
    token = null;
    usuario = null;
  }
}
