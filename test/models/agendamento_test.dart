import 'package:flutter_test/flutter_test.dart';
import 'package:lava_rapido_app/models/agendamento.dart';
import 'package:lava_rapido_app/models/servico.dart';
import 'package:lava_rapido_app/models/veiculo.dart';

void main() {
  group('Agendamento', () {
    test('deve criar um agendamento com os dados informados', () {
      final veiculo = Veiculo(
        idVeiculo: 1,
        marca: 'Toyota',
        modelo: 'Corolla',
        placa: 'ABC1D23',
        cor: 'Preto',
      );

      final servico = Servico(
        idServico: 10,
        nome: 'Lavagem Completa',
        preco: 80.0,
      );

      final agendamento = Agendamento(
        idAgendamento: 100,
        veiculo: veiculo,
        servicos: [servico],
        data: '2026-10-20',
        horario: '14:00',
        status: 'AGENDADO',
        valorTotal: 80.0,
        pago: false,
      );

      expect(agendamento.idAgendamento, 100);
      expect(agendamento.veiculo.idVeiculo, 1);
      expect(agendamento.servicos.length, 1);
      expect(agendamento.servicos.first.idServico, 10);
      expect(agendamento.data, '2026-10-20');
      expect(agendamento.horario, '14:00');
      expect(agendamento.status, 'AGENDADO');
      expect(agendamento.valorTotal, 80.0);
      expect(agendamento.pago, false);
      expect(agendamento.formaPagamento, isNull);
    });

    test('deve usar id como compatibilidade com idAgendamento', () {
      final agendamento = Agendamento(
        id: 7,
        veiculo: Veiculo(
          marca: 'Honda',
          modelo: 'Civic',
          placa: 'XYZ9A87',
          cor: 'Branco',
        ),
        servicos: [],
        data: '2026-10-20',
        horario: '10:00',
        status: 'AGENDADO',
        valorTotal: 0.0,
        pago: false,
      );

      expect(agendamento.idAgendamento, 7);
      expect(agendamento.id, 7);
    });

    test('deve atualizar idAgendamento ao alterar id', () {
      final agendamento = Agendamento(
        idAgendamento: 1,
        veiculo: Veiculo(
          marca: 'Ford',
          modelo: 'Ka',
          placa: 'DEF4G56',
          cor: 'Prata',
        ),
        servicos: [],
        data: '2026-10-20',
        horario: '11:00',
        status: 'AGENDADO',
        valorTotal: 0.0,
        pago: false,
      );

      agendamento.id = 99;

      expect(agendamento.idAgendamento, 99);
      expect(agendamento.id, 99);
    });

    test('deve criar agendamento completo a partir de JSON', () {
      final json = {
        'idAgendamento': 15,
        'veiculo': {
          'idVeiculo': 3,
          'idCliente': 8,
          'marca': 'Volkswagen',
          'modelo': 'Golf',
          'placa': 'GHI7J89',
          'cor': 'Azul',
        },
        'servicos': [
          {
            'idServico': 1,
            'nome': 'Lavagem',
            'descricao': 'Lavagem externa',
            'preco': 50,
          },
          {
            'idServico': 2,
            'nome': 'Polimento',
            'descricao': 'Polimento completo',
            'preco': 120.50,
          },
        ],
        'data': '2026-10-22',
        'horario': '15:30',
        'status': 'AGENDADO',
        'valorTotal': 170.50,
        'pago': true,
        'formaPagamento': 'PIX',
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.idAgendamento, 15);

      expect(agendamento.veiculo.idVeiculo, 3);
      expect(agendamento.veiculo.marca, 'Volkswagen');

      expect(agendamento.servicos.length, 2);
      expect(agendamento.servicos[0].nome, 'Lavagem');
      expect(agendamento.servicos[1].nome, 'Polimento');

      expect(agendamento.data, '2026-10-22');
      expect(agendamento.horario, '15:30');
      expect(agendamento.status, 'AGENDADO');

      expect(agendamento.valorTotal, 170.50);
      expect(agendamento.pago, true);
      expect(agendamento.formaPagamento, 'PIX');
    });

    test('deve converter valorTotal inteiro do JSON para double', () {
      final json = {
        'veiculo': {
          'marca': 'Fiat',
          'modelo': 'Argo',
          'placa': 'AAA1B23',
          'cor': 'Vermelho',
        },
        'servicos': [],
        'valorTotal': 100,
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.valorTotal, 100.0);
    });

    test('deve usar lista vazia quando JSON não possui serviços', () {
      final json = {
        'veiculo': {
          'marca': 'Fiat',
          'modelo': 'Uno',
          'placa': 'BBB2C34',
          'cor': 'Branco',
        },
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.servicos, isEmpty);
    });

    test('deve usar valores padrão para campos opcionais do JSON', () {
      final json = {
        'veiculo': {
          'marca': '',
          'modelo': '',
          'placa': '',
          'cor': '',
        },
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.idAgendamento, 0);
      expect(agendamento.data, '');
      expect(agendamento.horario, '');
      expect(agendamento.status, '');
      expect(agendamento.valorTotal, 0.0);
      expect(agendamento.pago, false);
      expect(agendamento.formaPagamento, isNull);
    });
  });
}