import 'package:flutter_test/flutter_test.dart';
import 'package:lava_rapido_app/models/pagamento.dart';

void main() {
  group('Pagamento', () {
    test('deve criar um pagamento com os dados informados', () {
      final pagamento = Pagamento(
        idPagamento: 1,
        idAgendamento: 10,
        valor: 120.0,
        formaPagamento: 'PIX',
        statusPagamento: 'PAGO',
        dataPagamento: '2026-10-18',
        veiculo: 'Toyota Corolla',
        servicos: 'Lavagem Completa',
      );

      expect(pagamento.idPagamento, 1);
      expect(pagamento.idAgendamento, 10);
      expect(pagamento.valor, 120.0);
      expect(pagamento.formaPagamento, 'PIX');
      expect(pagamento.statusPagamento, 'PAGO');
      expect(pagamento.dataPagamento, '2026-10-18');
      expect(pagamento.veiculo, 'Toyota Corolla');
      expect(pagamento.servicos, 'Lavagem Completa');
    });

    test('deve retornar pago como verdadeiro quando status for PAGO', () {
      final pagamento = Pagamento(
        idPagamento: 1,
        idAgendamento: 10,
        valor: 100.0,
        formaPagamento: 'PIX',
        statusPagamento: 'PAGO',
        dataPagamento: '',
        veiculo: '',
        servicos: '',
      );

      expect(pagamento.pago, true);
    });

    test('deve retornar pago como falso quando status não for PAGO', () {
      final pagamento = Pagamento(
        idPagamento: 1,
        idAgendamento: 10,
        valor: 100.0,
        formaPagamento: '',
        statusPagamento: 'PENDENTE',
        dataPagamento: '',
        veiculo: '',
        servicos: '',
      );

      expect(pagamento.pago, false);
    });

    test('deve criar pagamento a partir de JSON', () {
      final json = {
        'idPagamento': 5,
        'idAgendamento': 20,
        'valor': 95.50,
        'formaPagamento': 'DEBITO',
        'statusPagamento': 'PAGO',
        'dataPagamento': '2026-10-18',
        'veiculo': 'Honda Civic',
        'servicos': 'Lavagem e Polimento',
      };

      final pagamento = Pagamento.fromJson(json);

      expect(pagamento.idPagamento, 5);
      expect(pagamento.idAgendamento, 20);
      expect(pagamento.valor, 95.50);
      expect(pagamento.formaPagamento, 'DEBITO');
      expect(pagamento.statusPagamento, 'PAGO');
      expect(pagamento.pago, true);
    });

    test('deve converter valor inteiro do JSON para double', () {
      final pagamento = Pagamento.fromJson({
        'valor': 100,
      });

      expect(pagamento.valor, 100.0);
    });

    test('deve usar valores padrão quando JSON está vazio', () {
      final pagamento = Pagamento.fromJson({});

      expect(pagamento.idPagamento, 0);
      expect(pagamento.idAgendamento, 0);
      expect(pagamento.valor, 0.0);
      expect(pagamento.formaPagamento, '');
      expect(pagamento.statusPagamento, 'PENDENTE');
      expect(pagamento.dataPagamento, '');
      expect(pagamento.veiculo, '');
      expect(pagamento.servicos, '');
      expect(pagamento.pago, false);
    });
  });
}