import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/screens/meu_cadastro_screen.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

AmbienteApiTeste ambientePerfil({Map<String, dynamic>? cliente}) {
  return AmbienteApiTeste((request) async {
    expect(rotaApi(request), '/api/clientes/me');
    expect(request.method, 'GET');

    return respostaJson({'cliente': cliente ?? clienteJson()});
  });
}

void main() {
  group('Meu Cadastro - Carregamento', () {
    testWidgets('deve apresentar dados do cliente', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePerfil();

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        expect(find.text('Meu Cadastro'), findsOneWidget);

        expect(valorCampo(tester, 'Nome completo'), 'CLIENTE TESTE ATIVO');

        expect(valorCampo(tester, 'Telefone'), '(11) 90000-0101');

        expect(valorCampo(tester, 'E-mail'), 'ativo@example.test');

        expect(valorCampo(tester, 'CPF'), '987.654.101-30');

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve proteger campo CPF', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePerfil();

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        expect(tester.widget<TextField>(campo('CPF')).readOnly, isTrue);

        expect(find.text('O CPF não pode ser alterado.'), findsOneWidget);
      });
    });

    testWidgets('deve formatar telefone fixo', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePerfil(
        cliente: clienteJson(telefone: '1134567890'),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        expect(valorCampo(tester, 'Telefone'), '(11) 3456-7890');
      });
    });

    testWidgets('deve atualizar dados da sessao', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePerfil(
        cliente: clienteJson(nome: 'CLIENTE ATUALIZADO'),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        expect(SessaoCliente.clienteLogado!.nome, 'CLIENTE ATUALIZADO');
      });
    });

    testWidgets('deve exibir carregamento inicial', (tester) async {
      prepararWidgetTeste(tester);

      final pendente = Completer<http.Response>();

      final ambiente = AmbienteApiTeste((_) => pendente.future);

      await ambiente.executar(() async {
        await tester.pumpWidget(const MaterialApp(home: MeuCadastroScreen()));

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        pendente.complete(respostaJson({'cliente': clienteJson()}));

        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);

        expect(campo('CPF'), findsOneWidget);
      });
    });

    testWidgets('deve apresentar erro ao consultar cadastro', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste(
        (_) async =>
            respostaJson({'mensagem': 'Cadastro indisponível.'}, status: 500),
      );

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen());

        expect(find.text('Cadastro indisponível.'), findsOneWidget);

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });

  group('Meu Cadastro - Validacoes', () {
    for (final rotulo in ['Nome completo', 'Telefone', 'E-mail']) {
      testWidgets('deve exigir $rotulo', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambientePerfil();

        await ambiente.executar(() async {
          await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

          await preencherCampo(tester, rotulo, '');

          await tocar(tester, find.text('Salvar alterações'));

          expect(find.text('Preencha todos os campos.'), findsOneWidget);

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    for (final telefone in ['119123', '123456789']) {
      testWidgets('deve rejeitar telefone $telefone', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambientePerfil();

        await ambiente.executar(() async {
          await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

          await preencherCampo(tester, 'Telefone', telefone);

          await tocar(tester, find.text('Salvar alterações'));

          expect(find.text('Informe um telefone válido.'), findsOneWidget);

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    for (final email in ['cliente.example.test', 'cliente@example']) {
      testWidgets('deve rejeitar email $email', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = ambientePerfil();

        await ambiente.executar(() async {
          await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

          await preencherCampo(tester, 'E-mail', email);

          await tocar(tester, find.text('Salvar alterações'));

          expect(find.text('Informe um e-mail válido.'), findsOneWidget);

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    testWidgets('deve aplicar formatadores durante digitacao', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = ambientePerfil();

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        await preencherCampo(tester, 'Nome completo', 'novo cliente');

        await preencherCampo(tester, 'Telefone', '1191234567899');

        expect(valorCampo(tester, 'Nome completo'), 'NOVO CLIENTE');

        expect(valorCampo(tester, 'Telefone'), '(11) 91234-5678');
      });
    });
  });

  group('Meu Cadastro - Atualizacao', () {
    testWidgets('deve salvar dados e preservar CPF', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste((request) async {
        expect(rotaApi(request), '/api/clientes/me');

        if (request.method == 'GET') {
          return respostaJson({'cliente': clienteJson()});
        }

        expect(request.method, 'POST');

        expect(request.bodyFields, {
          'nome': 'NOVO CLIENTE',
          'telefone': '11912345678',
          'email': 'novo@example.test',
        });

        return respostaJson({
          'cliente': clienteJson(
            nome: 'NOVO CLIENTE',
            telefone: '11912345678',
            email: 'novo@example.test',
          ),
        });
      });

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        await preencherCampo(tester, 'Nome completo', 'novo cliente');

        await preencherCampo(tester, 'Telefone', '11912345678');

        await preencherCampo(tester, 'E-mail', 'novo@example.test');

        await tocar(tester, find.text('Salvar alterações'));

        expect(find.text('Dados atualizados com sucesso!'), findsOneWidget);

        expect(SessaoCliente.clienteLogado!.nome, 'NOVO CLIENTE');

        expect(SessaoCliente.clienteLogado!.email, 'novo@example.test');

        expect(SessaoCliente.clienteLogado!.cpf, '98765410130');

        expect(valorCampo(tester, 'CPF'), '987.654.101-30');

        expect(ambiente.requisicoes, hasLength(2));
      });
    });

    for (final caso in [
      (409, 'Este e-mail já está sendo utilizado.'),
      (403, 'Sua conta está inativa.'),
      (500, 'Não foi possível salvar.'),
    ]) {
      testWidgets('deve tratar falha ao salvar ${caso.$1}', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = AmbienteApiTeste((request) async {
          if (request.method == 'GET') {
            return respostaJson({'cliente': clienteJson()});
          }

          return respostaJson({'mensagem': caso.$2}, status: caso.$1);
        });

        await ambiente.executar(() async {
          await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

          await preencherCampo(tester, 'E-mail', 'novo@example.test');

          await tocar(tester, find.text('Salvar alterações'));

          expect(find.text(caso.$2), findsOneWidget);

          expect(SessaoCliente.clienteLogado!.email, 'ativo@example.test');

          expect(valorCampo(tester, 'E-mail'), 'novo@example.test');

          expect(ambiente.requisicoes, hasLength(2));
        });
      });
    }

    testWidgets('deve bloquear campos durante salvamento', (tester) async {
      prepararWidgetTeste(tester);

      final pendente = Completer<http.Response>();

      final ambiente = AmbienteApiTeste((request) async {
        if (request.method == 'GET') {
          return respostaJson({'cliente': clienteJson()});
        }

        return pendente.future;
      });

      await ambiente.executar(() async {
        await abrirTela(tester, const MeuCadastroScreen(), autenticado: true);

        final botao = find.text('Salvar alterações');

        await tester.ensureVisible(botao);
        await tester.tap(botao);
        await tester.pump();

        expect(find.text('Salvando...'), findsOneWidget);

        for (final rotulo in ['Nome completo', 'Telefone', 'E-mail']) {
          expect(tester.widget<TextField>(campo(rotulo)).enabled, isFalse);
        }

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );

        pendente.complete(respostaJson({'cliente': clienteJson()}));

        await tester.pumpAndSettle();

        expect(find.text('Salvar alterações'), findsOneWidget);

        expect(
          tester.widget<TextField>(campo('Nome completo')).enabled,
          isTrue,
        );
      });
    });
  });
}
