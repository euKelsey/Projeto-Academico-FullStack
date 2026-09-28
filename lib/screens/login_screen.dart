import 'package:flutter/material.dart';

import '../data/sessao_cliente.dart';
import '../services/api_service.dart';

import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController senhaController =
      TextEditingController();

  bool carregando = false;

  // ==========================================
  // LOGIN
  // ==========================================

  Future<void> entrar() async {
    final String email =
        emailController.text.trim();

    final String senha =
        senhaController.text;

    // CAMPOS VAZIOS
    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha o e-mail e a senha',
          ),
        ),
      );

      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      // ======================================
      // CHAMA A API
      // ======================================

      final cliente =
          await ApiService.loginCliente(
        email: email,
        senha: senha,
      );

      // ======================================
      // SALVA CLIENTE LOGADO NO FLUTTER
      // ======================================

      SessaoCliente.iniciar(
        cliente,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login realizado com sucesso!',
          ),
        ),
      );

      // ======================================
      // ABRE A HOME
      // ======================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem =
          e.toString();

      mensagem =
          mensagem.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // =================================
              // IMAGEM
              // =================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/fast_splash.png',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              // =================================
              // EMAIL
              // =================================

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                enabled: !carregando,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText:
                      'Digite seu e-mail',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // =================================
              // SENHA
              // =================================

              TextField(
                controller: senhaController,
                obscureText: true,
                enabled: !carregando,
                onSubmitted: (_) {
                  if (!carregando) {
                    entrar();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText:
                      'Digite sua senha',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =================================
              // ENTRAR
              // =================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      carregando
                          ? null
                          : entrar,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .inverseSurface,
                    foregroundColor:
                        Theme.of(context)
                            .colorScheme
                            .onInverseSurface,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                  ),
                  child: carregando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // =================================
              // CRIAR CONTA
              // =================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed:
                      carregando
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CadastroScreen(),
                                ),
                              );
                            },
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Theme.of(context)
                            .colorScheme
                            .onSurface,
                    side: BorderSide(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}