import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(
  ThemeMode.system,
);

void definirTema(
  ThemeMode modo,
) {
  themeModeNotifier.value =
      modo;
}

class FastSplashTheme {
  static const Color azul =
      Color(0xFF1677FF);

  static const Color azulEscuro =
      Color(0xFF0F4FA8);

  static const Color ciano =
      Color(0xFF18C8FF);

  static const Color cianoClaro =
      Color(0xFF77E6FF);

  static const Color laranja =
      Color(0xFFFF8A1F);

  static ThemeData get darkTheme {
    const Color fundo =
        Color(0xFF0D1218);

    const Color superficie =
        Color(0xFF18212C);

    const Color card =
        Color(0xFF1B2632);

    const Color texto =
        Color(0xFFFFFFFF);

    const Color textoSecundario =
        Color(0xFF96A2B2);

    final ColorScheme esquema =
        const ColorScheme.dark(
      primary: azul,
      secondary: ciano,
      tertiary: laranja,
      surface: superficie,
      surfaceContainerHighest:
          card,
      error: Color(0xFFFF6B6B),
      onPrimary:
          Color(0xFFFFFFFF),
      onSecondary:
          Color(0xFF0D1218),
      onSurface: texto,
      onError:
          Color(0xFFFFFFFF),
      outline:
          Color(0xFF415062),
      outlineVariant:
          Color(0xFF2C3947),
    );

    return _criarTema(
      esquema: esquema,
      fundo: fundo,
      textoSecundario:
          textoSecundario,
      brilho:
          Brightness.dark,
    );
  }

  static ThemeData get lightTheme {
    const Color fundo =
        Color(0xFFF3F7FB);

    const Color superficie =
        Color(0xFFFFFFFF);

    const Color card =
        Color(0xFFEAF1F7);

    const Color texto =
        Color(0xFF111820);

    const Color textoSecundario =
        Color(0xFF667485);

    final ColorScheme esquema =
        const ColorScheme.light(
      primary: azul,
      secondary:
          Color(0xFF009FD6),
      tertiary:
          Color(0xFFE56F00),
      surface: superficie,
      surfaceContainerHighest:
          card,
      error:
          Color(0xFFBA1A1A),
      onPrimary:
          Color(0xFFFFFFFF),
      onSecondary:
          Color(0xFFFFFFFF),
      onSurface: texto,
      onError:
          Color(0xFFFFFFFF),
      outline:
          Color(0xFF8A98A8),
      outlineVariant:
          Color(0xFFD5DEE8),
    );

    return _criarTema(
      esquema: esquema,
      fundo: fundo,
      textoSecundario:
          textoSecundario,
      brilho:
          Brightness.light,
    );
  }

  static ThemeData _criarTema({
    required ColorScheme esquema,
    required Color fundo,
    required Color textoSecundario,
    required Brightness brilho,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: esquema,
      scaffoldBackgroundColor:
          fundo,

      appBarTheme:
          AppBarTheme(
        backgroundColor:
            fundo,
        foregroundColor:
            esquema.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle:
            TextStyle(
          color:
              esquema.onSurface,
          fontSize: 20,
          fontWeight:
              FontWeight.w800,
        ),
      ),

      cardTheme:
          CardThemeData(
        color: esquema
            .surfaceContainerHighest,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          side:
              BorderSide(
            color:
                esquema
                    .outlineVariant,
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: esquema
            .surfaceContainerHighest,
        labelStyle:
            TextStyle(
          color:
              esquema.onSurface
                  .withValues(
            alpha: 0.78,
          ),
        ),
        hintStyle:
            TextStyle(
          color:
              textoSecundario,
        ),
        prefixIconColor:
            esquema.secondary,
        suffixIconColor:
            textoSecundario,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                esquema
                    .outlineVariant,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                esquema
                    .outlineVariant,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                esquema.secondary,
            width: 1.5,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          borderSide:
              BorderSide(
            color:
                esquema.error,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              esquema.primary,
          foregroundColor:
              esquema.onPrimary,
          minimumSize:
              const Size(
            0,
            52,
          ),
          elevation: 0,
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w800,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              esquema.onSurface,
          minimumSize:
              const Size(
            0,
            52,
          ),
          side:
              BorderSide(
            color:
                esquema
                    .outlineVariant,
          ),
          textStyle:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w700,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      snackBarTheme:
          SnackBarThemeData(
        backgroundColor:
            brilho ==
                    Brightness.dark
                ? const Color(
                    0xFF202B38,
                  )
                : const Color(
                    0xFF18212C,
                  ),
        contentTextStyle:
            const TextStyle(
          color: Colors.white,
        ),
        behavior:
            SnackBarBehavior.floating,
      ),

      dividerTheme:
          DividerThemeData(
        color:
            esquema.outlineVariant,
      ),

      progressIndicatorTheme:
          ProgressIndicatorThemeData(
        color:
            esquema.secondary,
      ),

      textTheme:
          ThemeData(
        brightness: brilho,
      ).textTheme.apply(
            bodyColor:
                esquema.onSurface,
            displayColor:
                esquema.onSurface,
          ),
    );
  }
}

class FastSplashScrollBehavior
    extends MaterialScrollBehavior {
  const FastSplashScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
