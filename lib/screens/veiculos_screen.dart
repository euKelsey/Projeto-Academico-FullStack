import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/veiculo.dart';
import '../services/api_service.dart';

class VeiculosScreen extends StatefulWidget {
  const VeiculosScreen({super.key});

  @override
  State<VeiculosScreen> createState() => _VeiculosScreenState();
}

class _VeiculosScreenState extends State<VeiculosScreen> {
  final TextEditingController placaController = TextEditingController();

  final TextEditingController marcaController = TextEditingController();

  final TextEditingController modeloController = TextEditingController();

  final TextEditingController corController = TextEditingController();

  List<Veiculo> veiculos = [];

  bool carregando = true;
  bool salvando = false;

  Veiculo? veiculoEmEdicao;

  // =====================================================
  // INICIAR
  // =====================================================

  @override
  void initState() {
    super.initState();

    carregarVeiculos();
  }

  // =====================================================
  // CARREGAR VEÍCULOS
  // =====================================================

  Future<void> carregarVeiculos() async {
    try {
      final List<Veiculo> resultado = await ApiService.listarVeiculos();

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

      mostrarMensagem(limparErro(e));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // =====================================================
  // NOVO VEÍCULO
  // =====================================================

  void abrirNovoVeiculo() {
    veiculoEmEdicao = null;

    limparFormulario();

    abrirFormulario();
  }

  // =====================================================
  // EDITAR VEÍCULO
  // =====================================================

  void abrirEdicao(Veiculo veiculo) {
    veiculoEmEdicao = veiculo;

    placaController.text = veiculo.placa.toUpperCase();

    marcaController.text = veiculo.marca.toUpperCase();

    modeloController.text = veiculo.modelo.toUpperCase();

    corController.text = veiculo.cor.toUpperCase();

    abrirFormulario();
  }

  // =====================================================
  // ABRIR FORMULÁRIO
  // =====================================================

  void abrirFormulario() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      backgroundColor: Colors.transparent,

      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,

                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),

                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),

                  child: formularioVeiculo(setModalState),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      veiculoEmEdicao = null;

      limparFormulario();
    });
  }

  // =====================================================
  // SALVAR
  // =====================================================

  Future<void> salvarVeiculo(StateSetter setModalState) async {
    final String placa = placaController.text.trim().toUpperCase();

    final String marca = marcaController.text.trim().toUpperCase();

    final String modelo = modeloController.text.trim().toUpperCase();

    final String cor = corController.text.trim().toUpperCase();

    if (placa.isEmpty || marca.isEmpty || modelo.isEmpty || cor.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');

      return;
    }

    if (!placaValida(placa)) {
      mostrarMensagem('Informe uma placa válida, como ABC1234 ou ABC1D23.');

      return;
    }

    setModalState(() {
      salvando = true;
    });

    try {
      final bool editando = veiculoEmEdicao != null;

      if (editando) {
        await ApiService.atualizarVeiculo(
          idVeiculo: veiculoEmEdicao!.idVeiculo,

          placa: placa,

          marca: marca,

          modelo: modelo,

          cor: cor,
        );
      } else {
        await ApiService.cadastrarVeiculo(
          placa: placa,

          marca: marca,

          modelo: modelo,

          cor: cor,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      mostrarMensagem(
        editando
            ? 'Veículo atualizado com sucesso!'
            : 'Veículo cadastrado com sucesso!',
      );

      carregando = true;

      await carregarVeiculos();
    } catch (e) {
      if (!mounted) {
        return;
      }

      mostrarMensagem(limparErro(e));
    } finally {
      salvando = false;
    }
  }

  // =====================================================
  // EXCLUIR VEÍCULO
  // =====================================================

  Future<void> excluirVeiculo(Veiculo veiculo) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir veículo'),

          content: Text(
            'Deseja realmente excluir '
            '${veiculo.marca} '
            '${veiculo.modelo} '
            '(${veiculo.placa})?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),

              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final String mensagem = await ApiService.excluirVeiculo(
        veiculo.idVeiculo,
      );

      if (!mounted) {
        return;
      }

      mostrarMensagem(mensagem);

      setState(() {
        veiculos.removeWhere((item) => item.idVeiculo == veiculo.idVeiculo);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      mostrarMensagem(limparErro(e));
    }
  }

  // =====================================================
  // VALIDAÇÃO DA PLACA
  // =====================================================

  bool placaValida(String placa) {
    final RegExp padraoAntigo = RegExp(r'^[A-Z]{3}[0-9]{4}$');

    final RegExp padraoMercosul = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

    return padraoAntigo.hasMatch(placa) || padraoMercosul.hasMatch(placa);
  }

  // =====================================================
  // LIMPAR FORMULÁRIO
  // =====================================================

  void limparFormulario() {
    placaController.clear();

    marcaController.clear();

    modeloController.clear();

    corController.clear();
  }

  // =====================================================
  // ERROS / MENSAGENS
  // =====================================================

  String limparErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // =====================================================
  // FORMULÁRIO
  // =====================================================

  Widget formularioVeiculo(StateSetter setModalState) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    final bool editando = veiculoEmEdicao != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,

            decoration: BoxDecoration(
              color: cores.onSurface.withValues(alpha: 0.18),

              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        const SizedBox(height: 22),

        Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),

                gradient: LinearGradient(
                  colors: [cores.primary, cores.secondary],
                ),
              ),

              child: Icon(
                editando ? Icons.edit_outlined : Icons.add_circle_outline,

                color: cores.onPrimary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    editando ? 'Editar veículo' : 'Novo veículo',

                    style: TextStyle(
                      color: cores.onSurface,

                      fontSize: 21,

                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    editando
                        ? 'Atualize os dados do veículo.'
                        : 'Cadastre um veículo na sua conta.',

                    style: TextStyle(
                      color: cores.onSurface.withValues(alpha: 0.58),

                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        // =========================================
        // PLACA
        // =========================================
        TextField(
          controller: placaController,

          enabled: !salvando,

          textCapitalization: TextCapitalization.characters,

          inputFormatters: [PlacaInputFormatter()],

          onChanged: (valor) {
            setModalState(() {});
          },

          decoration: InputDecoration(
            labelText: 'Placa',

            hintText: 'ABC1D23',

            prefixIcon: const Icon(Icons.confirmation_number_outlined),

            helperText: '7 caracteres — padrão antigo ou Mercosul.',

            errorText:
                placaController.text.length == 7 &&
                    !placaValida(placaController.text)
                ? 'Placa inválida. Use ABC1234 ou ABC1D23.'
                : null,
          ),
        ),

        const SizedBox(height: 14),

        // =========================================
        // MARCA
        // =========================================
        TextField(
          controller: marcaController,

          enabled: !salvando,

          textCapitalization: TextCapitalization.characters,

          inputFormatters: [VeiculoUpperCaseFormatter()],

          decoration: const InputDecoration(
            labelText: 'Marca',

            hintText: 'Ex.: HONDA',

            prefixIcon: Icon(Icons.factory_outlined),
          ),
        ),

        const SizedBox(height: 14),

        // =========================================
        // MODELO
        // =========================================
        TextField(
          controller: modeloController,

          enabled: !salvando,

          textCapitalization: TextCapitalization.characters,

          inputFormatters: [VeiculoUpperCaseFormatter()],

          decoration: const InputDecoration(
            labelText: 'Modelo',

            hintText: 'Ex.: CIVIC',

            prefixIcon: Icon(Icons.directions_car_outlined),
          ),
        ),

        const SizedBox(height: 14),

        // =========================================
        // COR
        // =========================================
        TextField(
          controller: corController,

          enabled: !salvando,

          textCapitalization: TextCapitalization.characters,

          inputFormatters: [VeiculoUpperCaseFormatter()],

          decoration: const InputDecoration(
            labelText: 'Cor',

            hintText: 'Ex.: PRETO',

            prefixIcon: Icon(Icons.palette_outlined),
          ),
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,

          child: ElevatedButton.icon(
            onPressed: salvando
                ? null
                : () {
                    salvarVeiculo(setModalState);
                  },

            icon: salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,

                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,

                      color: Colors.white,
                    ),
                  )
                : Icon(editando ? Icons.save_outlined : Icons.add_outlined),

            label: Text(
              salvando
                  ? 'Salvando...'
                  : editando
                  ? 'Salvar alterações'
                  : 'Cadastrar veículo',
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,

          child: OutlinedButton(
            onPressed: salvando
                ? null
                : () {
                    Navigator.pop(context);
                  },

            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // CARD DO VEÍCULO
  // =====================================================

  Widget cardVeiculo(Veiculo veiculo) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: cores.outlineVariant),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),

                  gradient: LinearGradient(
                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                    colors: [
                      cores.primary.withValues(alpha: 0.25),

                      cores.secondary.withValues(alpha: 0.14),
                    ],
                  ),
                ),

                child: Icon(
                  Icons.directions_car_outlined,

                  color: cores.secondary,

                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '${veiculo.marca.toUpperCase()} '
                      '${veiculo.modelo.toUpperCase()}',

                      style: TextStyle(
                        color: cores.onSurface,

                        fontSize: 16,

                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,

                      runSpacing: 6,

                      children: [
                        chipInformacao(
                          Icons.confirmation_number_outlined,

                          veiculo.placa.toUpperCase(),
                        ),

                        chipInformacao(
                          Icons.palette_outlined,

                          veiculo.cor.toUpperCase(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(color: cores.outlineVariant),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    abrirEdicao(veiculo);
                  },

                  icon: const Icon(Icons.edit_outlined, size: 18),

                  label: const Text('Editar'),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                tooltip: 'Excluir veículo',

                onPressed: () {
                  excluirVeiculo(veiculo);
                },

                style: IconButton.styleFrom(
                  minimumSize: const Size(52, 52),

                  foregroundColor: cores.error,

                  side: BorderSide(color: cores.error.withValues(alpha: 0.30)),
                ),

                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CHIP
  // =====================================================

  Widget chipInformacao(IconData icone, String texto) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: cores.secondary.withValues(alpha: 0.07),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: cores.secondary.withValues(alpha: 0.14)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icone, size: 13, color: cores.secondary),

          const SizedBox(width: 5),

          Text(
            texto,

            style: TextStyle(
              color: cores.onSurface.withValues(alpha: 0.78),

              fontSize: 11,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TELA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Veículos')),

      floatingActionButton: carregando
          ? null
          : FloatingActionButton.extended(
              onPressed: abrirNovoVeiculo,

              icon: const Icon(Icons.add),

              label: const Text('Novo veículo'),
            ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarVeiculos,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),

                padding: const EdgeInsets.fromLTRB(20, 18, 20, 95),

                children: [
                  Text(
                    'Seus veículos',

                    style: TextStyle(
                      color: cores.onSurface,

                      fontSize: 25,

                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    veiculos.isEmpty
                        ? 'Você ainda não possui veículos cadastrados.'
                        : veiculos.length == 1
                        ? '1 veículo cadastrado na sua conta.'
                        : '${veiculos.length} veículos cadastrados na sua conta.',

                    style: TextStyle(
                      color: cores.onSurface.withValues(alpha: 0.58),

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (veiculos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),

                      decoration: BoxDecoration(
                        color: cores.surfaceContainerHighest,

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(color: cores.outlineVariant),
                      ),

                      child: Column(
                        children: [
                          Icon(
                            Icons.directions_car_outlined,

                            size: 55,

                            color: cores.secondary,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Nenhum veículo cadastrado',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: cores.onSurface,

                              fontSize: 17,

                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            'Cadastre seu primeiro veículo para realizar agendamentos.',

                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: cores.onSurface.withValues(alpha: 0.58),

                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...veiculos.map(cardVeiculo),
                ],
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
}

// =====================================================
// TEXTO EM MAIÚSCULAS
// =====================================================

class VeiculoUpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String texto = newValue.text.toUpperCase();

    return TextEditingValue(
      text: texto,

      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

// =====================================================
// FORMATADOR DA PLACA
// =====================================================

class PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String placa = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    if (placa.length > 7) {
      placa = placa.substring(0, 7);
    }

    return TextEditingValue(
      text: placa,

      selection: TextSelection.collapsed(offset: placa.length),
    );
  }
}
