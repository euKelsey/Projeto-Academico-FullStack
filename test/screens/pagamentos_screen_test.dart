import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/screens/pagamentos_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambientePagamentos({bool vazio = false, bool erro = false}) {
  final pagamentos = <Map<String, dynamic>>[if (!vazio) pagamentoJson()];

  return AmbienteApiTeste((request) async {
    final rota = rotaApi(request);

    if (rota == '/api/pagamentos' && request.method == 'GET') {
      return respostaJson({'pagamentos': pagamentos});
    }

    if (rota == '/api/pagamentos/pagar' && request.method == 'POST') {
      if (erro) {
        return respostaJson({
          'mensagem': 'Pagamento indisponível.',
        }, status: 404);
      }

      final dados = request.bodyFields;

      expect(dados['idAgendamento'], '501');

      pagamentos[0] = pagamentoJson(
        status: 'PAGO',
        forma: dados['formaPagamento']!,
        data: '26/11/2026 10:30',
      );

      return respostaJson({'mensagem': 'Pagamento realizado com sucesso.'});
    }

    throw StateError('Rota inesperada: $rota');
  });
}

Future<void> abrirPagamento(WidgetTester tester) async {
  await tocar(tester, find.text('Pagar'));

  expect(find.text('Forma de Pagamento'), findsOneWidget);
}

Future<void> escolherPagamento(WidgetTester tester, String forma) async {
  await tocar(tester, find.text(forma));

  await tocar(tester, find.text('Continuar'));

  expect(find.text('Confirmar Pagamento'), findsOneWidget);
}

void main() {
  group('Pagamentos - Listagem', () {
    testWidgets('deve apresentar categorias vazias', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePagamentos(vazio: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen(), autenticado: true);

        expect(find.text('Nenhum pagamento pendente'), findsOneWidget);

        expect(find.text('Nenhum pagamento realizado'), findsOneWidget);

        expect(find.text('Pagar'), findsNothing);
      });
    });

    testWidgets('deve separar pagamentos por status', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'pagamentos': [
            pagamentoJson(),
            pagamentoJson(
              id: 702,
              idAgendamento: 502,
              status: 'PAGO',
              forma: 'PIX',
              valor: 80,
              data: '26/11/2026 10:30',
            ),
            pagamentoJson(
              id: 703,
              idAgendamento: 503,
              status: 'CANCELADO',
              valor: 999,
            ),
          ],
        }),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen());

        expect(find.text('Pagamentos Pendentes'), findsOneWidget);

        expect(find.text('Pagamentos Realizados'), findsOneWidget);

        expect(find.text('Status do pagamento: Pendente'), findsOneWidget);

        expect(find.text('Status do pagamento: Pago'), findsOneWidget);

        expect(find.text('Forma de pagamento: PIX'), findsOneWidget);

        expect(
          find.text('Data do pagamento: 26/11/2026 10:30'),
          findsOneWidget,
        );

        expect(find.text(r'Valor: R$ 999.00'), findsNothing);

        expect(find.text('Pagar'), findsOneWidget);
      });
    });
  });

  group('Pagamentos - Confirmacao', () {
    testWidgets('deve exigir forma de pagamento', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambientePagamentos();

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen());

        await abrirPagamento(tester);

        for (final forma in ['PIX', 'Crédito', 'Débito', 'Dinheiro']) {
          expect(find.text(forma), findsOneWidget);
        }

        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Continuar'),
              )
              .onPressed,
          isNull,
        );

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve desistir da escolha sem pagar', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambientePagamentos();

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen());

        await abrirPagamento(tester);

        await tocar(tester, find.text('Cancelar'));

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Pagar'), findsOneWidget);
        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve desistir da confirmacao final', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambientePagamentos();

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen());

        await abrirPagamento(tester);
        await escolherPagamento(tester, 'PIX');

        await tocar(tester, find.text('Não'));

        expect(find.text('Pagar'), findsOneWidget);
        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    for (final forma in [
      ('PIX', 'PIX'),
      ('Crédito', 'CREDITO'),
      ('Débito', 'DEBITO'),
      ('Dinheiro', 'DINHEIRO'),
    ]) {
      testWidgets('deve pagar utilizando ${forma.$1}', (tester) async {
        prepararWidgetTeste(tester);
        final ambiente = ambientePagamentos();

        await ambiente.executar(() async {
          await abrirTela(tester, const PagamentosScreen());

          await abrirPagamento(tester);
          await escolherPagamento(tester, forma.$1);

          expect(
            find.text(
              'Confirmar pagamento de R\$ 50.00 '
              'via ${forma.$1}?',
            ),
            findsOneWidget,
          );

          await tocar(tester, find.text('Sim, pagar'));

          expect(find.text('Pagamento realizado com sucesso.'), findsOneWidget);

          expect(find.text('Nenhum pagamento pendente'), findsOneWidget);

          expect(find.text('Status do pagamento: Pago'), findsOneWidget);

          expect(find.text('Forma de pagamento: ${forma.$1}'), findsOneWidget);

          expect(find.text('Pagar'), findsNothing);

          expect(ambiente.requisicoes, hasLength(3));

          expect(rotaApi(ambiente.requisicoes[1]), '/api/pagamentos/pagar');

          expect(ambiente.requisicoes[1].bodyFields, {
            'idAgendamento': '501',
            'formaPagamento': forma.$2,
          });

          expect(ambiente.requisicoes.last.method, 'GET');
        });
      });
    }

    testWidgets('deve preservar pendencia quando pagamento falhar', (
      tester,
    ) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePagamentos(erro: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const PagamentosScreen());

        await abrirPagamento(tester);
        await escolherPagamento(tester, 'PIX');

        await tocar(tester, find.text('Sim, pagar'));

        expect(find.text('Pagamento indisponível.'), findsOneWidget);

        expect(find.text('Status do pagamento: Pendente'), findsOneWidget);

        expect(find.text('Pagar'), findsOneWidget);
        expect(ambiente.requisicoes, hasLength(2));
      });
    });
  });
}
