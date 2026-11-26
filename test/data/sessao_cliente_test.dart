import 'package:flutter_test/flutter_test.dart';

import 'package:lava_rapido_app/data/sessao_cliente.dart';
import 'package:lava_rapido_app/models/cliente.dart';

import '../support/ambiente_teste.dart';

void main() {
  setUp(limparSessaoTeste);
  tearDown(limparSessaoTeste);

  group('SessaoCliente', () {
    test('deve iniciar sem cliente autenticado', () {
      expect(SessaoCliente.estaLogado, isFalse);
      expect(SessaoCliente.clienteLogado, isNull);
    });

    test('deve iniciar sessao com cliente', () {
      SessaoCliente.iniciar(clienteTeste);

      expect(SessaoCliente.estaLogado, isTrue);
      expect(SessaoCliente.clienteLogado, same(clienteTeste));
    });

    test('deve preservar identificacao do cliente', () {
      SessaoCliente.iniciar(clienteTeste);

      expect(SessaoCliente.clienteLogado!.idCliente, 101);

      expect(SessaoCliente.clienteLogado!.email, 'ativo@example.test');
    });

    test('deve atualizar cliente da sessao', () {
      SessaoCliente.iniciar(clienteTeste);

      final atualizado = Cliente.fromJson(
        clienteJson(nome: 'CLIENTE ATUALIZADO'),
      );

      SessaoCliente.iniciar(atualizado);

      expect(SessaoCliente.clienteLogado!.nome, 'CLIENTE ATUALIZADO');
    });

    test('deve substituir sessao por outro cliente', () {
      SessaoCliente.iniciar(clienteTeste);

      final outro = Cliente.fromJson({
        ...clienteJson(),
        'idCliente': 102,
        'email': 'livre@example.test',
      });

      SessaoCliente.iniciar(outro);

      expect(SessaoCliente.clienteLogado!.idCliente, 102);
    });

    test('deve limpar cliente ao encerrar sessao', () {
      SessaoCliente.iniciar(clienteTeste);
      SessaoCliente.encerrar();

      expect(SessaoCliente.estaLogado, isFalse);
      expect(SessaoCliente.clienteLogado, isNull);
    });

    test('deve aceitar encerramento repetido', () {
      SessaoCliente.encerrar();
      SessaoCliente.encerrar();

      expect(SessaoCliente.estaLogado, isFalse);
    });
  });
}
