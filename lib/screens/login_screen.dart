import 'package:flutter/material.dart';

import '../data/sessao_cliente.dart';
import '../services/api_service.dart';
import '../theme/theme_controller.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;
  bool ocultarSenha = true;

  Future<void> entrar() async {
    final String email = emailController.text.trim();

    final String senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha o e-mail e a senha.');

      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final cliente = await ApiService.loginCliente(email: email, senha: senha);

      SessaoCliente.iniciar(cliente);

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      mostrarMensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final cores = tema.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: tema.brightness == Brightness.dark
                ? const [Color(0xFF0D1218), Color(0xFF111B25)]
                : const [Color(0xFFF7FAFD), Color(0xFFEAF2F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: const _SeletorTema(),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 260,

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: cores.surfaceContainerHighest,

                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(
                          color: cores.secondary.withValues(alpha: 0.18),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: cores.primary.withValues(alpha: 0.15),

                            blurRadius: 30,
                          ),
                        ],
                      ),

                      child: Image.asset(
                        'assets/images/fast_splash.png',

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Agende, acompanhe e cuide do seu carro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cores.onSurface.withValues(alpha: 0.62),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const SizedBox(height: 30),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !carregando,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'cliente@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: senhaController,
                      obscureText: ocultarSenha,
                      enabled: !carregando,
                      onSubmitted: (_) {
                        if (!carregando) {
                          entrar();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarSenha = !ocultarSenha;
                            });
                          },
                          icon: Icon(
                            ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: carregando ? null : entrar,
                        child: carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'FAST SPLASH',
                            style: TextStyle(
                              color: cores.onSurface.withValues(alpha: 0.50),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeletorTema extends StatelessWidget {
  const _SeletorTema();

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, modo, child) {
        return PopupMenuButton<ThemeMode>(
          tooltip: 'Tema',
          onSelected: definirTema,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  Icon(Icons.brightness_auto_outlined),
                  SizedBox(width: 10),
                  Text('Seguir aparelho'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  Icon(Icons.light_mode_outlined),
                  SizedBox(width: 10),
                  Text('Tema claro'),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  Icon(Icons.dark_mode_outlined),
                  SizedBox(width: 10),
                  Text('Tema escuro'),
                ],
              ),
            ),
          ],
          icon: Icon(
            modo == ThemeMode.system
                ? Icons.brightness_auto_outlined
                : modo == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            color: cores.secondary,
          ),
        );
      },
    );
  }
}
