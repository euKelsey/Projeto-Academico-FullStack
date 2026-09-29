class Pagamento {
  int idPagamento;
  int idAgendamento;

  double valor;

  String formaPagamento;
  String statusPagamento;
  String dataPagamento;

  String veiculo;
  String servicos;

  Pagamento({
    required this.idPagamento,
    required this.idAgendamento,
    required this.valor,
    required this.formaPagamento,
    required this.statusPagamento,
    required this.dataPagamento,
    required this.veiculo,
    required this.servicos,
  });

  bool get pago =>
      statusPagamento == 'PAGO';

  factory Pagamento.fromJson(
    Map<String, dynamic> json,
  ) {
    return Pagamento(
      idPagamento:
          json['idPagamento'] ?? 0,

      idAgendamento:
          json['idAgendamento'] ?? 0,

      valor:
          (json['valor'] as num?)
                  ?.toDouble() ??
              0.0,

      formaPagamento:
          json['formaPagamento'] ?? '',

      statusPagamento:
          json['statusPagamento'] ??
              'PENDENTE',

      dataPagamento:
          json['dataPagamento'] ?? '',

      veiculo:
          json['veiculo'] ?? '',

      servicos:
          json['servicos'] ?? '',
    );
  }
}