import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() =>
      _CadastroScreenState();
}

class _CadastroScreenState
    extends State<CadastroScreen> {
  final TextEditingController nomeController =
      TextEditingController();

  final TextEditingController telefoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController cpfController =
      TextEditingController();

  final TextEditingController senhaController =
      TextEditingController();

  final TextEditingController confirmarSenhaController =
      TextEditingController();

  bool carregando = false;


  // ==========================================
  // CADASTRAR
  // ==========================================

  Future<void> cadastrar() async {
    final String nome =
        nomeController.text.trim();

    final String telefone =
        telefoneController.text.trim();

    final String email =
        emailController.text.trim();

    final String cpf =
        cpfController.text.trim();

    final String senha =
        senhaController.text;

    final String confirmarSenha =
        confirmarSenhaController.text;


    // CAMPOS VAZIOS
    if (nome.isEmpty ||
        telefone.isEmpty ||
        email.isEmpty ||
        cpf.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos.',
          ),
        ),
      );

      return;
    }


    // CONFIRMAÇÃO DA SENHA
    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem.',
          ),
        ),
      );

      return;
    }


    setState(() {
      carregando = true;
    });


    try {
      final String mensagem =
          await ApiService.cadastrarCliente(
        nome: nome,
        telefone: telefone,
        email: email,
        cpf: cpf,
        senha: senha,
      );


      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
          ),
        ),
      );


      Navigator.pop(context);


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
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    cpfController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller: emailController,
              keyboardType:
                  TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller: cpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  confirmarSenhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Senha',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    carregando ? null : cadastrar,
                child: Text(
                  carregando
                      ? 'Cadastrando...'
                      : 'Criar Conta',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}