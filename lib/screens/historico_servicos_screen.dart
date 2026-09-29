import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/pagamento.dart';
import '../services/api_service.dart';

class HistoricoServicosScreen
    extends StatefulWidget {

  const HistoricoServicosScreen({
    super.key,
  });

  @override
  State<HistoricoServicosScreen>
      createState() =>
          _HistoricoServicosScreenState();
}


class _HistoricoServicosScreenState
    extends State<HistoricoServicosScreen> {

  List<Agendamento> agendamentos = [];
  List<Pagamento> pagamentos = [];

  bool carregando = true;


  @override
  void initState() {
    super.initState();

    carregarHistorico();
  }


  // ==========================================
  // CARREGAR
  // ==========================================

  Future<void> carregarHistorico() async {

    try {

      final List<Agendamento>
          agendamentosResultado =
          await ApiService
              .listarAgendamentos();


      final List<Pagamento>
          pagamentosResultado =
          await ApiService
              .listarPagamentos();


      if (!mounted) {
        return;
      }


      setState(() {

        agendamentos =
            agendamentosResultado;

        pagamentos =
            pagamentosResultado;
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
  // HISTÓRICO
  // ==========================================

  List<Agendamento> get historico {

    return agendamentos
        .where(
          (agendamento) =>
              agendamento.status ==
                  'Finalizado'
              ||
              agendamento.status ==
                  'Cancelado',
        )
        .toList();
  }


  // ==========================================
  // BUSCAR PAGAMENTO DO AGENDAMENTO
  // ==========================================

  Pagamento? buscarPagamento(
    int idAgendamento,
  ) {

    for (
      final Pagamento pagamento
          in pagamentos
    ) {

      if (
        pagamento.idAgendamento ==
            idAgendamento
      ) {

        return pagamento;
      }
    }

    return null;
  }


  // ==========================================
  // NOME DA FORMA
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
  // STATUS DO PAGAMENTO
  // ==========================================

  String textoPagamento(
    Agendamento agendamento,
  ) {

    if (
      agendamento.status ==
          'Cancelado'
    ) {

      return 'Pagamento: Não realizado';
    }


    final Pagamento? pagamento =
        buscarPagamento(
      agendamento.idAgendamento,
    );


    if (
      pagamento == null
      ||
      pagamento.statusPagamento ==
          'PENDENTE'
    ) {

      return 'Pagamento: Pendente';
    }


    if (
      pagamento.statusPagamento ==
          'PAGO'
    ) {

      return 'Pagamento: Pago';
    }


    return 'Pagamento: '
        '${pagamento.statusPagamento}';
  }


  // ==========================================
  // DETALHES
  // ==========================================

  void abrirDetalhes(
    Agendamento agendamento,
  ) {

    final String nomesServicos =
        agendamento.servicos
            .map(
              (servico) =>
                  servico.nome,
            )
            .join(', ');


    final Pagamento? pagamento =
        buscarPagamento(
      agendamento.idAgendamento,
    );


    final bool pago =
        pagamento != null
        &&
        pagamento.statusPagamento ==
            'PAGO';


    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
            'Detalhes do Serviço',
          ),

          content:
              SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Veículo: '
                  '${agendamento.veiculo.marca} '
                  '${agendamento.veiculo.modelo}',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Placa: '
                  '${agendamento.veiculo.placa}',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Serviços: '
                  '$nomesServicos',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Data: '
                  '${agendamento.data}',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Horário: '
                  '${agendamento.horario}',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Valor: R\$ '
                  '${agendamento.valorTotal.toStringAsFixed(2)}',
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Status: '
                  '${agendamento.status}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Divider(),

                const SizedBox(
                  height: 12,
                ),

                const Text(
                  'Pagamento',
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  textoPagamento(
                    agendamento,
                  ),
                ),


                if (pago) ...[

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

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Data do pagamento: '
                    '${pagamento.dataPagamento}',
                  ),
                ],
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text(
                'Fechar',
              ),
            ),
          ],
        );
      },
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

    final List<Agendamento>
        listaHistorico =
        historico;


    return Scaffold(

      appBar:
          AppBar(
        title:
            const Text(
          'Histórico de Serviços',
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
                      carregarHistorico,

                  child:
                      listaHistorico.isEmpty

                          ? ListView(

                              physics:
                                  const AlwaysScrollableScrollPhysics(),

                              children:
                                  const [

                                SizedBox(
                                  height:
                                      250,
                                ),

                                Center(
                                  child:
                                      Text(
                                    'Nenhum serviço no histórico',
                                  ),
                                ),
                              ],
                            )

                          : ListView.builder(

                              physics:
                                  const AlwaysScrollableScrollPhysics(),

                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),

                              itemCount:
                                  listaHistorico
                                      .length,

                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {

                                final Agendamento
                                    agendamento =
                                    listaHistorico[
                                        index
                                    ];


                                final String
                                    nomesServicos =
                                    agendamento
                                        .servicos
                                        .map(
                                          (
                                            servico,
                                          ) =>
                                              servico.nome,
                                        )
                                        .join(
                                          ', ',
                                        );


                                final Pagamento?
                                    pagamento =
                                    buscarPagamento(
                                  agendamento
                                      .idAgendamento,
                                );


                                final bool pago =
                                    pagamento != null
                                    &&
                                    pagamento
                                            .statusPagamento ==
                                        'PAGO';


                                return Card(

                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 16,
                                  ),

                                  child:
                                      ListTile(

                                    leading:
                                        Icon(

                                      agendamento.status ==
                                              'Finalizado'

                                          ? Icons
                                              .check_circle

                                          : Icons
                                              .cancel,
                                    ),

                                    title:
                                        Text(
                                      '${agendamento.veiculo.marca} '
                                      '${agendamento.veiculo.modelo}',
                                    ),

                                    subtitle:
                                        Column(

                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        Text(
                                          'Serviços: '
                                          '$nomesServicos',
                                        ),

                                        Text(
                                          'Data: '
                                          '${agendamento.data}',
                                        ),

                                        Text(
                                          'Horário: '
                                          '${agendamento.horario}',
                                        ),

                                        Text(
                                          'Status: '
                                          '${agendamento.status}',
                                        ),

                                        Text(
                                          'Valor: R\$ '
                                          '${agendamento.valorTotal.toStringAsFixed(2)}',
                                        ),

                                        const SizedBox(
                                          height: 8,
                                        ),

                                        Text(
                                          textoPagamento(
                                            agendamento,
                                          ),
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),


                                        if (pago) ...[

                                          Text(
                                            'Forma: '
                                            '${nomeFormaPagamento(
                                              pagamento
                                                  .formaPagamento,
                                            )}',
                                          ),

                                          Text(
                                            'Pago em: '
                                            '${pagamento.dataPagamento}',
                                          ),
                                        ],
                                      ],
                                    ),

                                    trailing:
                                        const Icon(
                                      Icons
                                          .chevron_right,
                                    ),

                                    onTap: () {

                                      abrirDetalhes(
                                        agendamento,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
    );
  }
}