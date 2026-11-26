import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

async function abrirClientes(
    page: Page,
    perfil: 'administrador' | 'atendente' = 'administrador'
): Promise<void> {

    if (perfil === 'administrador') {

        await autenticarAdministrador(page);

    } else {

        await autenticarAtendente(page);

    }

    await page.locator('#fsMenuNav')
        .getByRole('link', {
            name: 'Clientes',
            exact: true,
        }).click();

    await expect(page)
        .toHaveURL(/\/cliente$/);

}

function linhasClientes(page: Page) {

    return page.locator(
        '.tabela-interna tbody tr'
    );

}

function clientePorId(
    page: Page,
    id: number
) {

    return linhasClientes(page).filter({

        has: page.getByText(
            `ID #${id}`,
            { exact: true }
        ),

    });

}

async function selecionarFiltro(
    page: Page,
    nome: string,
    filtro: string
): Promise<void> {

    await page.locator('.filtros-clientes')
        .getByRole('link', {
            name: nome,
            exact: true,
        }).click();

    await expect(page).toHaveURL(
        new RegExp(
            `/cliente\\?filtro=${filtro}$`
        )
    );

    await expect(
        page.locator('.filtro-selecionado')
    ).toHaveText(nome);

}

test.describe('Listagem e pesquisa de clientes', () => {

    // =========================================
    // ESTRUTURA DA LISTAGEM - 3 TESTES
    // =========================================

    test('deve apresentar pagina de clientes', async ({
        page,
    }) => {

        await abrirClientes(page);

        await expect(page)
            .toHaveTitle(
                'Clientes | Fast Splash'
            );

        await expect(
            page.getByRole('heading', {
                level: 1,
            })
        ).toHaveText(
            'Clientes cadastrados'
        );

        await expect(
            page.locator('#pesquisaTabela')
        ).toBeVisible();

        await expect(
            page.locator('.tabela-interna')
        ).toBeVisible();

    });

    test('deve apresentar colunas corretas na tabela', async ({
        page,
    }) => {

        await abrirClientes(page);

        await expect(
            page.locator(
                '.tabela-interna thead th'
            )
        ).toHaveText([

            'Cliente',
            'CPF',
            'Telefone',
            'E-mail',
            'Ações',

        ]);

    });

    test('deve apresentar os dados cadastrais do cliente', async ({
        page,
    }) => {

        await abrirClientes(page);

        const cliente =
            clientePorId(page, 101);

        await expect(cliente)
            .toHaveCount(1);

        await expect(cliente)
            .toContainText(
                'Cliente Teste Ativo'
            );

        await expect(cliente)
            .toContainText(
                '98765410130'
            );

        await expect(cliente)
            .toContainText(
                '11900000101'
            );

        await expect(cliente)
            .toContainText(
                'ativo@example.test'
            );

        await expect(
            cliente.locator('.cliente-avatar')
        ).toHaveText('CA');

    });

    // =========================================
    // FILTROS E ORDENACAO - 5 TESTES
    // =========================================

    test('deve listar somente clientes ativos por padrao', async ({
        page,
    }) => {

        await abrirClientes(page);

        await expect(
            linhasClientes(page)
        ).toHaveCount(2);

        await expect(
            clientePorId(page, 101)
        ).toBeVisible();

        await expect(
            clientePorId(page, 102)
        ).toBeVisible();

        await expect(
            clientePorId(page, 103)
        ).toHaveCount(0);

        await expect(
            clientePorId(page, 104)
        ).toHaveCount(0);

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText('Ativos');

    });

    test('deve filtrar clientes inativos', async ({
        page,
    }) => {

        await abrirClientes(page);

        await selecionarFiltro(
            page,
            'Inativos',
            'inativos'
        );

        await expect(
            linhasClientes(page)
        ).toHaveCount(1);

        await expect(
            clientePorId(page, 103)
        ).toBeVisible();

        await expect(
            clientePorId(page, 104)
        ).toHaveCount(0);

    });

    test('deve filtrar clientes excluidos', async ({
        page,
    }) => {

        await abrirClientes(page);

        await selecionarFiltro(
            page,
            'Excluídos',
            'excluidos'
        );

        await expect(
            linhasClientes(page)
        ).toHaveCount(1);

        await expect(
            clientePorId(page, 104)
        ).toBeVisible();

        await expect(
            clientePorId(page, 103)
        ).toHaveCount(0);

    });

    test('deve retornar aos ativos quando filtro for invalido', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta = await page.goto(
            '/cliente?filtro=invalido'
        );

        expect(resposta!.status())
            .toBe(200);

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText('Ativos');

        await expect(
            linhasClientes(page)
        ).toHaveCount(2);

    });

    test('deve ordenar clientes alfabeticamente pelo nome', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE cliente
            SET nome = 'ZULU TESTE'
            WHERE id_cliente = 101;

            UPDATE cliente
            SET nome = 'ALFA TESTE'
            WHERE id_cliente = 102;
        `);

        await abrirClientes(page);

        await expect(
            page.locator(
                '.tabela-interna tbody .cliente-identidade strong'
            )
        ).toHaveText([

            'ALFA TESTE',
            'ZULU TESTE',

        ]);

    });

    // =========================================
    // PESQUISA - 8 TESTES
    // =========================================

    const pesquisas = [

        {
            tipo: 'nome',
            termo: 'Cliente Teste Ativo',
            id: 101,
        },

        {
            tipo: 'CPF',
            termo: '98765410211',
            id: 102,
        },

        {
            tipo: 'email',
            termo: 'livre@example.test',
            id: 102,
        },

        {
            tipo: 'telefone',
            termo: '11900000101',
            id: 101,
        },

        {
            tipo: 'maiusculas e minusculas',
            termo: 'CLIENTE TESTE ATIVO',
            id: 101,
        },

    ];

    for (const item of pesquisas) {

        test(`deve pesquisar cliente por ${item.tipo}`, async ({
            page,
        }) => {

            await abrirClientes(page);

            await page.locator('#pesquisaTabela')
                .fill(item.termo);

            await expect(
                page.locator(
                    '.tabela-interna tbody tr:visible'
                )
            ).toHaveCount(1);

            await expect(
                clientePorId(page, item.id)
            ).toBeVisible();

            await expect(
                page.locator('#resultadoPesquisa')
            ).toHaveText(
                '1 resultado encontrado'
            );

        });

    }

    test('deve apresentar contagem de multiplos resultados', async ({
        page,
    }) => {

        await abrirClientes(page);

        await page.locator('#pesquisaTabela')
            .fill('Cliente Teste');

        await expect(
            page.locator(
                '.tabela-interna tbody tr:visible'
            )
        ).toHaveCount(2);

        await expect(
            page.locator('#resultadoPesquisa')
        ).toHaveText(
            '2 resultados encontrados'
        );

    });

    test('deve informar quando pesquisa nao encontra clientes', async ({
        page,
    }) => {

        await abrirClientes(page);

        await page.locator('#pesquisaTabela')
            .fill('CLIENTE-INEXISTENTE-999');

        await expect(
            page.locator(
                '.tabela-interna tbody tr:visible'
            )
        ).toHaveCount(0);

        await expect(
            page.locator('#resultadoPesquisa')
        ).toHaveText(
            '0 resultados encontrados'
        );

        await expect(page)
            .toHaveURL(/\/cliente$/);

    });

    test('deve restaurar listagem ao limpar pesquisa', async ({
        page,
    }) => {

        await abrirClientes(page);

        const pesquisa =
            page.locator('#pesquisaTabela');

        await pesquisa.fill(
            'CLIENTE-INEXISTENTE-999'
        );

        await expect(
            page.locator(
                '.tabela-interna tbody tr:visible'
            )
        ).toHaveCount(0);

        await pesquisa.clear();

        await expect(
            page.locator(
                '.tabela-interna tbody tr:visible'
            )
        ).toHaveCount(2);

        await expect(
            page.locator('#resultadoPesquisa')
        ).toHaveText('');

    });

    // =========================================
    // ESTADO VAZIO - 1 TESTE
    // =========================================

    test('deve apresentar estado vazio sem clientes na categoria', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE cliente
            SET ativo = 1
            WHERE id_cliente = 103;
        `);

        await abrirClientes(page);

        await selecionarFiltro(
            page,
            'Inativos',
            'inativos'
        );

        await expect(
            page.locator('.estado-vazio')
        ).toHaveText(
            'Nenhum cliente encontrado nesta categoria.'
        );

        await expect(
            page.locator('.tabela-interna')
        ).toHaveCount(0);

    });

    // =========================================
    // NAVEGACAO - 2 TESTES
    // =========================================

    test('deve acessar formulario de novo cliente', async ({
        page,
    }) => {

        await abrirClientes(page);

        const link = page.getByRole('link', {
            name: '+ Novo cliente',
            exact: true,
        });

        await expect(link).toHaveAttribute(
            'href',
            '/cadastro-cliente.jsp'
        );

        await link.click();

        await expect(page)
            .toHaveURL(
                /\/cadastro-cliente\.jsp$/
            );

        await expect(page)
            .toHaveTitle(
                'Novo cliente | Fast Splash'
            );

        await expect(
            page.locator('.form-interno')
        ).toBeVisible();

    });

    test('deve acessar formulario de edicao do cliente selecionado', async ({
        page,
    }) => {

        await abrirClientes(page);

        const cliente =
            clientePorId(page, 102);

        const editar = cliente.getByRole(
            'link',
            {
                name: 'Editar',
                exact: true,
            }
        );

        await expect(editar)
            .toHaveAttribute(
                'href',
                '/cliente?acao=editar&idCliente=102'
            );

        await editar.click();

        await expect(page)
            .toHaveURL(
                /\/cliente\?acao=editar&idCliente=102$/
            );

        await expect(page)
            .toHaveTitle(
                'Editar cliente | Fast Splash'
            );

        await expect(
            page.locator('#nome')
        ).toHaveValue(
            'Cliente Teste Livre'
        );

        await expect(
            page.locator(
                'input[name="idCliente"]'
            )
        ).toHaveValue('102');

    });

    // =========================================
    // PERMISSOES DO ATENDENTE - 3 TESTES
    // =========================================

    test('deve permitir atendente consultar clientes ativos', async ({
        page,
    }) => {

        await abrirClientes(
            page,
            'atendente'
        );

        await expect(
            linhasClientes(page)
        ).toHaveCount(2);

        await expect(
            page.locator('.filtros-clientes a')
        ).toHaveCount(1);

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText('Ativos');

        await expect(
            page.getByRole('link', {
                name: '+ Novo cliente',
                exact: true,
            })
        ).toBeVisible();

        await expect(
            clientePorId(page, 102)
                .getByRole('link', {
                    name: 'Editar',
                    exact: true,
                })
        ).toBeVisible();

    });

    for (const filtro of [

        'inativos',
        'excluidos',

    ]) {

        test(`deve impedir atendente de acessar filtro ${filtro}`, async ({
            page,
        }) => {

            await autenticarAtendente(page);

            const resposta = await page.goto(
                `/cliente?filtro=${filtro}`
            );

            expect(resposta).not.toBeNull();

            expect(resposta!.status())
                .toBe(403);

            await page.goto('/cliente');

            await expect(
                linhasClientes(page)
            ).toHaveCount(2);

        });

    }

});
