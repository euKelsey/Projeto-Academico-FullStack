import 'package:flutter_test/flutter_test.dart';
import 'package:lava_rapido_app/models/veiculo.dart';

void main() {
  group('Veiculo', () {
    test('deve criar um veículo com os dados informados', () {
      final veiculo = Veiculo(
        idVeiculo: 10,
        idCliente: 5,
        marca: 'Toyota',
        modelo: 'Corolla',
        placa: 'ABC1D23',
        cor: 'Preto',
      );

      expect(veiculo.idVeiculo, 10);
      expect(veiculo.idCliente, 5);
      expect(veiculo.marca, 'Toyota');
      expect(veiculo.modelo, 'Corolla');
      expect(veiculo.placa, 'ABC1D23');
      expect(veiculo.cor, 'Preto');
    });

    test('deve usar id como compatibilidade com idVeiculo', () {
      final veiculo = Veiculo(
        id: 7,
        marca: 'Honda',
        modelo: 'Civic',
        placa: 'XYZ9A87',
        cor: 'Branco',
      );

      expect(veiculo.idVeiculo, 7);
      expect(veiculo.id, 7);
    });

    test('deve atualizar idVeiculo ao alterar id', () {
      final veiculo = Veiculo(
        idVeiculo: 1,
        marca: 'Ford',
        modelo: 'Ka',
        placa: 'DEF4G56',
        cor: 'Prata',
      );

      veiculo.id = 99;

      expect(veiculo.idVeiculo, 99);
      expect(veiculo.id, 99);
    });

    test('deve criar veículo a partir de JSON', () {
      final json = {
        'idVeiculo': 15,
        'idCliente': 3,
        'marca': 'Volkswagen',
        'modelo': 'Golf',
        'placa': 'GHI7J89',
        'cor': 'Azul',
      };

      final veiculo = Veiculo.fromJson(json);

      expect(veiculo.idVeiculo, 15);
      expect(veiculo.idCliente, 3);
      expect(veiculo.marca, 'Volkswagen');
      expect(veiculo.modelo, 'Golf');
      expect(veiculo.placa, 'GHI7J89');
      expect(veiculo.cor, 'Azul');
    });

    test('deve usar valores padrão quando JSON não possui campos', () {
      final veiculo = Veiculo.fromJson({});

      expect(veiculo.idVeiculo, 0);
      expect(veiculo.idCliente, 0);
      expect(veiculo.marca, '');
      expect(veiculo.modelo, '');
      expect(veiculo.placa, '');
      expect(veiculo.cor, '');
    });
  });
}