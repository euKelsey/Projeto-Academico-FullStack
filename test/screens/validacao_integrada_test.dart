import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:lava_rapido_app/main.dart';
import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/screens/login_screen.dart';
import 'package:lava_rapido_app/screens/home_screen.dart';
import 'package:lava_rapido_app/screens/meu_cadastro_screen.dart';
import 'package:lava_rapido_app/screens/veiculos_screen.dart';
import 'package:lava_rapido_app/screens/agendamento_screen.dart';
import 'package:lava_rapido_app/screens/status_servico_screen.dart';
import 'package:lava_rapido_app/screens/historico_servicos_screen.dart';
import 'package:lava_rapido_app/screens/pagamentos_screen.dart';
import 'package:lava_rapido_app/theme/theme_controller.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

// =============================================
// BACKEND SIMULADO COMPARTILHADO
// =============================================

class BackendMobileTeste {
  List<Map<String, dynamic>> veiculos = [veiculoJson()];

  List<Map<String, dynamic>> servicos = [
    servicoJson(),
    servicoJson(id: 302, nome: 'Lavagem Completa Teste', preco: 80),
  ];

  List<Map<String, dynamic>> agendamentos = [];

  List<Map<String, dynamic>> pagamentos = [];

  Map<String, dynamic> cliente = clienteJson();

  final Set<String> rotasComErro = {};

  late final AmbienteApiTeste ambiente = AmbienteApiTeste(responder);

  Future<http.Response> responder(http.Request request) async {
    final rota = rotaApi(request);

    if (rotasComErro.contains(rota)) {
      return respostaJson({
        'sucesso': false,
        'mensagem': 'Conexão temporariamente indisponível.',
      }, status: 503);
    }

    if (rota == '/api/auth/login' && request.method == 'POST') {
      expect(request.bodyFields, {
        'email': 'ativo@example.test',
        'senha': senhaTeste,
      });

      return respostaJson(
        {'sucesso': true, 'cliente': cliente},
        headers: {'set-cookie': 'JSESSIONID=integracao123'},
      );
    }

    if (request.method == 'GET') {
      switch (rota) {
        case '/api/clientes/me':
          return respostaJson({'cliente': cliente});

        case '/api/veiculos':
          return respostaJson({'veiculos': veiculos});

        case '/api/servicos':
          return respostaJson({'servicos': servicos});

        case '/api/agendamentos':
          return respostaJson({'agendamentos': agendamentos});

        case '/api/pagamentos':
          return respostaJson({'pagamentos': pagamentos});
      }
    }

    if (rota == '/api/pagamentos/pagar' && request.method == 'POST') {
      final dados = request.bodyFields;

      final id = int.parse(dados['idAgendamento']!);

      final indice = pagamentos.indexWhere((p) => p['idAgendamento'] == id);

      expect(indice, greaterThanOrEqualTo(0));

      pagamentos[indice] = {
        ...pagamentos[indice],
        'statusPagamento': 'PAGO',
        'formaPagamento': dados['formaPagamento'],
        'dataPagamento': '26/11/2026 14:00',
      };

      return respostaJson({
        'sucesso': true,
        'mensagem': 'Pagamento realizado com sucesso.',
      });
    }

    throw StateError(
      'Requisicao inesperada: '
      '${request.method} $rota',
    );
  }

  int consultas(String rota) {
    return ambiente.requisicoes
        .where((request) => request.method == 'GET' && rotaApi(request) == rota)
        .length;
  }
}

Future<void> atualizarTela(WidgetTester tester) async {
  final indicador = tester.widget<RefreshIndicator>(
    find.byType(RefreshIndicator),
  );

  await indicador.onRefresh();
  await tester.pumpAndSettle();
}

Future<void> voltar(WidgetTester tester) async {
  final contexto = tester.element(find.byType(Scaffold).first);

  Navigator.of(contexto).pop();

  await tester.pumpAndSettle();
}

// =============================================
// 1.8.10.6 - HOME E NAVEGACAO
// =============================================

void main() {
  group('Home - Proximo agendamento', () {
    testWidgets('deve apresentar saudacao e estado vazio', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        expect(find.text('Olá, Cliente Teste Ativo'), findsOneWidget);

        expect(find.text('Próximo agendamento'), findsOneWidget);

        expect(
          find.text('Você não possui agendamentos ativos.'),
          findsOneWidget,
        );

        expect(backend.consultas('/api/agendamentos'), 1);
      });
    });

    testWidgets('deve selecionar agendamento mais proximo', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.agendamentos = [
        agendamentoJson(
          id: 501,
          data: '2027-01-20',
          veiculo: veiculoJson(modelo: 'DISTANTE'),
        ),
        agendamentoJson(
          id: 502,
          data: '2027-01-15',
          horario: '14:00',
          veiculo: veiculoJson(modelo: 'TARDE'),
        ),
        agendamentoJson(
          id: 503,
          data: '2027-01-15',
          horario: '09:00',
          veiculo: veiculoJson(modelo: 'MANHA'),
        ),
      ];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        expect(find.text('Volkswagen MANHA'), findsOneWidget);

        expect(find.text('15/01/2027'), findsOneWidget);
        expect(find.text('09:00'), findsOneWidget);

        expect(find.text('Volkswagen DISTANTE'), findsNothing);

        expect(find.text('Volkswagen TARDE'), findsNothing);
      });
    });

    testWidgets('deve ignorar registros encerrados', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.agendamentos = [
        agendamentoJson(id: 501, status: 'Finalizado'),
        agendamentoJson(id: 502, status: 'Cancelado'),
        agendamentoJson(id: 503, status: 'CONCLUIDO'),
      ];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        expect(
          find.text('Você não possui agendamentos ativos.'),
          findsOneWidget,
        );
      });
    });

    testWidgets('deve priorizar data valida sobre invalida', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.agendamentos = [
        agendamentoJson(
          data: 'invalida',
          veiculo: veiculoJson(modelo: 'INVALIDO'),
        ),
        agendamentoJson(
          id: 502,
          data: '2027-01-15',
          veiculo: veiculoJson(modelo: 'VALIDO'),
        ),
      ];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        expect(find.text('Volkswagen VALIDO'), findsOneWidget);

        expect(find.text('Volkswagen INVALIDO'), findsNothing);
      });
    });
  });

  group('Home - Navegacao', () {
    final destinos = [
      ('Meu Cadastro', MeuCadastroScreen, false),
      ('Meus Veículos', VeiculosScreen, false),
      ('Agendar', AgendamentoScreen, true),
      ('Acompanhar', StatusServicoScreen, true),
      ('Histórico', HistoricoServicosScreen, true),
      ('Pagamentos', PagamentosScreen, true),
    ];

    for (final destino in destinos) {
      testWidgets('deve navegar para ${destino.$1} e voltar', (tester) async {
        prepararWidgetTeste(tester);
        final backend = BackendMobileTeste();

        await backend.ambiente.executar(() async {
          await abrirTela(tester, const HomeScreen(), autenticado: true);

          await tocar(tester, find.text(destino.$1));

          expect(find.byType(destino.$2), findsOneWidget);

          expect(SessaoCliente.estaLogado, isTrue);

          final antes = backend.consultas('/api/agendamentos');

          await voltar(tester);

          expect(find.byType(HomeScreen), findsOneWidget);

          expect(find.byType(destino.$2), findsNothing);

          expect(
            backend.consultas('/api/agendamentos'),
            antes + (destino.$3 ? 1 : 0),
          );

          expect(SessaoCliente.estaLogado, isTrue);
        });
      });
    }
  });

  group('Integracao entre telas', () {
    testWidgets('deve atualizar home ao retornar do acompanhamento', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.agendamentos = [agendamentoJson()];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        expect(find.text('AGENDADO'), findsOneWidget);

        await tocar(tester, find.text('Acompanhar'));

        backend.agendamentos = [agendamentoJson(status: 'Em andamento')];

        await atualizarTela(tester);

        expect(find.text('Em lavagem'), findsOneWidget);

        await voltar(tester);

        expect(find.text('EM ANDAMENTO'), findsOneWidget);
      });
    });

    testWidgets('deve transferir registro finalizado para historico', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.agendamentos = [agendamentoJson(status: 'Em andamento')];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        await tocar(tester, find.text('Acompanhar'));

        expect(find.text('Em lavagem'), findsOneWidget);

        backend.agendamentos = [agendamentoJson(status: 'Finalizado')];

        await atualizarTela(tester);

        expect(find.text('Nenhum serviço em andamento'), findsOneWidget);

        await voltar(tester);

        expect(
          find.text('Você não possui agendamentos ativos.'),
          findsOneWidget,
        );

        await tocar(tester, find.text('Histórico'));

        expect(find.text('Concluído'), findsOneWidget);
        expect(find.text('TST1A01'), findsOneWidget);
      });
    });

    testWidgets('deve preservar cookie durante navegacao', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester);
        await tocar(tester, find.text('Entrar'));

        for (final destino in [
          'Meu Cadastro',
          'Meus Veículos',
          'Agendar',
          'Pagamentos',
        ]) {
          await tocar(tester, find.text(destino));
          await voltar(tester);
        }

        final consultas = backend.ambiente.requisicoes.where(
          (r) => r.method == 'GET',
        );

        expect(consultas, isNotEmpty);

        for (final request in consultas) {
          expect(cabecalho(request, 'Cookie'), 'JSESSIONID=integracao123');
        }

        await tocar(tester, find.byTooltip('Sair'));

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(SessaoCliente.estaLogado, isFalse);
        expect(find.byType(HomeScreen), findsNothing);
      });
    });

    testWidgets('deve manter pagamento confirmado ao reabrir tela', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.pagamentos = [pagamentoJson()];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        await tocar(tester, find.text('Pagamentos'));
        await tocar(tester, find.text('Pagar'));
        await tocar(tester, find.text('PIX'));
        await tocar(tester, find.text('Continuar'));
        await tocar(tester, find.text('Sim, pagar'));

        expect(find.text('Status do pagamento: Pago'), findsOneWidget);

        await voltar(tester);

        await tocar(tester, find.text('Pagamentos'));

        expect(find.text('Forma de pagamento: PIX'), findsOneWidget);

        expect(find.text('Pagar'), findsNothing);

        final postagens = backend.ambiente.requisicoes.where(
          (r) => r.method == 'POST' && rotaApi(r) == '/api/pagamentos/pagar',
        );

        expect(postagens, hasLength(1));
      });
    });
  });

  // =============================================
  // 1.8.10.7 - ATUALIZACAO E ERROS
  // =============================================

  group('Atualizacao e recuperacao', () {
    final telas = <(String, Widget, String)>[
      ('Home', const HomeScreen(), '/api/agendamentos'),
      ('Veiculos', const VeiculosScreen(), '/api/veiculos'),
      ('Agendamentos', const AgendamentoScreen(), '/api/servicos'),
      ('Acompanhamento', const StatusServicoScreen(), '/api/agendamentos'),
      ('Historico', const HistoricoServicosScreen(), '/api/agendamentos'),
      ('Pagamentos', const PagamentosScreen(), '/api/pagamentos'),
    ];

    for (final tela in telas) {
      testWidgets('deve realizar nova consulta em ${tela.$1}', (tester) async {
        prepararWidgetTeste(tester);
        final backend = BackendMobileTeste();

        await backend.ambiente.executar(() async {
          await abrirTela(tester, tela.$2, autenticado: true);

          expect(find.byType(RefreshIndicator), findsOneWidget);

          expect(backend.consultas(tela.$3), 1);

          await atualizarTela(tester);

          expect(backend.consultas(tela.$3), 2);

          expect(find.byType(CircularProgressIndicator), findsNothing);
        });
      });

      testWidgets('deve recuperar falha de consulta em ${tela.$1}', (
        tester,
      ) async {
        prepararWidgetTeste(tester);
        final backend = BackendMobileTeste();

        backend.rotasComErro.add(tela.$3);

        await backend.ambiente.executar(() async {
          await abrirTela(tester, tela.$2, autenticado: true);

          expect(
            find.text('Conexão temporariamente indisponível.'),
            findsOneWidget,
          );

          expect(find.byType(CircularProgressIndicator), findsNothing);

          backend.rotasComErro.clear();

          await atualizarTela(tester);

          expect(backend.consultas(tela.$3), 2);

          expect(find.byType(RefreshIndicator), findsOneWidget);

          expect(tester.takeException(), isNull);
        });
      });
    }

    testWidgets('deve atualizar home pelo gesto de puxar', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const HomeScreen(), autenticado: true);

        backend.agendamentos = [agendamentoJson()];

        await tester.drag(
          find.text('Olá, Cliente Teste Ativo'),
          const Offset(0, 400),
        );

        await tester.pumpAndSettle();

        expect(backend.consultas('/api/agendamentos'), 2);

        expect(find.text('Volkswagen Polo'), findsOneWidget);
      });
    });

    testWidgets('deve atualizar veiculos pelo gesto de puxar', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.veiculos = [];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen(), autenticado: true);

        expect(find.text('Nenhum veículo cadastrado'), findsOneWidget);

        backend.veiculos = [veiculoJson()];

        await tester.drag(
          find.text('Nenhum veículo cadastrado'),
          const Offset(0, 400),
        );

        await tester.pumpAndSettle();

        expect(backend.consultas('/api/veiculos'), 2);

        expect(find.text('TST1A01'), findsOneWidget);
      });
    });

    testWidgets('deve carregar pagamentos adicionados apos refresh', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen(), autenticado: true);

        expect(find.text('Pagar'), findsNothing);

        backend.pagamentos = [pagamentoJson()];

        await atualizarTela(tester);

        expect(find.text('Pagar'), findsOneWidget);

        expect(backend.consultas('/api/pagamentos'), 2);
      });
    });

    testWidgets('deve carregar novos servicos apos refresh', (tester) async {
      prepararWidgetTeste(tester);
      final backend = BackendMobileTeste();

      backend.servicos = [];

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen(), autenticado: true);

        expect(find.byType(Checkbox), findsNothing);

        backend.servicos = [servicoJson()];

        await atualizarTela(tester);

        expect(find.byType(Checkbox), findsOneWidget);

        expect(find.text('Lavagem Simples Teste'), findsOneWidget);
      });
    });

    testWidgets('deve ignorar resposta apos fechar tela', (tester) async {
      prepararWidgetTeste(tester);

      final pendente = Completer<http.Response>();

      final ambiente = AmbienteApiTeste((_) => pendente.future);

      await ambiente.executar(() async {
        await tester.pumpWidget(const MaterialApp(home: StatusServicoScreen()));

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());

        pendente.complete(
          respostaJson({
            'agendamentos': [agendamentoJson()],
          }),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(StatusServicoScreen), findsNothing);
      });
    });
  });

  // =============================================
  // 1.8.10.8 - RESPONSIVIDADE
  // =============================================

  group('Responsividade', () {
    final resolucoes = [
      ('Celular compacto', 360.0, 640.0),
      ('Celular moderno', 390.0, 844.0),
      ('Celular grande', 430.0, 932.0),
      ('Tablet', 768.0, 1024.0),
    ];

    final telas = <(String, Widget)>[
      ('Login', const LoginScreen()),
      ('Home', const HomeScreen()),
      ('Perfil', const MeuCadastroScreen()),
      ('Veiculos', const VeiculosScreen()),
      ('Agendamento', const AgendamentoScreen()),
      ('Acompanhamento', const StatusServicoScreen()),
      ('Historico', const HistoricoServicosScreen()),
      ('Pagamentos', const PagamentosScreen()),
    ];

    for (final resolucao in resolucoes) {
      for (final tela in telas) {
        testWidgets('deve renderizar ${tela.$1} em ${resolucao.$1}', (
          tester,
        ) async {
          prepararWidgetTeste(tester);

          tester.view.physicalSize = Size(resolucao.$2, resolucao.$3);

          final backend = BackendMobileTeste();

          backend.agendamentos = [
            agendamentoJson(),
            agendamentoJson(id: 502, status: 'Finalizado'),
          ];

          backend.pagamentos = [
            pagamentoJson(),
            pagamentoJson(
              id: 702,
              idAgendamento: 502,
              status: 'PAGO',
              forma: 'PIX',
            ),
          ];

          await backend.ambiente.executar(() async {
            await abrirTela(tester, tela.$2, autenticado: tela.$1 != 'Login');

            expect(find.byType(Scaffold), findsOneWidget);

            expect(tester.takeException(), isNull);

            final tamanho = tester.getSize(find.byType(Scaffold));

            expect(tamanho.width, resolucao.$2);
            expect(tamanho.height, resolucao.$3);

            expect(find.byType(CircularProgressIndicator), findsNothing);
          });
        });
      }
    }

    for (final modo in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('deve renderizar aplicativo com tema $modo', (tester) async {
        prepararWidgetTeste(tester);

        definirTema(modo);

        await tester.pumpWidget(const FastSplashApp());

        await tester.pumpAndSettle();

        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
          modo,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('deve permitir acessar botao de login em tela compacta', (
      tester,
    ) async {
      prepararWidgetTeste(tester);

      tester.view.physicalSize = const Size(360, 640);

      final backend = BackendMobileTeste();

      await backend.ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester);

        await tocar(tester, find.text('Entrar'));

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(SessaoCliente.estaLogado, isTrue);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
