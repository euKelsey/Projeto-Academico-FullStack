import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../services/api_service.dart';

class StatusServicoScreen
    extends StatefulWidget {

  const StatusServicoScreen({
    super.key,
  });

  @override
  State<StatusServicoScreen>
      createState() =>
          _StatusServicoScreenState();
}


class _StatusServicoScreenState
    extends State<StatusServicoScreen> {

  List<Agendamento> agendamentos = [];

  bool carregando = true;


  @override
  void initState() {
    super.initState();

    carregarAgendamentos();
  }


  // ==========================================
  // CARREGAR
  // ==========================================

  Future<void>
      carregarAgendamentos() async {

    try {

      final resultado =
          await ApiService
              .listarAgendamentos();


      if (!mounted) {
        return;
      }


      setState(() {

        agendamentos =
            resultado;
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
  // ATIVOS
  // ==========================================

  List<Agendamento>
      get agendamentosAtivos {

    return agendamentos
        .where(
          (agendamento) =>
              agendamento.status !=
                  'Finalizado'
              &&
              agendamento.status !=
                  'Cancelado',
        )
        .toList();
  }


  // ==========================================
  // CANCELAR
  // ==========================================

  Future<void> cancelar(
    Agendamento agendamento,
  ) async {

    final bool? confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title:
              const Text(
            'Cancelar Agendamento',
          ),

          content:
              const Text(
            'Tem certeza que deseja cancelar este agendamento?',
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
                'Sim, cancelar',
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
              .cancelarAgendamento(
        agendamento
            .idAgendamento,
      );


      if (!mounted) {
        return;
      }


      Navigator.pop(context);


      await carregarAgendamentos();


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


    final bool emAndamento =
        agendamento.status ==
            'Em andamento'
        ||
        agendamento.status ==
            'Finalizado';


    final bool finalizado =
        agendamento.status ==
            'Finalizado';


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
                  CrossAxisAlignment
                      .start,

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
                  height: 24,
                ),

                const Text(
                  'Acompanhamento',
                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Text(
                      'Agendado',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [

                    Icon(
                      emAndamento
                          ? Icons
                              .check_circle
                          : Icons
                              .radio_button_unchecked,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Text(
                      'Em andamento',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  children: [

                    Icon(
                      finalizado
                          ? Icons
                              .check_circle
                          : Icons
                              .radio_button_unchecked,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Text(
                      'Finalizado',
                    ),
                  ],
                ),
              ],
            ),
          ),

          actions: [

            if (
              agendamento.status ==
                  'Agendado'
            )

              TextButton(
                onPressed: () {

                  cancelar(
                    agendamento,
                  );
                },

                child:
                    const Text(
                  'Cancelar Agendamento',
                ),
              ),


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

    final ativos =
        agendamentosAtivos;


    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          'Acompanhar Serviço',
        ),
      ),


      body: carregando

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : RefreshIndicator(
              onRefresh:
                  carregarAgendamentos,

              child: ativos.isEmpty

                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      children:
                          const [
                        SizedBox(
                          height: 250,
                        ),

                        Center(
                          child: Text(
                            'Nenhum agendamento encontrado',
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
                          ativos.length,

                      itemBuilder:
                          (
                            context,
                            index,
                          ) {

                        final Agendamento
                            agendamento =
                            ativos[index];


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


                        return Card(
                          margin:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child:
                              ListTile(
                            leading:
                                const Icon(
                              Icons
                                  .local_car_wash,
                            ),

                            title: Text(
                              '${agendamento.veiculo.marca} '
                              '${agendamento.veiculo.modelo}',
                            ),

                            subtitle:
                                Text(
                              'Serviços: '
                              '$nomesServicos\n'
                              'Data: '
                              '${agendamento.data}\n'
                              'Horário: '
                              '${agendamento.horario}\n'
                              'Status: '
                              '${agendamento.status}\n'
                              'Valor: R\$ '
                              '${agendamento.valorTotal.toStringAsFixed(2)}',
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