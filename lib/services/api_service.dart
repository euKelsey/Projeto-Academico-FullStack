import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cliente.dart';

class ApiService {
  // ==========================================
  // ENDEREÇO DO BACKEND
  // ==========================================

  static const String baseUrl = 'http://10.0.2.2:8080/FastSplashWeb';

  // Cookie da sessão criada pelo Tomcat.
  static String? _cookieSessao;

  // ==========================================
  // CABEÇALHOS
  // ==========================================

  static Map<String, String> get _headers {
    final Map<String, String> headers = {'Accept': 'application/json'};

    if (_cookieSessao != null) {
      headers['Cookie'] = _cookieSessao!;
    }

    return headers;
  }

  // ==========================================
  // SALVAR COOKIE DA SESSÃO
  // ==========================================

  static void _salvarCookie(http.Response response) {
    final String? setCookie = response.headers['set-cookie'];

    if (setCookie == null || setCookie.isEmpty) {
      return;
    }

    // Pegamos somente:
    //
    // JSESSIONID=xxxxxxxx
    //
    // descartando Path, HttpOnly etc.
    final int fimCookie = setCookie.indexOf(';');

    if (fimCookie != -1) {
      _cookieSessao = setCookie.substring(0, fimCookie);
    } else {
      _cookieSessao = setCookie;
    }
  }

  // ==========================================
  // TESTE DA API
  // ==========================================

  static Future<String> testarApi() async {
    final Uri url = Uri.parse('$baseUrl/api/teste');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return dados['mensagem'] ?? 'API funcionando.';
    }

    throw Exception(
      dados['mensagem'] ??
          'Erro ao acessar API. '
              'Status: ${response.statusCode}',
    );
  }

  // ==========================================
  // CADASTRAR CLIENTE
  // ==========================================

  static Future<String> cadastrarCliente({
    required String nome,
    required String telefone,
    required String email,
    required String cpf,
    required String senha,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/clientes');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'cpf': cpf,
        'senha': senha,
      },
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 201) {
      return dados['mensagem'] ?? 'Cadastro realizado com sucesso.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao realizar cadastro.');
  }

  // ==========================================
  // LOGIN DO CLIENTE
  // ==========================================

  static Future<Cliente> loginCliente({
    required String email,
    required String senha,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/auth/login');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {'email': email, 'senha': senha},
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      // Guarda a sessão criada pelo Tomcat.
      _salvarCookie(response);

      final dynamic clienteJson = dados['cliente'];

      if (clienteJson is! Map<String, dynamic>) {
        throw Exception(
          'Dados do cliente inválidos '
          'na resposta do servidor.',
        );
      }

      return Cliente.fromJson(clienteJson);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao realizar login.');
  }

  // ==========================================
  // BUSCAR MEU CADASTRO
  // ==========================================

  static Future<Cliente> buscarMeuCadastro() async {
    final Uri url = Uri.parse('$baseUrl/api/clientes/me');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final dynamic clienteJson = dados['cliente'];

      if (clienteJson is! Map<String, dynamic>) {
        throw Exception(
          'Dados do cliente inválidos '
          'na resposta do servidor.',
        );
      }

      return Cliente.fromJson(clienteJson);
    }

    // Sessão não existe ou expirou.
    if (response.statusCode == 401) {
      throw Exception(
        dados['mensagem'] ??
            'Sua sessão expirou. '
                'Faça login novamente.',
      );
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao buscar cadastro.');
  }

  // ==========================================
  // ATUALIZAR MEU CADASTRO
  // ==========================================

  static Future<Cliente> atualizarMeuCadastro({
    required String nome,
    required String telefone,
    required String email,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/clientes/me');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {'nome': nome, 'telefone': telefone, 'email': email},
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final dynamic clienteJson = dados['cliente'];

      if (clienteJson is! Map<String, dynamic>) {
        throw Exception(
          'Dados do cliente inválidos '
          'na resposta do servidor.',
        );
      }

      return Cliente.fromJson(clienteJson);
    }

    if (response.statusCode == 401) {
      throw Exception(
        dados['mensagem'] ??
            'Sua sessão expirou. '
                'Faça login novamente.',
      );
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao atualizar cadastro.');
  }

  // ==========================================
  // ENCERRAR SESSÃO LOCAL
  // ==========================================

  static void encerrarSessao() {
    _cookieSessao = null;
  }

  // ==========================================
  // DECODIFICAR RESPOSTA JSON
  // ==========================================

  static Map<String, dynamic> _decodificarResposta(http.Response response) {
    final String corpo = utf8.decode(response.bodyBytes);

    // Resposta vazia.
    if (corpo.trim().isEmpty) {
      throw Exception(
        'O servidor retornou uma '
        'resposta vazia. '
        'Status: ${response.statusCode}',
      );
    }

    try {
      final dynamic dados = jsonDecode(corpo);

      if (dados is Map<String, dynamic>) {
        return dados;
      }

      throw Exception(
        'Formato de resposta '
        'inesperado.',
      );
    } on FormatException {
      // Aqui mostramos o verdadeiro
      // problema recebido do Tomcat.

      String resumo = corpo.trim();

      // Evita mostrar uma página HTML
      // gigantesca no SnackBar.
      if (resumo.length > 300) {
        resumo = resumo.substring(0, 300) + '...';
      }

      throw Exception(
        'O servidor não retornou JSON.\n'
        'Status: ${response.statusCode}\n'
        'Resposta: $resumo',
      );
    }
  }
}
