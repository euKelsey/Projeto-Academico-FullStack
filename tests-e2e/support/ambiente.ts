import { request } from '@playwright/test';
import { execFileSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';

const URL_AUTORIZADA =
    'http://127.0.0.1:8081';

const CONTAINER_DB =
    'fast-splash-mysql-test';

export function executarSqlTeste(
    sql: string
): string {

    const projeto = execFileSync(
        'docker',
        [
            'inspect',
            '--format',
            '{{index .Config.Labels "com.docker.compose.project"}}',
            CONTAINER_DB,
        ],
        { encoding: 'utf8' }
    ).trim();

    if (projeto !== 'fast-splash-tests') {

        throw new Error(
            'Container MySQL nao autorizado.'
        );

    }

    return execFileSync(

        'docker',

        [
            'exec',
            '-i',
            CONTAINER_DB,
            'sh',
            '-c',
            'MYSQL_PWD="$MYSQL_PASSWORD" mysql --default-character-set=utf8mb4 -u "$MYSQL_USER" -D fast_splash_test -N -B',
        ],

        {
            input: sql,
            encoding: 'utf8',
            timeout: 15000,
        }

    ).trim();

}

export async function verificarAmbienteIsolado(): Promise<void> {

    const url =
        process.env.FASTSPLASH_E2E_BASE_URL;

    if (url !== URL_AUTORIZADA) {

        throw new Error(
            'URL HTTP nao autorizada.'
        );

    }

    const banco = executarSqlTeste(
        'SELECT DATABASE();'
    );

    if (banco !== 'fast_splash_test') {

        throw new Error(
            'Banco de dados nao autorizado.'
        );

    }

    const marcador =
        'E2E_' + randomUUID().replace(/-/g, '');

    const contexto = await request.newContext({

        baseURL: URL_AUTORIZADA,

        timeout: 10000,

        maxRedirects: 0,

        extraHTTPHeaders: {
            Accept: 'application/json',
        },

    });

    try {

        executarSqlTeste(`
            INSERT INTO servico (
                nome,
                descricao,
                preco,
                ativo
            )
            VALUES (
                '${marcador}',
                'Marcador temporario de isolamento',
                1.23,
                1
            );
        `);

        const login = await contexto.post(

            '/api/auth/login',

            {
                form: {
                    email: 'ativo@example.test',
                    senha: 'SenhaFicticia@123',
                },
            }

        );

        if (login.status() !== 200) {

            throw new Error(
                'Falha na autenticacao do cliente de testes.'
            );

        }

        const dadosLogin = await login.json();

        if (
            dadosLogin.sucesso !== true ||
            dadosLogin.cliente?.idCliente !== 101
        ) {

            throw new Error(
                'Identidade do cliente de testes inesperada.'
            );

        }

        const resposta = await contexto.get(
            '/api/servicos'
        );

        if (resposta.status() !== 200) {

            throw new Error(
                'Falha na consulta de servicos.'
            );

        }

        const dados = await resposta.json();

        if (
            dados.sucesso !== true ||
            !Array.isArray(dados.servicos)
        ) {

            throw new Error(
                'Resposta HTTP inesperada.'
            );

        }

        const encontrados = dados.servicos.filter(
            (servico: { nome: string; preco: number }) =>
                servico.nome === marcador &&
                Number(servico.preco) === 1.23
        );

        if (encontrados.length !== 1) {

            throw new Error(
                'O servidor nao comprovou acesso ao banco isolado.'
            );

        }

        console.log(
            '=== IDENTIDADE DO BANCO COMPROVADA VIA HTTP ==='
        );

    } finally {

        try {

            executarSqlTeste(`
                DELETE FROM servico
                WHERE nome = '${marcador}';
            `);

        } finally {

            await contexto.dispose();

        }

    }

}
