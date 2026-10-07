import 'package:flutter/material.dart';

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


class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });


  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}


class _HomeScreenState
    extends State<HomeScreen> {

  List<Agendamento> agendamentos = [];

  bool carregando = true;


  // =====================================================
  // INICIAR TELA
  // =====================================================

  @override
  void initState() {

    super.initState();

    carregarHome();
  }


  // =====================================================
  // CARREGAR AGENDAMENTOS
  // =====================================================

  Future<void> carregarHome() async {

    try {

      final resultado =
          await ApiService.listarAgendamentos();


      if (!mounted) {
        return;
      }


      setState(() {

        agendamentos = resultado;
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
  // PRÓXIMO AGENDAMENTO
  // =====================================================

  Agendamento? get proximoAgendamento {

    final List<Agendamento> ativos =
        agendamentos
            .where(
              (agendamento) {

                final String status =
                    agendamento.status
                        .toUpperCase();


                return status != 'FINALIZADO'
                    && status != 'CANCELADO'
                    && status != 'CONCLUIDO';
              },
            )
            .toList();


    if (ativos.isEmpty) {

      return null;
    }


    ativos.sort(
      (a, b) {

        return converterDataHora(
          a.data,
          a.horario,
        ).compareTo(
          converterDataHora(
            b.data,
            b.horario,
          ),
        );
      },
    );


    return ativos.first;
  }


  DateTime converterDataHora(
    String data,
    String horario,
  ) {

    try {

      final partesData =
          data.split('-');

      final partesHorario =
          horario.split(':');


      return DateTime(
        int.parse(partesData[0]),
        int.parse(partesData[1]),
        int.parse(partesData[2]),
        int.parse(partesHorario[0]),
        int.parse(partesHorario[1]),
      );

    } catch (_) {

      return DateTime(2100);
    }
  }


  String formatarData(
    String data,
  ) {

    final partes =
        data.split('-');


    if (partes.length != 3) {

      return data;
    }


    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }


  String formatarStatus(
    String status,
  ) {

    return status
        .replaceAll(
          '_',
          ' ',
        )
        .toUpperCase();
  }


  // =====================================================
  // SAIR
  // =====================================================

  Future<void> sair() async {

    SessaoCliente.encerrar();

    ApiService.encerrarSessao();


    if (!mounted) {
      return;
    }


    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }


  // =====================================================
  // MOSTRAR ERRO
  // =====================================================

  void mostrarErro(
    Object erro,
  ) {

    final String mensagem =
        erro
            .toString()
            .replaceFirst(
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


  // =====================================================
  // CARD PRÓXIMO AGENDAMENTO
  // =====================================================

  Widget cardProximoAgendamento(
    Agendamento? agendamento,
  ) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    if (agendamento == null) {

      return Container(

        width: double.infinity,

        padding:
            const EdgeInsets.all(20),

        decoration:
            BoxDecoration(

          color:
              cores.surfaceContainerHighest,

          borderRadius:
              BorderRadius.circular(18),

          border:
              Border.all(
            color:
                cores.outlineVariant,
          ),
        ),

        child:
            Row(

          children: [

            Container(

              width: 52,
              height: 52,

              decoration:
                  BoxDecoration(

                borderRadius:
                    BorderRadius.circular(14),

                gradient:
                    LinearGradient(

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,

                  colors: [

                    cores.primary,

                    cores.secondary,
                  ],
                ),
              ),

              child:
                  Icon(

                Icons.calendar_month_outlined,

                color:
                    cores.onPrimary,

                size: 27,
              ),
            ),


            const SizedBox(
              width: 16,
            ),


            Expanded(

              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Próximo agendamento',

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
                    height: 5,
                  ),


                  Text(
                    'Você não possui agendamentos ativos.',

                    style:
                        TextStyle(

                      color:
                          cores.onSurface
                              .withValues(
                            alpha: 0.60,
                          ),

                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }


    final String servicos =
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

      decoration:
          BoxDecoration(

        color:
            cores.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(18),

        border:
            Border.all(

          color:
              cores.secondary
                  .withValues(
            alpha: 0.25,
          ),
        ),

        boxShadow: [

          BoxShadow(

            color:
                cores.primary
                    .withValues(
              alpha: 0.08,
            ),

            blurRadius: 24,
          ),
        ],
      ),

      child:
          Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(

            width: 52,
            height: 52,

            decoration:
                BoxDecoration(

              borderRadius:
                  BorderRadius.circular(14),

              gradient:
                  LinearGradient(

                begin:
                    Alignment.topLeft,

                end:
                    Alignment.bottomRight,

                colors: [

                  cores.primary,

                  cores.secondary,
                ],
              ),
            ),

            child:
                Icon(

              Icons.calendar_month_outlined,

              color:
                  cores.onPrimary,

              size: 27,
            ),
          ),


          const SizedBox(
            width: 16,
          ),


          Expanded(

            child:
                Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  'Próximo agendamento',

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
                  height: 8,
                ),


                Text(
                  '${agendamento.veiculo.marca} '
                  '${agendamento.veiculo.modelo}',

                  style:
                      TextStyle(

                    color:
                        cores.onSurface,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),


                const SizedBox(
                  height: 4,
                ),


                Text(
                  servicos,

                  style:
                      TextStyle(

                    color:
                        cores.onSurface
                            .withValues(
                          alpha: 0.72,
                        ),
                  ),
                ),


                const SizedBox(
                  height: 10,
                ),


                Wrap(

                  spacing: 8,

                  runSpacing: 8,

                  children: [

                    chipInfo(
                      Icons.event_outlined,
                      formatarData(
                        agendamento.data,
                      ),
                    ),

                    chipInfo(
                      Icons.schedule_outlined,
                      agendamento.horario,
                    ),

                    chipInfo(
                      Icons.info_outline,
                      formatarStatus(
                        agendamento.status,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // CHIP DE INFORMAÇÃO
  // =====================================================

  Widget chipInfo(
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
            cores.secondary
                .withValues(
          alpha: 0.08,
        ),

        borderRadius:
            BorderRadius.circular(20),

        border:
            Border.all(

          color:
              cores.secondary
                  .withValues(
            alpha: 0.15,
          ),
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
                    alpha: 0.78,
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
  // CARD DO MENU
  // =====================================================

  Widget cardMenu({

    required IconData icone,

    required String titulo,

    required String subtitulo,

    required VoidCallback onPressed,
  }) {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return InkWell(

      borderRadius:
          BorderRadius.circular(18),

      onTap:
          onPressed,

      child:
          Ink(

        decoration:
            BoxDecoration(

          color:
              cores.surfaceContainerHighest,

          borderRadius:
              BorderRadius.circular(18),

          border:
              Border.all(
            color:
                cores.outlineVariant,
          ),
        ),

        child:
            Padding(

          padding:
              const EdgeInsets.all(17),

          child:
              Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Container(

                width: 44,
                height: 44,

                decoration:
                    BoxDecoration(

                  borderRadius:
                      BorderRadius.circular(12),

                  gradient:
                      LinearGradient(

                    begin:
                        Alignment.topLeft,

                    end:
                        Alignment.bottomRight,

                    colors: [

                      cores.primary
                          .withValues(
                        alpha: 0.22,
                      ),

                      cores.secondary
                          .withValues(
                        alpha: 0.12,
                      ),
                    ],
                  ),
                ),

                child:
                    Icon(

                  icone,

                  color:
                      cores.secondary,

                  size: 25,
                ),
              ),


              const SizedBox(
                height: 16,
              ),


              Text(
                titulo,

                style:
                    TextStyle(

                  color:
                      cores.onSurface,

                  fontSize: 15,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),


              const SizedBox(
                height: 4,
              ),


              Text(
                subtitulo,

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style:
                    TextStyle(

                  color:
                      cores.onSurface
                          .withValues(
                        alpha: 0.58,
                      ),

                  fontSize: 11,

                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // =====================================================
  // TELA
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    final cliente =
        SessaoCliente.clienteLogado;

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return Scaffold(

      appBar:
          AppBar(

        automaticallyImplyLeading:
            false,

        title:
            marcaFastSplash(),

        actions: [

          seletorTema(),

          IconButton(

            tooltip:
                'Sair',

            onPressed:
                sair,

            icon:
                const Icon(
              Icons.logout,
            ),
          ),


          const SizedBox(
            width: 6,
          ),
        ],
      ),


      body:
          carregando

              ? const Center(

                  child:
                      CircularProgressIndicator(),
                )

              : RefreshIndicator(

                  onRefresh:
                      carregarHome,

                  child:
                      SingleChildScrollView(

                    physics:
                        const AlwaysScrollableScrollPhysics(
                      parent:
                          ClampingScrollPhysics(),
                    ),

                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      30,
                    ),

                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Olá, ${cliente?.nome ?? ''}',

                          style:
                              TextStyle(

                            color:
                                cores.onSurface,

                            fontSize: 27,

                            fontWeight:
                                FontWeight.w900,

                            letterSpacing:
                                -0.5,
                          ),
                        ),


                        const SizedBox(
                          height: 5,
                        ),


                        Text(
                          'Seu Fast Splash está pronto para você.',

                          style:
                              TextStyle(

                            color:
                                cores.onSurface
                                    .withValues(
                                  alpha: 0.60,
                                ),

                            fontSize: 14,
                          ),
                        ),


                        const SizedBox(
                          height: 24,
                        ),


                        cardProximoAgendamento(
                          proximoAgendamento,
                        ),


                        const SizedBox(
                          height: 30,
                        ),


                        Text(
                          'Acessos rápidos',

                          style:
                              TextStyle(

                            color:
                                cores.onSurface,

                            fontSize: 18,

                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),


                        const SizedBox(
                          height: 14,
                        ),


                        GridView.count(

                          crossAxisCount: 2,

                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 12,

                          mainAxisSpacing: 12,

                          childAspectRatio: 1.02,

                          children: [

                            cardMenu(

                              icone:
                                  Icons.person_outline,

                              titulo:
                                  'Meu Cadastro',

                              subtitulo:
                                  'Dados da sua conta',

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


                            cardMenu(

                              icone:
                                  Icons.directions_car_outlined,

                              titulo:
                                  'Meus Veículos',

                              subtitulo:
                                  'Cadastre e edite seus carros',

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


                            cardMenu(

                              icone:
                                  Icons.calendar_month_outlined,

                              titulo:
                                  'Agendar',

                              subtitulo:
                                  'Escolha serviço, data e horário',

                              onPressed: () async {

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AgendamentoScreen(),
                                  ),
                                );


                                await carregarHome();
                              },
                            ),


                            cardMenu(

                              icone:
                                  Icons.track_changes_outlined,

                              titulo:
                                  'Acompanhar',

                              subtitulo:
                                  'Veja o andamento da lavagem',

                              onPressed: () async {

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const StatusServicoScreen(),
                                  ),
                                );


                                await carregarHome();
                              },
                            ),


                            cardMenu(

                              icone:
                                  Icons.history,

                              titulo:
                                  'Histórico',

                              subtitulo:
                                  'Serviços concluídos e cancelados',

                              onPressed: () async {

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const HistoricoServicosScreen(),
                                  ),
                                );


                                await carregarHome();
                              },
                            ),


                            cardMenu(

                              icone:
                                  Icons.payments_outlined,

                              titulo:
                                  'Pagamentos',

                              subtitulo:
                                  'Pendências e pagamentos realizados',

                              onPressed: () async {

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PagamentosScreen(),
                                  ),
                                );


                                await carregarHome();
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


  // =====================================================
  // MARCA FAST SPLASH
  // =====================================================

  Widget marcaFastSplash() {

    final ColorScheme cores =
        Theme.of(context)
            .colorScheme;


    return RichText(

      text:
          TextSpan(

        style:
            const TextStyle(

          fontSize: 20,

          fontWeight:
              FontWeight.w900,
        ),

        children: [

          TextSpan(

            text:
                'Fast ',

            style:
                TextStyle(

              color:
                  cores.onSurface,
            ),
          ),


          TextSpan(

            text:
                'Splash',

            style:
                TextStyle(

              color:
                  cores.secondary,
            ),
          ),
        ],
      ),
    );
  }


  // =====================================================
  // SELETOR DE TEMA
  // =====================================================

  Widget seletorTema() {

    return ValueListenableBuilder<ThemeMode>(

      valueListenable:
          themeModeNotifier,

      builder: (
        context,
        modo,
        child,
      ) {

        IconData icone;


        if (modo == ThemeMode.light) {

          icone =
              Icons.light_mode_outlined;

        } else if (
            modo == ThemeMode.dark) {

          icone =
              Icons.dark_mode_outlined;

        } else {

          icone =
              Icons.brightness_auto_outlined;
        }


        return PopupMenuButton<ThemeMode>(

          tooltip:
              'Tema',

          onSelected:
              definirTema,

          icon:
              Icon(
            icone,
          ),

          itemBuilder:
              (context) {

            return [

              const PopupMenuItem<ThemeMode>(

                value:
                    ThemeMode.system,

                child:
                    Row(

                  children: [

                    Icon(
                      Icons.brightness_auto_outlined,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Text(
                      'Seguir aparelho',
                    ),
                  ],
                ),
              ),


              const PopupMenuItem<ThemeMode>(

                value:
                    ThemeMode.light,

                child:
                    Row(

                  children: [

                    Icon(
                      Icons.light_mode_outlined,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Text(
                      'Tema claro',
                    ),
                  ],
                ),
              ),


              const PopupMenuItem<ThemeMode>(

                value:
                    ThemeMode.dark,

                child:
                    Row(

                  children: [

                    Icon(
                      Icons.dark_mode_outlined,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Text(
                      'Tema escuro',
                    ),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }
}