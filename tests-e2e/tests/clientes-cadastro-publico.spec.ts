import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

const CLIENTE = {
    nome: 'Cliente Publico Teste',
    cpf: '98765410564',
    telefone: '11900000105',
    email: 'publico@example.test',
    senha: 'SenhaFicticia@123',
    confirmarSenha: 'SenhaFicticia@123',
};

const MENSAGEM_SUCESSO =
    'Cadastro realizado com sucesso. Agora você já pode usar sua conta no aplicativo Fast Splash.';

async function abrirCadastro(page: Page): Promise<void> {

    await page.goto('/cadastro.jsp');

    await expect(
        page.locator('#formCadastro')
    ).toBeVisible();

}

async function preencherCadastro(
    page: Page,
    dados: Partial<typeof CLIENTE> = {}
): Promise<void> {

    const cliente = {
        ...CLIENTE,
        ...dados,
    };

    for (const [campo, valor] of Object.entries(cliente)) {

        await page.locator(`#${campo}`)
            .fill(valor);

    }

}

async function enviarCadastro(page: Page): Promise<void> {

    await page.locator('#botaoCadastrar')
        .click();

}

async function validarSucesso(page: Page): Promise<void> {

    await expect(
        page.locator('#mensagemFormulario')
    ).toHaveText(MENSAGEM_SUCESSO);

    await expect(
        page.locator('#mensagemFormulario')
    ).toHaveClass(/\bsucesso\b/);

}

async function validarErro(
    page: Page,
    mensagem: string
): Promise<void> {

    const aviso =
        page.locator('#mensagemFormulario');

    await expect(aviso)
        .toBeVisible();

    await expect(aviso)
        .toHaveText(mensagem);

    await expect(aviso)
        .toHaveClass(/\berro\b/);

    await expect(
        page.locator('#botaoCadastrar')
    ).toBeEnabled();

    await expect(
        page.locator('#botaoCadastrar')
    ).toHaveText('Criar minha conta');

}

function quantidadeClientes(): number {

    return Number(
        executarSqlTeste(
            'SELECT COUNT(*) FROM cliente;'
        )
    );

}

test.describe('Cadastro publico de clientes', () => {

    // =========================================
    // ESTRUTURA E NAVEGACAO - 3 TESTES
    // =========================================

    test('deve apresentar formulario publico sem autenticacao', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await expect(page)
            .toHaveTitle('Cadastre-se | Fast Splash');

        await expect(
            page.locator('#formCadastro')
        ).toHaveAttribute(
            'action', '/api/clientes'
        );

        await expect(
            page.locator('#formCadastro')
        ).toHaveAttribute('method', 'post');

        for (const campo of Object.keys(CLIENTE)) {

            await expect(
                page.locator(`#${campo}`)
            ).toBeVisible();

        }

        await expect(
            page.locator('#mensagemFormulario')
        ).toHaveAttribute('aria-live', 'polite');

        await expect(
            page.locator('#fsMenu')
        ).toHaveCount(0);

    });

    test('deve acessar cadastro a partir da pagina inicial', async ({
        page,
    }) => {

        await page.goto('/');

        await page.locator('.menu-cadastro')
            .click();

        await expect(page)
            .toHaveURL(/\/cadastro\.jsp$/);

        await expect(
            page.locator('#formCadastro')
        ).toBeVisible();

    });

    test('deve retornar ao site sem criar conta', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await page.locator('.voltar-site')
            .click();

        await expect(page)
            .toHaveURL('http://127.0.0.1:8081/');

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // MASCARAS - 4 TESTES
    // =========================================

    test('deve formatar CPF automaticamente', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#cpf')
            .fill(CLIENTE.cpf);

        await expect(
            page.locator('#cpf')
        ).toHaveValue('987.654.105-64');

    });

    test('deve remover caracteres invalidos e limitar CPF', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#cpf')
            .evaluate((elemento) => {

                const campo =
                    elemento as HTMLInputElement;

                campo.value = 'abc987654105649999';

                campo.dispatchEvent(
                    new Event('input', {
                        bubbles: true,
                    })
                );

            });

        await expect(
            page.locator('#cpf')
        ).toHaveValue('987.654.105-64');

    });

    test('deve formatar telefone celular', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#telefone')
            .fill(CLIENTE.telefone);

        await expect(
            page.locator('#telefone')
        ).toHaveValue('(11) 90000-0105');

    });

    test('deve formatar telefone fixo', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#telefone')
            .fill('1133334444');

        await expect(
            page.locator('#telefone')
        ).toHaveValue('(11) 3333-4444');

    });

    // =========================================
    // CAMPOS OBRIGATORIOS - 6 TESTES
    // =========================================

    for (const campo of Object.keys(CLIENTE)) {

        test(`deve exigir campo ${campo}`, async ({
            page,
        }) => {

            await abrirCadastro(page);

            await preencherCadastro(page, {
                [campo]: '',
            });

            await enviarCadastro(page);

            expect(

                await page.locator(`#${campo}`)
                    .evaluate(
                        (elemento: HTMLInputElement) =>
                            elemento.validity.valueMissing
                    )

            ).toBe(true);

            await expect(page)
                .toHaveURL(/\/cadastro\.jsp$/);

            expect(quantidadeClientes())
                .toBe(4);

        });

    }

    // =========================================
    // VALIDACOES NO NAVEGADOR - 2 TESTES
    // =========================================

    test('deve impedir cadastro com email invalido', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {
            email: 'email-invalido',
        });

        await enviarCadastro(page);

        expect(

            await page.locator('#email')
                .evaluate(
                    (campo: HTMLInputElement) =>
                        campo.validity.typeMismatch
                )

        ).toBe(true);

        expect(quantidadeClientes())
            .toBe(4);

    });

    test('deve impedir cadastro quando senhas forem diferentes', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {
            confirmarSenha: 'OutraSenha@123',
        });

        let envios = 0;

        page.on('request', requisicao => {

            if (
                new URL(requisicao.url()).pathname
                    === '/api/clientes'
                && requisicao.method() === 'POST'
            ) {

                envios++;

            }

        });

        await enviarCadastro(page);

        await validarErro(
            page,
            'As senhas não coincidem.'
        );

        await expect(
            page.locator('#confirmarSenha')
        ).toBeFocused();

        expect(envios).toBe(0);

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // VALIDACOES DA API - 4 TESTES
    // =========================================

    const rejeicoes = [

        {
            nome: 'CPF duplicado',
            dados: {
                cpf: '98765410130',
            },
            status: 409,
            mensagem:
                'Já existe um cliente com este CPF ou e-mail.',
        },

        {
            nome: 'email duplicado',
            dados: {
                email: 'ativo@example.test',
            },
            status: 409,
            mensagem:
                'Já existe um cliente com este CPF ou e-mail.',
        },

        {
            nome: 'CPF incompleto',
            dados: {
                cpf: '123456789',
            },
            status: 400,
            mensagem:
                'O CPF deve possuir 11 dígitos.',
        },

        {
            nome: 'email de cliente excluido',
            dados: {
                email: 'excluido@example.test',
            },
            status: 409,
            mensagem:
                'Já existe um cliente com este CPF ou e-mail.',
        },

    ];

    for (const item of rejeicoes) {

        test(`deve rejeitar ${item.nome}`, async ({
            page,
        }) => {

            await abrirCadastro(page);

            await preencherCadastro(
                page, item.dados
            );

            const resposta =
                page.waitForResponse(resp =>
                    new URL(resp.url()).pathname
                        === '/api/clientes'
                    && resp.request().method()
                        === 'POST'
                );

            await enviarCadastro(page);

            expect(
                (await resposta).status()
            ).toBe(item.status);

            await validarErro(
                page, item.mensagem
            );

            expect(quantidadeClientes())
                .toBe(4);

        });

    }

    // =========================================
    // CADASTRO COM SUCESSO - 5 TESTES
    // =========================================

    test('deve criar conta pela interface publica', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        const resposta = page.waitForResponse(resp =>
            new URL(resp.url()).pathname
                === '/api/clientes'
            && resp.request().method()
                === 'POST'
        );

        await enviarCadastro(page);

        const resultado = await resposta;

        expect(resultado.status())
            .toBe(201);

        const dados = await resultado.json();

        expect(dados.sucesso)
            .toBe(true);

        expect(dados.email)
            .toBe(CLIENTE.email);

        expect(dados.idCliente)
            .toBeGreaterThan(0);

        await validarSucesso(page);

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve persistir dados normalizados e senha protegida', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await validarSucesso(page);

        const dados = executarSqlTeste(`
            SELECT nome, cpf, telefone, email,
                   ativo, excluido_em IS NULL,
                   senha_hash LIKE 'pbkdf2$%',
                   senha_hash <> 'SenhaFicticia@123'
            FROM cliente
            WHERE email = 'publico@example.test';
        `).split('\t');

        expect(dados).toEqual([

            'CLIENTE PUBLICO TESTE',
            CLIENTE.cpf,
            CLIENTE.telefone,
            CLIENTE.email,
            '1',
            '1',
            '1',
            '1',

        ]);

    });

    test('deve bloquear e limpar campos apos criar conta', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await validarSucesso(page);

        for (const campo of Object.keys(CLIENTE)) {

            const input =
                page.locator(`#${campo}`);

            await expect(input)
                .toBeDisabled();

            await expect(input)
                .toHaveValue('');

        }

        await expect(
            page.locator('#botaoCadastrar')
        ).toHaveAttribute('type', 'button');

        await expect(
            page.locator('#botaoCadastrar')
        ).toHaveText('Voltar para o site');

        await expect(
            page.locator('#botaoCadastrar')
        ).toBeEnabled();

    });

    test('deve autenticar conta criada pelo cadastro publico na API mobile', async ({
        page,
        playwright,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await validarSucesso(page);

        const api = await playwright.request.newContext({

            baseURL: 'http://127.0.0.1:8081',

        });

        try {

            const login = await api.post(
                '/api/auth/login',
                {
                    form: {
                        email: CLIENTE.email,
                        senha: CLIENTE.senha,
                    },
                    maxRedirects: 0,
                }
            );

            expect(login.status()).toBe(200);

            const dados = await login.json();

            expect(dados.sucesso)
                .toBe(true);

            expect(dados.cliente.email)
                .toBe(CLIENTE.email);

            expect(dados.cliente.nome)
                .toBe('CLIENTE PUBLICO TESTE');

            const cadastro = await api.get(
                '/api/clientes/me',
                { maxRedirects: 0 }
            );

            expect(cadastro.status())
                .toBe(200);

            const perfil = await cadastro.json();

            expect(perfil.cliente.idCliente)
                .toBe(dados.cliente.idCliente);

            expect(perfil.cliente.cpf)
                .toBe(CLIENTE.cpf);

        } finally {

            await api.dispose();

        }

    });

    test('deve apresentar cliente cadastrado publicamente no painel administrativo', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await validarSucesso(page);

        await autenticarAdministrador(page);

        await page.goto('/cliente');

        const linha = page.locator(
            '.tabela-interna tbody tr'
        ).filter({
            hasText: CLIENTE.email,
        });

        await expect(linha)
            .toHaveCount(1);

        await expect(linha)
            .toContainText(
                'CLIENTE PUBLICO TESTE'
            );

        await expect(linha)
            .toContainText(CLIENTE.cpf);

    });

    // =========================================
    // COMUNICACAO E RECUPERACAO - 6 TESTES
    // =========================================

    test('deve apresentar mensagem durante envio e bloquear botao', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        let liberar!: () => void;

        const espera = new Promise<void>(
            resolver => {
                liberar = resolver;
            }
        );

        let envios = 0;

        await page.route(
            '**/api/clientes',
            async route => {

                envios++;

                await espera;

                await route.continue();

            }
        );

        try {

            await enviarCadastro(page);

            await expect(
                page.locator('#botaoCadastrar')
            ).toBeDisabled();

            await expect(
                page.locator('#botaoCadastrar')
            ).toHaveText('Criando conta...');

            await expect.poll(
                () => envios
            ).toBe(1);

        } finally {

            liberar();

        }

        await validarSucesso(page);

        expect(envios).toBe(1);

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve informar falha de comunicacao com servidor', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await page.route(
            '**/api/clientes',
            route => route.abort('failed')
        );

        await enviarCadastro(page);

        await validarErro(
            page,
            'Não foi possível comunicar com o servidor. Tente novamente.'
        );

        expect(quantidadeClientes())
            .toBe(4);

    });

    test('deve tratar resposta de erro sem JSON', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await page.route(
            '**/api/clientes',
            route => route.fulfill({

                status: 503,
                contentType: 'text/plain',
                body: 'Servidor indisponivel',

            })
        );

        await enviarCadastro(page);

        await validarErro(
            page,
            'Não foi possível realizar o cadastro.'
        );

        expect(quantidadeClientes())
            .toBe(4);

    });

    test('deve permitir nova tentativa apos falha de comunicacao', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await page.route(
            '**/api/clientes',
            route => route.abort('failed')
        );

        await enviarCadastro(page);

        await validarErro(
            page,
            'Não foi possível comunicar com o servidor. Tente novamente.'
        );

        await expect(
            page.locator('#email')
        ).toHaveValue(CLIENTE.email);

        await page.unroute(
            '**/api/clientes'
        );

        await enviarCadastro(page);

        await validarSucesso(page);

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve permitir corrigir duplicidade e concluir cadastro', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {
            email: 'ativo@example.test',
        });

        await enviarCadastro(page);

        await validarErro(
            page,
            'Já existe um cliente com este CPF ou e-mail.'
        );

        await page.locator('#email')
            .fill(CLIENTE.email);

        await enviarCadastro(page);

        await validarSucesso(page);

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve retornar ao site apos sucesso sem duplicar cadastro', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        let envios = 0;

        page.on('request', requisicao => {

            if (
                new URL(requisicao.url()).pathname
                    === '/api/clientes'
                && requisicao.method() === 'POST'
            ) {

                envios++;

            }

        });

        await enviarCadastro(page);

        await validarSucesso(page);

        await page.locator('#botaoCadastrar')
            .click();

        await expect(page)
            .toHaveURL('http://127.0.0.1:8081/');

        expect(envios).toBe(1);

        expect(quantidadeClientes())
            .toBe(5);

    });

});
