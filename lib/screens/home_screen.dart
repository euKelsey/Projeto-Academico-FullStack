import 'package:flutter/material.dart';

import '../data/dados_temporarios.dart';
import '../data/sessao_cliente.dart';
import '../models/agendamento.dart';
import '../services/api_service.dart';
import '../theme/theme_controller.dart';

import 'agendamento_screen.dart';
import 'historico_servicos_screen.dart';
import 'login_screen.dart';
import 'meu_cadastro_screen.dart';
import 'pagamentos_screen.dart';
import 'status_servico_screen.dart';
import 'veiculos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ==========================================
  // CARD DO MENU
  // ==========================================

  Widget _cardMenu({
    required BuildContext context,
    required IconData icone,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                Theme.of(context)
                    .colorScheme
                    .outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 34,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              texto,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
                color:
                    Theme.of(context)
                        .colorScheme
                        .onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================
  // PRÓXIMO AGENDAMENTO
  // ==========================================

  Widget _cardProximoAgendamento({
    required BuildContext context,
    required Agendamento? agendamento,
  }) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;


    // SEM AGENDAMENTO
    if (agendamento == null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                colorScheme
                    .outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color:
                    colorScheme
                        .primaryContainer,
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              child: Icon(
                Icons
                    .calendar_today_outlined,
                color:
                    colorScheme
                        .onPrimaryContainer,
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Próximo agendamento',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                      color:
                          colorScheme
                              .onSurface,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'Você ainda não possui um serviço agendado.',
                    style:
                        TextStyle(
                      fontSize: 14,
                      color:
                          colorScheme
                              .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }


    final String nomesServicos =
        agendamento.servicos
            .map(
              (servico) =>
                  servico.nome,
            )
            .join(', ');


    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            colorScheme
                .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      colorScheme
                          .primaryContainer,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  Icons
                      .local_car_wash_outlined,
                  color:
                      colorScheme
                          .onPrimaryContainer,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Próximo agendamento',
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            colorScheme
                                .onSurface,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      '${agendamento.veiculo.marca} '
                      '${agendamento.veiculo.modelo}',
                      style:
                          TextStyle(
                        fontSize: 14,
                        color:
                            colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            nomesServicos,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color:
                  colorScheme
                      .onSurface,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Icon(
                Icons
                    .calendar_month_outlined,
                size: 18,
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                agendamento.data,
                style: TextStyle(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Icon(
                Icons.access_time,
                size: 18,
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                agendamento.horario,
                style: TextStyle(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color:
                    colorScheme.primary,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                agendamento.status,
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  color:
                      colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ==========================================
  // LOGOUT
  // ==========================================

  void _sair(
    BuildContext context,
  ) {
    // Limpa o cliente da memória.
    SessaoCliente.encerrar();

    // Limpa o cookie da sessão da API.
    ApiService.encerrarSessao();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }


  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final cliente =
        SessaoCliente.clienteLogado;


    // ========================================
    // PROTEÇÃO LOCAL
    // ========================================

    if (cliente == null) {
      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const LoginScreen(),
            ),
            (route) => false,
          );
        },
      );

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }


    // ========================================
    // PRÓXIMO AGENDAMENTO
    // TEMPORÁRIO
    // ========================================

    Agendamento?
        proximoAgendamento;

    for (final agendamento
        in agendamentos) {
      if (agendamento.status !=
              'Finalizado' &&
          agendamento.status !=
              'Cancelado') {
        proximoAgendamento =
            agendamento;

        break;
      }
    }


    return Scaffold(
      // ======================================
      // APP BAR
      // ======================================

      appBar: AppBar(
        title:
            const Text(
          'Fast Splash',
        ),
        actions: [
          // TEMA
          PopupMenuButton<ThemeMode>(
            tooltip: 'Tema',
            icon: const Icon(
              Icons
                  .brightness_6_outlined,
            ),
            onSelected:
                (ThemeMode modo) {
              themeModeNotifier.value =
                  modo;
            },
            itemBuilder:
                (context) =>
                    const [
              PopupMenuItem(
                value:
                    ThemeMode.system,
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .settings_suggest_outlined,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Sistema',
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                value:
                    ThemeMode.light,
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .light_mode_outlined,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Claro',
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                value:
                    ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .dark_mode_outlined,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Escuro',
                    ),
                  ],
                ),
              ),
            ],
          ),


          // LOGOUT
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              _sair(
                context,
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),


      // ======================================
      // BODY
      // ======================================

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              // ===============================
              // SAUDAÇÃO
              // ===============================

              Text(
                'Olá, ${cliente.nome}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .onSurface,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                'O que você deseja fazer hoje?',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 24,
              ),


              // ===============================
              // PRÓXIMO AGENDAMENTO
              // ===============================

              _cardProximoAgendamento(
                context: context,
                agendamento:
                    proximoAgendamento,
              ),

              const SizedBox(
                height: 28,
              ),


              // ===============================
              // TÍTULO
              // ===============================

              Text(
                'Acessos rápidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .onSurface,
                ),
              ),

              const SizedBox(
                height: 16,
              ),


              // ===============================
              // MENU
              // ===============================

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  // MEU CADASTRO
                  _cardMenu(
                    context: context,
                    icone:
                        Icons
                            .person_outline,
                    texto:
                        'Meu Cadastro',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const MeuCadastroScreen(),
                        ),
                      );
                    },
                  ),


                  // MEUS VEÍCULOS
                  _cardMenu(
                    context: context,
                    icone:
                        Icons
                            .directions_car_outlined,
                    texto:
                        'Meus Veículos',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const VeiculosScreen(),
                        ),
                      );
                    },
                  ),


                  // AGENDAR
                  _cardMenu(
                    context: context,
                    icone:
                        Icons
                            .calendar_month_outlined,
                    texto:
                        'Agendar Serviço',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const AgendamentoScreen(),
                        ),
                      );
                    },
                  ),


                  // ACOMPANHAR
                  _cardMenu(
                    context: context,
                    icone:
                        Icons
                            .track_changes_outlined,
                    texto:
                        'Acompanhar Serviço',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const StatusServicoScreen(),
                        ),
                      );
                    },
                  ),


                  // HISTÓRICO
                  _cardMenu(
                    context: context,
                    icone:
                        Icons.history,
                    texto:
                        'Histórico',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const HistoricoServicosScreen(),
                        ),
                      );
                    },
                  ),


                  // PAGAMENTOS
                  _cardMenu(
                    context: context,
                    icone:
                        Icons
                            .payment_outlined,
                    texto:
                        'Pagamentos',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const PagamentosScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}