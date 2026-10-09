import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../services/api_service.dart';

class StatusServicoScreen extends StatefulWidget {
  const StatusServicoScreen({super.key});

  @override
  State<StatusServicoScreen> createState() => _StatusServicoScreenState();
}

class _StatusServicoScreenState extends State<StatusServicoScreen> {
  List<Agendamento> agendamentos = [];

  bool carregando = true;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    carregarAgendamentos();
  }

  // =====================================================
  // CARREGAR
  // =====================================================

  Future<void> carregarAgendamentos() async {
    setState(() {
      carregando = true;
    });

    try {
      final List<Agendamento> resultado = await ApiService.listarAgendamentos();

      if (!mounted) {
        return;
      }

      setState(() {
        agendamentos = resultado.where((agendamento) {
          final String status = agendamento.status.toUpperCase();

          return status != 'CANCELADO' &&
              status != 'CONCLUIDO' &&
              status != 'FINALIZADO';
        }).toList();
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

  String formatarData(String data) {
    final List<String> partes = data.split('-');

    if (partes.length != 3) {
      return data;
    }

    return '${partes[2]}/'
        '${partes[1]}/'
        '${partes[0]}';
  }

  // =====================================================
  // STATUS
  // =====================================================

  String statusAtual(Agendamento agendamento) {
    final String status = agendamento.status.toUpperCase();

    if (status == 'EM_LAVAGEM' || status == 'EM ANDAMENTO') {
      return 'EM_LAVAGEM';
    }

    if (status == 'FINALIZADO' || status == 'CONCLUIDO') {
      return 'FINALIZADO';
    }

    if (status == 'AGUARDANDO') {
      return 'AGUARDANDO';
    }

    return 'AGENDADO';
  }

  String nomeStatus(String status) {
    switch (status) {
      case 'AGENDADO':
        return 'Agendado';

      case 'AGUARDANDO':
        return 'Aguardando atendimento';

      case 'EM_LAVAGEM':
        return 'Em lavagem';

      case 'FINALIZADO':
        return 'Finalizado';

      default:
        return status;
    }
  }

  // =====================================================
  // COR DO STATUS
  // =====================================================

  Color corStatus(BuildContext context, String status) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    switch (status) {
      case 'AGENDADO':
        return cores.tertiary;

      case 'AGUARDANDO':
        return cores.tertiary;

      case 'EM_LAVAGEM':
        return cores.secondary;

      case 'FINALIZADO':
        return Colors.green;

      default:
        return cores.primary;
    }
  }

  // =====================================================
  // ÍCONE STATUS
  // =====================================================

  IconData iconeStatus(String status) {
    switch (status) {
      case 'AGENDADO':
        return Icons.event_available_outlined;

      case 'AGUARDANDO':
        return Icons.hourglass_top_outlined;

      case 'EM_LAVAGEM':
        return Icons.local_car_wash_outlined;

      case 'FINALIZADO':
        return Icons.check_circle_outline;

      default:
        return Icons.info_outline;
    }
  }

  // =====================================================
  // ERRO
  // =====================================================

  void mostrarErro(Object erro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
    );
  }

  // =====================================================
  // CARD
  // =====================================================

  Widget cardAgendamento(Agendamento agendamento) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    final String status = statusAtual(agendamento);

    final Color cor = corStatus(context, status);

    final String servicos = agendamento.servicos
        .map((servico) => servico.nome)
        .join(', ');

    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        abrirDetalhes(agendamento);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: cores.surfaceContainerHighest,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: cores.outlineVariant),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),

                    color: cor.withValues(alpha: 0.10),
                  ),

                  child: Icon(iconeStatus(status), color: cor),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        '${agendamento.veiculo.marca} '
                        '${agendamento.veiculo.modelo}',

                        style: TextStyle(
                          color: cores.onSurface,

                          fontSize: 16,

                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        agendamento.veiculo.placa,

                        style: TextStyle(
                          color: cores.onSurface.withValues(alpha: 0.55),

                          fontSize: 12,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,

                  color: cores.onSurface.withValues(alpha: 0.45),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: cor.withValues(alpha: 0.20)),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(iconeStatus(status), color: cor, size: 14),

                  const SizedBox(width: 6),

                  Text(
                    nomeStatus(status),

                    style: TextStyle(
                      color: cor,

                      fontSize: 11,

                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              servicos,

              style: TextStyle(
                color: cores.onSurface.withValues(alpha: 0.72),

                fontSize: 13,

                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,

              runSpacing: 8,

              children: [
                chipInformacao(
                  Icons.event_outlined,

                  formatarData(agendamento.data),
                ),

                chipInformacao(Icons.schedule_outlined, agendamento.horario),

                chipInformacao(
                  Icons.payments_outlined,

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

  Widget chipInformacao(IconData icone, String texto) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: cores.onSurface.withValues(alpha: 0.04),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: cores.outlineVariant),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icone, size: 13, color: cores.secondary),

          const SizedBox(width: 5),

          Text(
            texto,

            style: TextStyle(
              color: cores.onSurface.withValues(alpha: 0.72),

              fontSize: 10,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CANCELAR AGENDAMENTO
  // =====================================================

  Future<void> cancelarAgendamento(Agendamento agendamento) async {
    final int idAgendamento = agendamento.id;

    if (idAgendamento == null) {
      mostrarErro('Agendamento inválido.');

      return;
    }

    final bool? confirmar = await showDialog<bool>(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar agendamento'),

          content: const Text(
            'Tem certeza que deseja cancelar este agendamento?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text('Não'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,

                foregroundColor: Theme.of(context).colorScheme.onError,
              ),

              child: const Text('Sim, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final String mensagem = await ApiService.cancelarAgendamento(
        idAgendamento,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));

      await carregarAgendamentos();
    } catch (e) {
      if (!mounted) {
        return;
      }

      mostrarErro(e);
    }
  }

  // =====================================================
  // DETALHES
  // =====================================================

  void abrirDetalhes(Agendamento agendamento) {
    final String status = statusAtual(agendamento);

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      useSafeArea: true,

      backgroundColor: Colors.transparent,

      builder: (BuildContext context) {
        final ColorScheme cores = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: cores.surface,

            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),

          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

            child: Column(
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

                const SizedBox(height: 24),

                Text(
                  'Acompanhamento',

                  style: TextStyle(
                    color: cores.onSurface,

                    fontSize: 23,

                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${agendamento.veiculo.marca} '
                  '${agendamento.veiculo.modelo} — '
                  '${agendamento.veiculo.placa}',

                  style: TextStyle(
                    color: cores.onSurface.withValues(alpha: 0.60),
                  ),
                ),

                const SizedBox(height: 27),

                etapaFluxo(
                  titulo: 'Agendado',

                  descricao: 'Seu agendamento foi confirmado.',

                  concluido: true,

                  atual: status == 'AGENDADO',
                ),

                linhaFluxo(true),

                etapaFluxo(
                  titulo: 'Aguardando',

                  descricao: 'O veículo aguarda o início do atendimento.',

                  concluido:
                      status == 'AGUARDANDO' ||
                      status == 'EM_LAVAGEM' ||
                      status == 'FINALIZADO',

                  atual: status == 'AGUARDANDO',
                ),

                linhaFluxo(status == 'EM_LAVAGEM' || status == 'FINALIZADO'),

                etapaFluxo(
                  titulo: 'Em lavagem',

                  descricao: 'O serviço está sendo realizado.',

                  concluido: status == 'EM_LAVAGEM' || status == 'FINALIZADO',

                  atual: status == 'EM_LAVAGEM',
                ),

                linhaFluxo(status == 'FINALIZADO'),

                etapaFluxo(
                  titulo: 'Finalizado',

                  descricao: 'O serviço foi concluído.',

                  concluido: status == 'FINALIZADO',

                  atual: status == 'FINALIZADO',
                ),

                const SizedBox(height: 30),

                if (status == 'AGENDADO') ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      cancelarAgendamento(agendamento);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: cores.error,

                      foregroundColor: cores.onError,
                    ),

                    icon: const Icon(Icons.cancel_outlined),

                    label: const Text('Cancelar agendamento'),
                  ),

                  const SizedBox(height: 10),
                ],

                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // ETAPA DO FLUXO
  // =====================================================

  Widget etapaFluxo({
    required String titulo,

    required String descricao,

    required bool concluido,

    required bool atual,
  }) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    final Color cor = concluido
        ? cores.secondary
        : cores.onSurface.withValues(alpha: 0.28);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: cor.withValues(alpha: 0.10),

            border: Border.all(color: cor, width: atual ? 2 : 1),
          ),

          child: Icon(
            concluido ? Icons.check : Icons.circle_outlined,

            color: cor,

            size: 19,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                titulo,

                style: TextStyle(
                  color: cores.onSurface,

                  fontSize: 15,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                descricao,

                style: TextStyle(
                  color: cores.onSurface.withValues(alpha: 0.55),

                  fontSize: 12,

                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // LINHA DO FLUXO
  // =====================================================

  Widget linhaFluxo(bool ativo) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      width: 2,
      height: 25,

      margin: const EdgeInsets.only(left: 18),

      color: ativo ? cores.secondary : cores.outlineVariant,
    );
  }

  // =====================================================
  // TELA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhar Serviço')),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarAgendamentos,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),

                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

                children: [
                  Text(
                    'Seus serviços',

                    style: TextStyle(
                      color: cores.onSurface,

                      fontSize: 25,

                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Acompanhe em tempo real o andamento dos seus serviços.',

                    style: TextStyle(
                      color: cores.onSurface.withValues(alpha: 0.58),

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (agendamentos.isEmpty)
                    estadoVazio()
                  else
                    ...agendamentos.map(cardAgendamento),
                ],
              ),
            ),
    );
  }

  // =====================================================
  // ESTADO VAZIO
  // =====================================================

  Widget estadoVazio() {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: cores.outlineVariant),
      ),

      child: Column(
        children: [
          Icon(Icons.local_car_wash_outlined, size: 55, color: cores.secondary),

          const SizedBox(height: 16),

          Text(
            'Nenhum serviço em andamento',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: cores.onSurface,

              fontSize: 17,

              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Quando você tiver um agendamento ativo, poderá acompanhar o andamento por aqui.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: cores.onSurface.withValues(alpha: 0.58),

              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
