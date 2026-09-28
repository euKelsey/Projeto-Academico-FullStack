import 'package:flutter/material.dart';

import '../data/sessao_cliente.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';

class MeuCadastroScreen extends StatefulWidget {
  const MeuCadastroScreen({super.key});

  @override
  State<MeuCadastroScreen> createState() =>
      _MeuCadastroScreenState();
}

class _MeuCadastroScreenState
    extends State<MeuCadastroScreen> {
  final TextEditingController nomeController =
      TextEditingController();

  final TextEditingController telefoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController cpfController =
      TextEditingController();

  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();

    carregarCadastro();
  }

  // ==========================================
  // CARREGAR DADOS DO CLIENTE
  // ==========================================

  Future<void> carregarCadastro() async {
    try {
      final Cliente cliente =
          await ApiService.buscarMeuCadastro();

      SessaoCliente.iniciar(
        cliente,
      );

      if (!mounted) {
        return;
      }

      nomeController.text =
          cliente.nome;

      telefoneController.text =
          cliente.telefone;

      emailController.text =
          cliente.email;

      cpfController.text =
          cliente.cpf;
    } catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem =
          e.toString();

      mensagem = mensagem.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  // ==========================================
  // SALVAR ALTERAÇÕES
  // ==========================================

  Future<void> salvar() async {
    final String nome =
        nomeController.text.trim();

    final String telefone =
        telefoneController.text.trim();

    final String email =
        emailController.text.trim();

    if (nome.isEmpty ||
        telefone.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos.',
          ),
        ),
      );

      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final Cliente clienteAtualizado =
          await ApiService
              .atualizarMeuCadastro(
        nome: nome,
        telefone: telefone,
        email: email,
      );

      // Atualiza também a sessão local.
      SessaoCliente.iniciar(
        clienteAtualizado,
      );

      if (!mounted) {
        return;
      }

      nomeController.text =
          clienteAtualizado.nome;

      telefoneController.text =
          clienteAtualizado.telefone;

      emailController.text =
          clienteAtualizado.email;

      cpfController.text =
          clienteAtualizado.cpf;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Dados atualizados com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      String mensagem =
          e.toString();

      mensagem = mensagem.replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    cpfController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Cadastro',
        ),
      ),
      body: carregando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    24.0,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      // =========================
                      // NOME
                      // =========================

                      TextField(
                        controller:
                            nomeController,
                        enabled: !salvando,
                        decoration:
                            const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon:
                              Icon(
                            Icons.person,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =========================
                      // TELEFONE
                      // =========================

                      TextField(
                        controller:
                            telefoneController,
                        enabled: !salvando,
                        keyboardType:
                            TextInputType
                                .phone,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Telefone',
                          prefixIcon:
                              Icon(
                            Icons.phone,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =========================
                      // E-MAIL
                      // =========================

                      TextField(
                        controller:
                            emailController,
                        enabled: !salvando,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'E-mail',
                          prefixIcon:
                              Icon(
                            Icons.email,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =========================
                      // CPF
                      // =========================

                      TextField(
                        controller:
                            cpfController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'CPF',
                          prefixIcon:
                              Icon(
                            Icons.badge,
                          ),
                          border:
                              OutlineInputBorder(),
                          helperText:
                              'O CPF não pode ser alterado.',
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =========================
                      // SALVAR
                      // =========================

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,
                        child:
                            ElevatedButton(
                          onPressed:
                              salvando
                                  ? null
                                  : salvar,
                          child: salvando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                  ),
                                )
                              : const Text(
                                  'Salvar Alterações',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}