import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../services/api_service.dart';


class HistoricoServicosScreen
    extends StatefulWidget {

  const HistoricoServicosScreen({
    super.key,
  });


  @override
  State<HistoricoServicosScreen> createState() =>
      _HistoricoServicosScreenState();
}


class _HistoricoServicosScreenState
    extends State<HistoricoServicosScreen> {

  List<Agendamento> historico = [];

  bool carregando = true;


  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    carregarHistorico();
  }


  // =====================================================
  // CARREGAR HISTÓRICO
  // =====================================================

  Future<void> carregarHistorico() async {

    setState(() {

      carregando = true;
    });


    try {

      final List<Agendamento> resultado =
          await ApiService
              .listarAgendamentos();


      if (!mounted) {
        return;
      }


      setState(() {

        historico =
            resultado.where(
          (agendamento) {

            final String status =
                agendamento.status
                    .toUpperCase();


            return status ==
                    'CONCLUIDO' ||
                status ==
                    'FINALIZADO' ||
                status ==
                    'CANCELADO';
          },
        ).toList();
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


  // =====================================================
  // FORMATAR DATA
  // =====================================================

  String formatarData(
    String data,
  ) {

    final List<String> partes =
        data.split('-');


    if (partes.length != 3) {

      return data;
    }


    return
        '${partes[2]}/'
        '${partes[1]}/'
        '${partes[0]}';
  }


  // =====================================================
  // STATUS
  // =====================================================

  bool foiCancelado(
    Agendamento agendamento,
  ) {

    return agendamento.status
            .toUpperCase() ==
        'CANCELADO';
  }


  String nomeStatus(
    Agendamento agendamento,
  ) {

    if (foiCancelado(
      agendamento,
    )) {

      return 'Cancelado';
    }


    return 'Concluído';
  }


  // =====================================================
  // MENSAGEM DE ERRO
  // =====================================================

  void mostrarErro(
    Object erro,
  ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content:
            Text(

          erro
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
        ),
      ),
    );
  }


  // =====================================================
  // CARD DO HISTÓRICO
  // =====================================================

  Widget cardHistorico(
    Agendamento agendamento,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;

    final bool cancelado =
        foiCancelado(
      agendamento,
    );

    final Color corStatus =
        cancelado
            ? cores.error
            : Colors.green;

    final String servicos =
        agendamento.servicos
            .map(
              (servico) =>
                  servico.nome,
            )
            .join(', ');


    return InkWell(

      borderRadius:
          BorderRadius.circular(
        18,
      ),

      onTap: () {

        abrirDetalhes(
          agendamento,
        );
      },

      child:
          Container(

        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.all(
          18,
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
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =================================
            // CABEÇALHO
            // =================================

            Row(

              children: [

                Container(

                  width: 48,
                  height: 48,

                  decoration:
                      BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),

                    color:
                        corStatus
                            .withValues(
                          alpha: 0.10,
                        ),
                  ),

                  child:
                      Icon(

                    cancelado
                        ? Icons
                            .cancel_outlined
                        : Icons
                            .check_circle_outline,

                    color:
                        corStatus,
                  ),
                ),


                const SizedBox(
                  width: 14,
                ),


                Expanded(

                  child:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        '${agendamento.veiculo.marca} '
                        '${agendamento.veiculo.modelo}',

                        style:
                            TextStyle(

                          color:
                              cores.onSurface,

                          fontSize: 16,

                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),


                      const SizedBox(
                        height: 4,
                      ),


                      Text(

                        agendamento
                            .veiculo
                            .placa,

                        style:
                            TextStyle(

                          color:
                              cores.onSurface
                                  .withValues(
                                alpha: 0.55,
                              ),

                          fontSize: 12,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),


                Icon(

                  Icons.chevron_right,

                  color:
                      cores.onSurface
                          .withValues(
                        alpha: 0.40,
                      ),
                ),
              ],
            ),


            const SizedBox(
              height: 16,
            ),


            // =================================
            // STATUS
            // =================================

            Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),

              decoration:
                  BoxDecoration(

                color:
                    corStatus
                        .withValues(
                      alpha: 0.08,
                    ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                border:
                    Border.all(

                  color:
                      corStatus
                          .withValues(
                        alpha: 0.22,
                      ),
                ),
              ),

              child:
                  Row(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  Icon(

                    cancelado
                        ? Icons
                            .cancel_outlined
                        : Icons
                            .check_circle_outline,

                    color:
                        corStatus,

                    size: 14,
                  ),


                  const SizedBox(
                    width: 6,
                  ),


                  Text(

                    nomeStatus(
                      agendamento,
                    ),

                    style:
                        TextStyle(

                      color:
                          corStatus,

                      fontSize: 11,

                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(
              height: 14,
            ),


            // =================================
            // SERVIÇOS
            // =================================

            Text(

              servicos.isEmpty
                  ? 'Serviço não informado'
                  : servicos,

              style:
                  TextStyle(

                color:
                    cores.onSurface
                        .withValues(
                      alpha: 0.72,
                    ),

                fontSize: 13,

                height: 1.4,
              ),
            ),


            const SizedBox(
              height: 14,
            ),


            // =================================
            // INFORMAÇÕES
            // =================================

            Wrap(

              spacing: 8,

              runSpacing: 8,

              children: [

                chipInformacao(

                  Icons
                      .event_outlined,

                  formatarData(
                    agendamento.data,
                  ),
                ),


                chipInformacao(

                  Icons
                      .schedule_outlined,

                  agendamento.horario,
                ),


                chipInformacao(

                  Icons
                      .payments_outlined,

                  'R\$ '
                  '${agendamento.valorTotal.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // =====================================================
  // CHIP
  // =====================================================

  Widget chipInformacao(
    IconData icone,
    String texto,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(

        color:
            cores.onSurface
                .withValues(
              alpha: 0.04,
            ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(

          color:
              cores.outlineVariant,
        ),
      ),

      child:
          Row(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(

            icone,

            size: 13,

            color:
                cores.secondary,
          ),


          const SizedBox(
            width: 5,
          ),


          Text(

            texto,

            style:
                TextStyle(

              color:
                  cores.onSurface
                      .withValues(
                    alpha: 0.72,
                  ),

              fontSize: 10,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // DETALHES
  // =====================================================

  void abrirDetalhes(
    Agendamento agendamento,
  ) {

    final bool cancelado =
        foiCancelado(
      agendamento,
    );

    final String servicos =
        agendamento.servicos
            .map(
              (servico) =>
                  servico.nome,
            )
            .join(', ');


    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      backgroundColor:
          Colors.transparent,

      builder:
          (BuildContext context) {

        final ColorScheme cores =
            Theme.of(context)
                .colorScheme;

        final Color corStatus =
            cancelado
                ? cores.error
                : Colors.green;


        return Container(

          decoration:
              BoxDecoration(

            color:
                cores.surface,

            borderRadius:
                const BorderRadius.vertical(

              top:
                  Radius.circular(
                26,
              ),
            ),
          ),

          child:
              SingleChildScrollView(

            physics:
                const ClampingScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),

            child:
                Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                // =========================
                // BARRINHA
                // =========================

                Center(

                  child:
                      Container(

                    width: 42,
                    height: 4,

                    decoration:
                        BoxDecoration(

                      color:
                          cores.onSurface
                              .withValues(
                            alpha: 0.18,
                          ),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),


                const SizedBox(
                  height: 24,
                ),


                // =========================
                // TÍTULO
                // =========================

                Row(

                  children: [

                    Container(

                      width: 50,
                      height: 50,

                      decoration:
                          BoxDecoration(

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),

                        color:
                            corStatus
                                .withValues(
                              alpha: 0.10,
                            ),
                      ),

                      child:
                          Icon(

                        cancelado
                            ? Icons
                                .cancel_outlined
                            : Icons
                                .check_circle_outline,

                        color:
                            corStatus,

                        size: 27,
                      ),
                    ),


                    const SizedBox(
                      width: 14,
                    ),


                    Expanded(

                      child:
                          Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            nomeStatus(
                              agendamento,
                            ),

                            style:
                                TextStyle(

                              color:
                                  cores.onSurface,

                              fontSize: 22,

                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),


                          const SizedBox(
                            height: 3,
                          ),


                          Text(

                            cancelado
                                ? 'Este agendamento foi cancelado.'
                                : 'Este serviço foi concluído.',

                            style:
                                TextStyle(

                              color:
                                  cores.onSurface
                                      .withValues(
                                    alpha: 0.57,
                                  ),

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                const SizedBox(
                  height: 27,
                ),


                // =========================
                // VEÍCULO
                // =========================

                tituloDetalhe(
                  'Veículo',
                ),


                const SizedBox(
                  height: 8,
                ),


                valorDetalhe(

                  '${agendamento.veiculo.marca} '
                  '${agendamento.veiculo.modelo} — '
                  '${agendamento.veiculo.placa}',
                ),


                const SizedBox(
                  height: 20,
                ),


                // =========================
                // SERVIÇOS
                // =========================

                tituloDetalhe(
                  'Serviços',
                ),


                const SizedBox(
                  height: 8,
                ),


                valorDetalhe(

                  servicos.isEmpty
                      ? 'Não informado'
                      : servicos,
                ),


                const SizedBox(
                  height: 20,
                ),


                // =========================
                // DATA
                // =========================

                Row(

                  children: [

                    Expanded(

                      child:
                          blocoDetalhe(

                        titulo:
                            'Data',

                        valor:
                            formatarData(
                          agendamento.data,
                        ),

                        icone:
                            Icons
                                .calendar_month_outlined,
                      ),
                    ),


                    const SizedBox(
                      width: 12,
                    ),


                    Expanded(

                      child:
                          blocoDetalhe(

                        titulo:
                            'Horário',

                        valor:
                            agendamento.horario,

                        icone:
                            Icons
                                .schedule_outlined,
                      ),
                    ),
                  ],
                ),


                const SizedBox(
                  height: 12,
                ),


                blocoDetalhe(

                  titulo:
                      'Valor do serviço',

                  valor:
                      'R\$ '
                      '${agendamento.valorTotal.toStringAsFixed(2)}',

                  icone:
                      Icons
                          .payments_outlined,
                ),


                const SizedBox(
                  height: 28,
                ),


                OutlinedButton(

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
            ),
          ),
        );
      },
    );
  }


  // =====================================================
  // TÍTULO DO DETALHE
  // =====================================================

  Widget tituloDetalhe(
    String texto,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Text(

      texto,

      style:
          TextStyle(

        color:
            cores.onSurface
                .withValues(
              alpha: 0.55,
            ),

        fontSize: 11,

        fontWeight:
            FontWeight.w700,
      ),
    );
  }


  // =====================================================
  // VALOR DO DETALHE
  // =====================================================

  Widget valorDetalhe(
    String texto,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Text(

      texto,

      style:
          TextStyle(

        color:
            cores.onSurface,

        fontSize: 14,

        fontWeight:
            FontWeight.w700,

        height: 1.4,
      ),
    );
  }


  // =====================================================
  // BLOCO DE DETALHE
  // =====================================================

  Widget blocoDetalhe({

    required String titulo,

    required String valor,

    required IconData icone,
  }) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Container(

      padding:
          const EdgeInsets.all(
        14,
      ),

      decoration:
          BoxDecoration(

        color:
            cores
                .surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(

          color:
              cores.outlineVariant,
        ),
      ),

      child:
          Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(

            icone,

            color:
                cores.secondary,

            size: 20,
          ),


          const SizedBox(
            height: 9,
          ),


          Text(

            titulo,

            style:
                TextStyle(

              color:
                  cores.onSurface
                      .withValues(
                    alpha: 0.52,
                  ),

              fontSize: 10,

              fontWeight:
                  FontWeight.w700,
            ),
          ),


          const SizedBox(
            height: 3,
          ),


          Text(

            valor,

            style:
                TextStyle(

              color:
                  cores.onSurface,

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // ESTADO VAZIO
  // =====================================================

  Widget estadoVazio() {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Container(

      padding:
          const EdgeInsets.all(
        28,
      ),

      decoration:
          BoxDecoration(

        color:
            cores.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(

          color:
              cores.outlineVariant,
        ),
      ),

      child:
          Column(

        children: [

          Icon(

            Icons.history,

            size: 55,

            color:
                cores.secondary,
          ),


          const SizedBox(
            height: 16,
          ),


          Text(

            'Histórico vazio',

            style:
                TextStyle(

              color:
                  cores.onSurface,

              fontSize: 17,

              fontWeight:
                  FontWeight.w800,
            ),
          ),


          const SizedBox(
            height: 7,
          ),


          Text(

            'Serviços concluídos e agendamentos cancelados aparecerão aqui.',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(

              color:
                  cores.onSurface
                      .withValues(
                    alpha: 0.58,
                  ),

              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // BUILD
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
          'Histórico',
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
                      ListView(

                    physics:
                        const AlwaysScrollableScrollPhysics(
                      parent:
                          ClampingScrollPhysics(),
                    ),

                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      30,
                    ),

                    children: [

                      Text(

                        'Histórico de serviços',

                        style:
                            TextStyle(

                          color:
                              cores.onSurface,

                          fontSize: 25,

                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),


                      const SizedBox(
                        height: 5,
                      ),


                      Text(

                        historico.isEmpty
                            ? 'Nenhum registro encontrado.'
                            : historico.length == 1
                                ? '1 registro encontrado.'
                                : '${historico.length} registros encontrados.',

                        style:
                            TextStyle(

                          color:
                              cores.onSurface
                                  .withValues(
                                alpha: 0.58,
                              ),

                          fontSize: 13,
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      if (historico.isEmpty)

                        estadoVazio()

                      else

                        ...historico.map(
                          cardHistorico,
                        ),
                    ],
                  ),
                ),
    );
  }
}