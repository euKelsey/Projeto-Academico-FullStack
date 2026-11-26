import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/theme/theme_controller.dart';

import 'ambiente_teste.dart';

void prepararWidgetTeste(WidgetTester tester) {
  limparSessaoTeste();
  definirTema(ThemeMode.light);

  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1000);

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    limparSessaoTeste();
    definirTema(ThemeMode.system);
  });
}

Future<void> abrirTela(
  WidgetTester tester,
  Widget tela, {
  bool autenticado = false,
}) async {
  if (autenticado) {
    SessaoCliente.iniciar(clienteTeste);
  }

  await tester.pumpWidget(
    MaterialApp(
      theme: FastSplashTheme.lightTheme,
      darkTheme: FastSplashTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: tela,
    ),
  );

  await tester.pumpAndSettle();
}

Finder campo(String rotulo) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == rotulo,
  );
}

String valorCampo(WidgetTester tester, String rotulo) {
  return tester.widget<TextField>(campo(rotulo)).controller!.text;
}

Future<void> preencherCampo(
  WidgetTester tester,
  String rotulo,
  String valor,
) async {
  final finder = campo(rotulo);

  await tester.ensureVisible(finder);
  await tester.enterText(finder, valor);
  await tester.pump();
}

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> preencherLogin(
  WidgetTester tester, {
  String email = 'ativo@example.test',
  String senha = senhaTeste,
}) async {
  await preencherCampo(tester, 'E-mail', email);
  await preencherCampo(tester, 'Senha', senha);
}
