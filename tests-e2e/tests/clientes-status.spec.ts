import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

type Filtro = 'ativos' | 'inativos' | 'excluidos';

type Acao = 'inativar' | 'reativar' | 'excluir' | 'restaurar';

function clientePorId(page: Page, id: number) {

    return page.locator(
        '.tabela-interna tbody tr'
    ).filter({

        has: page.getByText(
            `ID #${id}`,
            { exact: true }
        ),

    });

}

async function abrirClientes(
    page: Page,
    filtro: Filtro = 'ativos'
): Promise<void> {

    await autenticarAdministrador(page);

    await page.goto(
        `/cliente?filtro=${filtro}`
    );

}

function consultarStatus(id: number): string[] {

    return executarSqlTeste(`
        SELECT ativo, excluido_em IS NOT NULL
        FROM cliente
        WHERE id_cliente = ${id};
    `).split('\t');

}

async function executarAcao(
    page: Page,
    id: number,
    botao: string,
    confirmar: boolean = true
): Promise<void> {

    const linha = clientePorId(page, id);

    await expect(linha).toBeVisible();

    const acao = linha.getByRole(
        'button',
        {
            name: botao,
            exact: true,
        }
    );

    await expect(acao).toBeVisible();

    const dialogo = page.waitForEvent('dialog')
        .then(async dialog => {

            const tipo = dialog.type();

            if (confirmar) {

                await dialog.accept();

            } else {

                await dialog.dismiss();

            }

            return tipo;

        });

    const [tipo] = await Promise.all([

        dialogo,

        acao.click(),

    ]);

    expect(tipo).toBe('confirm');

}

async function validarSucesso(
    page: Page,
    status: string,
    mensagem: string
): Promise<void> {

    await expect(page).toHaveURL(
        new RegExp(
            `[?&]status=${status}(?:&|$)`
        )
    );

    await expect(
        page.locator('.aviso-sucesso-cliente')
    ).toHaveText(mensagem);

}

async function validarPendencias(
    page: Page
): Promise<void> {

    await expect(page).toHaveURL(
        /[?&]erro=pendencias(?:&|$)/
    );

    await expect(
        page.getByRole('alert')
    ).toContainText(
        'O cliente possui agendamentos ou atendimentos pendentes.'
    );

}

async function enviarStatus(
    page: Page,
    acao: Acao,
    idCliente: string,
    filtro: Filtro = 'ativos'
) {

    return page.request.post(
        '/cliente',
        {
            form: {

                acao,
                idCliente,
                filtro,

            },

            maxRedirects: 0,
        }
    );

}

test.describe('Status e permissoes de clientes', () => {

    // =========================================
    // CICLO DE VIDA - 5 TESTES
    // =========================================

    test('deve inativar cliente sem pendencias', async ({
        page,
    }) => {

        await abrirClientes(page);

        await executarAcao(
            page, 102, 'Inativar'
        );

        await validarSucesso(
            page,
            'inativado',
            'Cliente inativado com sucesso.'
        );

        expect(
            consultarStatus(102)
        ).toEqual(['0', '0']);

        await expect(
            clientePorId(page, 102)
        ).toHaveCount(0);

        await page.goto(
            '/cliente?filtro=inativos'
        );

        await expect(
            clientePorId(page, 102)
        ).toBeVisible();

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM veiculo
                WHERE id_cliente = 102;
            `)
        ).toBe('1');

    });

    test('deve reativar cliente inativo', async ({
        page,
    }) => {

        await abrirClientes(
            page, 'inativos'
        );

        await executarAcao(
            page, 103, 'Reativar'
        );

        await validarSucesso(
            page,
            'reativado',
            'Cliente reativado com sucesso.'
        );

        expect(
            consultarStatus(103)
        ).toEqual(['1', '0']);

        await expect(
            clientePorId(page, 103)
        ).toHaveCount(0);

        await page.goto(
            '/cliente?filtro=ativos'
        );

        await expect(
            clientePorId(page, 103)
        ).toBeVisible();

    });

    test('deve excluir logicamente cliente ativo sem pendencias', async ({
        page,
    }) => {

        await abrirClientes(page);

        await executarAcao(
            page, 102, 'Excluir'
        );

        await validarSucesso(
            page,
            'excluido',
            'Cliente excluido com sucesso. Historico preservado.'
        );

        expect(
            consultarStatus(102)
        ).toEqual(['0', '1']);

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM cliente;
            `)
        ).toBe('4');

        expect(
            executarSqlTeste(`
                SELECT COUNT(*)
                FROM veiculo
                WHERE id_cliente = 102;
            `)
        ).toBe('1');

        await page.goto(
            '/cliente?filtro=excluidos'
        );

        await expect(
            clientePorId(page, 102)
        ).toBeVisible();

    });

    test('deve excluir logicamente cliente inativo', async ({
        page,
    }) => {

        await abrirClientes(
            page, 'inativos'
        );

        await executarAcao(
            page, 103, 'Excluir'
        );

        await validarSucesso(
            page,
            'excluido',
            'Cliente excluido com sucesso. Historico preservado.'
        );

        expect(
            consultarStatus(103)
        ).toEqual(['0', '1']);

        await expect(
            clientePorId(page, 103)
        ).toHaveCount(0);

        await page.goto(
            '/cliente?filtro=excluidos'
        );

        await expect(
            clientePorId(page, 103)
        ).toBeVisible();

    });

    test('deve restaurar cliente excluido preservando historico', async ({
        page,
    }) => {

        await abrirClientes(
            page, 'excluidos'
        );

        await executarAcao(
            page, 104, 'Restaurar'
        );

        await validarSucesso(
            page,
            'restaurado',
            'Cliente restaurado com sucesso.'
        );

        expect(
            consultarStatus(104)
        ).toEqual(['1', '0']);

        await page.goto(
            '/cliente?filtro=ativos'
        );

        await expect(
            clientePorId(page, 104)
        ).toBeVisible();

        const historico = executarSqlTeste(`
            SELECT
                (SELECT COUNT(*) FROM veiculo
                    WHERE id_veiculo = 205
                    AND id_cliente = 104),

                (SELECT COUNT(*) FROM agendamento
                    WHERE id_agendamento = 506
                    AND id_veiculo = 205),

                (SELECT COUNT(*) FROM atendimento
                    WHERE id_atendimento = 605
                    AND id_agendamento = 506),

                (SELECT COUNT(*) FROM pagamento
                    WHERE id_pagamento = 706
                    AND id_agendamento = 506);
        `).split('\t');

        expect(historico).toEqual([
            '1', '1', '1', '1',
        ]);

    });

    // =========================================
    // BLOQUEIO POR PENDENCIAS - 2 TESTES
    // =========================================

    for (const botao of [

        'Inativar',
        'Excluir',

    ]) {

        test(`deve bloquear ${botao} cliente com pendencias`, async ({
            page,
        }) => {

            await abrirClientes(page);

            await executarAcao(
                page, 101, botao
            );

            await validarPendencias(page);

            expect(
                consultarStatus(101)
            ).toEqual(['1', '0']);

            await expect(
                clientePorId(page, 101)
            ).toBeVisible();

            expect(
                executarSqlTeste(`
                    SELECT COUNT(*)
                    FROM agendamento a
                    JOIN veiculo v
                        ON v.id_veiculo = a.id_veiculo
                    WHERE v.id_cliente = 101;
                `)
            ).toBe('5');

        });

    }

    // =========================================
    // CANCELAMENTO DE CONFIRMACAO - 4 TESTES
    // =========================================

    const cancelamentos: {

        botao: string;
        id: number;
        filtro: Filtro;
        esperado: string[];

    }[] = [

        {
            botao: 'Inativar',
            id: 102,
            filtro: 'ativos',
            esperado: ['1', '0'],
        },

        {
            botao: 'Reativar',
            id: 103,
            filtro: 'inativos',
            esperado: ['0', '0'],
        },

        {
            botao: 'Excluir',
            id: 102,
            filtro: 'ativos',
            esperado: ['1', '0'],
        },

        {
            botao: 'Restaurar',
            id: 104,
            filtro: 'excluidos',
            esperado: ['0', '1'],
        },

    ];

    for (const item of cancelamentos) {

        test(`deve preservar cliente ao cancelar ${item.botao}`, async ({
            page,
        }) => {

            await abrirClientes(
                page, item.filtro
            );

            const urlAnterior = page.url();

            await executarAcao(
                page,
                item.id,
                item.botao,
                false
            );

            await expect(page)
                .toHaveURL(urlAnterior);

            expect(
                consultarStatus(item.id)
            ).toEqual(item.esperado);

            await expect(
                clientePorId(page, item.id)
            ).toBeVisible();

            await expect(
                page.locator('.aviso-sucesso-cliente')
            ).toHaveCount(0);

        });

    }

    // =========================================
    // ACOES DISPONIVEIS NA INTERFACE - 3 TESTES
    // =========================================

    test('deve apresentar acoes corretas para cliente ativo', async ({
        page,
    }) => {

        await abrirClientes(page);

        const linha = clientePorId(
            page, 102
        );

        await expect(
            linha.getByRole('link', {
                name: 'Editar',
                exact: true,
            })
        ).toBeVisible();

        for (const nome of [

            'Inativar',
            'Excluir',

        ]) {

            await expect(
                linha.getByRole('button', {
                    name: nome,
                    exact: true,
                })
            ).toBeVisible();

        }

        for (const nome of [

            'Reativar',
            'Restaurar',

        ]) {

            await expect(
                linha.getByRole('button', {
                    name: nome,
                    exact: true,
                })
            ).toHaveCount(0);

        }

    });

    test('deve apresentar acoes corretas para cliente inativo', async ({
        page,
    }) => {

        await abrirClientes(
            page, 'inativos'
        );

        const linha = clientePorId(
            page, 103
        );

        for (const nome of [

            'Reativar',
            'Excluir',

        ]) {

            await expect(
                linha.getByRole('button', {
                    name: nome,
                    exact: true,
                })
            ).toBeVisible();

        }

        await expect(
            linha.getByRole('link', {
                name: 'Editar',
                exact: true,
            })
        ).toHaveCount(0);

        for (const nome of [

            'Inativar',
            'Restaurar',

        ]) {

            await expect(
                linha.getByRole('button', {
                    name: nome,
                    exact: true,
                })
            ).toHaveCount(0);

        }

    });

    test('deve apresentar somente restauracao para cliente excluido', async ({
        page,
    }) => {

        await abrirClientes(
            page, 'excluidos'
        );

        const linha = clientePorId(
            page, 104
        );

        await expect(
            linha.getByRole('button')
        ).toHaveCount(1);

        await expect(
            linha.getByRole('button', {
                name: 'Restaurar',
                exact: true,
            })
        ).toBeVisible();

        await expect(
            linha.getByRole('link', {
                name: 'Editar',
                exact: true,
            })
        ).toHaveCount(0);

    });

    // =========================================
    // PERMISSOES DO ATENDENTE - 4 TESTES
    // =========================================

    const restricoes: {

        acao: Acao;
        id: number;
        filtro: Filtro;
        esperado: string[];

    }[] = [

        {
            acao: 'inativar',
            id: 102,
            filtro: 'ativos',
            esperado: ['1', '0'],
        },

        {
            acao: 'reativar',
            id: 103,
            filtro: 'inativos',
            esperado: ['0', '0'],
        },

        {
            acao: 'excluir',
            id: 102,
            filtro: 'ativos',
            esperado: ['1', '0'],
        },

        {
            acao: 'restaurar',
            id: 104,
            filtro: 'excluidos',
            esperado: ['0', '1'],
        },

    ];

    for (const item of restricoes) {

        test(`deve impedir atendente de ${item.acao} cliente`, async ({
            page,
        }) => {

            await autenticarAtendente(page);

            await page.goto('/cliente');

            await expect(
                page.locator(
                    '.tabela-interna tbody .acoes-tabela button'
                )
            ).toHaveCount(0);

            const resposta = await enviarStatus(
                page,
                item.acao,
                String(item.id),
                item.filtro
            );

            expect(resposta.status())
                .toBe(403);

            expect(
                consultarStatus(item.id)
            ).toEqual(item.esperado);

        });

    }

    // =========================================
    // VALIDACAO DE IDENTIFICADORES - 3 TESTES
    // =========================================

    for (const id of [

        'abc',
        '0',
        '-1',

    ]) {

        test(`deve rejeitar identificador invalido ${id}`, async ({
            page,
        }) => {

            await autenticarAdministrador(page);

            const resposta = await enviarStatus(
                page,
                'inativar',
                id
            );

            expect(resposta.status())
                .toBe(400);

            expect(
                consultarStatus(101)
            ).toEqual(['1', '0']);

            expect(
                consultarStatus(102)
            ).toEqual(['1', '0']);

        });

    }

    // =========================================
    // TRANSICOES INVALIDAS - 5 TESTES
    // =========================================

    const transicoes: {

        acao: Acao;
        id: number;
        filtro: Filtro;
        erro: string;
        mensagem: string;
        esperado: string[];

    }[] = [

        {
            acao: 'inativar',
            id: 103,
            filtro: 'inativos',
            erro: 'jaInativo',
            mensagem: 'Este cliente ja esta inativo.',
            esperado: ['0', '0'],
        },

        {
            acao: 'reativar',
            id: 102,
            filtro: 'ativos',
            erro: 'jaAtivo',
            mensagem: 'Este cliente ja esta ativo.',
            esperado: ['1', '0'],
        },

        {
            acao: 'excluir',
            id: 104,
            filtro: 'excluidos',
            erro: 'jaExcluido',
            mensagem: 'Este cliente ja foi excluido.',
            esperado: ['0', '1'],
        },

        {
            acao: 'restaurar',
            id: 102,
            filtro: 'ativos',
            erro: 'naoExcluido',
            mensagem: 'Este cliente nao esta excluido.',
            esperado: ['1', '0'],
        },

        {
            acao: 'inativar',
            id: 999999,
            filtro: 'ativos',
            erro: 'naoEncontrado',
            mensagem: 'Cliente nao encontrado.',
            esperado: [''],
        },

    ];

    for (const item of transicoes) {

        test(`deve rejeitar transicao invalida ${item.erro}`, async ({
            page,
        }) => {

            await autenticarAdministrador(page);

            const resposta = await enviarStatus(
                page,
                item.acao,
                String(item.id),
                item.filtro
            );

            expect(resposta.status())
                .toBe(302);

            const destino = new URL(
                resposta.headers()['location'],
                'http://127.0.0.1:8081'
            );

            expect(destino.origin)
                .toBe('http://127.0.0.1:8081');

            expect(destino.pathname)
                .toBe('/cliente');

            expect(
                destino.searchParams.get('erro')
            ).toBe(item.erro);

            await page.goto(destino.href);

            await expect(
                page.getByRole('alert')
            ).toContainText(item.mensagem);

            expect(
                consultarStatus(item.id)
            ).toEqual(item.esperado);

            expect(
                executarSqlTeste(`
                    SELECT COUNT(*)
                    FROM cliente;
                `)
            ).toBe('4');

        });

    }

});
