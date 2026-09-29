import 'package:flutter/material.dart';

import '../models/veiculo.dart';
import '../services/api_service.dart';

class VeiculosScreen extends StatefulWidget {
  const VeiculosScreen({super.key});

  @override
  State<VeiculosScreen> createState() =>
      _VeiculosScreenState();
}

class _VeiculosScreenState
    extends State<VeiculosScreen> {
  final TextEditingController
      placaController =
      TextEditingController();

  final TextEditingController
      marcaController =
      TextEditingController();

  final TextEditingController
      modeloController =
      TextEditingController();

  final TextEditingController
      corController =
      TextEditingController();

  List<Veiculo> veiculos = [];

  bool carregando = true;
  bool salvando = false;

  bool mostrarFormulario = false;

  Veiculo? veiculoEmEdicao;


  @override
  void initState() {
    super.initState();

    carregarVeiculos();
  }


  // ==========================================
  // CARREGAR
  // ==========================================

  Future<void> carregarVeiculos() async {
    try {
      final List<Veiculo> resultado =
          await ApiService.listarVeiculos();

      if (!mounted) {
        return;
      }

      setState(() {
        veiculos = resultado;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(
        e,
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
  // ABRIR FORMULÁRIO NOVO
  // ==========================================

  void abrirFormularioNovo() {
    setState(() {
      mostrarFormulario = true;

      veiculoEmEdicao = null;

      placaController.clear();
      marcaController.clear();
      modeloController.clear();
      corController.clear();
    });
  }


  // ==========================================
  // ABRIR EDIÇÃO
  // ==========================================

  void abrirEdicao(
    Veiculo veiculo,
  ) {
    setState(() {
      veiculoEmEdicao =
          veiculo;

      mostrarFormulario =
          true;

      placaController.text =
          veiculo.placa;

      marcaController.text =
          veiculo.marca;

      modeloController.text =
          veiculo.modelo;

      corController.text =
          veiculo.cor;
    });
  }


  // ==========================================
  // FECHAR FORMULÁRIO
  // ==========================================

  void fecharFormulario() {
    setState(() {
      mostrarFormulario =
          false;

      veiculoEmEdicao =
          null;

      placaController.clear();
      marcaController.clear();
      modeloController.clear();
      corController.clear();
    });
  }


  // ==========================================
  // SALVAR
  // ==========================================

  Future<void> salvarVeiculo() async {
    final String placa =
        placaController.text.trim();

    final String marca =
        marcaController.text.trim();

    final String modelo =
        modeloController.text.trim();

    final String cor =
        corController.text.trim();


    if (
      placa.isEmpty ||
      marca.isEmpty ||
      modelo.isEmpty ||
      cor.isEmpty
    ) {
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


    setState(() {
      salvando = true;
    });


    try {
      final bool editando =
          veiculoEmEdicao != null;


      if (editando) {
        await ApiService
            .atualizarVeiculo(
          idVeiculo:
              veiculoEmEdicao!
                  .idVeiculo,
          placa: placa,
          marca: marca,
          modelo: modelo,
          cor: cor,
        );
      } else {
        await ApiService
            .cadastrarVeiculo(
          placa: placa,
          marca: marca,
          modelo: modelo,
          cor: cor,
        );
      }


      await carregarVeiculos();


      if (!mounted) {
        return;
      }


      fecharFormulario();


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Veículo atualizado com sucesso'
                : 'Veículo cadastrado com sucesso',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(
        e,
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }


  // ==========================================
  // EXCLUIR
  // ==========================================

  Future<void> excluirVeiculo(
    Veiculo veiculo,
  ) async {
    final bool? confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Excluir veículo',
          ),
          content: Text(
            'Deseja excluir '
            '${veiculo.marca} '
            '${veiculo.modelo}?',
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
                'Cancelar',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text(
                'Excluir',
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
              .excluirVeiculo(
        veiculo.idVeiculo,
      );


      await carregarVeiculos();


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

      _mostrarErro(
        e,
      );
    }
  }


  // ==========================================
  // ERRO
  // ==========================================

  void _mostrarErro(
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


  @override
  void dispose() {
    placaController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    corController.dispose();

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
        title:
            const Text(
          'Meus Veículos',
        ),
      ),
      body: carregando
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh:
                  carregarVeiculos,
              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Veículos cadastrados',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // SEM VEÍCULOS
                    // =========================

                    if (veiculos.isEmpty)
                      const Padding(
                        padding:
                            EdgeInsets
                                .symmetric(
                          vertical: 24,
                        ),
                        child: Text(
                          'Nenhum veículo cadastrado.',
                        ),
                      ),


                    // =========================
                    // LISTA
                    // =========================

                    ...veiculos.map(
                      (veiculo) =>
                          ListTile(
                        leading:
                            const Icon(
                          Icons
                              .directions_car,
                        ),
                        title: Text(
                          '${veiculo.marca} '
                          '${veiculo.modelo}',
                        ),
                        subtitle: Text(
                          'Placa: '
                          '${veiculo.placa}'
                          ' | '
                          'Cor: '
                          '${veiculo.cor}',
                        ),
                        trailing:
                            Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            IconButton(
                              onPressed:
                                  salvando
                                      ? null
                                      : () {
                                          abrirEdicao(
                                            veiculo,
                                          );
                                        },
                              icon:
                                  const Icon(
                                Icons.edit,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  salvando
                                      ? null
                                      : () {
                                          excluirVeiculo(
                                            veiculo,
                                          );
                                        },
                              icon:
                                  const Icon(
                                Icons
                                    .delete,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(
                      height: 16,
                    ),


                    // =========================
                    // ADICIONAR / CANCELAR
                    // =========================

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton
                              .icon(
                        onPressed:
                            salvando
                                ? null
                                : () {
                                    if (mostrarFormulario) {
                                      fecharFormulario();
                                    } else {
                                      abrirFormularioNovo();
                                    }
                                  },
                        icon: Icon(
                          mostrarFormulario
                              ? Icons.close
                              : Icons.add,
                        ),
                        label: Text(
                          mostrarFormulario
                              ? 'Cancelar'
                              : 'Adicionar Veículo',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),


                    // =========================
                    // FORMULÁRIO
                    // =========================

                    if (mostrarFormulario) ...[
                      TextField(
                        controller:
                            placaController,
                        enabled:
                            !salvando,
                        textCapitalization:
                            TextCapitalization
                                .characters,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Placa',
                          prefixIcon:
                              Icon(
                            Icons
                                .confirmation_number,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            marcaController,
                        enabled:
                            !salvando,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Marca',
                          prefixIcon:
                              Icon(
                            Icons
                                .business,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            modeloController,
                        enabled:
                            !salvando,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Modelo',
                          prefixIcon:
                              Icon(
                            Icons
                                .directions_car,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextField(
                        controller:
                            corController,
                        enabled:
                            !salvando,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Cor',
                          prefixIcon:
                              Icon(
                            Icons
                                .color_lens,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 50,
                        child:
                            ElevatedButton(
                          onPressed:
                              salvando
                                  ? null
                                  : salvarVeiculo,
                          child: salvando
                              ? const SizedBox(
                                  width:
                                      22,
                                  height:
                                      22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2.5,
                                  ),
                                )
                              : Text(
                                  veiculoEmEdicao ==
                                          null
                                      ? 'Salvar Veículo'
                                      : 'Salvar Alterações',
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}