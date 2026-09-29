import 'package:flutter/material.dart';

import '../models/veiculo.dart';
import '../models/servico.dart';
import '../services/api_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() =>
      _AgendamentoScreenState();
}

class _AgendamentoScreenState
    extends State<AgendamentoScreen> {
  final TextEditingController dataController =
      TextEditingController();

  final TextEditingController horarioController =
      TextEditingController();

  // ==========================================
  // DADOS DA API
  // ==========================================

  List<Veiculo> veiculos = [];

  List<Servico> servicosDisponiveis = [];

  final List<Servico> servicosSelecionados = [];

  Veiculo? veiculoSelecionado;

  DateTime? dataSelecionada;

  TimeOfDay? horarioSelecionado;

  bool carregando = true;

  bool salvando = false;


  // ==========================================
  // VALOR TOTAL
  // ==========================================

  double get valorTotal {
    double total = 0;

    for (final Servico servico
        in servicosSelecionados) {
      total += servico.preco;
    }

    return total;
  }


  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {
    super.initState();

    carregarDados();
  }


  // ==========================================
  // CARREGAR VEÍCULOS E SERVIÇOS
  // ==========================================

  Future<void> carregarDados() async {
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


  // ==========================================
  // SELECIONAR SERVIÇOS
  // ==========================================

  Future<void> selecionarServicos() async {
    final List<Servico> temporarios =
        List.from(
      servicosSelecionados,
    );

    final bool? confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (
                context,
                setStateDialog,
              ) {
            return AlertDialog(
              title: const Text(
                'Selecionar Serviços',
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children:
                      servicosDisponiveis
                          .map(
                    (servico) {
                      final bool selecionado =
                          temporarios.any(
                        (item) =>
                            item.idServico ==
                            servico.idServico,
                      );

                      return CheckboxListTile(
                        title: Text(
                          servico.nome,
                        ),
                        subtitle: Text(
                          'R\$ '
                          '${servico.preco.toStringAsFixed(2)}',
                        ),
                        value:
                            selecionado,
                        onChanged:
                            (bool? valor) {
                          setStateDialog(
                            () {
                              if (valor ==
                                  true) {
                                if (!temporarios
                                    .any(
                                  (item) =>
                                      item.idServico ==
                                      servico.idServico,
                                )) {
                                  temporarios
                                      .add(
                                    servico,
                                  );
                                }
                              } else {
                                temporarios
                                    .removeWhere(
                                  (item) =>
                                      item.idServico ==
                                      servico.idServico,
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: const Text(
                    'Confirmar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmar == true) {
      setState(() {
        servicosSelecionados
            .clear();

        servicosSelecionados
            .addAll(
          temporarios,
        );
      });
    }
  }


  // ==========================================
  // SELECIONAR DATA
  // ==========================================

  Future<void> selecionarData() async {
    final DateTime agora =
        DateTime.now();

    final DateTime? resultado =
        await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: DateTime(
        agora.year,
        agora.month,
        agora.day,
      ),
      lastDate:
          DateTime(2030),
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


  // ==========================================
  // SELECIONAR HORÁRIO
  // ==========================================

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


  // ==========================================
  // FORMATAR DATA PARA JAVA
  // ==========================================

  String dataParaApi() {
    final DateTime data =
        dataSelecionada!;

    return '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }


  // ==========================================
  // FORMATAR HORÁRIO PARA JAVA
  // ==========================================

  String horarioParaApi() {
    final TimeOfDay horario =
        horarioSelecionado!;

    return '${horario.hour.toString().padLeft(2, '0')}:'
        '${horario.minute.toString().padLeft(2, '0')}';
  }


  // ==========================================
  // CONFIRMAR AGENDAMENTO
  // ==========================================

  Future<void> confirmarAgendamento() async {
    final Veiculo? veiculo =
        veiculoSelecionado;

    if (veiculo == null ||
        servicosSelecionados.isEmpty ||
        dataSelecionada == null ||
        horarioSelecionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha todos os campos',
          ),
        ),
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
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Agendamento',
          ),
          content: Text(
            'Veículo: '
            '${veiculo.marca} '
            '${veiculo.modelo}\n\n'
            'Serviços: '
            '$nomesServicos\n\n'
            'Data: '
            '${dataController.text}\n'
            'Horário: '
            '${horarioController.text}\n\n'
            'Total: R\$ '
            '${valorTotal.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
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


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
          ),
        ),
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

        horarioController
            .clear();
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


  // ==========================================
  // MOSTRAR ERRO
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
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    dataController.dispose();
    horarioController.dispose();

    super.dispose();
  }


  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agendar Serviço',
        ),
      ),

      body: carregando
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
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    // =========================
                    // VEÍCULO
                    // =========================

                    DropdownButtonFormField<
                        Veiculo>(
                      key: ValueKey(
                        veiculoSelecionado?.idVeiculo,
                      ),
                      initialValue:
                          veiculoSelecionado,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Veículo',
                        prefixIcon:
                            Icon(
                          Icons
                              .directions_car,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      items: veiculos
                          .map(
                        (Veiculo veiculo) {
                          return DropdownMenuItem<
                              Veiculo>(
                            value:
                                veiculo,
                            child: Text(
                              '${veiculo.marca} '
                              '${veiculo.modelo} - '
                              '${veiculo.placa}',
                            ),
                          );
                        },
                      ).toList(),
                      onChanged:
                          salvando
                              ? null
                              : (
                                  Veiculo?
                                      novoVeiculo,
                                ) {
                                  setState(
                                    () {
                                      veiculoSelecionado =
                                          novoVeiculo;
                                    },
                                  );
                                },
                    ),

                    if (veiculos.isEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Você precisa cadastrar um veículo antes de realizar um agendamento.',
                      ),
                    ],

                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // SERVIÇOS
                    // =========================

                    InkWell(
                      onTap:
                          salvando ||
                                  servicosDisponiveis
                                      .isEmpty
                              ? null
                              : selecionarServicos,
                      child:
                          InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Serviços',
                          prefixIcon:
                              Icon(
                            Icons
                                .local_car_wash,
                          ),
                          suffixIcon:
                              Icon(
                            Icons
                                .arrow_drop_down,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                        child: Text(
                          servicosSelecionados
                                  .isEmpty
                              ? servicosDisponiveis
                                      .isEmpty
                                  ? 'Nenhum serviço disponível'
                                  : 'Selecionar serviços'
                              : servicosSelecionados
                                  .map(
                                    (
                                      servico,
                                    ) =>
                                        servico.nome,
                                  )
                                  .join(
                                    ', ',
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // DATA
                    // =========================

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
                        prefixIcon:
                            Icon(
                          Icons
                              .calendar_today,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // HORÁRIO
                    // =========================

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
                        prefixIcon:
                            Icon(
                          Icons
                              .access_time,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // VALOR TOTAL
                    // =========================

                    if (servicosSelecionados
                        .isNotEmpty)
                      Text(
                        'Valor total: R\$ '
                        '${valorTotal.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                    const SizedBox(
                      height: 24,
                    ),


                    // =========================
                    // CONFIRMAR
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
                                : confirmarAgendamento,
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
                                'Confirmar Agendamento',
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