import 'package:flutter_test/flutter_test.dart';
import 'package:lava_rapido_app/models/servico.dart';

void main() {
  group('Servico', () {
    test('deve criar um serviço com os dados informados', () {
      final servico = Servico(
        idServico: 10,
        nome: 'Lavagem Completa',
        descricao: 'Lavagem interna e externa',
        preco: 80.0,
      );

      expect(servico.idServico, 10);
      expect(servico.nome, 'Lavagem Completa');
      expect(servico.descricao, 'Lavagem interna e externa');
      expect(servico.preco, 80.0);
    });

    test('deve usar descrição vazia como valor padrão', () {
      final servico = Servico(
        nome: 'Lavagem Simples',
        preco: 40.0,
      );

      expect(servico.descricao, '');
    });

    test('deve usar id como compatibilidade com idServico', () {
      final servico = Servico(
        id: 7,
        nome: 'Polimento',
        preco: 120.0,
      );

      expect(servico.idServico, 7);
      expect(servico.id, 7);
    });

    test('deve atualizar idServico ao alterar id', () {
      final servico = Servico(
        idServico: 1,
        nome: 'Enceramento',
        preco: 60.0,
      );

      servico.id = 99;

      expect(servico.idServico, 99);
      expect(servico.id, 99);
    });

    test('deve criar serviço a partir de JSON', () {
      final json = {
        'idServico': 15,
        'nome': 'Higienização',
        'descricao': 'Limpeza interna detalhada',
        'preco': 150.50,
      };

      final servico = Servico.fromJson(json);

      expect(servico.idServico, 15);
      expect(servico.nome, 'Higienização');
      expect(servico.descricao, 'Limpeza interna detalhada');
      expect(servico.preco, 150.50);
    });

    test('deve converter preço inteiro do JSON para double', () {
      final json = {
        'idServico': 20,
        'nome': 'Lavagem',
        'descricao': 'Lavagem externa',
        'preco': 50,
      };

      final servico = Servico.fromJson(json);

      expect(servico.preco, 50.0);
    });

    test('deve usar valores padrão quando JSON não possui campos', () {
      final servico = Servico.fromJson({});

      expect(servico.idServico, 0);
      expect(servico.nome, '');
      expect(servico.descricao, '');
      expect(servico.preco, 0.0);
    });
  });
}