import 'package:flutter/material.dart';

import '../models/veiculo.dart';
import '../models/servico.dart';
import '../services/api_service.dart';


class AgendamentoScreen
    extends StatefulWidget {

  const AgendamentoScreen({
    super.key,
  });


  @override
  State<AgendamentoScreen> createState() =>
      _AgendamentoScreenState();
}


class _AgendamentoScreenState
    extends State<AgendamentoScreen> {

  final TextEditingController
      dataController =
      TextEditingController();

  final TextEditingController
      horarioController =
      TextEditingController();


  List<Veiculo> veiculos = [];

  List<Servico> servicosDisponiveis = [];

  final List<Servico>
      servicosSelecionados = [];


  Veiculo? veiculoSelecionado;

  DateTime? dataSelecionada;

  TimeOfDay? horarioSelecionado;


  bool carregando = true;

  bool salvando = false;


  // =====================================================
  // VALOR TOTAL
  // =====================================================

  double get valorTotal {

    double total = 0;


    for (
      final Servico servico
      in servicosSelecionados
    ) {

      total +=
          servico.preco;
    }


    return total;
  }


  // =====================================================
  // FORMULÁRIO COMPLETO
  // =====================================================

  bool get formularioCompleto {

    return veiculoSelecionado != null
        && servicosSelecionados.isNotEmpty
        && dataSelecionada != null
        && horarioSelecionado != null;
  }


  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    carregarDados();
  }


  // =====================================================
  // CARREGAR API
  // =====================================================

  Future<void> carregarDados() async {

    setState(() {

      carregando = true;
    });


    try {

      final resultados =
          await Future.wait([
        ApiService.listarVeiculos(),
        ApiService.listarServicos(),
      ]);


      if (!mounted) {
        return;
      }


      setState(() {

        veiculos =
            resultados[0]
                as List<Veiculo>;

        servicosDisponiveis =
            resultados[1]
                as List<Servico>;
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
  // SELECIONAR / REMOVER SERVIÇO
  // =====================================================

  void alterarServico(
    Servico servico,
    bool selecionado,
  ) {

    setState(() {

      if (selecionado) {

        final bool existe =
            servicosSelecionados.any(
          (item) =>
              item.idServico ==
              servico.idServico,
        );


        if (!existe) {

          servicosSelecionados.add(
            servico,
          );
        }

      } else {

        servicosSelecionados
            .removeWhere(
          (item) =>
              item.idServico ==
              servico.idServico,
        );
      }
    });
  }


  // =====================================================
  // DATA
  // =====================================================

  Future<void> selecionarData() async {

    final DateTime agora =
        DateTime.now();


    final DateTime? resultado =
        await showDatePicker(

      context: context,

      initialDate:
          agora,

      firstDate:
          DateTime(
        agora.year,
        agora.month,
        agora.day,
      ),

      lastDate:
          DateTime(
        2030,
        12,
        31,
      ),
    );


    if (resultado == null) {

      return;
    }


    setState(() {

      dataSelecionada =
          resultado;

      dataController.text =
          '${resultado.day.toString().padLeft(2, '0')}/'
          '${resultado.month.toString().padLeft(2, '0')}/'
          '${resultado.year}';
    });
  }


  // =====================================================
  // HORÁRIO
  // =====================================================

  Future<void> selecionarHorario() async {

    final TimeOfDay? resultado =
        await showTimePicker(

      context: context,

      initialTime:
          TimeOfDay.now(),
    );


    if (resultado == null) {

      return;
    }


    if (!mounted) {
      return;
    }


    setState(() {

      horarioSelecionado =
          resultado;

      horarioController.text =
          resultado.format(
        context,
      );
    });
  }


  // =====================================================
  // DATA PARA API
  // =====================================================

  String dataParaApi() {

    final DateTime data =
        dataSelecionada!;


    return
        '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }


  // =====================================================
  // HORÁRIO PARA API
  // =====================================================

  String horarioParaApi() {

    final TimeOfDay horario =
        horarioSelecionado!;


    return
        '${horario.hour.toString().padLeft(2, '0')}:'
        '${horario.minute.toString().padLeft(2, '0')}';
  }


  // =====================================================
  // CONFIRMAR
  // =====================================================

  Future<void> confirmarAgendamento() async {

    final Veiculo? veiculo =
        veiculoSelecionado;


    if (!formularioCompleto ||
        veiculo == null) {

      mostrarMensagem(
        'Preencha veículo, serviço, data e horário.',
      );

      return;
    }


    final String nomesServicos =
        servicosSelecionados
            .map(
              (servico) =>
                  servico.nome,
            )
            .join(', ');


    final bool? confirmar =
        await showDialog<bool>(

      context: context,

      builder:
          (BuildContext context) {

        final ColorScheme cores =
            Theme.of(context)
                .colorScheme;


        return AlertDialog(

          title:
              const Text(
            'Confirmar agendamento',
          ),


          content:
              Column(

            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              linhaResumoDialog(

                Icons
                    .directions_car_outlined,

                'Veículo',

                '${veiculo.marca} '
                '${veiculo.modelo} — '
                '${veiculo.placa}',
              ),


              const SizedBox(
                height: 14,
              ),


              linhaResumoDialog(

                Icons
                    .local_car_wash_outlined,

                'Serviços',

                nomesServicos,
              ),


              const SizedBox(
                height: 14,
              ),


              linhaResumoDialog(

                Icons
                    .event_outlined,

                'Data',

                dataController.text,
              ),


              const SizedBox(
                height: 14,
              ),


              linhaResumoDialog(

                Icons
                    .schedule_outlined,

                'Horário',

                horarioController.text,
              ),


              const SizedBox(
                height: 18,
              ),


              Container(

                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  14,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      cores.secondary
                          .withValues(
                        alpha: 0.08,
                      ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),

                  border:
                      Border.all(

                    color:
                        cores.secondary
                            .withValues(
                          alpha: 0.18,
                        ),
                  ),
                ),

                child:
                    Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Valor total',

                      style:
                          TextStyle(

                        color:
                            cores.onSurface
                                .withValues(
                              alpha: 0.60,
                            ),

                        fontSize: 12,
                      ),
                    ),


                    const SizedBox(
                      height: 3,
                    ),


                    Text(

                      'R\$ ${valorTotal.toStringAsFixed(2)}',

                      style:
                          TextStyle(

                        color:
                            cores.onSurface,

                        fontSize: 21,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                'Voltar',
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
                'Confirmar',
              ),
            ),
          ],
        );
      },
    );


    if (confirmar != true) {

      return;
    }


    setState(() {

      salvando = true;
    });


    try {

      final List<int> idsServicos =
          servicosSelecionados
              .map(
                (servico) =>
                    servico.idServico,
              )
              .toList();


      final String mensagem =
          await ApiService
              .cadastrarAgendamento(

        idVeiculo:
            veiculo.idVeiculo,

        idsServicos:
            idsServicos,

        data:
            dataParaApi(),

        horario:
            horarioParaApi(),
      );


      if (!mounted) {
        return;
      }


      mostrarMensagem(
        mensagem,
      );


      setState(() {

        veiculoSelecionado =
            null;

        servicosSelecionados
            .clear();

        dataSelecionada =
            null;

        horarioSelecionado =
            null;

        dataController.clear();

        horarioController.clear();
      });

    } catch (e) {

      if (!mounted) {
        return;
      }


      mostrarErro(e);

    } finally {

      if (mounted) {

        setState(() {

          salvando = false;
        });
      }
    }
  }


  // =====================================================
  // LINHA DO DIALOG
  // =====================================================

  Widget linhaResumoDialog(
    IconData icone,
    String titulo,
    String valor,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Row(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Icon(

          icone,

          size: 20,

          color:
              cores.secondary,
        ),


        const SizedBox(
          width: 10,
        ),


        Expanded(

          child:
              Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(

                titulo,

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
              ),


              const SizedBox(
                height: 2,
              ),


              Text(

                valor,

                style:
                    TextStyle(

                  color:
                      cores.onSurface,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // =====================================================
  // MENSAGENS
  // =====================================================

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


  void mostrarErro(
    Object erro,
  ) {

    mostrarMensagem(

      erro
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          ),
    );
  }


  // =====================================================
  // CARD DE SERVIÇO
  // =====================================================

  Widget cardServico(
    Servico servico,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    final bool selecionado =
        servicosSelecionados.any(
      (item) =>
          item.idServico ==
          servico.idServico,
    );


    return InkWell(

      borderRadius:
          BorderRadius.circular(
        16,
      ),

      onTap:
          salvando
              ? null
              : () {

                  alterarServico(
                    servico,
                    !selecionado,
                  );
                },

      child:
          AnimatedContainer(

        duration:
            const Duration(
          milliseconds: 180,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 11,
        ),

        padding:
            const EdgeInsets.all(
          15,
        ),

        decoration:
            BoxDecoration(

          color:
              selecionado
                  ? cores.secondary
                      .withValues(
                        alpha: 0.08,
                      )
                  : cores
                      .surfaceContainerHighest,

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          border:
              Border.all(

            color:
                selecionado
                    ? cores.secondary
                    : cores.outlineVariant,

            width:
                selecionado
                    ? 1.4
                    : 1,
          ),
        ),

        child:
            Row(

          children: [

            Container(

              width: 42,
              height: 42,

              decoration:
                  BoxDecoration(

                borderRadius:
                    BorderRadius.circular(
                  11,
                ),

                color:
                    cores.secondary
                        .withValues(
                      alpha: 0.10,
                    ),
              ),

              child:
                  Icon(

                Icons
                    .local_car_wash_outlined,

                color:
                    cores.secondary,
              ),
            ),


            const SizedBox(
              width: 13,
            ),


            Expanded(

              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    servico.nome,

                    style:
                        TextStyle(

                      color:
                          cores.onSurface,

                      fontSize: 14,

                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),


                  const SizedBox(
                    height: 4,
                  ),


                  Text(

                    'R\$ ${servico.preco.toStringAsFixed(2)}',

                    style:
                        TextStyle(

                      color:
                          cores.secondary,

                      fontSize: 13,

                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),


            Checkbox(

              value:
                  selecionado,

              onChanged:
                  salvando
                      ? null
                      : (
                          bool? valor,
                        ) {

                          alterarServico(
                            servico,
                            valor ??
                                false,
                          );
                        },
            ),
          ],
        ),
      ),
    );
  }


  // =====================================================
  // RESUMO
  // =====================================================

  Widget resumoAgendamento() {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
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
              cores.secondary
                  .withValues(
                alpha: 0.18,
              ),
        ),
      ),

      child:
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

              gradient:
                  LinearGradient(

                colors: [

                  cores.primary,

                  cores.secondary,
                ],
              ),
            ),

            child:
                Icon(

              Icons
                  .payments_outlined,

              color:
                  cores.onPrimary,
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

                  'Valor total',

                  style:
                      TextStyle(

                    color:
                        cores.onSurface
                            .withValues(
                          alpha: 0.55,
                        ),

                    fontSize: 12,
                  ),
                ),


                const SizedBox(
                  height: 3,
                ),


                Text(

                  'R\$ ${valorTotal.toStringAsFixed(2)}',

                  style:
                      TextStyle(

                    color:
                        cores.onSurface,

                    fontSize: 22,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),


          Text(

            '${servicosSelecionados.length} '
            '${servicosSelecionados.length == 1 ? 'serviço' : 'serviços'}',

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
          'Agendar Serviço',
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
                      carregarDados,

                  child:
                      SingleChildScrollView(

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

                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [

                        // =========================
                        // CABEÇALHO
                        // =========================

                        Text(

                          'Novo agendamento',

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

                          'Escolha seu veículo, os serviços, a data e o horário.',

                          style:
                              TextStyle(

                            color:
                                cores.onSurface
                                    .withValues(
                                  alpha: 0.58,
                                ),

                            fontSize: 13,

                            height: 1.4,
                          ),
                        ),


                        const SizedBox(
                          height: 25,
                        ),


                        // =========================
                        // VEÍCULO
                        // =========================

                        tituloSecao(
                          '1. Veículo',
                        ),


                        const SizedBox(
                          height: 10,
                        ),


                        if (veiculos.isEmpty)

                          avisoSemVeiculo()

                        else

                          DropdownButtonFormField<
                              Veiculo>(

                            value:
                                veiculoSelecionado,

                            isExpanded: true,

                            decoration:
                                const InputDecoration(

                              labelText:
                                  'Seu veículo',

                              prefixIcon:
                                  Icon(
                                Icons
                                    .directions_car_outlined,
                              ),
                            ),

                            hint:
                                const Text(
                              'Selecione um veículo',
                            ),

                            items:
                                veiculos.map(

                              (
                                Veiculo veiculo,
                              ) {

                                return DropdownMenuItem<
                                    Veiculo>(

                                  value:
                                      veiculo,

                                  child:
                                      Text(

                                    '${veiculo.marca} '
                                    '${veiculo.modelo} — '
                                    '${veiculo.placa}',
                                  ),
                                );
                              },
                            ).toList(),

                            onChanged:
                                salvando
                                    ? null
                                    : (
                                        Veiculo? valor,
                                      ) {

                                        setState(() {

                                          veiculoSelecionado =
                                              valor;
                                        });
                                      },
                          ),


                        const SizedBox(
                          height: 27,
                        ),


                        // =========================
                        // SERVIÇOS
                        // =========================

                        tituloSecao(
                          '2. Serviços',
                        ),


                        const SizedBox(
                          height: 5,
                        ),


                        Text(

                          'Você pode selecionar mais de um serviço.',

                          style:
                              TextStyle(

                            color:
                                cores.onSurface
                                    .withValues(
                                  alpha: 0.55,
                                ),

                            fontSize: 12,
                          ),
                        ),


                        const SizedBox(
                          height: 12,
                        ),


                        if (
                          servicosDisponiveis
                              .isEmpty
                        )

                          avisoGenerico(
                            'Nenhum serviço disponível no momento.',
                          )

                        else

                          ...servicosDisponiveis
                              .map(
                            cardServico,
                          ),


                        const SizedBox(
                          height: 20,
                        ),


                        // =========================
                        // DATA / HORÁRIO
                        // =========================

                        tituloSecao(
                          '3. Data e horário',
                        ),


                        const SizedBox(
                          height: 12,
                        ),


                        TextField(

                          controller:
                              dataController,

                          readOnly: true,

                          enabled:
                              !salvando,

                          onTap:
                              selecionarData,

                          decoration:
                              const InputDecoration(

                            labelText:
                                'Data',

                            hintText:
                                'Selecione a data',

                            prefixIcon:
                                Icon(
                              Icons
                                  .calendar_month_outlined,
                            ),

                            suffixIcon:
                                Icon(
                              Icons
                                  .chevron_right,
                            ),
                          ),
                        ),


                        const SizedBox(
                          height: 13,
                        ),


                        TextField(

                          controller:
                              horarioController,

                          readOnly: true,

                          enabled:
                              !salvando,

                          onTap:
                              selecionarHorario,

                          decoration:
                              const InputDecoration(

                            labelText:
                                'Horário',

                            hintText:
                                'Selecione o horário',

                            prefixIcon:
                                Icon(
                              Icons
                                  .schedule_outlined,
                            ),

                            suffixIcon:
                                Icon(
                              Icons
                                  .chevron_right,
                            ),
                          ),
                        ),


                        const SizedBox(
                          height: 25,
                        ),


                        // =========================
                        // RESUMO
                        // =========================

                        tituloSecao(
                          '4. Resumo',
                        ),


                        const SizedBox(
                          height: 12,
                        ),


                        resumoAgendamento(),


                        const SizedBox(
                          height: 25,
                        ),


                        // =========================
                        // CONFIRMAR
                        // =========================

                        SizedBox(

                          width:
                              double.infinity,

                          child:
                              ElevatedButton.icon(

                            onPressed:
                                salvando ||
                                        !formularioCompleto
                                    ? null
                                    : confirmarAgendamento,

                            icon:
                                salvando

                                    ? const SizedBox(

                                        width: 20,
                                        height: 20,

                                        child:
                                            CircularProgressIndicator(

                                          strokeWidth:
                                              2.3,

                                          color:
                                              Colors.white,
                                        ),
                                      )

                                    : const Icon(
                                        Icons
                                            .check_circle_outline,
                                      ),

                            label:
                                Text(

                              salvando
                                  ? 'Confirmando...'
                                  : 'Confirmar agendamento',
                            ),
                          ),
                        ),


                        if (!formularioCompleto) ...[

                          const SizedBox(
                            height: 9,
                          ),


                          Text(

                            'Preencha todas as etapas para confirmar.',

                            textAlign:
                                TextAlign.center,

                            style:
                                TextStyle(

                              color:
                                  cores.onSurface
                                      .withValues(
                                    alpha: 0.48,
                                  ),

                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }


  // =====================================================
  // TÍTULO DA SEÇÃO
  // =====================================================

  Widget tituloSecao(
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

        fontSize: 17,

        fontWeight:
            FontWeight.w800,
      ),
    );
  }


  // =====================================================
  // AVISO SEM VEÍCULO
  // =====================================================

  Widget avisoSemVeiculo() {

    return avisoGenerico(
      'Você precisa cadastrar um veículo antes de realizar um agendamento.',
    );
  }


  // =====================================================
  // AVISO
  // =====================================================

  Widget avisoGenerico(
    String mensagem,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Container(

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(

        color:
            cores.tertiary
                .withValues(
              alpha: 0.07,
            ),

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        border:
            Border.all(

          color:
              cores.tertiary
                  .withValues(
                alpha: 0.20,
              ),
        ),
      ),

      child:
          Row(

        children: [

          Icon(

            Icons.info_outline,

            color:
                cores.tertiary,
          ),


          const SizedBox(
            width: 11,
          ),


          Expanded(

            child:
                Text(

              mensagem,

              style:
                  TextStyle(

                color:
                    cores.onSurface
                        .withValues(
                      alpha: 0.75,
                    ),

                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {

    dataController.dispose();

    horarioController.dispose();

    super.dispose();
  }
}