import 'package:flutter/material.dart';

import '../data/sessao_cliente.dart';
import '../models/agendamento.dart';
import '../services/api_service.dart';

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


  @override
  void initState() {
    super.initState();

    carregarHome();
  }


  // ==========================================
  // CARREGAR DADOS
  // ==========================================

  Future<void> carregarHome() async {

    try {

      final resultado =
          await ApiService
              .listarAgendamentos();

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


  // ==========================================
  // PRÓXIMO AGENDAMENTO
  // ==========================================

  Agendamento?
      get proximoAgendamento {

    final List<Agendamento>
        ativos =
        agendamentos
            .where(
              (agendamento) =>
                  agendamento.status !=
                      'Finalizado'
                  &&
                  agendamento.status !=
                      'Cancelado',
            )
            .toList();


    if (ativos.isEmpty) {
      return null;
    }


    ativos.sort(
      (a, b) {

        final DateTime dataA =
            _converterDataHora(
          a.data,
          a.horario,
        );

        final DateTime dataB =
            _converterDataHora(
          b.data,
          b.horario,
        );

        return dataA.compareTo(
          dataB,
        );
      },
    );


    return ativos.first;
  }


  DateTime _converterDataHora(
    String data,
    String horario,
  ) {

    final partesData =
        data.split('-');

    final partesHorario =
        horario.split(':');


    return DateTime(
      int.parse(
        partesData[0],
      ),
      int.parse(
        partesData[1],
      ),
      int.parse(
        partesData[2],
      ),
      int.parse(
        partesHorario[0],
      ),
      int.parse(
        partesHorario[1],
      ),
    );
  }


  // ==========================================
  // LOGOUT
  // ==========================================

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
  // CARD PRÓXIMO AGENDAMENTO
  // ==========================================

  Widget cardProximoAgendamento(
    Agendamento? agendamento,
  ) {

    if (agendamento == null) {

      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFF34373C,
          ),

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border:
              Border.all(
            color:
                Colors.white12,
          ),
        ),

        child:
            const Row(

          children: [

            CircleAvatar(
              radius: 28,

              backgroundColor:
                  Color(
                0xFF1F5D8F,
              ),

              child:
                  Icon(
                Icons
                    .calendar_month_outlined,
                size: 30,
                color:
                    Colors.white,
              ),
            ),

            SizedBox(
              width: 16,
            ),

            Expanded(
              child:
                  Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    'Próximo agendamento',

                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Você ainda não possui um serviço agendado.',
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
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF34373C,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              Colors.white12,
        ),
      ),

      child:
          Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const CircleAvatar(
            radius: 28,

            backgroundColor:
                Color(
              0xFF1F5D8F,
            ),

            child:
                Icon(
              Icons
                  .calendar_month_outlined,
              size: 30,
              color:
                  Colors.white,
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

                const Text(
                  'Próximo agendamento',

                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  '${agendamento.veiculo.marca} '
                  '${agendamento.veiculo.modelo}',
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  servicos,
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${agendamento.data} '
                  'às '
                  '${agendamento.horario}',
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Status: '
                  '${agendamento.status}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================
  // CARD MENU
  // ==========================================

  Widget cardMenu({
    required BuildContext context,
    required IconData icone,
    required String texto,
    required VoidCallback onPressed,
  }) {

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        20,
      ),

      onTap:
          onPressed,

      child:
          Container(

        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFF34373C,
          ),

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border:
              Border.all(
            color:
                Colors.white12,
          ),
        ),

        child:
            Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icone,
              size: 40,
              color:
                  const Color(
                0xFF91C4FF,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
              ),

              child:
                  Text(
                texto,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
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

    final cliente =
        SessaoCliente.clienteLogado;


    return Scaffold(

      appBar:
          AppBar(

        automaticallyImplyLeading:
            false,

        actions: [

          IconButton(
            onPressed:
                sair,

            icon:
                const Icon(
              Icons.logout,
            ),
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
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(
                      16,
                    ),

                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Olá, ${cliente?.nome ?? ''}!',

                          style:
                              const TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'O que você deseja fazer hoje?',

                          style:
                              TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        cardProximoAgendamento(
                          proximoAgendamento,
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        const Text(
                          'Acessos rápidos',

                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        GridView.count(

                          crossAxisCount: 2,

                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          crossAxisSpacing:
                              14,

                          mainAxisSpacing:
                              14,

                          childAspectRatio:
                              1.15,

                          children: [

                            cardMenu(
                              context:
                                  context,

                              icone:
                                  Icons.person_outline,

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

                            cardMenu(
                              context:
                                  context,

                              icone:
                                  Icons.directions_car_outlined,

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

                            cardMenu(
                              context:
                                  context,

                              icone:
                                  Icons.calendar_month_outlined,

                              texto:
                                  'Agendar Serviço',

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
                              context:
                                  context,

                              icone:
                                  Icons.track_changes_outlined,

                              texto:
                                  'Acompanhar Serviço',

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
                              context:
                                  context,

                              icone:
                                  Icons.history,

                              texto:
                                  'Histórico',

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
                              context:
                                  context,

                              icone:
                                  Icons.payment_outlined,

                              texto:
                                  'Pagamentos',

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
}