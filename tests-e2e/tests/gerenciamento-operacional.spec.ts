import type { Page, APIRequestContext } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste as sql,
} from '../support/ambiente';

const BASE = 'http://127.0.0.1:8081';
const SENHA = 'SenhaFicticia@123';

type Modulo = 'agendamento' | 'atendimento' | 'pagamento';

// =============================================
// FUNCOES COMPARTILHADAS
// =============================================

function linhas(page: Page) {
    return page.locator('.tabela-interna tbody tr');
}

function agendamento(page: Page, id: number) {
    return linhas(page).filter({
        has: page.locator(
            '.agendamento-identidade span'
        ).filter({
            hasText: new RegExp(
                `^\\s*Agendamento\\s*#\\s*${id}\\s*$`
            ),
        }),
    });
}

function atendimento(page: Page, id: number) {
    return linhas(page).filter({
        has: page.locator(
            '.atendimento-identidade span'
        ).filter({
            hasText: new RegExp(
                `Atendimento\\s*#\\s*${id}\\s*·`
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
    nome: string
) {
    await page.locator('.filtros-clientes')
        .getByRole('link', {
            name: nome,
            exact: true,
        }).click();

    await expect(
        page.locator('.filtro-selecionado')
    ).toHaveText(nome);
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

async function limparPesquisa(
    page: Page,
    quantidade: number
) {
    await page.locator('#pesquisaTabela')
        .clear();

    await expect(
        page.locator('.tabela-interna tbody tr:visible')
    ).toHaveCount(quantidade);

    await expect(
        page.locator('#resultadoPesquisa')
    ).toHaveText('');
}

async function confirmarAcao(
    page: Page,
    botao: ReturnType<Page['locator']>,
    aceitar = true
) {
    const dialogo = page.waitForEvent('dialog')
        .then(async dialog => {
            const tipo = dialog.type();

            if (aceitar) {
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

function moeda(texto: string): number {
    return Number(
        texto.replace(/[^\d,.-]/g, '')
            .replace(/\.(?=\d{3}(?:[.,]|$))/g, '')
            .replace(',', '.')
    );
}

function dataFutura(): string {
    return sql(`
        SELECT DATE_ADD(
            CURDATE(), INTERVAL 3 DAY
        );
    `);
}

function contar(tabela: string): number {
    return Number(sql(
        `SELECT COUNT(*) FROM ${tabela};`
    ));
}

async function abrirNovoAgendamento(
    page: Page
) {
    await page.getByRole('link', {
        name: '+ Novo agendamento',
        exact: true,
    }).click();

    await expect(
        page.locator('#formAgendamento')
    ).toBeVisible();
}

async function preencherAgendamento(
    page: Page,
    cliente = '102',
    veiculo = '203',
    servicos = [301, 302],
    data = dataFutura(),
    horario = '14:30'
) {
    await page.locator('#idCliente')
        .selectOption(cliente);

    await page.locator('#idVeiculo')
        .selectOption(veiculo);

    for (const id of servicos) {
        await page.locator(
            `input[name="servicos"][value="${id}"]`
        ).check();
    }

    await page.locator('#data').fill(data);

    await page.locator('#horario').fill(horario);
}

async function criarAgendamento(
    page: Page,
    servicos = [301, 302]
): Promise<number> {

    await page.goto('/agendamento?acao=novo');

    const data = dataFutura();

    await preencherAgendamento(
        page, '102', '203',
        servicos, data
    );

    await page.getByRole('button', {
        name: 'Confirmar agendamento',
        exact: true,
    }).click();

    await expect(page)
        .toHaveURL(`${BASE}/agendamento`);

    const id = Number(sql(`
        SELECT id_agendamento
        FROM agendamento
        WHERE id_veiculo=203
          AND data='${data}'
          AND horario='14:30:00';
    `));

    expect(id).toBeGreaterThan(506);

    return id;
}

async function criarAtendimento(
    page: Page,
    idAgendamento: number
): Promise<number> {

    await page.goto('/atendimento?acao=novo');

    await page.locator('#idAgendamento')
        .selectOption(String(idAgendamento));

    await page.getByRole('button', {
        name: 'Criar atendimento',
        exact: true,
    }).click();

    await expect(page)
        .toHaveURL(`${BASE}/atendimento`);

    const id = Number(sql(`
        SELECT id_atendimento
        FROM atendimento
        WHERE id_agendamento=${idAgendamento};
    `));

    expect(id).toBeGreaterThan(605);

    return id;
}

async function autenticarMobile(
    api: APIRequestContext,
    email = 'ativo@example.test'
) {
    const resposta = await api.post(
        '/api/auth/login',
        {
            form: {
                email,
                senha: SENHA,
            },
            maxRedirects: 0,
        }
    );

    expect(resposta.status()).toBe(200);
    expect((await resposta.json()).sucesso)
        .toBe(true);
}

async function pagar(
    api: APIRequestContext,
    idAgendamento: number,
    formaPagamento = 'PIX'
) {
    return api.post(
        '/api/pagamentos/pagar',
        {
            form: {
                idAgendamento: String(idAgendamento),
                formaPagamento,
            },
            maxRedirects: 0,
        }
    );
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

// =============================================
// LISTAGENS, FILTROS E PESQUISAS
// =============================================

function testarListagem(config: {
    modulo: Modulo;
    titulo: string;
    filtros: {
        nome: string;
        ids: number[];
    }[];
    termo: string;
    encontrados: number;
    vazioSql: string;
    vazioFiltro: string;
}) {
    const localizar = config.modulo === 'atendimento'
        ? atendimento
        : agendamento;

    test('deve apresentar listagem inicial', async ({ page }) => {
        await abrir(page, config.modulo);

        await expect(page)
            .toHaveTitle(config.titulo);

        await expect(linhas(page))
            .toHaveCount(config.filtros[0].ids.length);

        for (const id of config.filtros[0].ids) {
            await expect(
                localizar(page, id)
            ).toBeVisible();
        }

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText(config.filtros[0].nome);
    });

    for (const item of config.filtros.slice(1)) {
        test(`deve filtrar ${item.nome}`, async ({ page }) => {
            await abrir(page, config.modulo);

            await filtro(page, item.nome);

            await expect(linhas(page))
                .toHaveCount(item.ids.length);

            for (const id of item.ids) {
                await expect(
                    localizar(page, id)
                ).toBeVisible();
            }
        });
    }

    test('deve normalizar filtro invalido', async ({ page }) => {
        await abrir(page, config.modulo);

        await page.goto(
            `/${config.modulo}?filtro=invalido`
        );

        await expect(
            page.locator('.filtro-selecionado')
        ).toHaveText(config.filtros[0].nome);

        await expect(linhas(page))
            .toHaveCount(config.filtros[0].ids.length);
    });

    test('deve pesquisar registros', async ({ page }) => {
        await abrir(page, config.modulo);

        await pesquisar(
            page,
            config.termo.toUpperCase(),
            config.encontrados
        );
    });

    test('deve tratar pesquisa vazia e restaurar registros', async ({ page }) => {
        await abrir(page, config.modulo);

        await pesquisar(
            page,
            'REGISTRO-INEXISTENTE-999',
            0
        );

        await limparPesquisa(
            page,
            config.filtros[0].ids.length
        );
    });

    test('deve apresentar categoria sem registros', async ({ page }) => {
        sql(config.vazioSql);

        await abrir(page, config.modulo);

        await filtro(page, config.vazioFiltro);

        await expect(
            page.locator('.tabela-card .estado-vazio')
        ).toBeVisible();

        await expect(
            page.locator('.tabela-interna')
        ).toHaveCount(0);
    });
}

async function testarOrdenacao(
    page: Page,
    chave: string,
    numerico = false
) {
    const cabecalho = page.locator(
        `.tabela-ordenavel[data-sort="${chave}"]`
    );

    for (const crescente of [true, false]) {
        if (crescente) {
            await cabecalho.click();
        } else {
            await cabecalho.focus();
            await page.keyboard.press('Enter');
        }

        await expect(cabecalho)
            .toHaveAttribute(
                'data-direcao',
                crescente ? 'asc' : 'desc'
            );

        const valores = await linhas(page)
            .evaluateAll((elementos, atributo) =>
                elementos.map(e =>
                    (e as HTMLElement)
                        .dataset[atributo] || ''
                ),
                chave
            );

        const esperado = [...valores].sort(
            (a, b) => {
                if (numerico) {
                    return Number(a) - Number(b);
                }

                return a < b ? -1 : a > b ? 1 : 0;
            }
        );

        expect(valores).toEqual(
            crescente
                ? esperado
                : esperado.reverse()
        );
    }
}

// =============================================
// 1.8.9.11 - AGENDAMENTOS
// =============================================

test.describe('Agendamentos', () => {

    testarListagem({
        modulo: 'agendamento',
        titulo: 'Agendamentos | Fast Splash',
        filtros: [
            { nome: 'Agendados', ids: [501,502,503] },
            { nome: 'Concluídos', ids: [504] },
            { nome: 'Cancelados', ids: [505] },
            { nome: 'Arquivados', ids: [506] },
        ],
        termo: 'TST1A01',
        encontrados: 2,
        vazioSql: `
            UPDATE agendamento
            SET arquivado_em=NOW()
            WHERE id_agendamento=505;
        `,
        vazioFiltro: 'Cancelados',
    });

    for (const chave of [
        'cliente', 'servicos',
        'data', 'valor', 'status',
    ]) {
        test(`deve ordenar agendamentos por ${chave}`, async ({ page }) => {
            await abrir(page, 'agendamento');

            await testarOrdenacao(
                page, chave, chave === 'valor'
            );
        });
    }

    test('deve apresentar dados completos e valor contratado', async ({ page }) => {
        await abrir(page, 'agendamento');

        const registro = agendamento(page, 501);

        await expect(registro).toContainText(
            'Cliente Teste Ativo'
        );

        await expect(registro).toContainText(
            'Volkswagen Polo - TST1A01'
        );

        await expect(registro).toContainText(
            'Lavagem Simples Teste'
        );

        await expect(registro).toContainText(
            '09:00'
        );

        await expect(
            registro.locator('.status-badge')
        ).toHaveText('AGENDADO');

        expect(moeda(
            await registro.locator(
                '.valor-destaque'
            ).innerText()
        )).toBe(50);
    });

    test('deve preservar valor historico apos alterar preco atual', async ({ page }) => {
        sql(`
            UPDATE servico
            SET preco=999.99
            WHERE id_servico=301;
        `);

        await abrir(page, 'agendamento');

        expect(moeda(
            await agendamento(page,501)
                .locator('.valor-destaque')
                .innerText()
        )).toBe(50);
    });

    test('deve iniciar formulario com campos dependentes bloqueados', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        await expect(
            page.locator('#idVeiculo')
        ).toBeDisabled();

        await expect(
            page.locator('#formAgendamento button[type="submit"]')
        ).toBeDisabled();

        expect(moeda(
            await page.locator('#valorTotal').innerText()
        )).toBe(0);
    });

    test('deve apresentar somente clientes e servicos ativos', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        const clientes = await page.locator(
            '#idCliente option'
        ).evaluateAll(es =>
            es.map(e => (e as HTMLOptionElement).value)
        );

        expect(clientes.sort()).toEqual(
            ['', '101', '102']
        );

        const servicos = await page.locator(
            'input[name="servicos"]'
        ).evaluateAll(es =>
            es.map(e => (e as HTMLInputElement).value)
        );

        expect(servicos.sort()).toEqual(
            ['301', '302']
        );
    });

    test('deve filtrar veiculos conforme proprietario', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        const cliente = page.locator('#idCliente');
        const veiculo = page.locator('#idVeiculo');

        await cliente.selectOption('101');

        await expect(veiculo).toBeEnabled();

        const opcoes = async () =>
            veiculo.locator('option[data-cliente]:not([hidden])')
                .evaluateAll(es =>
                    es.map(e =>
                        (e as HTMLOptionElement).value
                    ).sort()
                );

        expect(await opcoes()).toEqual(
            ['201', '202']
        );

        await veiculo.selectOption('201');

        await cliente.selectOption('102');

        await expect(veiculo).toHaveValue('');

        expect(await opcoes()).toEqual(['203']);

        await cliente.selectOption('');

        await expect(veiculo).toBeDisabled();
    });

    test('deve bloquear cliente sem veiculos disponiveis', async ({ page }) => {
        sql(`
            UPDATE veiculo
            SET ativo=0
            WHERE id_veiculo=203;
        `);

        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        await page.locator('#idCliente')
            .selectOption('102');

        await expect(
            page.locator('#idVeiculo')
        ).toBeDisabled();

        await expect(
            page.locator('#idVeiculo option').first()
        ).toHaveText(
            'Cliente sem veículos cadastrados'
        );
    });

    test('deve recalcular total ao selecionar e remover servicos', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        const simples = page.locator(
            'input[name="servicos"][value="301"]'
        );

        const completa = page.locator(
            'input[name="servicos"][value="302"]'
        );

        const total = async () => moeda(
            await page.locator('#valorTotal')
                .innerText()
        );

        await simples.check();
        expect(await total()).toBe(50);

        await completa.check();
        expect(await total()).toBe(130);

        await simples.uncheck();
        expect(await total()).toBe(80);

        await completa.uncheck();
        expect(await total()).toBe(0);
    });

    test('deve habilitar envio somente com formulario completo', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        await preencherAgendamento(
            page, '102', '203', [301]
        );

        const botao = page.locator(
            '#formAgendamento button[type="submit"]'
        );

        await expect(botao).toBeEnabled();

        await page.locator(
            'input[name="servicos"][value="301"]'
        ).uncheck();

        await expect(botao).toBeDisabled();
        expect(contar('agendamento')).toBe(6);
    });

    for (const item of [
        {
            nome: 'clientes',
            sql: 'UPDATE cliente SET ativo=0 WHERE ativo=1;',
            aviso: 'Não existem clientes cadastrados.',
        },
        {
            nome: 'veiculos',
            sql: 'UPDATE veiculo SET ativo=0 WHERE ativo=1;',
            aviso: 'Não existem veículos cadastrados.',
        },
        {
            nome: 'servicos',
            sql: 'UPDATE servico SET ativo=0 WHERE ativo=1;',
            aviso: 'Não existem serviços cadastrados.',
        },
    ]) {
        test(`deve impedir agendamento sem ${item.nome}`, async ({ page }) => {
            sql(item.sql);

            await abrir(page, 'agendamento');
            await abrirNovoAgendamento(page);

            await expect(
                page.locator('.aviso-interno').filter({
                    hasText: item.aviso,
                })
            ).toBeVisible();

            await expect(
                page.locator('#formAgendamento button[type="submit"]')
            ).toHaveCount(0);
        });
    }

    test('deve cancelar preenchimento sem gravar agendamento', async ({ page }) => {
        await abrir(page, 'agendamento');
        await abrirNovoAgendamento(page);

        await preencherAgendamento(page);

        await page.getByRole('link', {
            name: 'Cancelar',
            exact: true,
        }).click();

        await expect(page)
            .toHaveURL(`${BASE}/agendamento`);

        expect(contar('agendamento')).toBe(6);
    });

    test('deve cadastrar agendamento com dois servicos', async ({ page }) => {
        await abrir(page, 'agendamento');

        const id = await criarAgendamento(page);

        await expect(
            agendamento(page,id)
        ).toBeVisible();

        expect(sql(`
            SELECT id_veiculo,status
            FROM agendamento
            WHERE id_agendamento=${id};
        `)).toBe('203\tAGENDADO');

        expect(sql(`
            SELECT id_servico,valor_praticado
            FROM agendamento_servico
            WHERE id_agendamento=${id}
            ORDER BY id_servico;
        `)).toBe('301\t50.00\n302\t80.00');

        expect(contar('agendamento')).toBe(7);

        expect(moeda(
            await agendamento(page,id)
                .locator('.valor-destaque')
                .innerText()
        )).toBe(130);
    });

    test('deve permitir cadastro pelo atendente', async ({ page }) => {
        await abrir(page, 'agendamento', true);

        const id = await criarAgendamento(page,[301]);

        await expect(
            agendamento(page,id)
        ).toBeVisible();

        expect(sql(`
            SELECT SUM(valor_praticado)
            FROM agendamento_servico
            WHERE id_agendamento=${id};
        `)).toBe('50.00');
    });

    test('deve impedir agendamento duplicado', async ({ page }) => {
        await abrir(page, 'agendamento');

        await criarAgendamento(page);

        await page.goto('/agendamento?acao=novo');

        await preencherAgendamento(page);

        await page.getByRole('button', {
            name: 'Confirmar agendamento',
            exact: true,
        }).click();

        await expect(
            page.locator('.mensagem-interna-erro')
        ).toContainText(
            'Este veículo já possui um agendamento nesta data e horário.'
        );

        expect(contar('agendamento')).toBe(7);
        expect(contar('agendamento_servico')).toBe(9);
    });

    test('deve rejeitar agendamento sem servicos no backend', async ({ page }) => {
        await abrir(page, 'agendamento');

        const resposta = await post(
            page, 'agendamento', {
                idVeiculo: '203',
                data: dataFutura(),
                horario: '14:30',
            }
        );

        expect(await resposta.text())
            .toContain(
                'Selecione pelo menos um serviço.'
            );

        expect(contar('agendamento')).toBe(6);
    });

    test('deve rejeitar campos obrigatorios ausentes', async ({ page }) => {
        await abrir(page, 'agendamento');

        const dados = {
            idVeiculo: '203',
            data: dataFutura(),
            horario: '14:30',
            servicos: '301',
        };

        for (const campo of [
            'idVeiculo','data','horario',
        ]) {
            const resposta = await post(
                page, 'agendamento', {
                    ...dados,
                    [campo]: '',
                }
            );

            expect(await resposta.text())
                .toContain(
                    'Preencha o veículo, a data e o horário.'
                );
        }

        expect(contar('agendamento')).toBe(6);
    });

    test('deve rejeitar veiculo ou servico indisponivel sem gravacao parcial', async ({ page }) => {
        await abrir(page, 'agendamento');

        for (const dados of [
            { idVeiculo: '204', servicos: '301' },
            { idVeiculo: '205', servicos: '301' },
            { idVeiculo: '203', servicos: '303' },
            { idVeiculo: '203', servicos: '304' },
        ]) {
            const resposta = await post(
                page, 'agendamento', {
                    ...dados,
                    data: dataFutura(),
                    horario: '14:30',
                }
            );

            expect(resposta.status())
                .toBeGreaterThanOrEqual(400);

            expect(contar('agendamento')).toBe(6);

            expect(contar('agendamento_servico'))
                .toBe(7);
        }
    });

    test('deve cancelar agendamento sem atendimento ou pagamento', async ({ page }) => {
        await abrir(page, 'agendamento');

        const id = await criarAgendamento(page);

        await confirmarAcao(
            page,
            agendamento(page,id).locator(
                'button.acao-cancelar'
            )
        );

        await expect(
            agendamento(page,id)
        ).toHaveCount(0);

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=${id};
        `)).toBe('CANCELADO');

        await filtro(page,'Cancelados');

        await expect(
            agendamento(page,id)
        ).toBeVisible();

        expect(contar('agendamento')).toBe(7);
    });

    test('deve preservar agendamento ao desistir do cancelamento', async ({ page }) => {
        await abrir(page, 'agendamento');

        await confirmarAcao(
            page,
            agendamento(page,501).locator(
                'button.acao-cancelar'
            ),
            false
        );

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=501;
        `)).toBe('AGENDADO');
    });

    test('deve preservar agendamento concluido contra cancelamento direto', async ({ page }) => {
        await abrir(page, 'agendamento');

        const resposta = await post(
            page, 'agendamento', {
                acao: 'cancelar',
                idAgendamento: '504',
            }
        );

        expect(resposta.status()).toBe(302);

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=504;
        `)).toBe('CONCLUIDO');
    });

    test('deve disponibilizar agendamento Web na API mobile', async ({ page, playwright }) => {
        await abrir(page, 'agendamento');

        const id = await criarAgendamento(page);

        const api = await playwright.request.newContext({
            baseURL: BASE,
        });

        try {
            await autenticarMobile(
                api,'livre@example.test'
            );

            const resposta = await api.get(
                '/api/agendamentos'
            );

            expect(resposta.status()).toBe(200);

            const dados = await resposta.json();

            expect(dados.agendamentos).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        idAgendamento: id,
                        status: 'Agendado',
                        valorTotal: 130,
                    }),
                ])
            );
        } finally {
            await api.dispose();
        }
    });
});

// =============================================
// 1.8.9.12 - ATENDIMENTOS
// =============================================

test.describe('Atendimentos', () => {

    testarListagem({
        modulo: 'atendimento',
        titulo: 'Atendimentos | Fast Splash',
        filtros: [
            { nome: 'Aguardando', ids: [601,602] },
            { nome: 'Em lavagem', ids: [603] },
            { nome: 'Finalizados', ids: [604] },
            { nome: 'Arquivados', ids: [605] },
        ],
        termo: 'TST1A01',
        encontrados: 1,
        vazioSql: `
            UPDATE atendimento
            SET arquivado_em=NOW()
            WHERE id_atendimento=604;
        `,
        vazioFiltro: 'Finalizados',
    });

    test('deve apresentar pagamento pendente e impedir inicio na interface', async ({ page }) => {
        await abrir(page, 'atendimento');

        const registro = atendimento(page,601);

        await expect(
            registro.locator('td').nth(3)
        ).toHaveText('PENDENTE');

        await expect(registro)
            .toContainText('Aguardando pagamento');

        await expect(
            registro.getByRole('button', {
                name: 'Iniciar',
                exact: true,
            })
        ).toHaveCount(0);
    });

    test('deve apresentar pagamento confirmado e permitir inicio', async ({ page }) => {
        await abrir(page, 'atendimento');

        const registro = atendimento(page,602);

        await expect(
            registro.locator('td').nth(3)
        ).toHaveText('PAGO');

        await expect(
            registro.getByRole('button', {
                name: 'Iniciar',
                exact: true,
            })
        ).toBeVisible();
    });

    test('deve apresentar detalhes do atendimento aguardando', async ({ page }) => {
        await abrir(page, 'atendimento');

        await atendimento(page,601)
            .getByRole('link', {
                name: 'Detalhes',
                exact: true,
            }).click();

        await expect(page).toHaveTitle(
            'Detalhes do atendimento | Fast Splash'
        );

        await expect(
            page.locator('.atendimento-detalhes-grid')
        ).toContainText('Cliente Teste Ativo');

        await expect(
            page.locator('.atendimento-detalhes-grid')
        ).toContainText('TST1A01');

        await expect(
            page.locator('.atendimento-detalhes-grid')
        ).toContainText('Ainda não iniciado');

        await expect(
            page.locator('.atendimento-detalhes-grid')
        ).toContainText('Ainda não finalizado');

        await expect(
            page.locator('.fluxo-etapa.ativa')
        ).toHaveText('Aguardando');
    });

    for (const item of [
        { id:603, etapa:'Em lavagem' },
        { id:604, etapa:'Finalizado' },
    ]) {
        test(`deve apresentar detalhes na etapa ${item.etapa}`, async ({ page }) => {
            await abrir(page, 'atendimento');

            await page.goto(
                `/atendimento?acao=detalhes&idAtendimento=${item.id}`
            );

            await expect(
                page.locator('.fluxo-etapa.ativa')
            ).toHaveText(item.etapa);

            const inicio = page.locator(
                '.detalhe-card'
            ).filter({
                has: page.getByText(
                    'Início da lavagem',
                    { exact:true }
                ),
            }).locator('strong');

            await expect(inicio).toHaveText(
                /\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}/
            );

            const fim = page.locator(
                '.detalhe-card'
            ).filter({
                has: page.getByText(
                    'Finalização',
                    { exact:true }
                ),
            }).locator('strong');

            if (item.id === 604) {
                await expect(fim).toHaveText(
                    /\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}/
                );
            } else {
                await expect(fim)
                    .toHaveText('Ainda não finalizado');
            }
        });
    }

    test('deve retornar 404 para atendimento inexistente', async ({ page }) => {
        await abrir(page, 'atendimento');

        const resposta = await page.goto(
            '/atendimento?acao=detalhes&idAtendimento=999999'
        );

        expect(resposta!.status()).toBe(404);
    });

    test('deve informar ausencia de agendamentos disponiveis', async ({ page }) => {
        await abrir(page, 'atendimento');

        await page.getByRole('link', {
            name: '+ Novo atendimento',
            exact:true,
        }).click();

        await expect(
            page.locator('.aviso-interno')
        ).toContainText(
            'Não existem agendamentos disponíveis'
        );

        await expect(
            page.locator('#idAgendamento')
        ).toBeDisabled();

        await expect(
            page.locator('.form-interno button[type="submit"]')
        ).toHaveCount(0);
    });

    test('deve oferecer apenas agendamentos sem atendimento', async ({ page }) => {
        await abrir(page, 'atendimento');

        const id = await criarAgendamento(page);

        await page.goto('/atendimento?acao=novo');

        const opcoes = await page.locator(
            '#idAgendamento option'
        ).evaluateAll(es =>
            es.map(e =>
                (e as HTMLOptionElement).value
            )
        );

        expect(opcoes).toEqual(
            ['', String(id)]
        );
    });

    test('deve criar atendimento aguardando', async ({ page }) => {
        await abrir(page, 'atendimento');

        const idAgenda = await criarAgendamento(page);
        const id = await criarAtendimento(page,idAgenda);

        await expect(
            atendimento(page,id)
        ).toBeVisible();

        expect(sql(`
            SELECT status,data_inicio IS NULL,
                   data_fim IS NULL
            FROM atendimento
            WHERE id_atendimento=${id};
        `)).toBe('AGUARDANDO\t1\t1');

        expect(contar('atendimento')).toBe(6);
    });

    test('deve permitir criacao pelo atendente', async ({ page }) => {
        await abrir(page, 'atendimento', true);

        const idAgenda = await criarAgendamento(page);
        const id = await criarAtendimento(page,idAgenda);

        await expect(
            atendimento(page,id)
        ).toBeVisible();

        expect(contar('atendimento')).toBe(6);
    });

    test('deve cancelar formulario sem criar atendimento', async ({ page }) => {
        await abrir(page, 'atendimento');

        const id = await criarAgendamento(page);

        await page.goto('/atendimento?acao=novo');

        await page.locator('#idAgendamento')
            .selectOption(String(id));

        await page.getByRole('link', {
            name: 'Cancelar',
            exact:true,
        }).click();

        await expect(page)
            .toHaveURL(`${BASE}/atendimento`);

        expect(contar('atendimento')).toBe(5);
    });

    test('deve impedir atendimento duplicado', async ({ page }) => {
        await abrir(page, 'atendimento');

        const resposta = await post(
            page,'atendimento',{
                idAgendamento:'501',
            }
        );

        expect(await resposta.text())
            .toContain(
                'Este agendamento já possui um atendimento.'
            );

        expect(contar('atendimento')).toBe(5);
    });

    test('deve rejeitar criacao sem agendamento', async ({ page }) => {
        await abrir(page, 'atendimento');

        const resposta = await post(
            page,'atendimento',{
                idAgendamento:'',
            }
        );

        expect(await resposta.text())
            .toContain('Selecione um agendamento.');

        expect(contar('atendimento')).toBe(5);
    });

    test('deve impedir criacao para agendamento cancelado ou inexistente', async ({ page }) => {
        await abrir(page, 'atendimento');

        for (const id of ['505','999999']) {
            const resposta = await post(
                page,'atendimento',{
                    idAgendamento:id,
                }
            );

            expect(resposta.status())
                .toBeGreaterThanOrEqual(400);

            expect(contar('atendimento')).toBe(5);
        }
    });

    test('deve bloquear inicio sem pagamento no backend', async ({ page }) => {
        await abrir(page, 'atendimento');

        const resposta = await post(
            page,'atendimento',{
                acao:'iniciar',
                idAtendimento:'601',
            }
        );

        expect(await resposta.text())
            .toContain(
                'O atendimento só pode ser iniciado quando estiver AGUARDANDO e o pagamento estiver PAGO.'
            );

        expect(sql(`
            SELECT status,data_inicio IS NULL
            FROM atendimento
            WHERE id_atendimento=601;
        `)).toBe('AGUARDANDO\t1');
    });

    test('deve iniciar lavagem paga pela interface', async ({ page }) => {
        await abrir(page, 'atendimento');

        await atendimento(page,602)
            .getByRole('button', {
                name:'Iniciar',
                exact:true,
            }).click();

        await expect(page)
            .toHaveURL(/\/atendimento\?filtro=emLavagem$/);

        await expect(
            atendimento(page,602)
        ).toBeVisible();

        expect(sql(`
            SELECT status,data_inicio IS NOT NULL,
                   data_fim IS NULL
            FROM atendimento
            WHERE id_atendimento=602;
        `)).toBe('EM_LAVAGEM\t1\t1');
    });

    test('deve impedir reinicio de lavagem', async ({ page }) => {
        await abrir(page, 'atendimento');

        const antes = sql(`
            SELECT data_inicio FROM atendimento
            WHERE id_atendimento=603;
        `);

        const resposta = await post(
            page,'atendimento',{
                acao:'iniciar',
                idAtendimento:'603',
            }
        );

        expect(await resposta.text())
            .toContain(
                'O atendimento só pode ser iniciado'
            );

        expect(sql(`
            SELECT data_inicio FROM atendimento
            WHERE id_atendimento=603;
        `)).toBe(antes);
    });

    test('deve finalizar lavagem e concluir agendamento', async ({ page }) => {
        await abrir(page, 'atendimento');

        await atendimento(page,602)
            .getByRole('button', {
                name:'Iniciar',
                exact:true,
            }).click();

        await atendimento(page,602)
            .getByRole('button', {
                name:'Finalizar',
                exact:true,
            }).click();

        await expect(page)
            .toHaveURL(/\/atendimento\?filtro=finalizados$/);

        await expect(
            atendimento(page,602)
        ).toBeVisible();

        expect(sql(`
            SELECT at.status,a.status,
                   at.data_fim IS NOT NULL,
                   at.data_fim >= at.data_inicio
            FROM atendimento at
            JOIN agendamento a
              ON a.id_agendamento=at.id_agendamento
            WHERE at.id_atendimento=602;
        `)).toBe('FINALIZADO\tCONCLUIDO\t1\t1');
    });

    test('deve impedir finalizacao antes do inicio', async ({ page }) => {
        await abrir(page, 'atendimento');

        const resposta = await post(
            page,'atendimento',{
                acao:'finalizar',
                idAtendimento:'602',
            }
        );

        expect(resposta.status())
            .toBeGreaterThanOrEqual(400);

        expect(sql(`
            SELECT at.status,a.status
            FROM atendimento at
            JOIN agendamento a
              ON a.id_agendamento=at.id_agendamento
            WHERE at.id_atendimento=602;
        `)).toBe('AGUARDANDO\tAGENDADO');
    });

    test('deve preservar finalizacao contra repeticao da operacao', async ({ page }) => {
        await abrir(page, 'atendimento');

        const antes = sql(`
            SELECT data_inicio,data_fim
            FROM atendimento
            WHERE id_atendimento=604;
        `);

        const resposta = await post(
            page,'atendimento',{
                acao:'finalizar',
                idAtendimento:'604',
            }
        );

        expect(resposta.status())
            .toBeGreaterThanOrEqual(400);

        expect(sql(`
            SELECT data_inicio,data_fim
            FROM atendimento
            WHERE id_atendimento=604;
        `)).toBe(antes);
    });

    test('deve permitir iniciar e finalizar pelo atendente', async ({ page }) => {
        await abrir(page, 'atendimento',true);

        await atendimento(page,602)
            .getByRole('button',{
                name:'Iniciar',
                exact:true,
            }).click();

        await atendimento(page,602)
            .getByRole('button',{
                name:'Finalizar',
                exact:true,
            }).click();

        await expect(page)
            .toHaveURL(/filtro=finalizados$/);

        expect(sql(`
            SELECT status FROM atendimento
            WHERE id_atendimento=602;
        `)).toBe('FINALIZADO');
    });

    test('deve atualizar status da lavagem na API mobile', async ({ page, playwright }) => {
        await abrir(page, 'atendimento');

        const api = await playwright.request.newContext({
            baseURL:BASE,
        });

        try {
            await autenticarMobile(api);

            async function validar(status: string) {
                const resposta = await api.get(
                    '/api/agendamentos'
                );

                expect(resposta.status()).toBe(200);

                const dados = await resposta.json();

                expect(dados.agendamentos).toEqual(
                    expect.arrayContaining([
                        expect.objectContaining({
                            idAgendamento:502,
                            status,
                        }),
                    ])
                );
            }

            await atendimento(page,602)
                .getByRole('button',{
                    name:'Iniciar',
                    exact:true,
                }).click();

            await expect(page)
                .toHaveURL(/filtro=emLavagem$/);

            await validar('Em andamento');

            await atendimento(page,602)
                .getByRole('button',{
                    name:'Finalizar',
                    exact:true,
                }).click();

            await expect(page)
                .toHaveURL(/filtro=finalizados$/);

            await validar('Finalizado');

        } finally {
            await api.dispose();
        }
    });
});

// =============================================
// 1.8.9.13 - PAGAMENTOS
// =============================================

test.describe('Pagamentos', () => {

    testarListagem({
        modulo:'pagamento',
        titulo:'Pagamentos | Fast Splash',
        filtros:[
            { nome:'Pendentes',ids:[501] },
            { nome:'Pagos',ids:[502,503,504] },
            { nome:'Cancelados',ids:[505] },
            { nome:'Arquivados',ids:[506] },
        ],
        termo:'TST1A01',
        encontrados:1,
        vazioSql:`
            UPDATE pagamento
            SET arquivado_em=NOW()
            WHERE id_pagamento=705;
        `,
        vazioFiltro:'Cancelados',
    });

    for (const chave of [
        'cliente','agendamento','valor','status',
    ]) {
        test(`deve ordenar pagamentos por ${chave}`, async ({ page }) => {
            await abrir(page,'pagamento');
            await filtro(page,'Pagos');

            await testarOrdenacao(
                page,chave,chave==='valor'
            );
        });
    }

    test('deve apresentar dados do pagamento pendente', async ({ page }) => {
        await abrir(page,'pagamento');

        const registro = agendamento(page,501);

        await expect(registro)
            .toContainText('Cliente Teste Ativo');

        await expect(registro)
            .toContainText('Lavagem Simples Teste');

        await expect(registro)
            .toContainText('Aguardando pagamento');

        await expect(
            registro.locator('.pagamento-forma')
        ).toHaveText('—');

        await expect(
            registro.locator('.status-badge')
        ).toHaveText('PENDENTE');

        expect(moeda(
            await registro.locator('.valor-destaque')
                .innerText()
        )).toBe(50);
    });

    test('deve apresentar formas e datas dos pagamentos realizados', async ({ page }) => {
        await abrir(page,'pagamento');
        await filtro(page,'Pagos');

        for (const [id,forma] of [
            [502,'PIX'],
            [503,'CREDITO'],
            [504,'DEBITO'],
        ] as const) {
            const registro = agendamento(page,id);

            await expect(
                registro.locator('.pagamento-forma')
            ).toHaveText(forma);

            await expect(
                registro.locator('.pagamento-data')
            ).toHaveText(
                /\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}/
            );

            await expect(
                registro.locator('.status-badge')
            ).toHaveText('PAGO');
        }
    });

    test('deve manter valor historico dos pagamentos', async ({ page }) => {
        sql(`
            UPDATE servico
            SET preco=999.99
            WHERE id_servico=302;
        `);

        await abrir(page,'pagamento');
        await filtro(page,'Pagos');

        expect(moeda(
            await agendamento(page,502)
                .locator('.valor-destaque')
                .innerText()
        )).toBe(80);
    });

    test('deve listar pagamento virtual de novo agendamento', async ({ page }) => {
        await abrir(page,'pagamento');

        const id = await criarAgendamento(page);

        await page.goto('/pagamento');

        const registro = agendamento(page,id);

        await expect(registro).toBeVisible();

        await expect(
            registro.locator('.status-badge')
        ).toHaveText('PENDENTE');

        expect(moeda(
            await registro.locator('.valor-destaque')
                .innerText()
        )).toBe(130);

        expect(sql(`
            SELECT COUNT(*) FROM pagamento
            WHERE id_agendamento=${id};
        `)).toBe('0');
    });

    for (const forma of [
        'PIX','DINHEIRO','CREDITO','DEBITO',
    ]) {
        test(`deve refletir pagamento mobile em ${forma}`, async ({ page, playwright }) => {
            await abrir(page,'pagamento');

            const api = await playwright.request.newContext({
                baseURL:BASE,
            });

            try {
                await autenticarMobile(api);

                const resposta = await pagar(
                    api,501,forma
                );

                expect(resposta.status()).toBe(200);

                expect(
                    (await resposta.json()).sucesso
                ).toBe(true);

                await page.reload();

                await expect(
                    agendamento(page,501)
                ).toHaveCount(0);

                await filtro(page,'Pagos');

                const registro = agendamento(page,501);

                await expect(registro).toBeVisible();

                await expect(
                    registro.locator('.pagamento-forma')
                ).toHaveText(forma);

                expect(moeda(
                    await registro.locator(
                        '.valor-destaque'
                    ).innerText()
                )).toBe(50);

                expect(sql(`
                    SELECT status_pagamento,
                           forma_pagamento,valor
                    FROM pagamento
                    WHERE id_agendamento=501;
                `)).toBe(`PAGO\t${forma}\t50.00`);

                expect(contar('pagamento')).toBe(6);

            } finally {
                await api.dispose();
            }
        });
    }

    test('deve impedir pagamento duplicado e preservar registro original', async ({ page, playwright }) => {
        await abrir(page,'pagamento');

        const api = await playwright.request.newContext({
            baseURL:BASE,
        });

        try {
            await autenticarMobile(api);

            const antes = sql(`
                SELECT data_pagamento,valor,forma_pagamento
                FROM pagamento
                WHERE id_pagamento=702;
            `);

            const resposta = await pagar(
                api,502,'DINHEIRO'
            );

            expect(resposta.status()).toBe(404);

            expect(sql(`
                SELECT data_pagamento,valor,forma_pagamento
                FROM pagamento
                WHERE id_pagamento=702;
            `)).toBe(antes);

            expect(contar('pagamento')).toBe(6);

        } finally {
            await api.dispose();
        }
    });

    test('deve impedir pagamento de outro cliente', async ({ page, playwright }) => {
        await abrir(page,'pagamento');

        const api = await playwright.request.newContext({
            baseURL:BASE,
        });

        try {
            await autenticarMobile(
                api,'livre@example.test'
            );

            const resposta = await pagar(api,501);

            expect(resposta.status()).toBe(404);

            expect(sql(`
                SELECT status_pagamento
                FROM pagamento
                WHERE id_pagamento=701;
            `)).toBe('PENDENTE');

        } finally {
            await api.dispose();
        }
    });

    test('deve impedir pagamento cancelado', async ({ page, playwright }) => {
        await abrir(page,'pagamento');

        const api = await playwright.request.newContext({
            baseURL:BASE,
        });

        try {
            await autenticarMobile(api);

            const resposta = await pagar(api,505);

            expect(resposta.status()).toBe(404);

            expect(sql(`
                SELECT status_pagamento
                FROM pagamento
                WHERE id_pagamento=705;
            `)).toBe('CANCELADO');

        } finally {
            await api.dispose();
        }
    });

    test('deve permitir consulta financeira pelo atendente', async ({ page }) => {
        await abrir(page,'pagamento',true);

        await expect(
            agendamento(page,501)
        ).toBeVisible();

        await filtro(page,'Pagos');

        await expect(linhas(page)).toHaveCount(3);

        await expect(
            page.locator('.acoes-tabela button')
        ).toHaveCount(0);

        await filtro(page,'Arquivados');

        await expect(
            agendamento(page,506)
        ).toBeVisible();

        await expect(
            page.locator('.acoes-tabela button')
        ).toHaveCount(0);
    });

    test('deve bloquear operacao financeira Web nao implementada', async ({ page }) => {
        await abrir(page,'pagamento');

        const resposta = await post(
            page,'pagamento',{
                acao:'pagar',
                idPagamento:'701',
            }
        );

        expect(resposta.status()).toBe(400);

        expect(sql(`
            SELECT status_pagamento
            FROM pagamento
            WHERE id_pagamento=701;
        `)).toBe('PENDENTE');
    });
});

// =============================================
// PERMISSOES COMPARTILHADAS
// =============================================

test.describe('Permissoes operacionais', () => {

    const modulos = [
        {
            modulo:'agendamento',
            campo:'idAgendamento',
            ativo:'504',
            arquivado:'506',
            filtro:'concluidos',
        },
        {
            modulo:'atendimento',
            campo:'idAtendimento',
            ativo:'604',
            arquivado:'605',
            filtro:'finalizados',
        },
        {
            modulo:'pagamento',
            campo:'idPagamento',
            ativo:'704',
            arquivado:'706',
            filtro:'pagos',
        },
    ] as const;

    for (const item of modulos) {
        test(`deve restringir arquivamento de ${item.modulo} ao administrador`, async ({ page }) => {
            await abrir(page,item.modulo,true);

            await page.goto(
                `/${item.modulo}?filtro=${item.filtro}`
            );

            await expect(
                page.getByRole('button',{
                    name:'Arquivar',
                    exact:true,
                })
            ).toHaveCount(0);

            await page.goto(
                `/${item.modulo}?filtro=arquivados`
            );

            await expect(
                page.getByRole('button',{
                    name:'Restaurar',
                    exact:true,
                })
            ).toHaveCount(0);

            for (const acao of [
                'arquivar','restaurar',
            ]) {
                const resposta = await post(
                    page,item.modulo,{
                        acao,
                        [item.campo]: acao==='arquivar'
                            ? item.ativo
                            : item.arquivado,
                    }
                );

                expect(resposta.status()).toBe(403);
            }

            expect(sql(`
                SELECT arquivado_em IS NULL
                FROM ${item.modulo}
                WHERE id_${item.modulo}=${item.ativo};
            `)).toBe('1');

            expect(sql(`
                SELECT arquivado_em IS NOT NULL
                FROM ${item.modulo}
                WHERE id_${item.modulo}=${item.arquivado};
            `)).toBe('1');
        });
    }
});

// =============================================
// FLUXO INTEGRADO
// =============================================

test.describe('Integracao operacional e financeira', () => {

    test('deve concluir ciclo completo entre Web mobile e MySQL', async ({ page, playwright }) => {
        await abrir(page,'agendamento',true);

        const idAgenda = await criarAgendamento(page);

        const idAtendimento = await criarAtendimento(
            page,idAgenda
        );

        await expect(
            atendimento(page,idAtendimento)
        ).toContainText('Aguardando pagamento');

        await expect(
            atendimento(page,idAtendimento)
                .getByRole('button',{
                    name:'Iniciar',
                    exact:true,
                })
        ).toHaveCount(0);

        const api = await playwright.request.newContext({
            baseURL:BASE,
        });

        try {
            await autenticarMobile(
                api,'livre@example.test'
            );

            const resposta = await pagar(
                api,idAgenda,'PIX'
            );

            expect(resposta.status()).toBe(200);

            await page.reload();

            await atendimento(page,idAtendimento)
                .getByRole('button',{
                    name:'Iniciar',
                    exact:true,
                }).click();

            await expect(page)
                .toHaveURL(/filtro=emLavagem$/);

            await atendimento(page,idAtendimento)
                .getByRole('button',{
                    name:'Finalizar',
                    exact:true,
                }).click();

            await expect(page)
                .toHaveURL(/filtro=finalizados$/);

            expect(sql(`
                SELECT a.status,at.status,
                       p.status_pagamento,p.valor,
                       p.forma_pagamento,
                       at.data_fim >= at.data_inicio
                FROM agendamento a
                JOIN atendimento at
                  ON at.id_agendamento=a.id_agendamento
                JOIN pagamento p
                  ON p.id_agendamento=a.id_agendamento
                WHERE a.id_agendamento=${idAgenda};
            `)).toBe(
                'CONCLUIDO\tFINALIZADO\tPAGO\t130.00\tPIX\t1'
            );

            await page.goto(
                '/agendamento?filtro=concluidos'
            );

            await expect(
                agendamento(page,idAgenda)
            ).toBeVisible();

            await page.goto(
                '/pagamento?filtro=pagos'
            );

            await expect(
                agendamento(page,idAgenda)
            ).toBeVisible();

            const agenda = await api.get(
                '/api/agendamentos'
            );

            expect(agenda.status()).toBe(200);

            expect(
                (await agenda.json()).agendamentos
            ).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        idAgendamento:idAgenda,
                        status:'Finalizado',
                        valorTotal:130,
                    }),
                ])
            );

            const financeiro = await api.get(
                '/api/pagamentos'
            );

            expect(financeiro.status()).toBe(200);

            expect(
                (await financeiro.json()).pagamentos
            ).toEqual(
                expect.arrayContaining([
                    expect.objectContaining({
                        idAgendamento:idAgenda,
                        statusPagamento:'PAGO',
                        valor:130,
                        formaPagamento:'PIX',
                    }),
                ])
            );

            expect(contar('agendamento')).toBe(7);
            expect(contar('atendimento')).toBe(6);
            expect(contar('pagamento')).toBe(7);

        } finally {
            await api.dispose();
        }
    });
});
