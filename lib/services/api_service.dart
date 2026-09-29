import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cliente.dart';
import '../models/veiculo.dart';
import '../models/servico.dart';
import '../models/agendamento.dart';
import '../models/pagamento.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/FastSplashWeb';

  static String? _cookieSessao;

  // ==========================================
  // HEADERS
  // ==========================================

  static Map<String, String> get _headers {
    final Map<String, String> headers = {'Accept': 'application/json'};

    if (_cookieSessao != null) {
      headers['Cookie'] = _cookieSessao!;
    }

    return headers;
  }

  // ==========================================
  // COOKIE
  // ==========================================

  static void _salvarCookie(http.Response response) {
    final String? setCookie = response.headers['set-cookie'];

    if (setCookie == null || setCookie.isEmpty) {
      return;
    }

    final int fimCookie = setCookie.indexOf(';');

    if (fimCookie != -1) {
      _cookieSessao = setCookie.substring(0, fimCookie);
    } else {
      _cookieSessao = setCookie;
    }
  }

  // ==========================================
  // TESTE
  // ==========================================

  static Future<String> testarApi() async {
    final Uri url = Uri.parse('$baseUrl/api/teste');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return dados['mensagem'] ?? 'API funcionando.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao acessar API.');
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
  // LOGIN
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
      _salvarCookie(response);

      final dynamic clienteJson = dados['cliente'];

      if (clienteJson is! Map<String, dynamic>) {
        throw Exception('Dados do cliente inválidos.');
      }

      return Cliente.fromJson(clienteJson);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao realizar login.');
  }

  // ==========================================
  // MEU CADASTRO
  // ==========================================

  static Future<Cliente> buscarMeuCadastro() async {
    final Uri url = Uri.parse('$baseUrl/api/clientes/me');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final dynamic clienteJson = dados['cliente'];

      if (clienteJson is! Map<String, dynamic>) {
        throw Exception('Dados do cliente inválidos.');
      }

      return Cliente.fromJson(clienteJson);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao buscar cadastro.');
  }

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
        throw Exception('Dados do cliente inválidos.');
      }

      return Cliente.fromJson(clienteJson);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao atualizar cadastro.');
  }

  // ==========================================
  // VEÍCULOS - LISTAR
  // ==========================================

  static Future<List<Veiculo>> listarVeiculos() async {
    final Uri url = Uri.parse('$baseUrl/api/veiculos');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final List<dynamic> lista = dados['veiculos'] ?? [];

      return lista.map((item) => Veiculo.fromJson(item)).toList();
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao carregar veículos.');
  }

  // ==========================================
  // VEÍCULOS - CADASTRAR
  // ==========================================

  static Future<Veiculo> cadastrarVeiculo({
    required String placa,
    required String marca,
    required String modelo,
    required String cor,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/veiculos');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {'placa': placa, 'marca': marca, 'modelo': modelo, 'cor': cor},
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 201) {
      return Veiculo.fromJson(dados['veiculo']);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao cadastrar veículo.');
  }

  // ==========================================
  // VEÍCULOS - EDITAR
  // ==========================================

  static Future<Veiculo> atualizarVeiculo({
    required int idVeiculo,
    required String placa,
    required String marca,
    required String modelo,
    required String cor,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/veiculos/editar');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {
        'idVeiculo': idVeiculo.toString(),
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'cor': cor,
      },
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return Veiculo.fromJson(dados['veiculo']);
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao atualizar veículo.');
  }

  // ==========================================
  // VEÍCULOS - EXCLUIR
  // ==========================================

  static Future<String> excluirVeiculo(int idVeiculo) async {
    final Uri url = Uri.parse('$baseUrl/api/veiculos/excluir');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {'idVeiculo': idVeiculo.toString()},
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return dados['mensagem'] ?? 'Veículo excluído.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao excluir veículo.');
  }

  // ==========================================
  // LOGOUT LOCAL
  // ==========================================

  static void encerrarSessao() {
    _cookieSessao = null;
  }

  // ==========================================
  // SERVIÇOS
  // ==========================================

  static Future<List<Servico>> listarServicos() async {
    final Uri url = Uri.parse('$baseUrl/api/servicos');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final List<dynamic> lista = dados['servicos'] ?? [];

      return lista.map((item) => Servico.fromJson(item)).toList();
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao carregar serviços.');
  }

  // ==========================================
  // CRIAR AGENDAMENTO
  // ==========================================

  static Future<String> cadastrarAgendamento({
    required int idVeiculo,
    required List<int> idsServicos,
    required String data,
    required String horario,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/agendamentos');

    final List<MapEntry<String, String>> campos = [
      MapEntry('idVeiculo', idVeiculo.toString()),
      MapEntry('data', data),
      MapEntry('horario', horario),
      ...idsServicos.map((id) => MapEntry('idServico', id.toString())),
    ];

    final String body = campos
        .map(
          (campo) =>
              '${Uri.encodeQueryComponent(campo.key)}='
              '${Uri.encodeQueryComponent(campo.value)}',
        )
        .join('&');

    final Map<String, String> headers = {
      ..._headers,
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 201) {
      return dados['mensagem'] ?? 'Agendamento confirmado.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao realizar agendamento.');
  }

  // ==========================================
  // LISTAR AGENDAMENTOS
  // ==========================================

  static Future<List<Agendamento>> listarAgendamentos() async {
    final Uri url = Uri.parse('$baseUrl/api/agendamentos');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final List<dynamic> lista = dados['agendamentos'] ?? [];

      return lista.map((item) => Agendamento.fromJson(item)).toList();
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao carregar agendamentos.');
  }

  // ==========================================
  // CANCELAR AGENDAMENTO
  // ==========================================

  static Future<String> cancelarAgendamento(int idAgendamento) async {
    final Uri url = Uri.parse('$baseUrl/api/agendamentos/cancelar');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {'idAgendamento': idAgendamento.toString()},
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return dados['mensagem'] ?? 'Agendamento cancelado.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao cancelar agendamento.');
  }

  // ==========================================
  // PAGAMENTOS - LISTAR
  // ==========================================

  static Future<List<Pagamento>> listarPagamentos() async {
    final Uri url = Uri.parse('$baseUrl/api/pagamentos');

    final http.Response response = await http.get(url, headers: _headers);

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      final List<dynamic> lista = dados['pagamentos'] ?? [];

      return lista.map((item) => Pagamento.fromJson(item)).toList();
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao carregar pagamentos.');
  }

  // ==========================================
  // PAGAMENTOS - REALIZAR
  // ==========================================

  static Future<String> realizarPagamento({
    required int idAgendamento,
    required String formaPagamento,
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/pagamentos/pagar');

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: {
        'idAgendamento': idAgendamento.toString(),

        'formaPagamento': formaPagamento,
      },
    );

    final Map<String, dynamic> dados = _decodificarResposta(response);

    if (response.statusCode == 200) {
      return dados['mensagem'] ?? 'Pagamento realizado.';
    }

    throw Exception(dados['mensagem'] ?? 'Erro ao realizar pagamento.');
  }

  // ==========================================
  // JSON
  // ==========================================

  static Map<String, dynamic> _decodificarResposta(http.Response response) {
    final String corpo = utf8.decode(response.bodyBytes);

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

      throw Exception('Formato de resposta inesperado.');
    } on FormatException {
      String resumo = corpo.trim();

      if (resumo.length > 300) {
        resumo = '${resumo.substring(0, 300)}...';
      }

      throw Exception(
        'O servidor não retornou JSON.\n'
        'Status: ${response.statusCode}\n'
        'Resposta: $resumo',
      );
    }
  }
}
