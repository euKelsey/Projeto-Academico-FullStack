import { test, expect } from '../support/fixtures';

import {
    CONTAS_TESTE,
    preencherLogin,
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

const URL_AUTORIZADA =
    'http://127.0.0.1:8081';

const ADMIN =
    CONTAS_TESTE.administrador;

const ATENDENTE =
    CONTAS_TESTE.atendente;

test.describe('Autenticacao e permissoes Web', () => {

    // =========================================
    // INTERFACE DE LOGIN - 5 TESTES
    // =========================================

    test('deve apresentar os campos e formulario de login', async ({
        page,
    }) => {

        await page.goto('/login');

        const formulario = page.locator(
            '.form-login'
        );

        await expect(formulario)
            .toBeVisible();

        await expect(formulario)
            .toHaveAttribute('method', 'post');

        await expect(formulario)
            .toHaveAttribute('action', '/login');

        const email = page.getByLabel(
            'E-mail',
            { exact: true }
        );

        const senha = page.getByLabel(
            'Senha',
            { exact: true }
        );

        await expect(email)
            .toHaveAttribute('type', 'email');

        await expect(email)
            .toHaveAttribute('name', 'email');

        await expect(email)
            .toHaveAttribute(
                'autocomplete',
                'username'
            );

        await expect(senha)
            .toHaveAttribute('type', 'password');

        await expect(senha)
            .toHaveAttribute('name', 'senha');

        await expect(senha)
            .toHaveAttribute(
                'autocomplete',
                'current-password'
            );

        await expect(
            page.getByRole('button', {
                name: 'Entrar no sistema',
                exact: true,
            })
        ).toBeEnabled();

        await expect(
            page.getByRole('alert')
        ).toHaveCount(0);

    });

    test('deve retornar ao site pelo link do login', async ({
        page,
    }) => {

        await page.goto('/login');

        await page.locator(
            '.login-voltar'
        ).click();

        await expect(page).toHaveURL(
            `${URL_AUTORIZADA}/`
        );

        await expect(page)
            .toHaveTitle('Fast Splash');

    });

    test('deve exigir preenchimento do email', async ({
        page,
    }) => {

        await page.goto('/login');

        await page.locator('#senha')
            .fill(ADMIN.senha);

        await page.locator('.botao-login')
            .click();

        const valido = await page.locator(
            '#email'
        ).evaluate(
            (campo: HTMLInputElement) =>
                campo.validity.valueMissing
        );

        expect(valido).toBe(true);

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve exigir preenchimento da senha', async ({
        page,
    }) => {

        await page.goto('/login');

        await page.locator('#email')
            .fill(ADMIN.email);

        await page.locator('.botao-login')
            .click();

        expect(

            await page.locator('#senha')
                .evaluate(
                    (campo: HTMLInputElement) =>
                        campo.validity.valueMissing
                )

        ).toBe(true);

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve validar formato do email no navegador', async ({
        page,
    }) => {

        await page.goto('/login');

        await page.locator('#email')
            .fill('email-invalido');

        await page.locator('#senha')
            .fill(ADMIN.senha);

        await page.locator('.botao-login')
            .click();

        expect(

            await page.locator('#email')
                .evaluate(
                    (campo: HTMLInputElement) =>
                        campo.validity.typeMismatch
                )

        ).toBe(true);

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    // =========================================
    // AUTENTICACAO VALIDA - 2 TESTES
    // =========================================

    test('deve autenticar administrador pelo formulario', async ({
        page,
        context,
    }) => {

        await autenticarAdministrador(page);

        const cookies = await context.cookies(
            URL_AUTORIZADA
        );

        const sessao = cookies.find(
            cookie => cookie.name === 'JSESSIONID'
        );

        expect(sessao).toBeDefined();

        expect(sessao!.httpOnly).toBe(true);

        await expect(
            page.locator('#fsMenuNav .fs-menu-item')
        ).toHaveCount(8);

    });

    test('deve autenticar atendente pelo formulario', async ({
        page,
    }) => {

        await autenticarAtendente(page);

        await expect(
            page.locator('#fsMenuNav .fs-menu-item')
        ).toHaveCount(6);

        await expect(
            page.locator('#fsMenuNav')
                .getByRole('link', {
                    name: 'Serviços',
                    exact: true,
                })
        ).toHaveCount(0);

        await expect(
            page.locator('#fsMenuNav')
                .getByRole('link', {
                    name: 'Colaboradores',
                    exact: true,
                })
        ).toHaveCount(0);

    });

    // =========================================
    // AUTENTICACAO INVALIDA - 5 TESTES
    // =========================================

    test('deve rejeitar email inexistente', async ({
        page,
    }) => {

        await preencherLogin(
            page,
            'inexistente@example.test',
            ADMIN.senha
        );

        await expect(
            page.getByRole('alert')
        ).toHaveText(
            'E-mail ou senha inválidos.'
        );

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve rejeitar senha incorreta', async ({
        page,
    }) => {

        await preencherLogin(
            page,
            ADMIN.email,
            'SenhaIncorreta@123'
        );

        await expect(
            page.getByRole('alert')
        ).toHaveText(
            'E-mail ou senha inválidos.'
        );

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve rejeitar colaborador inativo', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE colaborador
            SET ativo = 0
            WHERE id_colaborador = 401;
        `);

        await preencherLogin(
            page,
            ADMIN.email,
            ADMIN.senha
        );

        await expect(
            page.getByRole('alert')
        ).toHaveText(
            'E-mail ou senha inválidos.'
        );

    });

    test('deve rejeitar colaborador excluido', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE colaborador
            SET ativo = 0,
                excluido_em = NOW()
            WHERE id_colaborador = 401;
        `);

        await preencherLogin(
            page,
            ADMIN.email,
            ADMIN.senha
        );

        await expect(
            page.getByRole('alert')
        ).toHaveText(
            'E-mail ou senha inválidos.'
        );

    });

    test('deve impedir login de colaborador operacional', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE colaborador
            SET nivel_acesso = 'OPERACIONAL'
            WHERE id_colaborador = 401;
        `);

        await preencherLogin(
            page,
            ADMIN.email,
            ADMIN.senha
        );

        await expect(
            page.getByRole('alert')
        ).toHaveText(
            'Este funcionário não possui acesso ao sistema.'
        );

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    // =========================================
    // VALIDACAO NO BACKEND - 2 TESTES
    // =========================================

    test('deve rejeitar requisicao de login sem email', async ({
        request,
    }) => {

        const resposta = await request.post(
            '/login',
            {
                form: {
                    senha: ADMIN.senha,
                },

                maxRedirects: 0,
            }
        );

        expect(resposta.status()).toBe(200);

        expect(await resposta.text())
            .toContain(
                'Informe o e-mail e a senha.'
            );

    });

    test('deve rejeitar requisicao de login sem senha', async ({
        request,
    }) => {

        const resposta = await request.post(
            '/login',
            {
                form: {
                    email: ADMIN.email,
                },

                maxRedirects: 0,
            }
        );

        expect(resposta.status()).toBe(200);

        expect(await resposta.text())
            .toContain(
                'Informe o e-mail e a senha.'
            );

    });

    // =========================================
    // ROTAS PROTEGIDAS SEM SESSAO - 8 TESTES
    // =========================================

    const rotasProtegidas = [

        '/dashboard',
        '/cliente',
        '/veiculo',
        '/servico',
        '/colaborador',
        '/agendamento',
        '/atendimento',
        '/pagamento',

    ];

    for (const rota of rotasProtegidas) {

        test(`deve proteger ${rota} sem autenticacao`, async ({
            page,
        }) => {

            await page.goto(rota);

            await expect(page)
                .toHaveURL(
                    `${URL_AUTORIZADA}/login`
                );

            await expect(
                page.locator('.form-login')
            ).toBeVisible();

            await expect(
                page.locator('#fsMenu')
            ).toHaveCount(0);

        });

    }

    // =========================================
    // RESTRICOES DO ATENDENTE - 2 TESTES
    // =========================================

    for (const rota of [

        '/servico',
        '/colaborador',

    ]) {

        test(`deve impedir atendente de acessar ${rota}`, async ({
            page,
        }) => {

            await autenticarAtendente(page);

            const resposta = await page.goto(
                rota
            );

            expect(resposta).not.toBeNull();

            expect(resposta!.status())
                .toBe(403);

            await page.goto('/dashboard');

            await expect(
                page.locator(
                    '.fs-menu-perfil strong'
                )
            ).toHaveText('Atendente');

        });

    }

    // =========================================
    // PERMISSOES DO ADMINISTRADOR - 2 TESTES
    // =========================================

    const rotasAdmin = [

        {
            rota: '/servico',
            nome: 'Serviços',
        },

        {
            rota: '/colaborador',
            nome: 'Colaboradores',
        },

    ];

    for (const item of rotasAdmin) {

        test(`deve permitir administrador acessar ${item.nome}`, async ({
            page,
        }) => {

            await autenticarAdministrador(
                page
            );

            const link = page.locator(
                '#fsMenuNav'
            ).getByRole('link', {
                name: item.nome,
                exact: true,
            });

            await expect(link).toBeVisible();

            await link.click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}${item.rota}`
            );

            await expect(
                page.locator('#fsMenu')
            ).toBeVisible();

        });

    }

    // =========================================
    // GERENCIAMENTO DA SESSAO - 3 TESTES
    // =========================================

    test('deve manter autenticacao apos recarregar pagina', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await page.reload();

        expect(resposta).not.toBeNull();

        expect(resposta!.status()).toBe(200);

        await expect(page)
            .toHaveURL(/\/dashboard$/);

        await expect(
            page.locator('.fs-menu-perfil strong')
        ).toHaveText('Administrador');

    });

    test('deve redirecionar colaborador autenticado do login para painel', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.goto('/login');

        await expect(page)
            .toHaveURL(/\/dashboard$/);

    });

    test('deve invalidar sessao ao sair do sistema', async ({
        page,
        context,
    }) => {

        await autenticarAdministrador(page);

        const cookies = await context.cookies(
            URL_AUTORIZADA
        );

        const sessao = cookies.find(
            cookie => cookie.name === 'JSESSIONID'
        );

        expect(sessao).toBeDefined();

        await page.getByRole('link', {
            name: 'Sair',
            exact: true,
        }).click();

        await expect(page)
            .toHaveURL(/\/login$/);

        const resposta = await context.request.get(
            '/dashboard',
            {
                headers: {
                    Cookie: `JSESSIONID=${sessao!.value}`,
                },

                maxRedirects: 0,
            }
        );

        expect(resposta.status()).toBe(302);

        expect(
            resposta.headers()['location']
        ).toMatch(/\/login$/);

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    // =========================================
    // REVOGACAO DE ACESSO - 3 TESTES
    // =========================================

    test('deve revogar sessao apos inativacao do colaborador', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        executarSqlTeste(`
            UPDATE colaborador
            SET ativo = 0
            WHERE id_colaborador = 401;
        `);

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve revogar sessao apos exclusao do colaborador', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        executarSqlTeste(`
            UPDATE colaborador
            SET ativo = 0,
                excluido_em = NOW()
            WHERE id_colaborador = 401;
        `);

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve atualizar permissoes quando administrador se torna atendente', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        executarSqlTeste(`
            UPDATE colaborador
            SET nivel_acesso = 'ATENDENTE'
            WHERE id_colaborador = 401;
        `);

        const resposta = await page.goto(
            '/servico'
        );

        expect(resposta).not.toBeNull();

        expect(resposta!.status())
            .toBe(403);

        await page.goto('/dashboard');

        await expect(
            page.locator('.fs-menu-perfil strong')
        ).toHaveText('Atendente');

        await expect(
            page.locator('#fsMenuNav .fs-menu-item')
        ).toHaveCount(6);

    });

    // =========================================
    // NAVEGACAO AUTENTICADA - 2 TESTES
    // =========================================

    for (const perfil of [

        'administrador',
        'atendente',

    ] as const) {

        test(`deve retornar do site ao painel como ${perfil}`, async ({
            page,
        }) => {

            if (perfil === 'administrador') {

                await autenticarAdministrador(
                    page
                );

            } else {

                await autenticarAtendente(
                    page
                );

            }

            await page.getByRole('link', {
                name: 'Ver site',
                exact: true,
            }).click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}/`
            );

            await expect(
                page.locator('header')
                    .getByRole('link', {
                        name: 'Painel administrativo',
                        exact: true,
                    })
            ).toBeVisible();

            await expect(
                page.locator('footer')
                    .getByRole('link', {
                        name: 'Painel administrativo',
                        exact: true,
                    })
            ).toBeVisible();

            await expect(
                page.locator('footer')
                    .getByRole('link', {
                        name: 'Entrar',
                        exact: true,
                    })
            ).toHaveCount(0);

            await page.locator('header')
                .getByRole('link', {
                    name: 'Painel administrativo',
                    exact: true,
                }).click();

            await expect(page)
                .toHaveURL(/\/dashboard$/);

        });

    }

    // =========================================
    // ISOLAMENTO DAS SESSOES - 2 TESTES
    // =========================================

    test('deve impedir cliente mobile de acessar painel Web', async ({
        page,
        context,
    }) => {

        const login = await context.request.post(
            '/api/auth/login',
            {
                form: {
                    email: 'ativo@example.test',
                    senha: 'SenhaFicticia@123',
                },

                maxRedirects: 0,
            }
        );

        expect(login.status()).toBe(200);

        await page.goto('/dashboard');

        await expect(page)
            .toHaveURL(/\/login$/);

    });

    test('deve impedir colaborador de acessar API privada do cliente sem autenticacao propria', async ({
        page,
        context,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await context.request.get(
            '/api/clientes/me',
            {
                maxRedirects: 0,
            }
        );

        expect(resposta.status()).toBe(401);

        const dados = await resposta.json();

        expect(dados.sucesso).toBe(false);

    });

    // =========================================
    // NAVEGACAO PERMITIDA AO ATENDENTE - 5 TESTES
    // =========================================

    const rotasAtendente = [

        {
            rota: '/cliente',
            nome: 'Clientes',
        },

        {
            rota: '/veiculo',
            nome: 'Veículos',
        },

        {
            rota: '/agendamento',
            nome: 'Agendamentos',
        },

        {
            rota: '/atendimento',
            nome: 'Atendimentos',
        },

        {
            rota: '/pagamento',
            nome: 'Pagamentos',
        },

    ];

    for (const item of rotasAtendente) {

        test(`deve permitir atendente acessar ${item.nome}`, async ({
            page,
        }) => {

            await autenticarAtendente(page);

            const link = page.locator(
                '#fsMenuNav'
            ).getByRole('link', {
                name: item.nome,
                exact: true,
            });

            await expect(link).toBeVisible();

            await link.click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}${item.rota}`
            );

            await expect(
                page.locator('#fsMenu')
            ).toBeVisible();

            await expect(
                page.locator(
                    '.fs-menu-perfil strong'
                )
            ).toHaveText('Atendente');

        });

    }

});
