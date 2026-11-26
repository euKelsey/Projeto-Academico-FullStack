import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/models/veiculo.dart';
import 'package:lava_rapido_app/screens/agendamento_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambienteAgendamento({
  bool semVeiculos = false,
  bool semServicos = false,
  bool erroConsulta = false,
  bool erroCadastro = false,
}) {
  return AmbienteApiTeste((request) async {
    final rota = rotaApi(request);

    if (request.method == 'GET') {
      if (erroConsulta) {
        return respostaJson({
          'mensagem': 'Consulta indisponível.',
        }, status: 500);
      }

      switch (rota) {
        case '/api/veiculos':
          return respostaJson({
            'veiculos': [if (!semVeiculos) veiculoJson()],
          });

        case '/api/servicos':
          return respostaJson({
            'servicos': [
              if (!semServicos) ...[
                servicoJson(),
                servicoJson(id: 302, nome: 'Lavagem Completa Teste', preco: 80),
              ],
            ],
          });
      }
    }

    if (rota == '/api/agendamentos' && request.method == 'POST') {
      if (erroCadastro) {
        return respostaJson({
          'mensagem':
              'Este veículo já possui um agendamento neste dia e horário.',
        }, status: 409);
      }

      return respostaJson({
        'mensagem': 'Agendamento confirmado com sucesso.',
      }, status: 201);
    }

    throw StateError('Requisicao inesperada: $rota');
  });
}

Finder botaoConfirmar() {
  return find.widgetWithText(ElevatedButton, 'Confirmar agendamento');
}

Future<void> selecionarVeiculo(WidgetTester tester) async {
  await tocar(tester, find.byType(DropdownButtonFormField<Veiculo>));

  await tocar(tester, find.text('Volkswagen Polo — TST1A01').last);
}

Future<void> selecionarServicos(WidgetTester tester) async {
  await tocar(tester, find.byType(Checkbox).at(0));

  await tocar(tester, find.byType(Checkbox).at(1));
}

Future<void> selecionarData(WidgetTester tester) async {
  await tocar(tester, campo('Data'));

  final contexto = tester.element(find.byType(DatePickerDialog));

  final rotulo = MaterialLocalizations.of(contexto).okButtonLabel;

  await tocar(tester, find.text(rotulo));
}

Future<void> selecionarHorario(WidgetTester tester) async {
  await tocar(tester, campo('Horário'));

  final contexto = tester.element(find.byType(TimePickerDialog));

  final rotulo = MaterialLocalizations.of(contexto).okButtonLabel;

  await tocar(tester, find.text(rotulo));
}

Future<void> preencherAgendamento(WidgetTester tester) async {
  await selecionarVeiculo(tester);
  await selecionarServicos(tester);
  await selecionarData(tester);
  await selecionarHorario(tester);
}

void main() {
  group('Agendamento - Carregamento', () {
    testWidgets('deve consultar veiculos e servicos', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen(), autenticado: true);

        expect(find.text('Novo agendamento'), findsOneWidget);

        expect(find.byType(DropdownButtonFormField<Veiculo>), findsOneWidget);

        expect(find.text('Lavagem Simples Teste'), findsOneWidget);

        expect(find.text('Lavagem Completa Teste'), findsOneWidget);

        expect(
          ambiente.requisicoes.map(rotaApi),
          unorderedEquals(['/api/veiculos', '/api/servicos']),
        );
      });
    });

    testWidgets('deve bloquear agendamento sem veiculos', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteAgendamento(semVeiculos: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        expect(
          find.text(
            'Você precisa cadastrar um veículo antes de realizar um agendamento.',
          ),
          findsOneWidget,
        );

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNull,
        );
      });
    });

    testWidgets('deve informar ausencia de servicos', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteAgendamento(semServicos: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        expect(
          find.text('Nenhum serviço disponível no momento.'),
          findsOneWidget,
        );

        expect(find.byType(Checkbox), findsNothing);

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNull,
        );
      });
    });

    testWidgets('deve apresentar falha de consulta', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteAgendamento(erroConsulta: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        expect(find.text('Consulta indisponível.'), findsOneWidget);

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });

  group('Agendamento - Selecao e valores', () {
    testWidgets('deve iniciar com total zero', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        expect(find.text(r'R$ 0.00'), findsOneWidget);

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNull,
        );
      });
    });

    testWidgets('deve recalcular total dos servicos', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await tocar(tester, find.byType(Checkbox).at(0));

        expect(find.text('1 serviço'), findsOneWidget);

        expect(find.text(r'R$ 50.00'), findsNWidgets(2));

        await tocar(tester, find.byType(Checkbox).at(1));

        expect(find.text('2 serviços'), findsOneWidget);

        expect(find.text(r'R$ 130.00'), findsOneWidget);

        await tocar(tester, find.byType(Checkbox).at(0));

        expect(find.text('1 serviço'), findsOneWidget);

        expect(find.text(r'R$ 80.00'), findsNWidgets(2));

        await tocar(tester, find.byType(Checkbox).at(1));

        expect(find.text('0 serviços'), findsOneWidget);
        expect(find.text(r'R$ 0.00'), findsOneWidget);
      });
    });

    testWidgets('deve permitir selecionar pelo card', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await tocar(tester, find.text('Lavagem Simples Teste'));

        expect(
          tester.widget<Checkbox>(find.byType(Checkbox).first).value,
          isTrue,
        );

        await tocar(tester, find.text('Lavagem Simples Teste'));

        expect(
          tester.widget<Checkbox>(find.byType(Checkbox).first).value,
          isFalse,
        );
      });
    });

    testWidgets('deve manter data e horario somente leitura', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        for (final rotulo in ['Data', 'Horário']) {
          expect(tester.widget<TextField>(campo(rotulo)).readOnly, isTrue);
        }
      });
    });

    testWidgets('deve habilitar confirmacao com formulario completo', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await preencherAgendamento(tester);

        expect(valorCampo(tester, 'Data'), matches(r'^\d{2}/\d{2}/\d{4}$'));

        expect(valorCampo(tester, 'Horário'), isNotEmpty);

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNotNull,
        );

        await tocar(tester, find.byType(Checkbox).at(0));

        await tocar(tester, find.byType(Checkbox).at(1));

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNull,
        );
      });
    });
  });

  group('Agendamento - Confirmacao', () {
    testWidgets('deve mostrar resumo antes do envio', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await preencherAgendamento(tester);

        await tocar(tester, botaoConfirmar());

        final dialogo = find.byType(AlertDialog);

        expect(dialogo, findsOneWidget);

        expect(
          find.descendant(
            of: dialogo,
            matching: find.text(
              'Lavagem Simples Teste, Lavagem Completa Teste',
            ),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(of: dialogo, matching: find.text(r'R$ 130.00')),
          findsOneWidget,
        );

        expect(ambiente.requisicoes, hasLength(2));
      });
    });

    testWidgets('deve desistir sem perder selecao', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await preencherAgendamento(tester);
        await tocar(tester, botaoConfirmar());

        await tocar(tester, find.text('Voltar'));

        expect(find.byType(AlertDialog), findsNothing);

        expect(find.text(r'R$ 130.00'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(2));
      });
    });

    testWidgets('deve cadastrar agendamento e limpar formulario', (
      tester,
    ) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteAgendamento();

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await preencherAgendamento(tester);

        final data = valorCampo(tester, 'Data');
        final partes = data.split('/');

        await tocar(tester, botaoConfirmar());

        await tocar(tester, find.text('Confirmar'));

        expect(
          find.text('Agendamento confirmado com sucesso.'),
          findsOneWidget,
        );

        expect(ambiente.requisicoes, hasLength(3));

        final requisicao = ambiente.requisicoes.last;

        expect(requisicao.method, 'POST');

        expect(rotaApi(requisicao), '/api/agendamentos');

        final campos = Uri.parse('http://teste.local/?${requisicao.body}')
            .queryParametersAll;

        expect(campos['idVeiculo'], ['201']);

        expect(campos['idServico'], ['301', '302']);

        expect(campos['data'], ['${partes[2]}-${partes[1]}-${partes[0]}']);

        expect(campos['horario']!.single, matches(r'^\d{2}:\d{2}$'));

        expect(valorCampo(tester, 'Data'), isEmpty);

        expect(valorCampo(tester, 'Horário'), isEmpty);

        expect(find.text(r'R$ 0.00'), findsOneWidget);

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNull,
        );
      });
    });

    testWidgets('deve preservar formulario em caso de conflito', (
      tester,
    ) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteAgendamento(erroCadastro: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const AgendamentoScreen());

        await preencherAgendamento(tester);

        final data = valorCampo(tester, 'Data');

        await tocar(tester, botaoConfirmar());
        await tocar(tester, find.text('Confirmar'));

        expect(find.textContaining('já possui um agendamento'), findsOneWidget);

        expect(find.text(r'R$ 130.00'), findsOneWidget);

        expect(valorCampo(tester, 'Data'), data);

        expect(
          tester.widget<ElevatedButton>(botaoConfirmar()).onPressed,
          isNotNull,
        );
      });
    });
  });
}
