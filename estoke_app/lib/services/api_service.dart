import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // Endereço base da futura API Spring Boot.
  static const String baseUrl = 'http://localhost:8080/api';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Cabeçalhos padrão das requisições.
  Map<String, String> get headers {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Requisição GET: consultar dados.
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await _client.get(uri, headers: headers);

    return _handleResponse(response);
  }

  // Requisição POST: cadastrar dados.
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Requisição PUT: atualizar dados.
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Requisição DELETE: remover dados.
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await _client.delete(uri, headers: headers);

    return _handleResponse(response);
  }

  // Tratamento das respostas da API.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      'Erro na comunicação com a API. '
      'Código HTTP: ${response.statusCode}. '
      'Resposta: ${response.body}',
    );
  }

  // Encerra o cliente HTTP.
  void dispose() {
    _client.close();
  }
}
