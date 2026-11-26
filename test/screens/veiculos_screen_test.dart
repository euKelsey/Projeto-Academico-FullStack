import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/screens/veiculos_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambienteVeiculos({
  bool vazio = false,
  int? erro,
  String mensagem = 'Operação não permitida.',
}) {
  final veiculos = <Map<String, dynamic>>[if (!vazio) veiculoJson()];

  return AmbienteApiTeste((request) async {
    final rota = rotaApi(request);

    if (request.method == 'GET') {
      expect(rota, '/api/veiculos');

      return respostaJson({'veiculos': veiculos});
    }

    if (erro != null) {
      return respostaJson({
        'sucesso': false,
        'mensagem': mensagem,
      }, status: erro);
    }

    final dados = request.bodyFields;

    switch (rota) {
      case '/api/veiculos':
        final novo = veiculoJson(
          id: 203,
          placa: dados['placa']!,
          marca: dados['marca']!,
          modelo: dados['modelo']!,
          cor: dados['cor']!,
        );

        veiculos.add(novo);

        return respostaJson({'veiculo': novo}, status: 201);

      case '/api/veiculos/editar':
        final id = int.parse(dados['idVeiculo']!);

        final atualizado = veiculoJson(
          id: id,
          placa: dados['placa']!,
          marca: dados['marca']!,
          modelo: dados['modelo']!,
          cor: dados['cor']!,
        );

        final indice = veiculos.indexWhere((v) => v['idVeiculo'] == id);

        veiculos[indice] = atualizado;

        return respostaJson({'veiculo': atualizado});

      case '/api/veiculos/excluir':
        final id = int.parse(dados['idVeiculo']!);

        veiculos.removeWhere((v) => v['idVeiculo'] == id);

        return respostaJson({'mensagem': 'Veículo excluído com sucesso.'});

      default:
        throw StateError('Rota inesperada: $rota');
    }
  });
}

Future<void> novoVeiculo(WidgetTester tester) async {
  await tocar(tester, find.text('Novo veículo'));

  expect(campo('Placa'), findsOneWidget);
  expect(campo('Marca'), findsOneWidget);
  expect(campo('Modelo'), findsOneWidget);
  expect(campo('Cor'), findsOneWidget);
}

Future<void> preencherVeiculo(
  WidgetTester tester, {
  String placa = 'tst9a99',
  String marca = 'fiat',
  String modelo = 'argo',
  String cor = 'prata',
}) async {
  await preencherCampo(tester, 'Placa', placa);
  await preencherCampo(tester, 'Marca', marca);
  await preencherCampo(tester, 'Modelo', modelo);
  await preencherCampo(tester, 'Cor', cor);
}

void main() {
  group('Veiculos - Listagem', () {
    testWidgets('deve apresentar veiculo cadastrado', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen(), autenticado: true);

        expect(find.text('TST1A01'), findsOneWidget);
        expect(find.text('Editar'), findsOneWidget);
        expect(find.byTooltip('Excluir veículo'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve apresentar lista vazia', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos(vazio: true);

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        expect(find.text('Nenhum veículo cadastrado'), findsOneWidget);
      });
    });

    testWidgets('deve apresentar falha de carregamento', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste(
        (_) async =>
            respostaJson({'mensagem': 'Veículos indisponíveis.'}, status: 500),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        expect(find.text('Veículos indisponíveis.'), findsOneWidget);

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });

  group('Veiculos - Cadastro', () {
    testWidgets('deve abrir formulario vazio', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await novoVeiculo(tester);

        for (final rotulo in ['Placa', 'Marca', 'Modelo', 'Cor']) {
          expect(valorCampo(tester, rotulo), isEmpty);
        }
      });
    });

    testWidgets('deve aplicar formatadores nos campos', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await novoVeiculo(tester);

        await preencherVeiculo(tester, placa: 'tst-9a99');

        expect(valorCampo(tester, 'Placa'), 'TST9A99');

        expect(valorCampo(tester, 'Marca'), 'FIAT');

        expect(valorCampo(tester, 'Modelo'), 'ARGO');

        expect(valorCampo(tester, 'Cor'), 'PRATA');
      });
    });

    for (final rotulo in ['Placa', 'Marca', 'Modelo', 'Cor']) {
      testWidgets('deve exigir campo $rotulo', (tester) async {
        prepararWidgetTeste(tester);
        final ambiente = ambienteVeiculos();

        await ambiente.executar(() async {
          await abrirTela(tester, const VeiculosScreen());

          await novoVeiculo(tester);
          await preencherVeiculo(tester);
          await preencherCampo(tester, rotulo, '');

          await tocar(tester, find.text('Cadastrar veículo'));

          expect(find.text('Preencha todos os campos.'), findsOneWidget);

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    for (final placa in ['ABC', '1234567', 'ABCDEFG', 'ABC1DE2']) {
      testWidgets('deve rejeitar placa $placa', (tester) async {
        prepararWidgetTeste(tester);
        final ambiente = ambienteVeiculos();

        await ambiente.executar(() async {
          await abrirTela(tester, const VeiculosScreen());

          await novoVeiculo(tester);

          await preencherVeiculo(tester, placa: placa);

          await tocar(tester, find.text('Cadastrar veículo'));

          expect(
            find.text('Informe uma placa válida, como ABC1234 ou ABC1D23.'),
            findsOneWidget,
          );

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    for (final placa in ['TST9999', 'TST9A99']) {
      testWidgets('deve cadastrar placa valida $placa', (tester) async {
        prepararWidgetTeste(tester);
        final ambiente = ambienteVeiculos();

        await ambiente.executar(() async {
          await abrirTela(tester, const VeiculosScreen());

          await novoVeiculo(tester);

          await preencherVeiculo(tester, placa: placa);

          await tocar(tester, find.text('Cadastrar veículo'));

          expect(find.text('Veículo cadastrado com sucesso!'), findsOneWidget);

          expect(find.text(placa), findsOneWidget);
          expect(campo('Placa'), findsNothing);

          expect(ambiente.requisicoes, hasLength(3));

          expect(ambiente.requisicoes[1].bodyFields, {
            'placa': placa,
            'marca': 'FIAT',
            'modelo': 'ARGO',
            'cor': 'PRATA',
          });
        });
      });
    }

    testWidgets('deve cancelar cadastro sem enviar POST', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await novoVeiculo(tester);
        await preencherVeiculo(tester);

        await tocar(tester, find.text('Cancelar'));

        expect(campo('Placa'), findsNothing);
        expect(ambiente.requisicoes, hasLength(1));

        await novoVeiculo(tester);

        expect(valorCampo(tester, 'Placa'), isEmpty);
      });
    });

    testWidgets('deve apresentar conflito de placa', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteVeiculos(
        erro: 409,
        mensagem: 'Esta placa já está cadastrada.',
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await novoVeiculo(tester);
        await preencherVeiculo(tester);

        await tocar(tester, find.text('Cadastrar veículo'));

        expect(find.text('Esta placa já está cadastrada.'), findsOneWidget);

        expect(campo('Placa'), findsOneWidget);
        expect(ambiente.requisicoes, hasLength(2));
      });
    });
  });

  group('Veiculos - Edicao', () {
    testWidgets('deve preencher dados existentes', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.text('Editar'));

        expect(valorCampo(tester, 'Placa'), 'TST1A01');

        expect(valorCampo(tester, 'Marca'), 'VOLKSWAGEN');

        expect(valorCampo(tester, 'Modelo'), 'POLO');

        expect(valorCampo(tester, 'Cor'), 'BRANCO');
      });
    });

    testWidgets('deve atualizar veiculo pelo ID', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.text('Editar'));

        await preencherCampo(tester, 'Cor', 'azul');

        await tocar(tester, find.text('Salvar alterações'));

        expect(find.text('Veículo atualizado com sucesso!'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(3));

        expect(ambiente.requisicoes[1].bodyFields, {
          'idVeiculo': '201',
          'placa': 'TST1A01',
          'marca': 'VOLKSWAGEN',
          'modelo': 'POLO',
          'cor': 'AZUL',
        });

        await tocar(tester, find.text('Editar'));

        expect(valorCampo(tester, 'Cor'), 'AZUL');
      });
    });

    testWidgets('deve cancelar edicao sem alterar dados', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.text('Editar'));

        await preencherCampo(tester, 'Cor', 'azul');

        await tocar(tester, find.text('Cancelar'));

        await tocar(tester, find.text('Editar'));

        expect(valorCampo(tester, 'Cor'), 'BRANCO');

        expect(ambiente.requisicoes, hasLength(1));
      });
    });
  });

  group('Veiculos - Exclusao', () {
    testWidgets('deve solicitar confirmacao', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.byTooltip('Excluir veículo'));

        expect(find.byType(AlertDialog), findsOneWidget);

        expect(find.textContaining('TST1A01').last, findsOneWidget);

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve preservar veiculo ao cancelar', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.byTooltip('Excluir veículo'));

        await tocar(tester, find.text('Cancelar'));

        expect(find.text('TST1A01'), findsOneWidget);
        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve excluir e atualizar listagem', (tester) async {
      prepararWidgetTeste(tester);
      final ambiente = ambienteVeiculos();

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.byTooltip('Excluir veículo'));

        await tocar(tester, find.text('Excluir'));

        expect(find.text('TST1A01'), findsNothing);

        expect(find.text('Nenhum veículo cadastrado'), findsOneWidget);

        expect(ambiente.requisicoes, hasLength(2));

        expect(ambiente.requisicoes.last.bodyFields, {'idVeiculo': '201'});
      });
    });

    testWidgets('deve preservar veiculo com pendencias', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambienteVeiculos(
        erro: 409,
        mensagem: 'Este veículo possui agendamentos ou atendimentos pendentes.',
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const VeiculosScreen());

        await tocar(tester, find.byTooltip('Excluir veículo'));

        await tocar(tester, find.text('Excluir'));

        expect(
          find.textContaining('agendamentos ou atendimentos pendentes'),
          findsOneWidget,
        );

        expect(find.text('TST1A01'), findsOneWidget);
      });
    });
  });
}
