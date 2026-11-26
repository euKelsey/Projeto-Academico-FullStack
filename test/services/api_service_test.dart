import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:lava_rapido_app/services/api_service.dart';

import '../support/ambiente_teste.dart';

Matcher erroComMensagem(String mensagem) {
  return throwsA(
    isA<Exception>().having(
      (erro) => erro.toString(),
      'mensagem',
      contains(mensagem),
    ),
  );
}

Future<void> verificarRequisicao(
  http.Request request, {
  required String metodo,
  required String rota,
}) async {
  expect(request.method, metodo);
  expect(rotaApi(request), rota);

  expect(cabecalho(request, 'Accept'), 'application/json');
}

void main() {
  setUp(limparSessaoTeste);
  tearDown(limparSessaoTeste);

  group('ApiService - Comunicacao', () {
    test('deve consultar endpoint de teste', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(request, metodo: 'GET', rota: '/api/teste');

        return respostaJson({'mensagem': 'API funcionando.'});
      });

      expect(await ambiente.executar(ApiService.testarApi), 'API funcionando.');

      expect(ambiente.requisicoes, hasLength(1));
    });

    test('deve usar mensagem padrao de sucesso', () async {
      final ambiente = AmbienteApiTeste((_) async => respostaJson({}));

      expect(await ambiente.executar(ApiService.testarApi), 'API funcionando.');
    });

    test('deve preservar caracteres UTF-8', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({'mensagem': 'Conexão disponível.'}),
      );

      expect(
        await ambiente.executar(ApiService.testarApi),
        'Conexão disponível.',
      );
    });

    test('deve apresentar erro retornado pelo servidor', () async {
      final ambiente = AmbienteApiTeste(
        (_) async =>
            respostaJson({'mensagem': 'Servidor indisponível.'}, status: 503),
      );

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        erroComMensagem('Servidor indisponível.'),
      );
    });

    test('deve utilizar erro padrao sem mensagem', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({}, status: 500),
      );

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        erroComMensagem('Erro ao acessar API.'),
      );
    });

    for (final status in [200, 500]) {
      test('deve rejeitar resposta vazia $status', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => http.Response('', status),
        );

        await expectLater(
          ambiente.executar(ApiService.testarApi),
          erroComMensagem('resposta vazia. Status: $status'),
        );
      });
    }

    test('deve rejeitar resposta somente com espacos', () async {
      final ambiente = AmbienteApiTeste((_) async => http.Response('   ', 200));

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        erroComMensagem('resposta vazia'),
      );
    });

    for (final corpo in ['[]', 'null', '123', '"texto"']) {
      test('deve rejeitar JSON nao objeto $corpo', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => http.Response(corpo, 200),
        );

        await expectLater(
          ambiente.executar(ApiService.testarApi),
          erroComMensagem('Formato de resposta inesperado.'),
        );
      });
    }

    test('deve tratar resposta HTML', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => http.Response('<html>Erro interno</html>', 500),
      );

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        erroComMensagem('O servidor não retornou JSON.'),
      );
    });

    test('deve limitar resumo de resposta invalida', () async {
      final corpo = List.filled(500, 'X').join();

      final ambiente = AmbienteApiTeste((_) async => http.Response(corpo, 500));

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        throwsA(
          isA<Exception>().having(
            (erro) => erro.toString(),
            'mensagem',
            allOf(
              contains('Status: 500'),
              contains('Resposta: ${corpo.substring(0, 300)}...'),
              isNot(contains(corpo)),
            ),
          ),
        ),
      );
    });

    test('deve propagar falha de conexao', () async {
      final ambiente = AmbienteApiTeste((_) async {
        throw http.ClientException('Falha de conexão simulada');
      });

      await expectLater(
        ambiente.executar(ApiService.testarApi),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  group('ApiService - Autenticacao', () {
    test('deve enviar credenciais e converter cliente', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/auth/login',
        );

        expect(request.bodyFields, {
          'email': 'ativo@example.test',
          'senha': senhaTeste,
        });

        expect(cabecalho(request, 'Cookie'), isNull);

        return respostaJson({'sucesso': true, 'cliente': clienteJson()});
      });

      final cliente = await ambiente.executar(
        () => ApiService.loginCliente(
          email: 'ativo@example.test',
          senha: senhaTeste,
        ),
      );

      expect(cliente.idCliente, 101);
      expect(cliente.email, 'ativo@example.test');
      expect(cliente.nome, 'Cliente Teste Ativo');
    });

    for (final status in [400, 401, 403, 500]) {
      test('deve tratar falha de login $status', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => respostaJson({
            'sucesso': false,
            'mensagem': 'Login recusado.',
          }, status: status),
        );

        await expectLater(
          ambiente.executar(
            () => ApiService.loginCliente(
              email: 'ativo@example.test',
              senha: senhaTeste,
            ),
          ),
          erroComMensagem('Login recusado.'),
        );
      });
    }

    for (final cliente in [null, 'invalido', []]) {
      test('deve rejeitar cliente invalido: $cliente', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => respostaJson({'cliente': cliente}),
        );

        await expectLater(
          ambiente.executar(
            () => ApiService.loginCliente(
              email: 'ativo@example.test',
              senha: senhaTeste,
            ),
          ),
          erroComMensagem('Dados do cliente inválidos.'),
        );
      });
    }

    for (final cookie in [
      'JSESSIONID=teste123; Path=/; HttpOnly',
      'JSESSIONID=teste123',
    ]) {
      test('deve reutilizar cookie: $cookie', () async {
        final ambiente = AmbienteApiTeste((request) async {
          if (rotaApi(request) == '/api/auth/login') {
            return respostaJson(
              {'cliente': clienteJson()},
              headers: {'set-cookie': cookie},
            );
          }

          expect(cabecalho(request, 'Cookie'), 'JSESSIONID=teste123');

          return respostaJson({
            'veiculos': [veiculoJson()],
          });
        });

        await ambiente.executar(() async {
          await ApiService.loginCliente(
            email: 'ativo@example.test',
            senha: senhaTeste,
          );

          await ApiService.listarVeiculos();
        });

        expect(ambiente.requisicoes, hasLength(2));
      });
    }

    test('deve remover cookie no logout local', () async {
      final ambiente = AmbienteApiTeste((request) async {
        if (rotaApi(request) == '/api/auth/login') {
          return respostaJson(
            {'cliente': clienteJson()},
            headers: {'set-cookie': 'JSESSIONID=teste123'},
          );
        }

        return respostaJson({'veiculos': []});
      });

      await ambiente.executar(() async {
        await ApiService.loginCliente(
          email: 'ativo@example.test',
          senha: senhaTeste,
        );

        await ApiService.listarVeiculos();

        ApiService.encerrarSessao();

        await ApiService.listarVeiculos();
      });

      expect(
        cabecalho(ambiente.requisicoes[1], 'Cookie'),
        'JSESSIONID=teste123',
      );

      expect(cabecalho(ambiente.requisicoes[2], 'Cookie'), isNull);
    });
  });

  group('ApiService - Perfil', () {
    test('deve consultar cadastro autenticado', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'GET',
          rota: '/api/clientes/me',
        );

        return respostaJson({'cliente': clienteJson()});
      });

      final cliente = await ambiente.executar(ApiService.buscarMeuCadastro);

      expect(cliente.idCliente, 101);
      expect(cliente.cpf, '98765410130');
      expect(cliente.telefone, '11900000101');
    });

    test('deve atualizar cadastro sem enviar CPF ou ID', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/clientes/me',
        );

        expect(request.bodyFields, {
          'nome': 'CLIENTE ATUALIZADO',
          'telefone': '11912345678',
          'email': 'novo@example.test',
        });

        return respostaJson({
          'cliente': clienteJson(
            nome: 'CLIENTE ATUALIZADO',
            telefone: '11912345678',
            email: 'novo@example.test',
          ),
        });
      });

      final cliente = await ambiente.executar(
        () => ApiService.atualizarMeuCadastro(
          nome: 'CLIENTE ATUALIZADO',
          telefone: '11912345678',
          email: 'novo@example.test',
        ),
      );

      expect(cliente.nome, 'CLIENTE ATUALIZADO');
      expect(cliente.email, 'novo@example.test');
      expect(cliente.cpf, '98765410130');
    });

    for (final status in [401, 403, 404]) {
      test('deve tratar erro de consulta $status', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => respostaJson({
            'mensagem': 'Cadastro indisponível.',
          }, status: status),
        );

        await expectLater(
          ambiente.executar(ApiService.buscarMeuCadastro),
          erroComMensagem('Cadastro indisponível.'),
        );
      });
    }

    test('deve apresentar conflito de email', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'mensagem': 'Este e-mail já está sendo utilizado.',
        }, status: 409),
      );

      await expectLater(
        ambiente.executar(
          () => ApiService.atualizarMeuCadastro(
            nome: 'CLIENTE',
            telefone: '11900000101',
            email: 'duplicado@example.test',
          ),
        ),
        erroComMensagem('Este e-mail já está sendo utilizado.'),
      );
    });

    test('deve rejeitar cadastro sem objeto cliente', () async {
      final ambiente = AmbienteApiTeste((_) async => respostaJson({}));

      await expectLater(
        ambiente.executar(ApiService.buscarMeuCadastro),
        erroComMensagem('Dados do cliente inválidos.'),
      );
    });
  });

  group('ApiService - Veiculos', () {
    test('deve listar e converter veiculos', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'GET',
          rota: '/api/veiculos',
        );

        return respostaJson({
          'veiculos': [
            veiculoJson(),
            veiculoJson(id: 202, modelo: 'Civic', placa: 'TST1A02'),
          ],
        });
      });

      final lista = await ambiente.executar(ApiService.listarVeiculos);

      expect(lista, hasLength(2));
      expect(lista.first.idVeiculo, 201);
      expect(lista.last.placa, 'TST1A02');
    });

    test('deve cadastrar veiculo com parametros corretos', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/veiculos',
        );

        expect(request.bodyFields, {
          'placa': 'TST1A01',
          'marca': 'VOLKSWAGEN',
          'modelo': 'POLO',
          'cor': 'BRANCO',
        });

        return respostaJson({'veiculo': veiculoJson()}, status: 201);
      });

      final veiculo = await ambiente.executar(
        () => ApiService.cadastrarVeiculo(
          placa: 'TST1A01',
          marca: 'VOLKSWAGEN',
          modelo: 'POLO',
          cor: 'BRANCO',
        ),
      );

      expect(veiculo.idVeiculo, 201);
    });

    test('deve enviar ID ao atualizar veiculo', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/veiculos/editar',
        );

        expect(request.bodyFields, {
          'idVeiculo': '201',
          'placa': 'TST1A01',
          'marca': 'VOLKSWAGEN',
          'modelo': 'POLO',
          'cor': 'AZUL',
        });

        return respostaJson({'veiculo': veiculoJson(cor: 'AZUL')});
      });

      final veiculo = await ambiente.executar(
        () => ApiService.atualizarVeiculo(
          idVeiculo: 201,
          placa: 'TST1A01',
          marca: 'VOLKSWAGEN',
          modelo: 'POLO',
          cor: 'AZUL',
        ),
      );

      expect(veiculo.cor, 'AZUL');
    });

    test('deve enviar ID na exclusao', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/veiculos/excluir',
        );

        expect(request.bodyFields, {'idVeiculo': '201'});

        return respostaJson({'mensagem': 'Veículo excluído com sucesso.'});
      });

      expect(
        await ambiente.executar(() => ApiService.excluirVeiculo(201)),
        'Veículo excluído com sucesso.',
      );
    });

    test('deve apresentar conflito de placa duplicada', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'mensagem': 'Esta placa já está cadastrada.',
        }, status: 409),
      );

      await expectLater(
        ambiente.executar(
          () => ApiService.cadastrarVeiculo(
            placa: 'TST1A01',
            marca: 'VW',
            modelo: 'POLO',
            cor: 'BRANCO',
          ),
        ),
        erroComMensagem('Esta placa já está cadastrada.'),
      );
    });

    test('deve apresentar bloqueio de exclusao com pendencias', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'mensagem':
              'Este veículo possui agendamentos ou atendimentos pendentes.',
        }, status: 409),
      );

      await expectLater(
        ambiente.executar(() => ApiService.excluirVeiculo(201)),
        erroComMensagem('agendamentos ou atendimentos pendentes'),
      );
    });
  });

  group('ApiService - Servicos', () {
    test('deve listar servicos com precos numericos', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'GET',
          rota: '/api/servicos',
        );

        return respostaJson({
          'servicos': [
            servicoJson(),
            servicoJson(id: 302, nome: 'Lavagem Completa', preco: 80.50),
          ],
        });
      });

      final lista = await ambiente.executar(ApiService.listarServicos);

      expect(lista, hasLength(2));
      expect(lista.first.preco, 50.0);
      expect(lista.last.preco, 80.50);
    });
  });

  group('ApiService - Agendamentos', () {
    test('deve enviar todos os IDs de servicos', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/agendamentos',
        );

        final campos = Uri.parse('http://teste.local/?${request.body}')
            .queryParametersAll;

        expect(campos, {
          'idVeiculo': ['201'],
          'data': ['2027-01-15'],
          'horario': ['09:30'],
          'idServico': ['301', '302'],
        });

        expect(
          cabecalho(request, 'Content-Type'),
          contains('application/x-www-form-urlencoded'),
        );

        return respostaJson({
          'mensagem': 'Agendamento confirmado com sucesso.',
        }, status: 201);
      });

      expect(
        await ambiente.executar(
          () => ApiService.cadastrarAgendamento(
            idVeiculo: 201,
            idsServicos: [301, 302],
            data: '2027-01-15',
            horario: '09:30',
          ),
        ),
        'Agendamento confirmado com sucesso.',
      );
    });

    test('deve listar agendamento com objetos relacionados', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'agendamentos': [agendamentoJson()],
        }),
      );

      final lista = await ambiente.executar(ApiService.listarAgendamentos);

      expect(lista, hasLength(1));
      expect(lista.first.idAgendamento, 501);
      expect(lista.first.veiculo.idVeiculo, 201);
      expect(lista.first.servicos.first.idServico, 301);
      expect(lista.first.valorTotal, 50.0);
    });

    test('deve enviar ID no cancelamento', () async {
      final ambiente = AmbienteApiTeste((request) async {
        await verificarRequisicao(
          request,
          metodo: 'POST',
          rota: '/api/agendamentos/cancelar',
        );

        expect(request.bodyFields, {'idAgendamento': '501'});

        return respostaJson({'mensagem': 'Agendamento cancelado com sucesso.'});
      });

      expect(
        await ambiente.executar(() => ApiService.cancelarAgendamento(501)),
        'Agendamento cancelado com sucesso.',
      );
    });

    test('deve tratar agendamento duplicado', () async {
      final ambiente = AmbienteApiTeste(
        (_) async =>
            respostaJson({'mensagem': 'Agendamento duplicado.'}, status: 409),
      );

      await expectLater(
        ambiente.executar(
          () => ApiService.cadastrarAgendamento(
            idVeiculo: 201,
            idsServicos: [301],
            data: '2027-01-15',
            horario: '09:30',
          ),
        ),
        erroComMensagem('Agendamento duplicado.'),
      );
    });

    test('deve apresentar bloqueio de cancelamento', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'mensagem': 'Este agendamento não pode mais ser cancelado.',
        }, status: 409),
      );

      await expectLater(
        ambiente.executar(() => ApiService.cancelarAgendamento(501)),
        erroComMensagem('não pode mais ser cancelado'),
      );
    });
  });

  group('ApiService - Pagamentos', () {
    test('deve converter pagamentos pendentes e pagos', () async {
      final ambiente = AmbienteApiTeste(
        (_) async => respostaJson({
          'pagamentos': [
            pagamentoJson(),
            pagamentoJson(
              id: 702,
              idAgendamento: 502,
              status: 'PAGO',
              forma: 'PIX',
              valor: 80,
            ),
          ],
        }),
      );

      final lista = await ambiente.executar(ApiService.listarPagamentos);

      expect(lista, hasLength(2));
      expect(lista.first.pago, isFalse);
      expect(lista.last.pago, isTrue);
      expect(lista.last.valor, 80.0);
      expect(lista.last.formaPagamento, 'PIX');
    });

    for (final forma in ['PIX', 'DINHEIRO', 'CREDITO', 'DEBITO']) {
      test('deve enviar pagamento por $forma', () async {
        final ambiente = AmbienteApiTeste((request) async {
          await verificarRequisicao(
            request,
            metodo: 'POST',
            rota: '/api/pagamentos/pagar',
          );

          expect(request.bodyFields, {
            'idAgendamento': '501',
            'formaPagamento': forma,
          });

          return respostaJson({'mensagem': 'Pagamento realizado com sucesso.'});
        });

        expect(
          await ambiente.executar(
            () => ApiService.realizarPagamento(
              idAgendamento: 501,
              formaPagamento: forma,
            ),
          ),
          'Pagamento realizado com sucesso.',
        );
      });
    }

    test('deve apresentar pagamento indisponivel', () async {
      final ambiente = AmbienteApiTeste(
        (_) async =>
            respostaJson({'mensagem': 'Pagamento indisponível.'}, status: 404),
      );

      await expectLater(
        ambiente.executar(
          () => ApiService.realizarPagamento(
            idAgendamento: 501,
            formaPagamento: 'PIX',
          ),
        ),
        erroComMensagem('Pagamento indisponível.'),
      );
    });
  });

  group('ApiService - Listagens compartilhadas', () {
    final listagens = <String, Future<List<dynamic>> Function()>{
      'veiculos': ApiService.listarVeiculos,
      'servicos': ApiService.listarServicos,
      'agendamentos': ApiService.listarAgendamentos,
      'pagamentos': ApiService.listarPagamentos,
    };

    for (final item in listagens.entries) {
      test('deve aceitar lista vazia de ${item.key}', () async {
        final ambiente = AmbienteApiTeste(
          (_) async => respostaJson({item.key: []}),
        );

        expect(await ambiente.executar(item.value), isEmpty);
      });

      test('deve tratar lista ausente de ${item.key}', () async {
        final ambiente = AmbienteApiTeste((_) async => respostaJson({}));

        expect(await ambiente.executar(item.value), isEmpty);
      });

      for (final status in [401, 403, 500]) {
        test('deve tratar erro $status em ${item.key}', () async {
          final ambiente = AmbienteApiTeste(
            (_) async => respostaJson({
              'mensagem': 'Falha na consulta.',
            }, status: status),
          );

          await expectLater(
            ambiente.executar(item.value),
            erroComMensagem('Falha na consulta.'),
          );
        });
      }
    }
  });
}
