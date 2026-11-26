import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

const CLIENTE = {

    nome: 'Cliente Novo Teste',
    cpf: '98765410564',
    telefone: '11900000105',
    email: 'novo-cliente@example.test',
    senha: 'SenhaFicticia@123',
    confirmarSenha: 'SenhaFicticia@123',

};

async function abrirCadastro(
    page: Page,
    perfil: 'administrador' | 'atendente' = 'administrador'
): Promise<void> {

    if (perfil === 'administrador') {

        await autenticarAdministrador(page);

    } else {

        await autenticarAtendente(page);

    }

    await page.goto('/cliente');

    await page.getByRole('link', {
        name: '+ Novo cliente',
        exact: true,
    }).click();

    await expect(page).toHaveURL(
        /\/cadastro-cliente\.jsp$/
    );

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

async function enviarCadastro(
    page: Page
): Promise<void> {

    await page.getByRole('button', {
        name: 'Cadastrar cliente',
        exact: true,
    }).click();

}

function quantidadeClientes(): number {

    return Number(
        executarSqlTeste(
            'SELECT COUNT(*) FROM cliente;'
        )
    );

}

async function abrirEdicao(
    page: Page,
    perfil: 'administrador' | 'atendente' = 'administrador',
    id: number = 102
): Promise<void> {

    if (perfil === 'administrador') {

        await autenticarAdministrador(page);

    } else {

        await autenticarAtendente(page);

    }

    await page.goto('/cliente');

    await page.locator(
        '.tabela-interna tbody tr'
    ).filter({

        has: page.getByText(
            `ID #${id}`,
            { exact: true }
        ),

    }).getByRole('link', {
        name: 'Editar',
        exact: true,
    }).click();

    await expect(page).toHaveTitle(
        'Editar cliente | Fast Splash'
    );

}

async function salvarEdicao(
    page: Page
): Promise<void> {

    await page.getByRole('button', {
        name: 'Salvar alterações',
        exact: true,
    }).click();

    await expect(page)
        .toHaveURL(/\/cliente$/);

}

test.describe('Cadastro administrativo e edicao de clientes', () => {

    // =========================================
    // FORMULARIO DE CADASTRO - 3 TESTES
    // =========================================

    test('deve apresentar formulario completo de cadastro', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await expect(page).toHaveTitle(
            'Novo cliente | Fast Splash'
        );

        await expect(
            page.getByRole('heading', {
                level: 1,
            })
        ).toHaveText('Cadastrar cliente');

        const formulario =
            page.locator('.form-interno');

        await expect(formulario)
            .toHaveAttribute('action', '/cliente');

        await expect(formulario)
            .toHaveAttribute('method', 'post');

        for (const campo of Object.keys(CLIENTE)) {

            await expect(
                page.locator(`#${campo}`)
            ).toBeVisible();

        }

        await expect(
            page.locator('#senha')
        ).toHaveAttribute('type', 'password');

        await expect(
            page.locator('#confirmarSenha')
        ).toHaveAttribute('type', 'password');

    });

    test('deve exigir todos os campos do cadastro', async ({
        page,
    }) => {

        await abrirCadastro(page);

        for (const campo of Object.keys(CLIENTE)) {

            await expect(
                page.locator(`#${campo}`)
            ).toHaveAttribute('required', '');

        }

    });

    test('deve cancelar cadastro sem inserir cliente', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await page.getByRole('link', {
            name: 'Cancelar',
            exact: true,
        }).click();

        await expect(page)
            .toHaveURL(/\/cliente$/);

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // MASCARAS E PADRONIZACAO - 5 TESTES
    // =========================================

    test('deve converter nome para maiusculas', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#nome')
            .fill('Cliente Novo Teste');

        await expect(
            page.locator('#nome')
        ).toHaveValue(
            'CLIENTE NOVO TESTE'
        );

    });

    test('deve aplicar mascara de CPF', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#cpf')
            .fill(CLIENTE.cpf);

        await expect(
            page.locator('#cpf')
        ).toHaveValue(
            '987.654.105-64'
        );

    });

    test('deve remover letras e limitar CPF a onze digitos', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#cpf')
            .fill('abc987654105649999');

        const cpf = await page.locator(
            '#cpf'
        ).inputValue();

        expect(cpf).toMatch(
            /^\d{3}\.\d{3}\.\d{3}-\d{2}$/
        );

        expect(
            cpf.replace(/\D/g, '')
        ).toBe(CLIENTE.cpf);

    });

    test('deve aplicar mascara de telefone celular', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#telefone')
            .fill(CLIENTE.telefone);

        await expect(
            page.locator('#telefone')
        ).toHaveValue(
            '(11) 90000-0105'
        );

    });

    test('deve aplicar mascara de telefone fixo', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await page.locator('#telefone')
            .fill('1133334444');

        await expect(
            page.locator('#telefone')
        ).toHaveValue(
            '(11) 3333-4444'
        );

    });

    // =========================================
    // CADASTRO VALIDO - 4 TESTES
    // =========================================

    test('deve cadastrar cliente pelo administrador', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await expect(page)
            .toHaveURL(/\/cliente$/);

        const linha = page.locator(
            '.tabela-interna tbody tr'
        ).filter({
            hasText: CLIENTE.email,
        });

        await expect(linha)
            .toHaveCount(1);

        await expect(linha)
            .toContainText(
                'CLIENTE NOVO TESTE'
            );

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve permitir cadastro realizado pelo atendente', async ({
        page,
    }) => {

        await abrirCadastro(
            page, 'atendente'
        );

        await preencherCadastro(page);

        await enviarCadastro(page);

        await expect(page)
            .toHaveURL(/\/cliente$/);

        await expect(
            page.locator(
                '.tabela-interna tbody tr'
            ).filter({
                hasText: CLIENTE.email,
            })
        ).toBeVisible();

        expect(quantidadeClientes())
            .toBe(5);

    });

    test('deve persistir dados normalizados e senha protegida', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await expect(page)
            .toHaveURL(/\/cliente$/);

        const dados = executarSqlTeste(`
            SELECT nome, cpf, telefone, email,
                   ativo, excluido_em IS NULL,
                   senha_hash LIKE 'pbkdf2$%',
                   senha_hash <> 'SenhaFicticia@123'
            FROM cliente
            WHERE email = 'novo-cliente@example.test';
        `).split('\t');

        expect(dados).toEqual([

            'CLIENTE NOVO TESTE',
            CLIENTE.cpf,
            CLIENTE.telefone,
            CLIENTE.email,
            '1',
            '1',
            '1',
            '1',

        ]);

    });

    test('deve permitir login mobile do cliente cadastrado pelo Web', async ({
        page,
        playwright,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page);

        await enviarCadastro(page);

        await expect(page)
            .toHaveURL(/\/cliente$/);

        const api = await playwright.request.newContext({

            baseURL: 'http://127.0.0.1:8081',

        });

        try {

            const resposta = await api.post(
                '/api/auth/login',
                {
                    form: {

                        email: CLIENTE.email,
                        senha: CLIENTE.senha,

                    },

                    maxRedirects: 0,
                }
            );

            expect(resposta.status())
                .toBe(200);

            const dados =
                await resposta.json();

            expect(dados.sucesso)
                .toBe(true);

            expect(dados.cliente.email)
                .toBe(CLIENTE.email);

            expect(dados.cliente.nome)
                .toBe('CLIENTE NOVO TESTE');

            expect(dados.cliente.cpf)
                .toBe(CLIENTE.cpf);

        } finally {

            await api.dispose();

        }

    });

    // =========================================
    // VALIDACOES DO CADASTRO - 4 TESTES
    // =========================================

    test('deve impedir cadastro com nome vazio', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {
            nome: '',
        });

        await enviarCadastro(page);

        expect(

            await page.locator('#nome')
                .evaluate(
                    (campo: HTMLInputElement) =>
                        campo.validity.valueMissing
                )

        ).toBe(true);

        await expect(page).toHaveURL(
            /\/cadastro-cliente\.jsp$/
        );

        expect(quantidadeClientes())
            .toBe(4);

    });

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

    test('deve impedir cadastro com senhas diferentes no navegador', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {

            confirmarSenha: 'OutraSenha@123',

        });

        let mensagem = '';

        page.once('dialog', async dialog => {

            mensagem = dialog.message();

            await dialog.accept();

        });

        await enviarCadastro(page);

        expect(mensagem)
            .toBe('As senhas não coincidem.');

        await expect(
            page.locator('#confirmarSenha')
        ).toBeFocused();

        await expect(page).toHaveURL(
            /\/cadastro-cliente\.jsp$/
        );

        expect(quantidadeClientes())
            .toBe(4);

    });

    test('deve rejeitar senhas diferentes diretamente no backend', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await page.request.post(
            '/cliente',
            {
                form: {

                    ...CLIENTE,

                    confirmarSenha: 'OutraSenha@123',

                },

                maxRedirects: 0,
            }
        );

        expect(resposta.status())
            .toBe(400);

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // CAMPOS OBRIGATORIOS NO BACKEND - 1 TESTE
    // =========================================

    test('deve rejeitar cadastro sem campos obrigatorios no backend', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        for (const campo of Object.keys(CLIENTE)) {

            const dados = {

                ...CLIENTE,

                [campo]: '',

            };

            const resposta =
                await page.request.post(
                    '/cliente',
                    {
                        form: dados,
                        maxRedirects: 0,
                    }
                );

            expect(
                resposta.status(),
                `Campo obrigatorio: ${campo}`
            ).toBe(400);

        }

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // INTEGRIDADE DE DADOS - 2 TESTES
    // =========================================

    test('nao deve inserir cliente com CPF duplicado', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {

            cpf: '98765410130',

        });

        await enviarCadastro(page);

        await expect(page).toHaveURL(
            /\/cliente$/
        );

        expect(quantidadeClientes())
            .toBe(4);

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM cliente
                WHERE cpf = '98765410130';
            `)
        ).toBe('1');

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM cliente
                WHERE email = 'novo-cliente@example.test';
            `)
        ).toBe('0');

    });

    test('nao deve inserir cliente com email duplicado', async ({
        page,
    }) => {

        await abrirCadastro(page);

        await preencherCadastro(page, {

            email: 'ativo@example.test',

        });

        await enviarCadastro(page);

        await expect(page)
            .toHaveURL(/\/cliente$/);

        expect(quantidadeClientes())
            .toBe(4);

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM cliente
                WHERE email = 'ativo@example.test';
            `)
        ).toBe('1');

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM cliente
                WHERE cpf = '98765410564';
            `)
        ).toBe('0');

    });

    // =========================================
    // FORMULARIO DE EDICAO - 3 TESTES
    // =========================================

    test('deve apresentar dados atuais no formulario de edicao', async ({
        page,
    }) => {

        await abrirEdicao(page);

        await expect(
            page.locator('#nome')
        ).toHaveValue(
            'Cliente Teste Livre'
        );

        await expect(
            page.locator('#cpf')
        ).toHaveValue('98765410211');

        await expect(
            page.locator('#telefone')
        ).toHaveValue('11900000102');

        await expect(
            page.locator('#email')
        ).toHaveValue(
            'livre@example.test'
        );

        await expect(
            page.locator(
                'input[name="acao"]'
            )
        ).toHaveValue('atualizar');

        await expect(
            page.locator(
                'input[name="idCliente"]'
            )
        ).toHaveValue('102');

    });

    test('nao deve disponibilizar campo de senha na edicao', async ({
        page,
    }) => {

        await abrirEdicao(page);

        await expect(
            page.locator(
                'input[type="password"]'
            )
        ).toHaveCount(0);

        await expect(
            page.locator('.form-observacao')
        ).toContainText(
            'A senha não é modificada nesta tela.'
        );

    });

    test('deve cancelar edicao sem alterar dados', async ({
        page,
    }) => {

        await abrirEdicao(page);

        await page.locator('#nome')
            .fill('NOME NAO SALVO');

        await page.getByRole('link', {
            name: 'Cancelar',
            exact: true,
        }).click();

        await expect(page)
            .toHaveURL(/\/cliente$/);

        expect(
            executarSqlTeste(`
                SELECT nome
                FROM cliente
                WHERE id_cliente = 102;
            `)
        ).toBe(
            'Cliente Teste Livre'
        );

    });

    // =========================================
    // ATUALIZACAO DE CLIENTES - 4 TESTES
    // =========================================

    test('deve atualizar dados do cliente pelo administrador', async ({
        page,
    }) => {

        await abrirEdicao(page);

        await page.locator('#nome')
            .fill('Cliente Livre Atualizado');

        await page.locator('#cpf')
            .fill('987.654.105-64');

        await page.locator('#telefone')
            .fill('(11) 90000-0105');

        await page.locator('#email')
            .fill('atualizado@example.test');

        await salvarEdicao(page);

        const dados = executarSqlTeste(`
            SELECT nome, cpf, telefone, email
            FROM cliente
            WHERE id_cliente = 102;
        `).split('\t');

        expect(dados).toEqual([

            'CLIENTE LIVRE ATUALIZADO',
            '98765410564',
            '11900000105',
            'atualizado@example.test',

        ]);

        await expect(
            page.locator(
                '.tabela-interna tbody tr'
            ).filter({
                hasText: 'atualizado@example.test',
            })
        ).toContainText(
            'CLIENTE LIVRE ATUALIZADO'
        );

    });

    test('deve permitir atualizacao realizada pelo atendente', async ({
        page,
    }) => {

        await abrirEdicao(
            page, 'atendente'
        );

        await page.locator('#nome')
            .fill('Cliente Editado Atendente');

        await salvarEdicao(page);

        expect(
            executarSqlTeste(`
                SELECT nome
                FROM cliente
                WHERE id_cliente = 102;
            `)
        ).toBe(
            'CLIENTE EDITADO ATENDENTE'
        );

    });

    test('deve preservar senha durante atualizacao cadastral', async ({
        page,
    }) => {

        const hashAnterior =
            executarSqlTeste(`
                SELECT senha_hash
                FROM cliente
                WHERE id_cliente = 102;
            `);

        await abrirEdicao(page);

        await page.locator('#nome')
            .fill('Cliente Editado Teste');

        await salvarEdicao(page);

        const hashAtual =
            executarSqlTeste(`
                SELECT senha_hash
                FROM cliente
                WHERE id_cliente = 102;
            `);

        expect(hashAtual)
            .toBe(hashAnterior);

    });

    test('deve preservar relacionamentos ao atualizar cliente', async ({
        page,
    }) => {

        await abrirEdicao(
            page, 'administrador', 101
        );

        await page.locator('#nome')
            .fill('Cliente Ativo Atualizado');

        await salvarEdicao(page);

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM veiculo
                WHERE id_cliente = 101;
            `)
        ).toBe('2');

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM agendamento a
                JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo
                WHERE v.id_cliente = 101;
            `)
        ).toBe('5');

        expect(quantidadeClientes())
            .toBe(4);

    });

    // =========================================
    // PROTECAO DA EDICAO - 2 TESTES
    // =========================================

    test('deve impedir edicao de cliente inexistente', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await page.goto(
            '/cliente?acao=editar&idCliente=999999'
        );

        expect(resposta)
            .not.toBeNull();

        expect(resposta!.status())
            .toBe(404);

    });

    test('deve impedir edicao e atualizacao de cliente excluido', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await page.goto(
            '/cliente?acao=editar&idCliente=104'
        );

        expect(resposta!.status())
            .toBe(404);

        const atualizacao =
            await page.request.post(
                '/cliente',
                {
                    form: {

                        acao: 'atualizar',
                        idCliente: '104',
                        nome: 'ALTERACAO INDEVIDA',
                        cpf: '98765410483',
                        telefone: '11900000104',
                        email: 'excluido@example.test',

                    },

                    maxRedirects: 0,
                }
            );

        expect(atualizacao.status())
            .toBe(409);

        expect(
            executarSqlTeste(`
                SELECT nome
                FROM cliente
                WHERE id_cliente = 104;
            `)
        ).toBe(
            'Cliente Teste Excluido'
        );

    });

});
