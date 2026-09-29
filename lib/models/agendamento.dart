import 'veiculo.dart';
import 'servico.dart';

class Agendamento {
  int idAgendamento;

  Veiculo veiculo;

  List<Servico> servicos;

  String data;
  String horario;
  String status;

  double valorTotal;

  bool pago;
  String? formaPagamento;

  Agendamento({
    int? id,
    int? idAgendamento,
    required this.veiculo,
    required this.servicos,
    required this.data,
    required this.horario,
    required this.status,
    required this.valorTotal,
    required this.pago,
    this.formaPagamento,
  }) : idAgendamento =
            idAgendamento ?? id ?? 0;

  // Compatibilidade temporária.
  int get id => idAgendamento;

  set id(int valor) {
    idAgendamento = valor;
  }

  factory Agendamento.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> servicosJson =
        json['servicos'] ?? [];

    return Agendamento(
      idAgendamento:
          json['idAgendamento'] ?? 0,

      veiculo: Veiculo.fromJson(
        json['veiculo'],
      ),

      servicos: servicosJson
          .map(
            (item) => Servico.fromJson(
              item,
            ),
          )
          .toList(),

      data:
          json['data'] ?? '',

      horario:
          json['horario'] ?? '',

      status:
          json['status'] ?? '',

      valorTotal:
          (json['valorTotal'] as num?)
                  ?.toDouble() ??
              0.0,

      pago:
          json['pago'] ?? false,

      formaPagamento:
          json['formaPagamento'],
    );
  }
}