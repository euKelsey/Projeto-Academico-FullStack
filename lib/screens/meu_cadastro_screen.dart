import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sessao_cliente.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';


class MeuCadastroScreen
    extends StatefulWidget {

  const MeuCadastroScreen({
    super.key,
  });


  @override
  State<MeuCadastroScreen> createState() =>
      _MeuCadastroScreenState();
}


class _MeuCadastroScreenState
    extends State<MeuCadastroScreen> {

  final TextEditingController
      nomeController =
      TextEditingController();

  final TextEditingController
      telefoneController =
      TextEditingController();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      cpfController =
      TextEditingController();


  bool carregando = true;
  bool salvando = false;


  // =====================================================
  // INICIAR
  // =====================================================

  @override
  void initState() {

    super.initState();

    carregarCadastro();
  }


  // =====================================================
  // CARREGAR CADASTRO
  // =====================================================

  Future<void> carregarCadastro() async {

    try {

      final Cliente cliente =
          await ApiService
              .buscarMeuCadastro();


      SessaoCliente.iniciar(
        cliente,
      );


      if (!mounted) {
        return;
      }


      nomeController.text =
          cliente.nome.toUpperCase();

      telefoneController.text =
          formatarTelefone(
        cliente.telefone,
      );

      emailController.text =
          cliente.email;

      cpfController.text =
          formatarCpf(
        cliente.cpf,
      );

    } catch (e) {

      if (!mounted) {
        return;
      }


      mostrarMensagem(
        e.toString().replaceFirst(
              'Exception: ',
              '',
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


  // =====================================================
  // SALVAR
  // =====================================================

  Future<void> salvar() async {

    final String nome =
        nomeController.text
            .trim()
            .toUpperCase();

    final String telefone =
        somenteNumeros(
          telefoneController.text,
        );

    final String email =
        emailController.text.trim();


    if (
        nome.isEmpty ||
        telefone.isEmpty ||
        email.isEmpty) {

      mostrarMensagem(
        'Preencha todos os campos.',
      );

      return;
    }


    if (telefone.length < 10) {

      mostrarMensagem(
        'Informe um telefone válido.',
      );

      return;
    }


    if (
        !email.contains('@') ||
        !email.contains('.')) {

      mostrarMensagem(
        'Informe um e-mail válido.',
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


      SessaoCliente.iniciar(
        clienteAtualizado,
      );


      if (!mounted) {
        return;
      }


      nomeController.text =
          clienteAtualizado.nome
              .toUpperCase();

      telefoneController.text =
          formatarTelefone(
        clienteAtualizado.telefone,
      );

      emailController.text =
          clienteAtualizado.email;

      cpfController.text =
          formatarCpf(
        clienteAtualizado.cpf,
      );


      mostrarMensagem(
        'Dados atualizados com sucesso!',
      );

    } catch (e) {

      if (!mounted) {
        return;
      }


      mostrarMensagem(
        e.toString().replaceFirst(
              'Exception: ',
              '',
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


  // =====================================================
  // UTILITÁRIOS
  // =====================================================

  String somenteNumeros(
    String valor,
  ) {

    return valor.replaceAll(
      RegExp(r'\D'),
      '',
    );
  }


  String formatarCpf(
    String cpf,
  ) {

    final String numeros =
        somenteNumeros(cpf);


    if (numeros.length != 11) {

      return cpf;
    }


    return
        '${numeros.substring(0, 3)}.'
        '${numeros.substring(3, 6)}.'
        '${numeros.substring(6, 9)}-'
        '${numeros.substring(9, 11)}';
  }


  String formatarTelefone(
    String telefone,
  ) {

    final String numeros =
        somenteNumeros(
          telefone,
        );


    if (numeros.length == 11) {

      return
          '(${numeros.substring(0, 2)}) '
          '${numeros.substring(2, 7)}-'
          '${numeros.substring(7, 11)}';
    }


    if (numeros.length == 10) {

      return
          '(${numeros.substring(0, 2)}) '
          '${numeros.substring(2, 6)}-'
          '${numeros.substring(6, 10)}';
    }


    return telefone;
  }


  void mostrarMensagem(
    String mensagem,
  ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content:
            Text(
          mensagem,
        ),
      ),
    );
  }


  @override
  void dispose() {

    nomeController.dispose();

    telefoneController.dispose();

    emailController.dispose();

    cpfController.dispose();

    super.dispose();
  }


  // =====================================================
  // TELA
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Scaffold(

      appBar:
          AppBar(

        title:
            const Text(
          'Meu Cadastro',
        ),
      ),


      body:
          carregando

              ? const Center(

                  child:
                      CircularProgressIndicator(),
                )

              : SingleChildScrollView(

                  physics:
                      const ClampingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    30,
                  ),

                  child:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                    children: [

                      // =================================
                      // CARD DE PERFIL
                      // =================================

                      Container(

                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              cores
                                  .surfaceContainerHighest,

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),

                          border:
                              Border.all(

                            color:
                                cores
                                    .outlineVariant,
                          ),
                        ),

                        child:
                            Row(

                          children: [

                            Container(

                              width: 58,
                              height: 58,

                              decoration:
                                  BoxDecoration(

                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),

                                gradient:
                                    LinearGradient(

                                  begin:
                                      Alignment.topLeft,

                                  end:
                                      Alignment.bottomRight,

                                  colors: [

                                    cores.primary,

                                    cores.secondary,
                                  ],
                                ),
                              ),

                              child:
                                  Icon(

                                Icons.person_outline,

                                color:
                                    cores.onPrimary,

                                size: 30,
                              ),
                            ),


                            const SizedBox(
                              width: 16,
                            ),


                            Expanded(

                              child:
                                  Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    'Dados da conta',

                                    style:
                                        TextStyle(

                                      color:
                                          cores.onSurface,

                                      fontSize: 18,

                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),


                                  const SizedBox(
                                    height: 5,
                                  ),


                                  Text(
                                    'Atualize suas informações de contato.',

                                    style:
                                        TextStyle(

                                      color:
                                          cores.onSurface
                                              .withValues(
                                            alpha: 0.60,
                                          ),

                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      // =================================
                      // NOME
                      // =================================

                      TextField(

                        controller:
                            nomeController,

                        enabled:
                            !salvando,

                        textCapitalization:
                            TextCapitalization.characters,

                        inputFormatters: [

                          UpperCaseTextFormatter(),
                        ],

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Nome completo',

                          prefixIcon:
                              Icon(
                            Icons.person_outline,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 14,
                      ),


                      // =================================
                      // TELEFONE
                      // =================================

                      TextField(

                        controller:
                            telefoneController,

                        enabled:
                            !salvando,

                        keyboardType:
                            TextInputType.phone,

                        inputFormatters: [

                          FilteringTextInputFormatter
                              .digitsOnly,

                          TelefoneInputFormatter(),
                        ],

                        decoration:
                            const InputDecoration(

                          labelText:
                              'Telefone',

                          hintText:
                              '(00) 00000-0000',

                          prefixIcon:
                              Icon(
                            Icons.phone_outlined,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 14,
                      ),


                      // =================================
                      // E-MAIL
                      // =================================

                      TextField(

                        controller:
                            emailController,

                        enabled:
                            !salvando,

                        keyboardType:
                            TextInputType.emailAddress,

                        decoration:
                            const InputDecoration(

                          labelText:
                              'E-mail',

                          hintText:
                              'cliente@email.com',

                          prefixIcon:
                              Icon(
                            Icons.email_outlined,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 14,
                      ),


                      // =================================
                      // CPF
                      // =================================

                      TextField(

                        controller:
                            cpfController,

                        readOnly: true,

                        decoration:
                            InputDecoration(

                          labelText:
                              'CPF',

                          prefixIcon:
                              const Icon(
                            Icons.badge_outlined,
                          ),

                          suffixIcon:
                              Icon(
                            Icons.lock_outline,

                            color:
                                cores.onSurface
                                    .withValues(
                                  alpha: 0.45,
                                ),
                          ),

                          helperText:
                              'O CPF não pode ser alterado.',
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      // =================================
                      // BOTÃO SALVAR
                      // =================================

                      SizedBox(

                        width:
                            double.infinity,

                        child:
                            ElevatedButton.icon(

                          onPressed:
                              salvando
                                  ? null
                                  : salvar,

                          icon:
                              salvando

                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )

                                  : const Icon(
                                      Icons.save_outlined,
                                    ),

                          label:
                              Text(

                            salvando
                                ? 'Salvando...'
                                : 'Salvar alterações',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


// =====================================================
// FORMATADOR PARA MAIÚSCULAS
// =====================================================

class UpperCaseTextFormatter
    extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    return newValue.copyWith(

      text:
          newValue.text.toUpperCase(),

      selection:
          newValue.selection,
    );
  }
}


// =====================================================
// MÁSCARA DE TELEFONE
// =====================================================

class TelefoneInputFormatter
    extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    String numeros =
        newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    );


    if (numeros.length > 11) {

      numeros =
          numeros.substring(
        0,
        11,
      );
    }


    String texto = '';


    if (numeros.isNotEmpty) {

      texto += '(';


      if (numeros.length >= 2) {

        texto +=
            numeros.substring(
          0,
          2,
        );

        texto += ') ';

      } else {

        texto += numeros;
      }
    }


    if (numeros.length > 2) {

      if (numeros.length <= 10) {

        final int fim =
            numeros.length > 6
                ? 6
                : numeros.length;


        texto +=
            numeros.substring(
          2,
          fim,
        );


        if (numeros.length > 6) {

          texto +=
              '-${numeros.substring(6)}';
        }

      } else {

        final int fim =
            numeros.length > 7
                ? 7
                : numeros.length;


        texto +=
            numeros.substring(
          2,
          fim,
        );


        if (numeros.length > 7) {

          texto +=
              '-${numeros.substring(7)}';
        }
      }
    }


    return TextEditingValue(

      text:
          texto,

      selection:
          TextSelection.collapsed(
        offset:
            texto.length,
      ),
    );
  }
}