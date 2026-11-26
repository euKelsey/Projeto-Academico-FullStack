import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/screens/status_servico_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambienteStatus({
  String status = 'Agendado',
  bool vazio = false,
  bool erro = false,
}) {
  final agendamentos = <Map<String, dynamic>>[
    if (!vazio) agendamentoJson(status: status),
  ];

  return AmbienteApiTeste((request) async {
    final rota = rotaApi(request);

    if (rota == '/api/agendamentos' && request.method == 'GET') {
      return respostaJson({'agendamentos': agendamentos});
    }

    if (rota == '/api/agendamentos/cancelar' && request.method == 'POST') {
      expect(request.bodyFields, {'idAgendamento': '501'});

      if (erro) {
        return respostaJson({
          'mensagem': 'Este agendamento não pode mais ser cancelado.',
        }, status: 409);
      }

      agendamentos[0]['status'] = 'Cancelado';

      return respostaJson({'mensagem': 'Agendamento cancelado com sucesso.'});
    }

    throw StateError('Rota inesperada: $rota');
  });
}

Future<void> abrirDetalhesStatus(WidgetTester tester) async {
  await tocar(tester, find.text('TST1A01'));

  expect(find.text('Acompanhamento'), findsOneWidget);
}

Future<void> abrirCancelamento(WidgetTester tester) async {
  await abrirDetalhesStatus(tester);

  await tocar(tester, find.text('Cancelar agendamento'));

  expect(find.byType(AlertDialog), findsOneWidget);
}

void main() {
  group('Acompanhamento - Listagem', () {
    testWidgets('deve apresentar estado vazio', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteStatus(vazio: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const StatusServicoScreen(), autenticado: true);

        expect(find.text('Nenhum serviço em andamento'), findsOneWidget);
      });
    });

    for (final caso in [
      ('Agendado', 'Agendado', 1, true),
      ('AGUARDANDO', 'Aguardando atendimento', 2, false),
      ('Em andamento', 'Em lavagem', 3, false),
    ]) {
      testWidgets('deve apresentar etapa ${caso.$1}', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambienteStatus(status: caso.$1);

        await ambiente.executar(() async {
          await abrirTela(tester, const StatusServicoScreen());

          expect(find.text(caso.$2), findsOneWidget);

          await abrirDetalhesStatus(tester);

          final painel = find.byType(BottomSheet);

          expect(painel, findsOneWidget);

          for (final etapa in [
            'Agendado',
            'Aguardando',
            'Em lavagem',
            'Finalizado',
          ]) {
            expect(
              find.descendant(of: painel, matching: find.text(etapa)),
              findsOneWidget,
            );
          }

          expect(
            find.descendant(of: painel, matching: find.byIcon(Icons.check)),
            findsNWidgets(caso.$3),
          );

          expect(
            find.descendant(
              of: painel,
              matching: find.text('Cancelar agendamento'),
            ),
            caso.$4 ? findsOneWidget : findsNothing,
          );

          await tocar(tester, find.text('Fechar'));

          expect(find.text('Acompanhamento'), findsNothing);
        });
      });
    }

    testWidgets('deve ocultar registros encerrados', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'agendamentos': [
            agendamentoJson(),
            agendamentoJson(
              id: 502,
              status: 'Finalizado',
              veiculo: veiculoJson(id: 202, placa: 'TST1A02'),
            ),
            agendamentoJson(
              id: 503,
              status: 'Cancelado',
              veiculo: veiculoJson(id: 203, placa: 'TST1A03'),
            ),
            agendamentoJson(
              id: 504,
              status: 'CONCLUIDO',
              veiculo: veiculoJson(id: 204, placa: 'TST1A04'),
            ),
          ],
        }),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const StatusServicoScreen());

        expect(find.text('TST1A01'), findsOneWidget);

        for (final placa in ['TST1A02', 'TST1A03', 'TST1A04']) {
          expect(find.text(placa), findsNothing);
        }
      });
    });
  });

  group('Acompanhamento - Cancelamento', () {
    testWidgets('deve preservar registro ao desistir', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteStatus();

      await ambiente.executar(() async {
        await abrirTela(tester, const StatusServicoScreen());

        await abrirCancelamento(tester);

        await tocar(tester, find.text('Não'));

        expect(find.byType(AlertDialog), findsNothing);

        expect(find.text('Acompanhamento'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve cancelar e atualizar listagem', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteStatus();

      await ambiente.executar(() async {
        await abrirTela(tester, const StatusServicoScreen());

        await abrirCancelamento(tester);

        await tocar(tester, find.text('Sim, cancelar'));

        expect(find.text('Agendamento cancelado com sucesso.'), findsOneWidget);

        expect(find.text('TST1A01'), findsNothing);

        expect(find.text('Nenhum serviço em andamento'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(3));

        expect(rotaApi(ambiente.requisicoes[1]), '/api/agendamentos/cancelar');
      });
    });

    testWidgets('deve preservar registro quando cancelamento falhar', (
      tester,
    ) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteStatus(erro: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const StatusServicoScreen());

        await abrirCancelamento(tester);

        await tocar(tester, find.text('Sim, cancelar'));

        expect(
          find.text('Este agendamento não pode mais ser cancelado.'),
          findsOneWidget,
        );

        expect(find.text('Acompanhamento'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(2));

        await tocar(tester, find.text('Fechar'));

        expect(find.text('TST1A01'), findsOneWidget);
      });
    });
  });

  testWidgets('deve atualizar status apos nova consulta', (tester) async {
    prepararWidgetTeste(tester);

    var status = 'Agendado';

    final ambiente = AmbienteApiTeste(
      (_) async => respostaJson({
        'agendamentos': [agendamentoJson(status: status)],
      }),
    );

    await ambiente.executar(() async {
      await abrirTela(tester, const StatusServicoScreen());

      expect(find.text('Agendado'), findsOneWidget);

      status = 'Em andamento';

      final atualizador = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );

      await atualizador.onRefresh();
      await tester.pumpAndSettle();

      expect(find.text('Em lavagem'), findsOneWidget);

      status = 'Finalizado';

      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();

      await tester.pumpAndSettle();

      expect(find.text('Nenhum serviço em andamento'), findsOneWidget);

      expect(ambiente.requisicoes, hasLength(3));
    });
  });
}
