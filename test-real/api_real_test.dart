import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/services/api_service.dart';

const urlAutorizada = 'http://127.0.0.1:8081';
const senha = 'SenhaFicticia@123';

Future<void> autenticar({String email = 'ativo@example.test'}) async {
  final cliente = await ApiService.loginCliente(email: email, senha: senha);

  expect(cliente.email, email);
}

void main() {
  setUpAll(() {
    if (ApiService.baseUrl != urlAutorizada) {
      throw StateError(
        'URL nao autorizada para testes reais: '
        '${ApiService.baseUrl}',
      );
    }
  });

  setUp(ApiService.encerrarSessao);
  tearDown(ApiService.encerrarSessao);

  group('Flutter - Backend real', () {
    test('deve autenticar cliente ativo', () async {
      final cliente = await ApiService.loginCliente(
        email: 'ativo@example.test',
        senha: senha,
      );

      expect(cliente.idCliente, 101);
      expect(cliente.email, 'ativo@example.test');
    });

    test('deve rejeitar senha incorreta', () async {
      await expectLater(
        ApiService.loginCliente(
          email: 'ativo@example.test',
          senha: 'senha-incorreta',
        ),
        throwsException,
      );
    });

    test('deve rejeitar cliente inativo', () async {
      await expectLater(
        ApiService.loginCliente(email: 'inativo@example.test', senha: senha),
        throwsException,
      );
    });

    test('deve consultar perfil com cookie real', () async {
      await autenticar();

      final cliente = await ApiService.buscarMeuCadastro();

      expect(cliente.idCliente, 101);
      expect(cliente.cpf, '98765410130');
      expect(cliente.email, 'ativo@example.test');
    });

    test('deve listar somente veiculos do cliente', () async {
      await autenticar();

      final veiculos = await ApiService.listarVeiculos();

      expect(veiculos.map((v) => v.idVeiculo), unorderedEquals([201, 202]));
    });

    test('deve isolar veiculos de outro cliente', () async {
      await autenticar(email: 'livre@example.test');

      final veiculos = await ApiService.listarVeiculos();

      expect(veiculos, hasLength(1));
      expect(veiculos.first.idVeiculo, 203);
    });

    test('deve listar somente servicos ativos', () async {
      await autenticar();

      final servicos = await ApiService.listarServicos();

      expect(servicos.map((s) => s.idServico), unorderedEquals([301, 302]));

      expect(servicos.firstWhere((s) => s.idServico == 301).preco, 50.0);
    });

    test('deve consultar agendamentos reais', () async {
      await autenticar();

      final agendamentos = await ApiService.listarAgendamentos();

      final registro = agendamentos.firstWhere((a) => a.idAgendamento == 501);

      expect(registro.veiculo.idVeiculo, 201);
      expect(registro.valorTotal, 50.0);
      expect(registro.status, 'Agendado');
    });

    test('deve interpretar status reais da lavagem', () async {
      await autenticar();

      final agendamentos = await ApiService.listarAgendamentos();

      expect(
        agendamentos.firstWhere((a) => a.idAgendamento == 503).status,
        'Em andamento',
      );

      expect(
        agendamentos.firstWhere((a) => a.idAgendamento == 504).status,
        'Finalizado',
      );
    });

    test('deve interpretar pagamentos reais', () async {
      await autenticar();

      final pagamentos = await ApiService.listarPagamentos();

      expect(
        pagamentos.firstWhere((p) => p.idAgendamento == 501).pago,
        isFalse,
      );

      final pago = pagamentos.firstWhere((p) => p.idAgendamento == 502);

      expect(pago.pago, isTrue);
      expect(pago.valor, 80.0);
      expect(pago.formaPagamento, 'PIX');
    });

    test('deve bloquear consulta apos logout local', () async {
      await autenticar();

      expect(await ApiService.listarVeiculos(), isNotEmpty);

      ApiService.encerrarSessao();

      await expectLater(ApiService.listarVeiculos(), throwsException);
    });

    test('deve executar ciclo real de agendamento e pagamento', () async {
      await autenticar(email: 'livre@example.test');

      final data = DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String()
          .substring(0, 10);

      await ApiService.cadastrarAgendamento(
        idVeiculo: 203,
        idsServicos: [301, 302],
        data: data,
        horario: '14:30',
      );

      final agendamentos = await ApiService.listarAgendamentos();

      final novo = agendamentos.firstWhere(
        (a) =>
            a.veiculo.idVeiculo == 203 &&
            a.data == data &&
            a.horario == '14:30',
      );

      expect(novo.idAgendamento, greaterThan(506));
      expect(novo.valorTotal, 130.0);
      expect(novo.servicos, hasLength(2));

      final id = novo.idAgendamento;

      final pendentes = await ApiService.listarPagamentos();

      expect(pendentes.firstWhere((p) => p.idAgendamento == id).pago, isFalse);

      await ApiService.realizarPagamento(
        idAgendamento: id,
        formaPagamento: 'PIX',
      );

      final atualizados = await ApiService.listarPagamentos();

      final pago = atualizados.firstWhere((p) => p.idAgendamento == id);

      expect(pago.pago, isTrue);
      expect(pago.valor, 130.0);
      expect(pago.formaPagamento, 'PIX');

      await expectLater(
        ApiService.realizarPagamento(idAgendamento: id, formaPagamento: 'PIX'),
        throwsException,
      );
    });
  });
}
