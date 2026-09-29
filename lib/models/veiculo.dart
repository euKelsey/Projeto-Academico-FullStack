class Veiculo {
  int idVeiculo;
  int idCliente;

  String marca;
  String modelo;
  String placa;
  String cor;

  Veiculo({
    int? id,
    int? idVeiculo,
    this.idCliente = 0,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.cor,
  }) : idVeiculo = idVeiculo ?? id ?? 0;

  // Compatibilidade temporária com
  // telas antigas que ainda usam veiculo.id
  int get id => idVeiculo;

  set id(int valor) {
    idVeiculo = valor;
  }

  factory Veiculo.fromJson(
    Map<String, dynamic> json,
  ) {
    return Veiculo(
      idVeiculo: json['idVeiculo'] ?? 0,
      idCliente: json['idCliente'] ?? 0,
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placa: json['placa'] ?? '',
      cor: json['cor'] ?? '',
    );
  }
}