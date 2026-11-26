import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/screens/login_screen.dart';
import 'package:lava_rapido_app/screens/home_screen.dart';
import 'package:lava_rapido_app/main.dart';
import 'package:lava_rapido_app/theme/theme_controller.dart';

import '../support/ambiente_teste.dart';
import '../support/widgets_teste.dart';

void main() {
  group('Login - Interface e validacoes', () {
    testWidgets('deve apresentar campos e identidade visual', (tester) async {
      prepararWidgetTeste(tester);

      await abrirTela(tester, const LoginScreen());

      expect(campo('E-mail'), findsOneWidget);
      expect(campo('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('FAST SPLASH'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(SessaoCliente.estaLogado, isFalse);
    });

    testWidgets('deve utilizar teclado de email', (tester) async {
      prepararWidgetTeste(tester);

      await abrirTela(tester, const LoginScreen());

      expect(
        tester.widget<TextField>(campo('E-mail')).keyboardType,
        TextInputType.emailAddress,
      );
    });

    testWidgets('deve ocultar senha inicialmente', (tester) async {
      prepararWidgetTeste(tester);

      await abrirTela(tester, const LoginScreen());

      expect(tester.widget<TextField>(campo('Senha')).obscureText, isTrue);
    });

    testWidgets('deve alternar visibilidade da senha', (tester) async {
      prepararWidgetTeste(tester);

      await abrirTela(tester, const LoginScreen());

      await preencherCampo(tester, 'Senha', senhaTeste);

      await tocar(tester, find.byIcon(Icons.visibility_outlined));

      expect(tester.widget<TextField>(campo('Senha')).obscureText, isFalse);

      await tocar(tester, find.byIcon(Icons.visibility_off_outlined));

      expect(tester.widget<TextField>(campo('Senha')).obscureText, isTrue);

      expect(valorCampo(tester, 'Senha'), senhaTeste);
    });

    for (final dados in [
      ['', ''],
      ['', senhaTeste],
      ['ativo@example.test', ''],
      ['   ', senhaTeste],
    ]) {
      testWidgets('deve rejeitar campos incompletos ${dados.first}', (
        tester,
      ) async {
        prepararWidgetTeste(tester);

        final ambiente = AmbienteApiTeste(
          (_) async => throw StateError('Nao deveria consultar API'),
        );

        await ambiente.executar(() async {
          await abrirTela(tester, const LoginScreen());

          await preencherLogin(tester, email: dados[0], senha: dados[1]);

          await tocar(tester, find.text('Entrar'));

          expect(find.text('Preencha o e-mail e a senha.'), findsOneWidget);

          expect(ambiente.requisicoes, isEmpty);
          expect(SessaoCliente.estaLogado, isFalse);
        });
      });
    }
  });

  group('Login - Integracao HTTP', () {
    testWidgets('deve autenticar e abrir tela inicial', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste((request) async {
        switch (rotaApi(request)) {
          case '/api/auth/login':
            expect(request.method, 'POST');

            expect(request.bodyFields, {
              'email': 'ativo@example.test',
              'senha': senhaTeste,
            });

            return respostaJson(
              {'cliente': clienteJson()},
              headers: {'set-cookie': 'JSESSIONID=teste123'},
            );

          case '/api/agendamentos':
            expect(cabecalho(request, 'Cookie'), 'JSESSIONID=teste123');

            return respostaJson({'agendamentos': []});

          default:
            throw StateError('Requisicao inesperada');
        }
      });

      await ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester, email: ' ativo@example.test ');

        await tocar(tester, find.text('Entrar'));

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);

        expect(find.text('Olá, Cliente Teste Ativo'), findsOneWidget);

        expect(SessaoCliente.estaLogado, isTrue);

        expect(SessaoCliente.clienteLogado!.idCliente, 101);

        expect(ambiente.requisicoes, hasLength(2));
      });
    });

    for (final caso in [
      [401, 'E-mail ou senha inválidos.'],
      [403, 'Sua conta está inativa.'],
      [500, 'Servidor indisponível.'],
    ]) {
      testWidgets('deve apresentar erro HTTP ${caso[0]}', (tester) async {
        prepararWidgetTeste(tester);

        final ambiente = AmbienteApiTeste(
          (_) async => respostaJson({
            'sucesso': false,
            'mensagem': caso[1],
          }, status: caso[0] as int),
        );

        await ambiente.executar(() async {
          await abrirTela(tester, const LoginScreen());

          await preencherLogin(tester);

          await tocar(tester, find.text('Entrar'));

          expect(find.text(caso[1] as String), findsOneWidget);

          expect(find.byType(LoginScreen), findsOneWidget);

          expect(SessaoCliente.estaLogado, isFalse);

          expect(tester.widget<TextField>(campo('E-mail')).enabled, isTrue);

          expect(ambiente.requisicoes, hasLength(1));
        });
      });
    }

    testWidgets('deve apresentar falha de conexao', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste((_) async {
        throw http.ClientException('Conexao indisponivel');
      });

      await ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester);
        await tocar(tester, find.text('Entrar'));

        expect(find.textContaining('Conexao indisponivel'), findsOneWidget);

        expect(SessaoCliente.estaLogado, isFalse);
      });
    });

    testWidgets('deve bloquear formulario durante login', (tester) async {
      prepararWidgetTeste(tester);

      final pendente = Completer<http.Response>();

      final ambiente = AmbienteApiTeste((_) => pendente.future);

      await ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester);

        final botao = find.text('Entrar');

        await tester.ensureVisible(botao);
        await tester.tap(botao);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        expect(tester.widget<TextField>(campo('E-mail')).enabled, isFalse);

        expect(tester.widget<TextField>(campo('Senha')).enabled, isFalse);

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );

        pendente.complete(
          respostaJson({'mensagem': 'Login recusado.'}, status: 401),
        );

        await tester.pumpAndSettle();

        expect(find.text('Entrar'), findsOneWidget);

        expect(tester.widget<TextField>(campo('E-mail')).enabled, isTrue);

        expect(ambiente.requisicoes, hasLength(1));
      });
    });

    testWidgets('deve encerrar sessao e retornar ao login', (tester) async {
      prepararWidgetTeste(tester);

      final ambiente = AmbienteApiTeste((request) async {
        if (rotaApi(request) == '/api/auth/login') {
          return respostaJson(
            {'cliente': clienteJson()},
            headers: {'set-cookie': 'JSESSIONID=teste123'},
          );
        }

        return respostaJson({'agendamentos': [], 'veiculos': []});
      });

      await ambiente.executar(() async {
        await abrirTela(tester, const LoginScreen());

        await preencherLogin(tester);
        await tocar(tester, find.text('Entrar'));

        expect(SessaoCliente.estaLogado, isTrue);

        await tocar(tester, find.byTooltip('Sair'));

        expect(find.byType(LoginScreen), findsOneWidget);

        expect(find.byType(HomeScreen), findsNothing);

        expect(SessaoCliente.estaLogado, isFalse);
        expect(valorCampo(tester, 'Senha'), isEmpty);
      });
    });
  });

  group('Login - Tema', () {
    for (final caso in [
      ('Tema escuro', ThemeMode.dark),
      ('Tema claro', ThemeMode.light),
      ('Seguir aparelho', ThemeMode.system),
    ]) {
      testWidgets('deve selecionar ${caso.$1}', (tester) async {
        prepararWidgetTeste(tester);

        await tester.pumpWidget(const FastSplashApp());

        await tester.pumpAndSettle();

        await tocar(tester, find.byTooltip('Tema'));

        await tocar(tester, find.text(caso.$1));

        expect(themeModeNotifier.value, caso.$2);

        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
          caso.$2,
        );
      });
    }
  });
}
