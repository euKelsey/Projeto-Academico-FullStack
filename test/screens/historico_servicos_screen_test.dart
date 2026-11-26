import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/screens/historico_servicos_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambienteHistorico(List<Map<String, dynamic>> registros) {
  return AmbienteApiTeste((request) async {
    expect(request.method, 'GET');

    expect(rotaApi(request), '/api/agendamentos');

    return respostaJson({'agendamentos': registros});
  });
}

void main() {
  group('Historico - Listagem', () {
    testWidgets('deve apresentar historico vazio', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteHistorico([]);

      await ambiente.executar(() async {
        await abrirTela(
          tester,
          const HistoricoServicosScreen(),
          autenticado: true,
        );

        expect(find.text('Histórico vazio'), findsOneWidget);

        expect(find.text('Nenhum registro encontrado.'), findsOneWidget);
      });
    });

    for (final caso in [
      ('Finalizado', 'Concluído'),
      ('CONCLUIDO', 'Concluído'),
      ('Cancelado', 'Cancelado'),
    ]) {
      testWidgets('deve apresentar registro ${caso.$1}', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambienteHistorico([
          agendamentoJson(status: caso.$1, valorTotal: 90, data: '2026-11-24'),
        ]);

        await ambiente.executar(() async {
          await abrirTela(tester, const HistoricoServicosScreen());

          expect(find.text('1 registro encontrado.'), findsOneWidget);

          expect(find.text(caso.$2), findsOneWidget);

          expect(find.text('TST1A01'), findsOneWidget);

          expect(find.text('24/11/2026'), findsOneWidget);

          expect(find.text(r'R$ 90.00'), findsOneWidget);
        });
      });
    }

    testWidgets('deve excluir registros ativos do historico', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteHistorico([
        agendamentoJson(status: 'Finalizado'),
        agendamentoJson(
          id: 502,
          status: 'Cancelado',
          veiculo: veiculoJson(id: 202, placa: 'TST1A02'),
        ),
        agendamentoJson(
          id: 503,
          status: 'Agendado',
          veiculo: veiculoJson(id: 203, placa: 'TST1A03'),
        ),
        agendamentoJson(
          id: 504,
          status: 'Em andamento',
          veiculo: veiculoJson(id: 204, placa: 'TST1A04'),
        ),
        agendamentoJson(
          id: 505,
          status: 'AGUARDANDO',
          veiculo: veiculoJson(id: 205, placa: 'TST1A05'),
        ),
      ]);

      await ambiente.executar(() async {
        await abrirTela(tester, const HistoricoServicosScreen());

        expect(find.text('2 registros encontrados.'), findsOneWidget);

        expect(find.text('TST1A01'), findsOneWidget);
        expect(find.text('TST1A02'), findsOneWidget);

        for (final placa in ['TST1A03', 'TST1A04', 'TST1A05']) {
          expect(find.text(placa), findsNothing);
        }
      });
    });
  });

  group('Historico - Detalhes', () {
    for (final caso in [
      ('Finalizado', 'Este serviço foi concluído.'),
      ('Cancelado', 'Este agendamento foi cancelado.'),
    ]) {
      testWidgets('deve abrir detalhes de ${caso.$1}', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambienteHistorico([
          agendamentoJson(
            status: caso.$1,
            valorTotal: 130,
            servicos: [
              servicoJson(),
              servicoJson(id: 302, nome: 'Lavagem Completa Teste', preco: 80),
            ],
          ),
        ]);

        await ambiente.executar(() async {
          await abrirTela(tester, const HistoricoServicosScreen());

          await tocar(tester, find.text('TST1A01'));

          final painel = find.byType(BottomSheet);

          expect(painel, findsOneWidget);

          expect(find.text(caso.$2), findsOneWidget);

          expect(
            find.descendant(
              of: painel,
              matching: find.text('Volkswagen Polo — TST1A01'),
            ),
            findsOneWidget,
          );

          expect(
            find.descendant(
              of: painel,
              matching: find.text(
                'Lavagem Simples Teste, Lavagem Completa Teste',
              ),
            ),
            findsOneWidget,
          );

          expect(
            find.descendant(of: painel, matching: find.text(r'R$ 130.00')),
            findsOneWidget,
          );

          expect(find.text('Cancelar agendamento'), findsNothing);

          await tocar(tester, find.text('Fechar'));

          expect(find.byType(BottomSheet), findsNothing);
          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    testWidgets('deve preservar valor historico contratado', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteHistorico([
        agendamentoJson(
          status: 'Finalizado',
          valorTotal: 50,
          servicos: [servicoJson(preco: 999)],
        ),
      ]);

      await ambiente.executar(() async {
        await abrirTela(tester, const HistoricoServicosScreen());

        expect(find.text(r'R$ 50.00'), findsOneWidget);

        expect(find.text(r'R$ 999.00'), findsNothing);
      });
    });
  });

  testWidgets('deve atualizar historico apos nova consulta', (tester) async {
    prepararWidgetTeste(tester);

    final registros = <Map<String, dynamic>>[];

    final ambiente = ambienteHistorico(registros);

    await ambiente.executar(() async {
      await abrirTela(tester, const HistoricoServicosScreen());

      expect(find.text('Histórico vazio'), findsOneWidget);

      registros.add(agendamentoJson(status: 'Finalizado'));

      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();

      await tester.pumpAndSettle();

      expect(find.text('Histórico vazio'), findsNothing);

      expect(find.text('1 registro encontrado.'), findsOneWidget);

      expect(ambiente.requisicoes, hasLength(2));
    });
  });

  testWidgets('deve apresentar falha de consulta', (tester) async {
    prepararWidgetTeste(tester);

    final ambiente = AmbienteApiTeste(
      (_) async =>
          respostaJson({'mensagem': 'Histórico indisponível.'}, status: 500),
    );

    await ambiente.executar(() async {
      await abrirTela(tester, const HistoricoServicosScreen());

      expect(find.text('Histórico indisponível.'), findsOneWidget);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
