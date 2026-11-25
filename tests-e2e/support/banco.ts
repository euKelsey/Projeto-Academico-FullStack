import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { executarSqlTeste } from './ambiente';

const CAMINHO_SEED = resolve(
    __dirname,
    '../../database/seed_test.sql'
);

export function restaurarBancoTeste(): void {

    const banco = executarSqlTeste(
        'SELECT DATABASE();'
    );

    if (banco !== 'fast_splash_test') {

        throw new Error(
            'Restauracao bloqueada: banco nao autorizado.'
        );

    }

    const seedOriginal = readFileSync(
        CAMINHO_SEED,
        'utf8'
    );

    const seed = seedOriginal

        .replace(/^\uFEFF/, '')

        .split(/\r?\n/)

        .filter(linha => {

            const texto = linha.trim();

            return !(
                /^USE\s+/i.test(texto) ||
                /^START\s+TRANSACTION\s*;/i.test(texto) ||
                /^COMMIT\s*;/i.test(texto)
            );

        })

        .join('\n');

    if (!/INSERT\s+INTO/i.test(seed)) {

        throw new Error(
            'Seed de testes invalido.'
        );

    }

    executarSqlTeste(`

        START TRANSACTION;

        DELETE FROM colaborador_atendimento;
        DELETE FROM pagamento;
        DELETE FROM atendimento;
        DELETE FROM agendamento_servico;
        DELETE FROM agendamento;
        DELETE FROM veiculo;
        DELETE FROM colaborador;
        DELETE FROM servico;
        DELETE FROM cliente;

        ${seed}

        COMMIT;

    `);

}
