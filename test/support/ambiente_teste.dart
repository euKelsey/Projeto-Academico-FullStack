import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/services/api_service.dart';
import 'package:lava_rapido_app/models/cliente.dart';

const senhaTeste = 'SenhaFicticia@123';

const clienteTeste = Cliente(
  idCliente: 101,
  nome: 'Cliente Teste Ativo',
  cpf: '98765410130',
  telefone: '11900000101',
  email: 'ativo@example.test',
);

Map<String, dynamic> clienteJson({
  String nome = 'Cliente Teste Ativo',
  String telefone = '11900000101',
  String email = 'ativo@example.test',
}) {
  return {
    'idCliente': 101,
    'nome': nome,
    'cpf': '98765410130',
    'telefone': telefone,
    'email': email,
  };
}

Map<String, dynamic> veiculoJson({
  int id = 201,
  String marca = 'Volkswagen',
  String modelo = 'Polo',
  String placa = 'TST1A01',
  String cor = 'Branco',
}) {
  return {
    'idVeiculo': id,
    'idCliente': 101,
    'marca': marca,
    'modelo': modelo,
    'placa': placa,
    'cor': cor,
  };
}

Map<String, dynamic> servicoJson({
  int id = 301,
  String nome = 'Lavagem Simples Teste',
  num preco = 50,
}) {
  return {
    'idServico': id,
    'nome': nome,
    'descricao': 'Servico ficticio',
    'preco': preco,
  };
}

Map<String, dynamic> agendamentoJson({
  int id = 501,
  String status = 'Agendado',
  String data = '2027-01-15',
  String horario = '09:00',
  num valorTotal = 50,
  bool pago = false,
  String? formaPagamento,
  Map<String, dynamic>? veiculo,
  List<Map<String, dynamic>>? servicos,
}) {
  return {
    'idAgendamento': id,
    'veiculo': veiculo ?? veiculoJson(),
    'servicos': servicos ?? [servicoJson()],
    'data': data,
    'horario': horario,
    'status': status,
    'valorTotal': valorTotal,
    'pago': pago,
    'formaPagamento': formaPagamento,
  };
}

Map<String, dynamic> pagamentoJson({
  int id = 701,
  int idAgendamento = 501,
  String status = 'PENDENTE',
  String forma = '',
  String data = '',
  num valor = 50,
}) {
  return {
    'idPagamento': id,
    'idAgendamento': idAgendamento,
    'valor': valor,
    'statusPagamento': status,
    'formaPagamento': forma,
    'dataPagamento': data,
    'veiculo': 'Volkswagen Polo',
    'servicos': 'Lavagem Simples Teste',
  };
}

http.Response respostaJson(
  Map<String, dynamic> dados, {
  int status = 200,
  Map<String, String> headers = const {},
}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(dados)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8', ...headers},
  );
}

String rotaApi(http.Request request) {
  final caminho = request.url.path;
  final inicio = caminho.indexOf('/api/');

  if (inicio == -1) {
    throw StateError('Rota inesperada: $caminho');
  }

  return caminho.substring(inicio);
}

String? cabecalho(http.Request request, String nome) {
  for (final item in request.headers.entries) {
    if (item.key.toLowerCase() == nome.toLowerCase()) {
      return item.value;
    }
  }

  return null;
}

class AmbienteApiTeste {
  final List<http.Request> requisicoes = [];

  late final MockClient cliente;

  AmbienteApiTeste(
    Future<http.Response> Function(http.Request request) responder,
  ) {
    cliente = MockClient((request) async {
      requisicoes.add(request);

      return responder(request);
    });
  }

  Future<T> executar<T>(Future<T> Function() acao) {
    return http.runWithClient(acao, () => cliente);
  }
}

void limparSessaoTeste() {
  SessaoCliente.encerrar();
  ApiService.encerrarSessao();
}
