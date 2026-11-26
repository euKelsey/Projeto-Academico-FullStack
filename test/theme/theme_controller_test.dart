import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/theme/theme_controller.dart';

void main() {
  setUp(() {
    definirTema(ThemeMode.system);
  });

  tearDown(() {
    definirTema(ThemeMode.system);
  });

  group('Gerenciamento de tema', () {
    test('deve iniciar seguindo o aparelho', () {
      expect(themeModeNotifier.value, ThemeMode.system);
    });

    for (final modo in ThemeMode.values) {
      test('deve selecionar tema $modo', () {
        definirTema(modo);

        expect(themeModeNotifier.value, modo);
      });
    }

    test('deve notificar alteracao de tema', () {
      var notificacoes = 0;

      void listener() {
        notificacoes++;
      }

      themeModeNotifier.addListener(listener);

      try {
        definirTema(ThemeMode.dark);
        definirTema(ThemeMode.light);
        definirTema(ThemeMode.system);

        expect(notificacoes, 3);
      } finally {
        themeModeNotifier.removeListener(listener);
      }
    });

    test('nao deve notificar selecao repetida', () {
      var notificacoes = 0;

      void listener() {
        notificacoes++;
      }

      themeModeNotifier.addListener(listener);

      try {
        definirTema(ThemeMode.system);

        expect(notificacoes, 0);
      } finally {
        themeModeNotifier.removeListener(listener);
      }
    });
  });

  group('FastSplashTheme', () {
    test('deve configurar tema claro', () {
      expect(FastSplashTheme.lightTheme.brightness, Brightness.light);

      expect(
        FastSplashTheme.lightTheme.colorScheme.brightness,
        Brightness.light,
      );
    });

    test('deve configurar tema escuro', () {
      expect(FastSplashTheme.darkTheme.brightness, Brightness.dark);

      expect(FastSplashTheme.darkTheme.colorScheme.brightness, Brightness.dark);
    });

    test('deve manter identidade visual azul', () {
      expect(FastSplashTheme.azul, const Color(0xFF1677FF));

      expect(FastSplashTheme.ciano, const Color(0xFF18C8FF));

      expect(FastSplashTheme.laranja, const Color(0xFFFF8A1F));
    });

    test('deve diferenciar fundos claro e escuro', () {
      expect(
        FastSplashTheme.lightTheme.scaffoldBackgroundColor,
        isNot(FastSplashTheme.darkTheme.scaffoldBackgroundColor),
      );
    });
  });
}
