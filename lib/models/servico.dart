class Servico {
  int idServico;
  String nome;
  String descricao;
  double preco;

  Servico({
    int? id,
    int? idServico,
    required this.nome,
    this.descricao = '',
    required this.preco,
  }) : idServico = idServico ?? id ?? 0;

  // Compatibilidade com partes antigas do app.
  int get id => idServico;

  set id(int valor) {
    idServico = valor;
  }

  factory Servico.fromJson(
    Map<String, dynamic> json,
  ) {
    return Servico(
      idServico: json['idServico'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
    );
  }
}