import { test, expect } from '../support/fixtures';

import {
    executarSqlTeste,
} from '../support/ambiente';

const URL_AUTORIZADA =
    'http://127.0.0.1:8081';

const EMAIL_CLIENTE =
    'ativo@example.test';

const SENHA_CLIENTE =
    'SenhaFicticia@123';

test.describe('Integracao navegador e servidor', () => {

    test('deve acessar a pagina inicial do Fast Splash', async ({
        page,
    }) => {

        const resposta = await page.goto('/');

        expect(resposta).not.toBeNull();

        expect(resposta!.status()).toBe(200);

        await expect(
            page.locator('body')
        ).toBeVisible();

    });

    test('deve carregar um documento HTML valido', async ({
        page,
    }) => {

        const resposta = await page.goto('/');

        expect(resposta).not.toBeNull();

        expect(
            resposta!.headers()['content-type']
        ).toContain('text/html');

        await expect(
            page.locator('html')
        ).toHaveCount(1);

        await expect(
            page.locator('body')
        ).toHaveCount(1);

        const titulo = await page.title();

        expect(titulo.trim().length)
            .toBeGreaterThan(0);

    });

    test('deve permanecer no servidor local autorizado', async ({
        page,
    }) => {

        await page.goto('/');

        const urlAtual = new URL(page.url());

        expect(urlAtual.origin)
            .toBe(URL_AUTORIZADA);

    });

    test('deve bloquear consulta sem autenticacao pelo navegador', async ({
        page,
    }) => {

        const resposta = await page.goto(
            '/api/clientes/me'
        );

        expect(resposta).not.toBeNull();

        expect(resposta!.status())
            .toBe(401);

        const dados = await resposta!.json();

        expect(dados.sucesso)
            .toBe(false);

        expect(typeof dados.mensagem)
            .toBe('string');

    });

    test('deve autenticar cliente no servidor isolado', async ({
        context,
    }) => {

        const resposta = await context.request.post(
            '/api/auth/login',
            {
                form: {
                    email: EMAIL_CLIENTE,
                    senha: SENHA_CLIENTE,
                },

                maxRedirects: 0,
            }
        );

        expect(resposta.status())
            .toBe(200);

        const dados = await resposta.json();

        expect(dados.sucesso)
            .toBe(true);

        expect(dados.cliente.idCliente)
            .toBe(101);

        expect(dados.cliente.email)
            .toBe(EMAIL_CLIENTE);

        const cookies = await context.cookies(
            URL_AUTORIZADA
        );

        const sessao = cookies.find(
            cookie => cookie.name === 'JSESSIONID'
        );

        expect(sessao).toBeDefined();

        expect(sessao!.value.length)
            .toBeGreaterThan(0);

        expect(sessao!.httpOnly)
            .toBe(true);

    });

    test('deve compartilhar sessao entre requisicao e navegador', async ({
        page,
        context,
    }) => {

        const login = await context.request.post(
            '/api/auth/login',
            {
                form: {
                    email: EMAIL_CLIENTE,
                    senha: SENHA_CLIENTE,
                },

                maxRedirects: 0,
            }
        );

        expect(login.status())
            .toBe(200);

        const resposta = await page.goto(
            '/api/clientes/me'
        );

        expect(resposta).not.toBeNull();

        expect(resposta!.status())
            .toBe(200);

        const dados = await resposta!.json();

        expect(dados.sucesso)
            .toBe(true);

        expect(dados.cliente.idCliente)
            .toBe(101);

        expect(dados.cliente.email)
            .toBe(EMAIL_CLIENTE);

    });

    test('deve consultar servicos ativos pelo navegador', async ({
        page,
        context,
    }) => {

        const login = await context.request.post(
            '/api/auth/login',
            {
                form: {
                    email: EMAIL_CLIENTE,
                    senha: SENHA_CLIENTE,
                },

                maxRedirects: 0,
            }
        );

        expect(login.status())
            .toBe(200);

        const resposta = await page.goto(
            '/api/servicos'
        );

        expect(resposta).not.toBeNull();

        expect(resposta!.status())
            .toBe(200);

        const dados = await resposta!.json();

        expect(dados.sucesso)
            .toBe(true);

        expect(dados.servicos)
            .toHaveLength(2);

        const ids = dados.servicos.map(
            (servico: { idServico: number }) =>
                servico.idServico
        );

        expect(ids.sort((a: number, b: number) => a - b))
            .toEqual([301, 302]);

    });

    test('deve refletir alteracoes do MySQL nas respostas HTTP', async ({
        page,
        context,
    }) => {

        const login = await context.request.post(
            '/api/auth/login',
            {
                form: {
                    email: EMAIL_CLIENTE,
                    senha: SENHA_CLIENTE,
                },

                maxRedirects: 0,
            }
        );

        expect(login.status())
            .toBe(200);

        executarSqlTeste(`
            UPDATE servico
            SET preco = 123.45
            WHERE id_servico = 301;
        `);

        const resposta = await page.goto(
            '/api/servicos'
        );

        expect(resposta).not.toBeNull();

        expect(resposta!.status())
            .toBe(200);

        const dados = await resposta!.json();

        const servico = dados.servicos.find(
            (item: { idServico: number }) =>
                item.idServico === 301
        );

        expect(servico)
            .toBeDefined();

        expect(Number(servico.preco))
            .toBe(123.45);

    });

});
