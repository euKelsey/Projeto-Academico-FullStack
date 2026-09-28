class Cliente {
  final int idCliente;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;

  const Cliente({
    required this.idCliente,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
  });

  factory Cliente.fromJson(
    Map<String, dynamic> json,
  ) {
    return Cliente(
      idCliente: json['idCliente'],
      nome: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}