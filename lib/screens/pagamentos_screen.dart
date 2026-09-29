import 'package:flutter/material.dart';

import '../models/pagamento.dart';
import '../services/api_service.dart';

class PagamentosScreen
    extends StatefulWidget {

  const PagamentosScreen({
    super.key,
  });

  @override
  State<PagamentosScreen>
      createState() =>
          _PagamentosScreenState();
}


class _PagamentosScreenState
    extends State<PagamentosScreen> {

  List<Pagamento> pagamentos = [];

  bool carregando = true;


  @override
  void initState() {
    super.initState();

    carregarPagamentos();
  }


  // ==========================================
  // CARREGAR
  // ==========================================

  Future<void>
      carregarPagamentos() async {

    try {

      final List<Pagamento> resultado =
          await ApiService
              .listarPagamentos();

      if (!mounted) {
        return;
      }

      setState(() {
        pagamentos = resultado;
      });

    } catch (e) {

      if (!mounted) {
        return;
      }

      mostrarErro(e);

    } finally {

      if (mounted) {

        setState(() {
          carregando = false;
        });
      }
    }
  }


  // ==========================================
  // FILTROS
  // ==========================================

  List<Pagamento>
      get pagamentosPendentes {

    return pagamentos
        .where(
          (pagamento) =>
              pagamento.statusPagamento ==
                  'PENDENTE',
        )
        .toList();
  }


  List<Pagamento>
      get pagamentosPagos {

    return pagamentos
        .where(
          (pagamento) =>
              pagamento.statusPagamento ==
                  'PAGO',
        )
        .toList();
  }


  // ==========================================
  // CONFIRMAR PAGAMENTO
  // ==========================================

  Future<void> confirmarPagamento(
    Pagamento pagamento,
  ) async {

    String? formaPagamento;


    final String? formaEscolhida =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setStateDialog,
          ) {
            return AlertDialog(
              title: const Text(
                'Forma de Pagamento',
              ),
              content: RadioGroup<String>(
                groupValue: formaPagamento,
                onChanged: (valor) {
                  setStateDialog(() {
                    formaPagamento = valor;
                  });
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text('PIX'),
                      value: 'PIX',
                    ),
                    RadioListTile<String>(
                      title: Text('Crédito'),
                      value: 'CREDITO',
                    ),
                    RadioListTile<String>(
                      title: Text('Débito'),
                      value: 'DEBITO',
                    ),
                    RadioListTile<String>(
                      title: Text('Dinheiro'),
                      value: 'DINHEIRO',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: formaPagamento == null
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            formaPagamento,
                          );
                        },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (formaEscolhida == null) {
      return;
    }

    if (!mounted) {
      return;
    }


    final bool? confirmar =
        await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            'Confirmar Pagamento',
          ),

          content:
              Text(
            'Confirmar pagamento de '
            'R\$ ${pagamento.valor.toStringAsFixed(2)} '
            'via ${nomeFormaPagamento(formaEscolhida)}?',
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'Não',
              ),
            ),

            ElevatedButton(
              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
                  const Text(
                'Sim, pagar',
              ),
            ),
          ],
        );
      },
    );


    if (confirmar != true) {
      return;
    }


    try {

      final String mensagem =
          await ApiService
              .realizarPagamento(
        idAgendamento:
            pagamento.idAgendamento,

        formaPagamento:
            formaEscolhida,
      );


      await carregarPagamentos();


      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
          ),
        ),
      );


    } catch (e) {

      if (!mounted) {
        return;
      }

      mostrarErro(e);
    }
  }


  // ==========================================
  // NOME DA FORMA DE PAGAMENTO
  // ==========================================

  String nomeFormaPagamento(
    String forma,
  ) {

    switch (forma) {

      case 'PIX':
        return 'PIX';

      case 'CREDITO':
        return 'Crédito';

      case 'DEBITO':
        return 'Débito';

      case 'DINHEIRO':
        return 'Dinheiro';

      default:
        return forma;
    }
  }


  // ==========================================
  // CARD
  // ==========================================

  Widget criarCardPagamento(
    Pagamento pagamento,
  ) {

    final bool pago =
        pagamento.statusPagamento ==
            'PAGO';


    return Card(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child:
          Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              pagamento.veiculo,

              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Serviços: '
              '${pagamento.servicos}',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Valor: R\$ '
              '${pagamento.valor.toStringAsFixed(2)}',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              pago
                  ? 'Status do pagamento: Pago'
                  : 'Status do pagamento: Pendente',

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),


            if (
              pago &&
              pagamento
                  .formaPagamento
                  .isNotEmpty
            ) ...[

              const SizedBox(
                height: 8,
              ),

              Text(
                'Forma de pagamento: '
                '${nomeFormaPagamento(
                  pagamento
                      .formaPagamento,
                )}',
              ),
            ],


            if (
              pago &&
              pagamento
                  .dataPagamento
                  .isNotEmpty
            ) ...[

              const SizedBox(
                height: 8,
              ),

              Text(
                'Data do pagamento: '
                '${pagamento.dataPagamento}',
              ),
            ],


            if (!pago) ...[

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed: () {

                    confirmarPagamento(
                      pagamento,
                    );
                  },

                  child:
                      const Text(
                    'Pagar',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  // ==========================================
  // ERRO
  // ==========================================

  void mostrarErro(
    Object erro,
  ) {

    String mensagem =
        erro.toString();


    mensagem =
        mensagem.replaceFirst(
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
  }


  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar:
          AppBar(
        title:
            const Text(
          'Pagamentos',
        ),
      ),


      body:
          carregando

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : RefreshIndicator(

                  onRefresh:
                      carregarPagamentos,

                  child:
                      ListView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    children: [

                      const Text(
                        'Pagamentos Pendentes',

                        style:
                            TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),


                      if (
                        pagamentosPendentes
                            .isEmpty
                      )

                        const Text(
                          'Nenhum pagamento pendente',
                        ),


                      ...pagamentosPendentes
                          .map(
                        criarCardPagamento,
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      const Text(
                        'Pagamentos Realizados',

                        style:
                            TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),


                      if (
                        pagamentosPagos
                            .isEmpty
                      )

                        const Text(
                          'Nenhum pagamento realizado',
                        ),


                      ...pagamentosPagos
                          .map(
                        criarCardPagamento,
                      ),
                    ],
                  ),
                ),
    );
  }
}