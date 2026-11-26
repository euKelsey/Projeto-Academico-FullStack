import type { Page } from '@playwright/test';
import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
    preencherLogin,
} from '../support/autenticacao';

import {
    executarSqlTeste as sql,
} from '../support/ambiente';

type Modulo = 'veiculo' | 'servico' | 'colaborador';
type Filtro = 'ativos' | 'inativos' | 'excluidos';

const BASE_URL = 'http://127.0.0.1:8081';
const SENHA = 'SenhaFicticia@123';

const identificadores = {
    veiculo: 'idVeiculo',
    servico: 'idServico',
    colaborador: 'idColaborador',
};

function linhas(page: Page) {
    return page.locator('.tabela-interna tbody tr');
}

function linha(page: Page, id: number) {
    return linhas(page).filter({
        has: page.locator(
            '.veiculo-identidade div span, ' +
            '.cliente-identidade div span'
        ).filter({
            hasText: new RegExp(
                `^\\s*ID\\s*#\\s*${id}\\s*$`
            ),
        }),
    });
}

async function abrir(
    page: Page,
    modulo: Modulo,
    atendente = false
) {
    if (atendente) {
        await autenticarAtendente(page);
    } else {
        await autenticarAdministrador(page);
    }

    const resposta = await page.goto(`/${modulo}`);

    expect(resposta!.status()).toBe(200);
}

async function filtro(
    page: Page,
    categoria: Filtro
) {
    const nomes = {
        ativos: 'Ativos',
        inativos: 'Inativos',
        excluidos: 'Excluídos',
    };

    await page.locator('.filtros-clientes')
        .getByRole('link', {
            name: nomes[categoria],
            exact: true,
        }).click();

    await expect(
        page.locator('.filtro-selecionado')
    ).toHaveText(nomes[categoria]);
}

async function pesquisar(
    page: Page,
    termo: string,
    quantidade: number
) {
    await page.locator('#pesquisaTabela')
        .fill(termo);

    await expect(
        page.locator('.tabela-interna tbody tr:visible')
    ).toHaveCount(quantidade);

    await expect(
        page.locator('#resultadoPesquisa')
    ).toHaveText(
        quantidade === 1
            ? '1 resultado encontrado'
            : `${quantidade} resultados encontrados`
    );
}

async function novo(page: Page) {
    await page.locator(
        '.interna-cabecalho .botao-interno-principal'
    ).click();

    await expect(
        page.locator('.form-interno')
    ).toBeVisible();
}

async function editar(page: Page, id: number) {
    await linha(page, id)
        .getByRole('link', {
            name: 'Editar',
            exact: true,
        }).click();

    await expect(
        page.locator('.form-interno')
    ).toBeVisible();
}

async function preencher(
    page: Page,
    dados: Record<string, string>
) {
    for (const [campo, valor] of Object.entries(dados)) {
        const input = page.locator(`#${campo}`);

        const tag = await input.evaluate(
            elemento => elemento.tagName
        );

        if (tag === 'SELECT') {
            await input.selectOption(valor);
        } else {
            await input.fill(valor);
        }
    }
}

async function salvar(
    page: Page,
    modulo: Modulo
) {
    await page.locator(
        '.form-interno button[type="submit"]'
    ).click();

    await expect(page).toHaveURL(
        `${BASE_URL}/${modulo}`
    );
}

function estado(modulo: Modulo, id: number) {
    return sql(`
        SELECT ativo, excluido_em IS NOT NULL
        FROM ${modulo}
        WHERE id_${modulo} = ${id};
    `);
}

function quantidade(modulo: Modulo) {
    return Number(sql(
        `SELECT COUNT(*) FROM ${modulo};`
    ));
}

async function acaoStatus(
    page: Page,
    id: number,
    acao: string,
    confirmar = true,
    possuiDialogo = true
) {
    const botao = linha(page, id)
        .getByRole('button', {
            name: acao,
            exact: true,
        });

    if (!possuiDialogo) {
        await botao.click();
        return;
    }

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
        botao.click(),
    ]);

    expect(tipo).toBe('confirm');
}

async function sucesso(
    page: Page,
    status: string
) {
    await expect(page).toHaveURL(
        new RegExp(`[?&]status=${status}(?:&|$)`)
    );

    await expect(
        page.locator('.aviso-sucesso-cliente')
    ).toBeVisible();
}

async function erro(
    page: Page,
    codigo: string,
    mensagem: string
) {
    await expect(page).toHaveURL(
        new RegExp(`[?&]erro=${codigo}(?:&|$)`)
    );

    await expect(
        page.getByRole('alert')
    ).toContainText(mensagem);
}

async function post(
    page: Page,
    modulo: Modulo,
    dados: Record<string, string>
) {
    return page.request.post(
        `/${modulo}`,
        {
            form: dados,
            maxRedirects: 0,
        }
    );
}

async function postStatus(
    page: Page,
    modulo: Modulo,
    id: string,
    acao: string,
    categoria: Filtro = 'ativos'
) {
    return post(page, modulo, {
        acao,
        filtro: categoria,
        [identificadores[modulo]]: id,
    });
}

async function validarRedirecionamentoErro(
    page: Page,
    modulo: Modulo,
    id: string,
    acao: string,
    codigo: string
) {
    const resposta = await postStatus(
        page, modulo, id, acao
    );

    expect(resposta.status()).toBe(302);

    const destino = new URL(
        resposta.headers()['location'],
        BASE_URL
    );

    expect(destino.origin).toBe(BASE_URL);
    expect(destino.pathname).toBe(`/${modulo}`);
    expect(destino.searchParams.get('erro'))
        .toBe(codigo);

    await page.goto(destino.href);

    await expect(
        page.getByRole('alert')
    ).toBeVisible();
}

// =============================================
// TESTES COMPARTILHADOS DE LISTAGEM
// =============================================

function testesListagem(config: {
    modulo: Modulo;
    titulo: string;
    ativos: number[];
    inativos: number[];
    excluidos: number[];
    pesquisa: string;
    resultados: number;
    prepararExcluidos?: string;
    prepararVazio: string;
}) {
    const m = config.modulo;

    test('deve listar registros ativos e colunas da tabela', async ({ page }) => {
        await abrir(page, m);

        await expect(page).toHaveTitle(
            config.titulo
        );

        await expect(linhas(page))
            .toHaveCount(config.ativos.length);

        for (const id of config.ativos) {
            await expect(linha(page, id))
                .toBeVisible();
        }

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText('Ativos');

        await expect(
            page.locator('.tabela-interna thead th').first()
        ).toBeVisible();
    });

    test('deve filtrar registros inativos', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'inativos');

        await expect(linhas(page))
            .toHaveCount(config.inativos.length);

        for (const id of config.inativos) {
            await expect(linha(page, id))
                .toBeVisible();
        }
    });

    test('deve filtrar registros excluidos', async ({ page }) => {
        if (config.prepararExcluidos) {
            sql(config.prepararExcluidos);
        }

        await abrir(page, m);
        await filtro(page, 'excluidos');

        await expect(linhas(page))
            .toHaveCount(config.excluidos.length);

        for (const id of config.excluidos) {
            await expect(linha(page, id))
                .toBeVisible();
        }
    });

    test('deve normalizar filtro invalido', async ({ page }) => {
        await abrir(page, m);

        const resposta = await page.goto(
            `/${m}?filtro=invalido`
        );

        expect(resposta!.status()).toBe(200);

        await expect(linhas(page))
            .toHaveCount(config.ativos.length);

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText('Ativos');
    });

    test('deve pesquisar sem diferenciar maiusculas e minusculas', async ({ page }) => {
        await abrir(page, m);

        await pesquisar(
            page,
            config.pesquisa.toUpperCase(),
            config.resultados
        );
    });

    test('deve informar pesquisa sem resultados e restaurar tabela', async ({ page }) => {
        await abrir(page, m);

        await pesquisar(
            page,
            'REGISTRO-INEXISTENTE-999',
            0
        );

        await page.locator('#pesquisaTabela')
            .clear();

        await expect(
            page.locator('.tabela-interna tbody tr:visible')
        ).toHaveCount(config.ativos.length);

        await expect(
            page.locator('#resultadoPesquisa')
        ).toHaveText('');
    });

    test('deve apresentar estado vazio da categoria', async ({ page }) => {
        sql(config.prepararVazio);

        await abrir(page, m);
        await filtro(page, 'inativos');

        await expect(
            page.locator('.estado-vazio')
        ).toBeVisible();

        await expect(
            page.locator('.tabela-interna')
        ).toHaveCount(0);
    });

    test('deve cancelar cadastro sem inserir registro', async ({ page }) => {
        const anterior = quantidade(m);

        await abrir(page, m);
        await novo(page);

        await page.getByRole('link', {
            name: 'Cancelar',
            exact: true,
        }).click();

        await expect(page).toHaveURL(
            `${BASE_URL}/${m}`
        );

        expect(quantidade(m)).toBe(anterior);
    });

    test('deve cancelar edicao sem modificar registro', async ({ page }) => {
        const id = config.ativos[
            config.ativos.length - 1
        ];

        const anterior = sql(`
            SELECT *
            FROM ${m}
            WHERE id_${m} = ${id};
        `);

        await abrir(page, m);
        await editar(page, id);

        const campo = m === 'veiculo'
            ? '#modelo'
            : '#nome';

        await page.locator(campo)
            .fill('ALTERACAO CANCELADA');

        await page.getByRole('link', {
            name: 'Cancelar',
            exact: true,
        }).click();

        await expect(page).toHaveURL(
            `${BASE_URL}/${m}`
        );

        expect(sql(`
            SELECT *
            FROM ${m}
            WHERE id_${m} = ${id};
        `)).toBe(anterior);
    });

    test('deve rejeitar edicao de registro inexistente', async ({ page }) => {
        await abrir(page, m);

        const resposta = await page.goto(
            `/${m}?acao=editar&${identificadores[m]}=999999`
        );

        expect(resposta!.status()).toBe(404);
    });

    test('deve rejeitar identificadores invalidos nas operacoes de status', async ({ page }) => {
        await abrir(page, m);

        for (const id of ['abc', '0', '-1']) {
            const resposta = await postStatus(
                page, m, id, 'inativar'
            );

            expect(resposta.status()).toBe(400);
        }
    });
}

// =============================================
// INTEGRACAO COM API MOBILE
// =============================================

async function consultarApi(
    page: Page,
    email: string,
    rota: string
) {
    const api = await page.context()
        .request.post('/api/auth/login', {
            form: {
                email,
                senha: SENHA,
            },
            maxRedirects: 0,
        });

    expect(api.status()).toBe(200);

    const resposta = await page.request.get(
        rota,
        { maxRedirects: 0 }
    );

    expect(resposta.status()).toBe(200);

    return resposta.json();
}

// =============================================
// 1.8.9.8 - VEICULOS
// =============================================

test.describe('Veiculos', () => {
    const m = 'veiculo';

    const dados = {
        idCliente: '102',
        placa: 'TST9A99',
        marca: 'Honda',
        modelo: 'Fit',
        cor: 'Azul',
    };

    testesListagem({
        modulo: m,
        titulo: 'Veículos | Fast Splash',
        ativos: [201, 202, 203],
        inativos: [204],
        excluidos: [205],
        pesquisa: 'TST1A01',
        resultados: 1,
        prepararVazio:
            'UPDATE veiculo SET ativo=1 WHERE id_veiculo=204;',
    });

    test('deve mostrar proprietarios e dados dos veiculos', async ({ page }) => {
        await abrir(page, m);

        await expect(linha(page, 201))
            .toContainText('Volkswagen Polo');

        await expect(linha(page, 201))
            .toContainText('TST1A01');

        await expect(linha(page, 201))
            .toContainText('Cliente Teste Ativo');

        await expect(linha(page, 201))
            .toContainText('Branco');

        await pesquisar(
            page, 'Cliente Teste Ativo', 2
        );
    });

    test('deve preservar nome do proprietario no historico', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'excluidos');

        await expect(linha(page, 205))
            .toContainText('Cliente Teste Excluido');
    });

    test('deve oferecer somente proprietarios ativos no cadastro', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        const opcoes = await page.locator(
            '#idCliente option'
        ).evaluateAll(elementos =>
            elementos.map(e =>
                (e as HTMLOptionElement).value
            )
        );

        expect(opcoes).toEqual([
            '', '101', '102',
        ]);
    });

    test('deve bloquear cadastro sem proprietarios ativos', async ({ page }) => {
        sql(`
            UPDATE cliente
            SET ativo=0
            WHERE ativo=1;
        `);

        await abrir(page, m);
        await novo(page);

        await expect(
            page.locator('.aviso-interno')
        ).toContainText(
            'Nenhum cliente está disponível.'
        );

        await expect(
            page.locator('#idCliente')
        ).toBeDisabled();

        await expect(
            page.getByRole('button', {
                name: 'Cadastrar veículo',
            })
        ).toHaveCount(0);
    });

    for (const placa of ['tst9a99', 'tst9999']) {
        test(`deve cadastrar placa valida ${placa}`, async ({ page }) => {
            await abrir(page, m);
            await novo(page);

            await preencher(page, {
                ...dados,
                placa,
            });

            await expect(
                page.locator('#placa')
            ).toHaveValue(placa.toUpperCase());

            await expect(
                page.locator('#marca')
            ).toHaveValue('HONDA');

            await salvar(page, m);

            expect(sql(`
                SELECT id_cliente, marca, modelo, cor, ativo
                FROM veiculo
                WHERE placa='${placa.toUpperCase()}';
            `)).toBe(
                '102\tHONDA\tFIT\tAZUL\t1'
            );

            expect(quantidade(m)).toBe(6);
        });
    }

    test('deve normalizar caracteres da placa', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await page.locator('#placa').evaluate(e => {
            const input = e as HTMLInputElement;
            input.value = 'tst-9a99!!';
            input.dispatchEvent(
                new Event('input', { bubbles: true })
            );
        });

        await expect(
            page.locator('#placa')
        ).toHaveValue('TST9A99');
    });

    test('deve impedir placa invalida no formulario', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await preencher(page, {
            ...dados,
            placa: '1234567',
        });

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        expect(await page.locator('#placa')
            .evaluate(e =>
                (e as HTMLInputElement)
                    .validity.patternMismatch
            )
        ).toBe(true);

        expect(quantidade(m)).toBe(5);
    });

    test('deve rejeitar campos vazios e placas invalidas no backend', async ({ page }) => {
        await abrir(page, m);

        for (const campo of Object.keys(dados)) {
            const resposta = await post(
                page, m, {
                    ...dados,
                    [campo]: '',
                }
            );

            expect(resposta.status()).toBe(400);
        }

        const resposta = await post(page, m, {
            ...dados,
            placa: '1234567',
        });

        expect(resposta.status()).toBe(400);
        expect(quantidade(m)).toBe(5);
    });

    for (const id of ['103', '104', '999999']) {
        test(`deve rejeitar proprietario indisponivel ${id}`, async ({ page }) => {
            await abrir(page, m);

            const resposta = await post(
                page, m, {
                    ...dados,
                    idCliente: id,
                }
            );

            expect(resposta.status()).toBe(409);
            expect(quantidade(m)).toBe(5);
        });
    }

    test('deve impedir placa duplicada', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await preencher(page, {
            ...dados,
            placa: 'TST1A01',
        });

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        await expect(page).toHaveURL(
            `${BASE_URL}/veiculo`
        );

        expect(quantidade(m)).toBe(5);

        expect(sql(`
            SELECT COUNT(*) FROM veiculo
            WHERE placa='TST1A01';
        `)).toBe('1');
    });

    test('deve editar dados preservando relacionamentos', async ({ page }) => {
        await abrir(page, m);
        await editar(page, 201);

        await expect(
            page.locator('#idCliente')
        ).toHaveValue('101');

        await expect(
            page.locator('#placa')
        ).toHaveValue('TST1A01');

        await preencher(page, {
            cor: 'Cinza',
            modelo: 'Polo atualizado',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT modelo, cor, id_cliente
            FROM veiculo WHERE id_veiculo=201;
        `)).toBe(
            'POLO ATUALIZADO\tCINZA\t101'
        );

        expect(sql(`
            SELECT COUNT(*) FROM agendamento
            WHERE id_veiculo=201;
        `)).toBe('2');
    });

    test('deve permitir alterar proprietario de veiculo sem historico', async ({ page }) => {
        await abrir(page, m);
        await editar(page, 203);

        await preencher(page, {
            idCliente: '101',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT id_cliente FROM veiculo
            WHERE id_veiculo=203;
        `)).toBe('101');
    });

    test('deve impedir alteracao para proprietario inativo', async ({ page }) => {
        await abrir(page, m);

        const resposta = await post(page, m, {
            ...dados,
            acao: 'atualizar',
            idVeiculo: '203',
            idCliente: '103',
        });

        expect(resposta.status()).toBe(409);

        expect(sql(`
            SELECT id_cliente FROM veiculo
            WHERE id_veiculo=203;
        `)).toBe('102');
    });

    test('deve impedir edicao de inativos e excluidos', async ({ page }) => {
        await abrir(page, m);

        for (const id of [204, 205]) {
            const resposta = await page.goto(
                `/veiculo?acao=editar&idVeiculo=${id}`
            );

            expect(resposta!.status()).toBe(404);

            const atualizacao = await post(
                page, m, {
                    ...dados,
                    acao: 'atualizar',
                    idVeiculo: String(id),
                }
            );

            expect(atualizacao.status()).toBe(404);
        }
    });

    test('deve permitir cadastro e edicao pelo atendente', async ({ page }) => {
        await abrir(page, m, true);
        await novo(page);
        await preencher(page, dados);
        await salvar(page, m);

        const id = Number(sql(`
            SELECT id_veiculo FROM veiculo
            WHERE placa='TST9A99';
        `));

        await editar(page, id);

        await preencher(page, {
            cor: 'Verde',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT cor FROM veiculo
            WHERE id_veiculo=${id};
        `)).toBe('VERDE');
    });

    test('deve inativar e reativar veiculo sem pendencias', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 203, 'Inativar'
        );

        await sucesso(page, 'inativado');
        expect(estado(m, 203)).toBe('0\t0');

        await filtro(page, 'inativos');

        await acaoStatus(
            page, 203, 'Reativar'
        );

        await sucesso(page, 'reativado');
        expect(estado(m, 203)).toBe('1\t0');
    });

    test('deve excluir logicamente e restaurar veiculo', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 203, 'Excluir'
        );

        await sucesso(page, 'excluido');
        expect(estado(m, 203)).toBe('0\t1');
        expect(quantidade(m)).toBe(5);

        await filtro(page, 'excluidos');

        await acaoStatus(
            page, 203, 'Restaurar'
        );

        await sucesso(page, 'restaurado');
        expect(estado(m, 203)).toBe('1\t0');
    });

    for (const acao of ['Inativar', 'Excluir']) {
        test(`deve bloquear ${acao} com pendencias`, async ({ page }) => {
            await abrir(page, m);
            await acaoStatus(page, 201, acao);

            await erro(
                page,
                'pendencias',
                'O veículo possui agendamentos ou atendimentos pendentes.'
            );

            expect(estado(m, 201)).toBe('1\t0');
        });
    }

    test('deve bloquear reativacao com proprietario inativo', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'inativos');

        await acaoStatus(
            page, 204, 'Reativar'
        );

        await erro(
            page,
            'clienteInativo',
            'O proprietário precisa estar ativo'
        );

        expect(estado(m, 204)).toBe('0\t0');
    });

    test('deve bloquear restauracao com proprietario excluido', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'excluidos');

        await acaoStatus(
            page, 205, 'Restaurar'
        );

        await erro(
            page,
            'clienteInativo',
            'O proprietário precisa estar ativo'
        );

        expect(estado(m, 205)).toBe('0\t1');
    });

    test('deve preservar historico ao restaurar veiculo', async ({ page }) => {
        sql(`
            UPDATE cliente
            SET ativo=1, excluido_em=NULL
            WHERE id_cliente=104;
        `);

        await abrir(page, m);
        await filtro(page, 'excluidos');

        await acaoStatus(
            page, 205, 'Restaurar'
        );

        await sucesso(page, 'restaurado');
        expect(estado(m, 205)).toBe('1\t0');

        expect(sql(`
            SELECT COUNT(*)
            FROM agendamento a
            JOIN atendimento at
                ON at.id_agendamento=a.id_agendamento
            JOIN pagamento p
                ON p.id_agendamento=a.id_agendamento
            WHERE a.id_veiculo=205;
        `)).toBe('1');
    });

    test('deve cancelar operacao de status', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 203, 'Excluir', false
        );

        expect(estado(m, 203)).toBe('1\t0');
    });

    test('deve restringir filtros e alteracoes de status ao administrador', async ({ page }) => {
        await abrir(page, m, true);

        await expect(
            page.locator('.filtros-clientes a')
        ).toHaveCount(1);

        await expect(
            page.locator('.acoes-tabela button')
        ).toHaveCount(0);

        for (const categoria of [
            'inativos', 'excluidos',
        ]) {
            const resposta = await page.goto(
                `/veiculo?filtro=${categoria}`
            );

            expect(resposta!.status()).toBe(403);
        }

        for (const acao of [
            'inativar', 'reativar',
            'excluir', 'restaurar',
        ]) {
            const resposta = await postStatus(
                page, m, '203', acao
            );

            expect(resposta.status()).toBe(403);
        }

        expect(estado(m, 203)).toBe('1\t0');
    });

    test('deve rejeitar transicoes invalidas', async ({ page }) => {
        await abrir(page, m);

        const casos = [
            ['204', 'inativar', 'jaInativo'],
            ['203', 'reativar', 'jaAtivo'],
            ['205', 'excluir', 'jaExcluido'],
            ['203', 'restaurar', 'naoExcluido'],
            ['999999', 'excluir', 'naoEncontrado'],
        ];

        for (const [id, acao, codigo] of casos) {
            await validarRedirecionamentoErro(
                page, m, id, acao, codigo
            );
        }

        expect(estado(m, 203)).toBe('1\t0');
        expect(estado(m, 204)).toBe('0\t0');
        expect(estado(m, 205)).toBe('0\t1');
    });

    test('deve disponibilizar veiculo cadastrado no Web pela API mobile', async ({ page, context }) => {
        await abrir(page, m);
        await novo(page);
        await preencher(page, dados);
        await salvar(page, m);

        const mobile = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const pagina = await mobile.newPage();

            const resultado = await consultarApi(
                pagina,
                'livre@example.test',
                '/api/veiculos'
            );

            expect(resultado.veiculos).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        placa: 'TST9A99',
                        idCliente: 102,
                    }),
                ])
            );
        } finally {
            await mobile.close();
        }
    });

    test('deve remover veiculo inativado da API mobile', async ({ page, context }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 203, 'Inativar'
        );

        await sucesso(page, 'inativado');

        const mobile = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const resultado = await consultarApi(
                await mobile.newPage(),
                'livre@example.test',
                '/api/veiculos'
            );

            expect(resultado.veiculos).toEqual([]);
        } finally {
            await mobile.close();
        }
    });
});

// =============================================
// 1.8.9.9 - SERVICOS
// =============================================

test.describe('Servicos', () => {
    const m = 'servico';

    const dados = {
        nome: 'Polimento Teste',
        descricao: 'Servico ficticio',
        precoExibicao: '12550',
    };

    testesListagem({
        modulo: m,
        titulo: 'Serviços | Fast Splash',
        ativos: [301, 302],
        inativos: [303],
        excluidos: [304],
        pesquisa: 'Lavagem Completa',
        resultados: 1,
        prepararVazio:
            'UPDATE servico SET ativo=1 WHERE id_servico=303;',
    });

    test('deve mostrar descricao e preco na listagem', async ({ page }) => {
        await abrir(page, m);

        const registro = linha(page, 301);

        await expect(registro)
            .toContainText('Lavagem Simples Teste');

        await expect(registro)
            .toContainText('Lavagem externa');

        await expect(registro)
            .toContainText(/R\$\s*50[,.]00/);
    });

    test('deve aplicar mascara monetaria e valor decimal', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await page.locator('#precoExibicao')
            .fill('123456');

        await expect(
            page.locator('#precoExibicao')
        ).toHaveValue(/R\$\s*1\.234,56/);

        await expect(
            page.locator('#preco')
        ).toHaveValue('1234.56');

        await page.locator('#precoExibicao')
            .clear();

        await expect(
            page.locator('#preco')
        ).toHaveValue('');
    });

    test('deve cadastrar servico com preco correto', async ({ page }) => {
        await abrir(page, m);
        await novo(page);
        await preencher(page, dados);
        await salvar(page, m);

        expect(sql(`
            SELECT descricao, preco, ativo
            FROM servico
            WHERE nome='Polimento Teste';
        `)).toBe(
            'Servico ficticio\t125.50\t1'
        );

        expect(quantidade(m)).toBe(5);
    });

    test('deve aceitar descricao opcional', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await preencher(page, {
            ...dados,
            descricao: '',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT COUNT(*) FROM servico
            WHERE nome='Polimento Teste'
              AND COALESCE(descricao,'')='';
        `)).toBe('1');
    });

    test('deve exigir nome e preco no formulario', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        for (const campo of [
            '#nome', '#precoExibicao',
        ]) {
            await expect(
                page.locator(campo)
            ).toHaveAttribute('required', '');
        }

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        await expect(
            page.locator('.form-interno')
        ).toBeVisible();

        expect(quantidade(m)).toBe(4);
    });

    test('deve impedir persistencia de preco negativo', async ({ page }) => {
        await abrir(page, m);

        const resposta = await post(page, m, {
            nome: 'Servico Invalido',
            descricao: 'Teste',
            preco: '-10.00',
        });

        expect(resposta.status()).toBeGreaterThanOrEqual(400);
        expect(quantidade(m)).toBe(4);
    });

    test('deve editar servico sem modificar precos historicos', async ({ page }) => {
        const historico = sql(`
            SELECT id_agendamento, valor_praticado
            FROM agendamento_servico
            WHERE id_servico=301
            ORDER BY id_agendamento;
        `);

        await abrir(page, m);
        await editar(page, 301);

        await expect(
            page.locator('#precoExibicao')
        ).toHaveValue(/R\$\s*50,00/);

        await preencher(page, {
            nome: 'Lavagem Atualizada',
            descricao: 'Descricao atualizada',
            precoExibicao: '6990',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT nome, descricao, preco
            FROM servico WHERE id_servico=301;
        `)).toBe(
            'Lavagem Atualizada\tDescricao atualizada\t69.90'
        );

        expect(sql(`
            SELECT id_agendamento, valor_praticado
            FROM agendamento_servico
            WHERE id_servico=301
            ORDER BY id_agendamento;
        `)).toBe(historico);
    });

    test('deve bloquear edicao de inativos e excluidos', async ({ page }) => {
        await abrir(page, m);

        for (const id of [303, 304]) {
            const resposta = await page.goto(
                `/servico?acao=editar&idServico=${id}`
            );

            expect(resposta!.status()).toBe(404);

            const atualizacao = await post(
                page, m, {
                    acao: 'atualizar',
                    idServico: String(id),
                    nome: 'Teste',
                    descricao: '',
                    preco: '10.00',
                }
            );

            expect(atualizacao.status()).toBe(404);
        }
    });

    test('deve inativar e reativar servico', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 301, 'Inativar'
        );

        await sucesso(page, 'inativado');
        expect(estado(m, 301)).toBe('0\t0');

        await filtro(page, 'inativos');

        await acaoStatus(
            page, 301, 'Reativar'
        );

        await sucesso(page, 'reativado');
        expect(estado(m, 301)).toBe('1\t0');
    });

    test('deve excluir logicamente e restaurar servico preservando historico', async ({ page }) => {
        const historico = sql(`
            SELECT *
            FROM agendamento_servico
            WHERE id_servico=301
            ORDER BY id_agendamento;
        `);

        await abrir(page, m);

        await acaoStatus(
            page, 301, 'Excluir'
        );

        await sucesso(page, 'excluido');
        expect(estado(m, 301)).toBe('0\t1');
        expect(quantidade(m)).toBe(4);

        await filtro(page, 'excluidos');

        await acaoStatus(
            page, 301, 'Restaurar'
        );

        await sucesso(page, 'restaurado');
        expect(estado(m, 301)).toBe('1\t0');

        expect(sql(`
            SELECT *
            FROM agendamento_servico
            WHERE id_servico=301
            ORDER BY id_agendamento;
        `)).toBe(historico);
    });

    test('deve excluir servico inativo', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'inativos');

        await acaoStatus(
            page, 303, 'Excluir'
        );

        await sucesso(page, 'excluido');
        expect(estado(m, 303)).toBe('0\t1');
    });

    test('deve cancelar exclusao', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 301, 'Excluir', false
        );

        expect(estado(m, 301)).toBe('1\t0');
    });

    test('deve rejeitar transicoes invalidas', async ({ page }) => {
        await abrir(page, m);

        const casos = [
            ['303', 'inativar'],
            ['301', 'reativar'],
            ['304', 'excluir'],
            ['301', 'restaurar'],
            ['999999', 'inativar'],
        ];

        for (const [id, acao] of casos) {
            await validarRedirecionamentoErro(
                page, m, id, acao,
                'operacaoInvalida'
            );
        }

        expect(estado(m, 301)).toBe('1\t0');
        expect(estado(m, 303)).toBe('0\t0');
        expect(estado(m, 304)).toBe('0\t1');
    });

    test('deve restringir todas as operacoes ao administrador', async ({ page }) => {
        await autenticarAtendente(page);

        const rotas = [
            '/servico',
            '/servico?acao=novo',
            '/servico?acao=editar&idServico=301',
            '/servico?filtro=inativos',
            '/servico?filtro=excluidos',
        ];

        for (const rota of rotas) {
            const resposta = await page.goto(rota);
            expect(resposta!.status()).toBe(403);
        }

        for (const acao of [
            'cadastrar', 'atualizar',
            'inativar', 'reativar',
            'excluir', 'restaurar',
        ]) {
            const resposta = await post(page, m, {
                acao,
                idServico: '301',
                nome: 'Alteracao indevida',
                descricao: '',
                preco: '1.00',
            });

            expect(resposta.status()).toBe(403);
        }

        expect(estado(m, 301)).toBe('1\t0');
        expect(quantidade(m)).toBe(4);

        expect(sql(`
            SELECT preco FROM servico
            WHERE id_servico=301;
        `)).toBe('50.00');
    });

    test('deve refletir cadastro e preco atualizado na API mobile', async ({ page, context }) => {
        await abrir(page, m);
        await novo(page);
        await preencher(page, dados);
        await salvar(page, m);

        await editar(page, 301);

        await preencher(page, {
            precoExibicao: '7550',
        });

        await salvar(page, m);

        const mobile = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const resultado = await consultarApi(
                await mobile.newPage(),
                'ativo@example.test',
                '/api/servicos'
            );

            expect(resultado.servicos).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        nome: 'Polimento Teste',
                        preco: 125.50,
                    }),
                    expect.objectContaining({
                        idServico: 301,
                        preco: 75.50,
                    }),
                ])
            );
        } finally {
            await mobile.close();
        }
    });

    test('deve ocultar servico inativado da API mobile', async ({ page, context }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 301, 'Inativar'
        );

        await sucesso(page, 'inativado');

        const mobile = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const resultado = await consultarApi(
                await mobile.newPage(),
                'ativo@example.test',
                '/api/servicos'
            );

            expect(
                resultado.servicos.map(
                    (s: { idServico: number }) =>
                        s.idServico
                )
            ).toEqual([302]);
        } finally {
            await mobile.close();
        }
    });
});

// =============================================
// 1.8.9.10 - COLABORADORES
// =============================================

test.describe('Colaboradores', () => {
    const m = 'colaborador';

    const dados = {
        nome: 'Colaborador Novo Teste',
        cargo: 'Atendimento',
        nivelAcesso: 'ATENDENTE',
        email: 'colaborador-novo@example.test',
        senha: SENHA,
    };

    testesListagem({
        modulo: m,
        titulo: 'Colaboradores | Fast Splash',
        ativos: [401, 402, 403, 404],
        inativos: [405],
        excluidos: [405],
        pesquisa: 'Operacional Teste',
        resultados: 2,
        prepararExcluidos: `
            UPDATE colaborador
            SET excluido_em=NOW()
            WHERE id_colaborador=405;
        `,
        prepararVazio: `
            UPDATE colaborador
            SET ativo=1
            WHERE id_colaborador=405;
        `,
    });

    test('deve apresentar niveis de acesso e status', async ({ page }) => {
        await abrir(page, m);

        await expect(linha(page, 401))
            .toContainText('ADMINISTRADOR');

        await expect(linha(page, 402))
            .toContainText('ATENDENTE');

        await expect(linha(page, 403))
            .toContainText('OPERACIONAL');

        await expect(linha(page, 403))
            .toContainText('Ativo');
    });

    for (const nivel of [
        'ADMINISTRADOR', 'ATENDENTE',
    ]) {
        test(`deve cadastrar ${nivel} com credenciais protegidas`, async ({ page, context }) => {
            await abrir(page, m);
            await novo(page);

            await preencher(page, {
                ...dados,
                nivelAcesso: nivel,
            });

            await salvar(page, m);

            expect(sql(`
                SELECT nivel_acesso,
                       senha_hash LIKE 'pbkdf2$%',
                       ativo
                FROM colaborador
                WHERE email='colaborador-novo@example.test';
            `)).toBe(`${nivel}\t1\t1`);

            const outro = await context.browser()!
                .newContext({ baseURL: BASE_URL });

            try {
                const pagina = await outro.newPage();

                await preencherLogin(
                    pagina, dados.email, SENHA
                );

                await expect(pagina)
                    .toHaveURL(/\/dashboard$/);

                await expect(
                    pagina.locator('.fs-menu-perfil strong')
                ).toHaveText(
                    nivel === 'ADMINISTRADOR'
                        ? 'Administrador'
                        : 'Atendente'
                );
            } finally {
                await outro.close();
            }
        });
    }

    test('deve cadastrar operacional sem credenciais', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await preencher(page, {
            ...dados,
            nivelAcesso: 'OPERACIONAL',
            email: '',
            senha: '',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT nivel_acesso,
                   email IS NULL,
                   senha_hash IS NULL,
                   ativo
            FROM colaborador
            WHERE nome='Colaborador Novo Teste';
        `)).toBe('OPERACIONAL\t1\t1\t1');
    });

    for (const nivel of [
        'ADMINISTRADOR', 'ATENDENTE',
    ]) {
        for (const campo of ['email', 'senha']) {
            test(`deve exigir ${campo} para ${nivel}`, async ({ page }) => {
                await abrir(page, m);
                await novo(page);

                await preencher(page, {
                    ...dados,
                    nivelAcesso: nivel,
                    [campo]: '',
                });

                await page.locator(
                    '.form-interno button[type="submit"]'
                ).click();

                await expect(
                    page.locator('.mensagem-interna-erro')
                ).toContainText(
                    campo === 'email'
                        ? 'E-mail é obrigatório'
                        : 'Senha é obrigatória'
                );

                expect(quantidade(m)).toBe(5);
            });
        }
    }

    test('deve rejeitar nivel de acesso invalido', async ({ page }) => {
        await abrir(page, m);

        const resposta = await post(page, m, {
            ...dados,
            nivelAcesso: 'INVALIDO',
        });

        expect(await resposta.text())
            .toContain('Nível de acesso inválido.');

        expect(quantidade(m)).toBe(5);
    });

    test('deve rejeitar nome ou cargo vazio', async ({ page }) => {
        await abrir(page, m);

        for (const campo of ['nome', 'cargo']) {
            const resposta = await post(
                page, m, {
                    ...dados,
                    [campo]: '',
                }
            );

            expect(await resposta.text())
                .toContain(`Informe o ${campo}.`);
        }

        expect(quantidade(m)).toBe(5);
    });

    test('deve rejeitar email duplicado com mensagem amigavel', async ({ page }) => {
        await abrir(page, m);
        await novo(page);

        await preencher(page, {
            ...dados,
            email: 'admin@example.test',
        });

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        await expect(
            page.locator('.mensagem-interna-erro')
        ).toHaveText(
            'Já existe um colaborador com este e-mail.'
        );

        expect(quantidade(m)).toBe(5);
    });

    test('deve editar colaborador preservando senha', async ({ page }) => {
        const hash = sql(`
            SELECT senha_hash FROM colaborador
            WHERE id_colaborador=402;
        `);

        await abrir(page, m);
        await editar(page, 402);

        await expect(
            page.locator('#senha')
        ).toHaveValue('');

        await preencher(page, {
            nome: 'Atendente Atualizado',
            cargo: 'Recepcao',
        });

        await salvar(page, m);

        expect(sql(`
            SELECT nome, cargo, senha_hash
            FROM colaborador
            WHERE id_colaborador=402;
        `)).toBe(
            `Atendente Atualizado\tRecepcao\t${hash}`
        );
    });

    test('deve alterar senha e permitir login com nova credencial', async ({ page, context }) => {
        const anterior = sql(`
            SELECT senha_hash FROM colaborador
            WHERE id_colaborador=402;
        `);

        const novaSenha = 'NovaSenhaFicticia@456';

        await abrir(page, m);
        await editar(page, 402);

        await preencher(page, {
            senha: novaSenha,
        });

        await salvar(page, m);

        const atual = sql(`
            SELECT senha_hash FROM colaborador
            WHERE id_colaborador=402;
        `);

        expect(atual).not.toBe(anterior);
        expect(atual).toMatch(/^pbkdf2\$/);

        const outro = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const pagina = await outro.newPage();

            await preencherLogin(
                pagina,
                'atendente@example.test',
                SENHA
            );

            await expect(
                pagina.locator('.login-erro')
            ).toBeVisible();

            await preencherLogin(
                pagina,
                'atendente@example.test',
                novaSenha
            );

            await expect(pagina)
                .toHaveURL(/\/dashboard$/);
        } finally {
            await outro.close();
        }
    });

    test('deve exigir senha ao promover operacional', async ({ page }) => {
        await abrir(page, m);
        await editar(page, 404);

        await preencher(page, {
            nivelAcesso: 'ATENDENTE',
            email: 'promovido@example.test',
            senha: '',
        });

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        await expect(
            page.locator('.mensagem-interna-erro')
        ).toContainText(
            'Informe uma senha para permitir acesso'
        );

        expect(sql(`
            SELECT nivel_acesso FROM colaborador
            WHERE id_colaborador=404;
        `)).toBe('OPERACIONAL');
    });

    test('deve promover operacional com credenciais validas', async ({ page }) => {
        await abrir(page, m);
        await editar(page, 404);

        await preencher(page, {
            nivelAcesso: 'ATENDENTE',
            email: 'promovido@example.test',
            senha: SENHA,
        });

        await salvar(page, m);

        expect(sql(`
            SELECT nivel_acesso, email,
                   senha_hash LIKE 'pbkdf2$%'
            FROM colaborador
            WHERE id_colaborador=404;
        `)).toBe(
            'ATENDENTE\tpromovido@example.test\t1'
        );

        expect(sql(`
            SELECT COUNT(*)
            FROM colaborador_atendimento
            WHERE id_colaborador=404;
        `)).toBe('2');
    });

    test('deve proteger nivel do ultimo administrador', async ({ page }) => {
        await abrir(page, m);
        await editar(page, 401);

        await preencher(page, {
            nivelAcesso: 'ATENDENTE',
        });

        await page.locator(
            '.form-interno button[type="submit"]'
        ).click();

        await erro(
            page,
            'ultimoAdministrador',
            'O sistema precisa manter pelo menos um administrador ativo.'
        );

        expect(sql(`
            SELECT nivel_acesso FROM colaborador
            WHERE id_colaborador=401;
        `)).toBe('ADMINISTRADOR');
    });

    test('deve proteger propria conta contra inativacao e exclusao', async ({ page }) => {
        await abrir(page, m);

        await expect(
            linha(page, 401).getByRole('button')
        ).toHaveCount(0);

        for (const acao of [
            'inativar', 'excluir',
        ]) {
            await validarRedirecionamentoErro(
                page, m, '401', acao,
                'proprioUsuario'
            );
        }

        expect(estado(m, 401)).toBe('1\t0');
    });

    test('deve inativar e reativar colaborador', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 402, 'Inativar'
        );

        await sucesso(page, 'inativado');
        expect(estado(m, 402)).toBe('0\t0');

        await filtro(page, 'inativos');

        await acaoStatus(
            page, 402, 'Reativar', true, false
        );

        await sucesso(page, 'reativado');
        expect(estado(m, 402)).toBe('1\t0');
    });

    test('deve excluir e restaurar colaborador preservando historico', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 404, 'Excluir'
        );

        await sucesso(page, 'excluido');
        expect(estado(m, 404)).toBe('0\t1');

        await filtro(page, 'excluidos');

        await acaoStatus(
            page, 404, 'Restaurar'
        );

        await sucesso(page, 'restaurado');
        expect(estado(m, 404)).toBe('1\t0');

        expect(sql(`
            SELECT COUNT(*)
            FROM colaborador_atendimento
            WHERE id_colaborador=404;
        `)).toBe('2');

        expect(quantidade(m)).toBe(5);
    });

    test('deve excluir colaborador inativo', async ({ page }) => {
        await abrir(page, m);
        await filtro(page, 'inativos');

        await acaoStatus(
            page, 405, 'Excluir'
        );

        await sucesso(page, 'excluido');
        expect(estado(m, 405)).toBe('0\t1');
    });

    for (const acao of ['Inativar', 'Excluir']) {
        test(`deve bloquear ${acao} colaborador com atendimento pendente`, async ({ page }) => {
            await abrir(page, m);

            await acaoStatus(
                page, 403, acao
            );

            await erro(
                page,
                'pendencias',
                'Este colaborador possui atendimentos pendentes.'
            );

            expect(estado(m, 403)).toBe('1\t0');
        });
    }

    test('deve cancelar exclusao de colaborador', async ({ page }) => {
        await abrir(page, m);

        await acaoStatus(
            page, 404, 'Excluir', false
        );

        expect(estado(m, 404)).toBe('1\t0');
    });

    test('deve impedir edicao de colaborador inativo ou excluido', async ({ page }) => {
        await abrir(page, m);

        for (const excluido of [false, true]) {
            if (excluido) {
                sql(`
                    UPDATE colaborador
                    SET excluido_em=NOW()
                    WHERE id_colaborador=405;
                `);
            }

            const resposta = await page.goto(
                '/colaborador?acao=editar&idColaborador=405'
            );

            expect(resposta!.status()).toBe(404);

            const atualizacao = await post(
                page, m, {
                    ...dados,
                    acao: 'atualizar',
                    idColaborador: '405',
                }
            );

            expect(atualizacao.status()).toBe(404);
        }
    });

    test('deve rejeitar transicoes invalidas', async ({ page }) => {
        sql(`
            UPDATE colaborador
            SET ativo=0, excluido_em=NOW()
            WHERE id_colaborador=404;
        `);

        await abrir(page, m);

        const casos = [
            ['405', 'inativar', 'jaInativo'],
            ['402', 'reativar', 'jaAtivo'],
            ['404', 'excluir', 'jaExcluido'],
            ['402', 'restaurar', 'naoExcluido'],
            ['999999', 'inativar', 'naoEncontrado'],
        ];

        for (const [id, acao, codigo] of casos) {
            await validarRedirecionamentoErro(
                page, m, id, acao, codigo
            );
        }

        expect(estado(m, 402)).toBe('1\t0');
        expect(estado(m, 404)).toBe('0\t1');
        expect(estado(m, 405)).toBe('0\t0');
    });

    test('deve impedir acesso administrativo pelo atendente', async ({ page }) => {
        await autenticarAtendente(page);

        for (const rota of [
            '/colaborador',
            '/colaborador?acao=novo',
            '/colaborador?acao=editar&idColaborador=401',
            '/colaborador?filtro=inativos',
            '/colaborador?filtro=excluidos',
        ]) {
            const resposta = await page.goto(rota);
            expect(resposta!.status()).toBe(403);
        }

        for (const acao of [
            'cadastrar', 'atualizar',
            'inativar', 'reativar',
            'excluir', 'restaurar',
        ]) {
            const resposta = await post(
                page, m, {
                    ...dados,
                    acao,
                    idColaborador: '401',
                }
            );

            expect(resposta.status()).toBe(403);
        }

        expect(estado(m, 401)).toBe('1\t0');
        expect(quantidade(m)).toBe(5);
    });

    test('deve revogar sessao apos inativacao pela interface', async ({ page, context }) => {
        await abrir(page, m);

        const outro = await context.browser()!
            .newContext({ baseURL: BASE_URL });

        try {
            const atendente = await outro.newPage();

            await autenticarAtendente(atendente);

            await acaoStatus(
                page, 402, 'Inativar'
            );

            await sucesso(page, 'inativado');

            await atendente.goto('/dashboard');

            await expect(atendente)
                .toHaveURL(/\/login$/);

        } finally {
            await outro.close();
        }
    });
});
