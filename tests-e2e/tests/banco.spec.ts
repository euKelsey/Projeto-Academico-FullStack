import { test, expect } from '../support/fixtures';

import {
    executarSqlTeste,
} from '../support/ambiente';

import {
    restaurarBancoTeste,
} from '../support/banco';

test.describe('Restauracao do banco de testes', () => {

    test('deve utilizar exclusivamente o banco de testes', () => {

        expect(
            executarSqlTeste('SELECT DATABASE();')
        ).toBe('fast_splash_test');

    });

    test('deve restaurar os quatro clientes originais', () => {

        expect(

            executarSqlTeste(
                'SELECT COUNT(*) FROM cliente;'
            )

        ).toBe('4');

    });

    test('deve restaurar os cinco veiculos originais', () => {

        expect(

            executarSqlTeste(
                'SELECT COUNT(*) FROM veiculo;'
            )

        ).toBe('5');

    });

    test('deve restaurar os quatro servicos originais', () => {

        expect(

            executarSqlTeste(
                'SELECT COUNT(*) FROM servico;'
            )

        ).toBe('4');

    });

    test('deve restaurar os relacionamentos operacionais', () => {

        const resultado = executarSqlTeste(`

            SELECT
                (SELECT COUNT(*) FROM agendamento),
                (SELECT COUNT(*) FROM agendamento_servico),
                (SELECT COUNT(*) FROM atendimento),
                (SELECT COUNT(*) FROM pagamento),
                (SELECT COUNT(*) FROM colaborador),
                (SELECT COUNT(*) FROM colaborador_atendimento);

        `);

        expect(
            resultado.split('\t').map(Number)
        ).toEqual([6, 7, 5, 6, 5, 4]);

    });

    test('deve restaurar um registro alterado', () => {

        executarSqlTeste(`

            UPDATE servico
            SET preco = 999.99
            WHERE id_servico = 301;

        `);

        expect(

            executarSqlTeste(`

                SELECT preco
                FROM servico
                WHERE id_servico = 301;

            `)

        ).toBe('999.99');

        restaurarBancoTeste();

        expect(

            executarSqlTeste(`

                SELECT preco
                FROM servico
                WHERE id_servico = 301;

            `)

        ).toBe('50.00');

    });

    test('deve remover registros temporarios na restauracao', () => {

        executarSqlTeste(`

            INSERT INTO servico (
                nome,
                descricao,
                preco,
                ativo
            )
            VALUES (
                'SERVICO TEMPORARIO E2E',
                'Registro criado durante o teste',
                25.00,
                1
            );

        `);

        expect(

            executarSqlTeste(
                'SELECT COUNT(*) FROM servico;'
            )

        ).toBe('5');

        restaurarBancoTeste();

        expect(

            executarSqlTeste(
                'SELECT COUNT(*) FROM servico;'
            )

        ).toBe('4');

    });

    test('deve restaurar o banco repetidamente', () => {

        restaurarBancoTeste();

        restaurarBancoTeste();

        restaurarBancoTeste();

        const resultado = executarSqlTeste(`

            SELECT
                (SELECT COUNT(*) FROM cliente),
                (SELECT COUNT(*) FROM veiculo),
                (SELECT COUNT(*) FROM servico),
                (SELECT COUNT(*) FROM agendamento),
                (SELECT COUNT(*) FROM pagamento);

        `);

        expect(
            resultado.split('\t').map(Number)
        ).toEqual([4, 5, 4, 6, 6]);

    });

});
