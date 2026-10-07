import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(
    const FastSplashApp(),
  );
}

class FastSplashApp
    extends StatelessWidget {
  const FastSplashApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ValueListenableBuilder<
        ThemeMode>(
      valueListenable:
          themeModeNotifier,
      builder: (
        context,
        themeMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner:
              false,
          title: 'Fast Splash',

          themeMode: themeMode,

          theme:
              FastSplashTheme.lightTheme,

          darkTheme:
              FastSplashTheme.darkTheme,

          scrollBehavior:
              const FastSplashScrollBehavior(),

          home:
              const LoginScreen(),
        );
      },
    );
  }
}
