import 'package:flutter_test/flutter_test.dart';
import 'package:lava_rapido_app/models/cliente.dart';

void main() {
  group('Cliente', () {
    test('deve criar um cliente com os dados informados', () {
      const cliente = Cliente(
        idCliente: 1,
        nome: 'Kelsey',
        cpf: '12345678900',
        telefone: '11999999999',
        email: 'teste@email.com',
      );

      expect(cliente.idCliente, 1);
      expect(cliente.nome, 'Kelsey');
      expect(cliente.cpf, '12345678900');
      expect(cliente.telefone, '11999999999');
      expect(cliente.email, 'teste@email.com');
    });

    test('deve criar cliente a partir de JSON', () {
      final json = {
        'idCliente': 5,
        'nome': 'João',
        'cpf': '98765432100',
        'telefone': '11888888888',
        'email': 'joao@email.com',
      };

      final cliente = Cliente.fromJson(json);

      expect(cliente.idCliente, 5);
      expect(cliente.nome, 'João');
      expect(cliente.cpf, '98765432100');
      expect(cliente.telefone, '11888888888');
      expect(cliente.email, 'joao@email.com');
    });

    test('deve usar strings vazias quando campos opcionais não existem', () {
      final cliente = Cliente.fromJson({
        'idCliente': 1,
      });

      expect(cliente.idCliente, 1);
      expect(cliente.nome, '');
      expect(cliente.cpf, '');
      expect(cliente.telefone, '');
      expect(cliente.email, '');
    });
  });
}