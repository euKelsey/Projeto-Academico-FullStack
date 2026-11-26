import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
    preencherLogin,
    CONTAS_TESTE,
} from '../support/autenticacao';

import {
    executarSqlTeste as sql,
} from '../support/ambiente';

const BASE = 'http://127.0.0.1:8081';
const SENHA = 'SenhaFicticia@123';

type Modulo = 'agendamento' | 'atendimento' | 'pagamento';

const historico = [
    {
        modulo: 'agendamento',
        campo: 'idAgendamento',
        id: 504,
        arquivado: 506,
        pendente: 501,
        filtro: 'concluidos',
        status: 'status',
        valorStatus: 'CONCLUIDO',
    },
    {
        modulo: 'atendimento',
        campo: 'idAtendimento',
        id: 604,
        arquivado: 605,
        pendente: 601,
        filtro: 'finalizados',
        status: 'status',
        valorStatus: 'FINALIZADO',
    },
    {
        modulo: 'pagamento',
        campo: 'idPagamento',
        id: 704,
        arquivado: 706,
        pendente: 701,
        filtro: 'pagos',
        status: 'status_pagamento',
        valorStatus: 'PAGO',
    },
] as const;

function registro(
    page: Page,
    campo: string,
    id: number
) {
    return page.locator(
        '.tabela-interna tbody tr'
    ).filter({
        has: page.locator(
            `input[name="${campo}"][value="${id}"]`
        ),
    });
}

async function confirmar(
    page: Page,
    botao: ReturnType<Page['locator']>,
    aceitar = true
) {
    const evento = page.waitForEvent('dialog')
        .then(async dialog => {

            expect(dialog.type()).toBe('confirm');

            if (aceitar) {
                await dialog.accept();
            } else {
                await dialog.dismiss();
            }
        });

    await Promise.all([
        evento,
        botao.click(),
    ]);
}

async function enviar(
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

function arquivado(
    modulo: Modulo,
    id: number
) {
    return sql(`
        SELECT arquivado_em IS NOT NULL
        FROM ${modulo}
        WHERE id_${modulo}=${id};
    `);
}

function quantidade(modulo: Modulo) {
    return sql(`
        SELECT COUNT(*) FROM ${modulo};
    `);
}

async function validarRedirecionamento(
    page: Page,
    parametro: string,
    valor: string
) {
    await expect.poll(() =>
        new URL(page.url())
            .searchParams.get(parametro)
    ).toBe(valor);
}

// =============================================
// 1.8.9.14 - HISTORICO E ARQUIVAMENTO
// =============================================

test.describe('Historico e arquivamento', () => {

    for (const item of historico) {

        test.describe(item.modulo, () => {

            test('deve arquivar registro pela interface sem exclusao fisica', async ({ page }) => {

                await autenticarAdministrador(page);

                await page.goto(
                    `/${item.modulo}?filtro=${item.filtro}`
                );

                const antes = quantidade(
                    item.modulo
                );

                await confirmar(
                    page,
                    registro(
                        page, item.campo, item.id
                    ).getByRole('button', {
                        name: 'Arquivar',
                        exact: true,
                    })
                );

                await validarRedirecionamento(
                    page, 'status', 'arquivado'
                );

                expect(arquivado(
                    item.modulo, item.id
                )).toBe('1');

                expect(quantidade(
                    item.modulo
                )).toBe(antes);

                await expect(
                    registro(
                        page, item.campo, item.id
                    )
                ).toHaveCount(0);

                await page.goto(
                    `/${item.modulo}?filtro=arquivados`
                );

                await expect(
                    registro(
                        page, item.campo, item.id
                    )
                ).toBeVisible();

            });

            test('deve restaurar registro pela interface', async ({ page }) => {

                await autenticarAdministrador(page);

                await page.goto(
                    `/${item.modulo}?filtro=arquivados`
                );

                const botao = registro(
                    page,
                    item.campo,
                    item.arquivado
                ).getByRole('button', {
                    name: 'Restaurar',
                    exact: true,
                });

                await expect(botao).toBeVisible();

                // Funciona com confirmacao quando
                // existente e com envio direto.

                const tratarDialogo = async (
                    dialog: import('@playwright/test').Dialog
                ) => {
                    await dialog.accept();
                };

                page.on('dialog', tratarDialogo);

                try {
                    await botao.click();

                    await validarRedirecionamento(
                        page, 'status', 'restaurado'
                    );
                } finally {
                    page.off('dialog', tratarDialogo);
                }

                expect(arquivado(
                    item.modulo, item.arquivado
                )).toBe('0');

                await page.goto(
                    `/${item.modulo}?filtro=${item.filtro}`
                );

                await expect(
                    registro(
                        page,
                        item.campo,
                        item.arquivado
                    )
                ).toBeVisible();

            });

            test('deve cancelar confirmacao sem arquivar', async ({ page }) => {

                await autenticarAdministrador(page);

                await page.goto(
                    `/${item.modulo}?filtro=${item.filtro}`
                );

                await confirmar(
                    page,
                    registro(
                        page, item.campo, item.id
                    ).getByRole('button', {
                        name: 'Arquivar',
                        exact: true,
                    }),
                    false
                );

                expect(arquivado(
                    item.modulo, item.id
                )).toBe('0');

                await expect(
                    registro(
                        page, item.campo, item.id
                    )
                ).toBeVisible();

            });

            test('deve bloquear arquivamento de registro pendente', async ({ page }) => {

                await autenticarAdministrador(page);

                const resposta = await enviar(
                    page, item.modulo, {
                        acao: 'arquivar',
                        [item.campo]:
                            String(item.pendente),
                    }
                );

                expect(resposta.status())
                    .toBe(302);

                const destino = new URL(
                    resposta.headers()['location'],
                    BASE
                );

                expect(destino.origin)
                    .toBe(BASE);

                expect(destino.searchParams.get(
                    'erro'
                )).toBe('operacaoInvalida');

                expect(arquivado(
                    item.modulo, item.pendente
                )).toBe('0');

            });

            test('deve rejeitar arquivamento repetido', async ({ page }) => {

                await autenticarAdministrador(page);

                const anterior = sql(`
                    SELECT arquivado_em
                    FROM ${item.modulo}
                    WHERE id_${item.modulo}
                        =${item.arquivado};
                `);

                const resposta = await enviar(
                    page, item.modulo, {
                        acao: 'arquivar',
                        [item.campo]:
                            String(item.arquivado),
                    }
                );

                expect(resposta.status())
                    .toBe(302);

                expect(new URL(
                    resposta.headers()['location'],
                    BASE
                ).searchParams.get('erro'))
                    .toBe('operacaoInvalida');

                expect(sql(`
                    SELECT arquivado_em
                    FROM ${item.modulo}
                    WHERE id_${item.modulo}
                        =${item.arquivado};
                `)).toBe(anterior);

            });

            test('deve rejeitar restauracao de registro nao arquivado', async ({ page }) => {

                await autenticarAdministrador(page);

                const resposta = await enviar(
                    page, item.modulo, {
                        acao: 'restaurar',
                        [item.campo]: String(item.id),
                    }
                );

                expect(resposta.status())
                    .toBe(302);

                expect(new URL(
                    resposta.headers()['location'],
                    BASE
                ).searchParams.get('erro'))
                    .toBe('operacaoInvalida');

                expect(arquivado(
                    item.modulo, item.id
                )).toBe('0');

            });

            test('deve rejeitar identificadores invalidos', async ({ page }) => {

                await autenticarAdministrador(page);

                for (const id of ['abc', '0', '-1']) {

                    const resposta = await enviar(
                        page, item.modulo, {
                            acao: 'arquivar',
                            [item.campo]: id,
                        }
                    );

                    expect(resposta.status())
                        .toBe(400);

                }

            });

            test('deve preservar status original no ciclo de arquivamento', async ({ page }) => {

                await autenticarAdministrador(page);

                for (const acao of [
                    'arquivar', 'restaurar',
                ]) {

                    const resposta = await enviar(
                        page, item.modulo, {
                            acao,
                            [item.campo]:
                                String(item.id),
                        }
                    );

                    expect(resposta.status())
                        .toBe(302);

                    expect(new URL(
                        resposta.headers()['location'],
                        BASE
                    ).searchParams.get('status'))
                        .toBe(
                            acao === 'arquivar'
                                ? 'arquivado'
                                : 'restaurado'
                        );

                    expect(sql(`
                        SELECT ${item.status}
                        FROM ${item.modulo}
                        WHERE id_${item.modulo}
                            =${item.id};
                    `)).toBe(item.valorStatus);

                }

                expect(arquivado(
                    item.modulo, item.id
                )).toBe('0');

            });

        });

    }

    test('deve arquivar e restaurar agendamento cancelado', async ({ page }) => {

        await autenticarAdministrador(page);

        await page.goto(
            '/agendamento?filtro=cancelados'
        );

        await confirmar(
            page,
            registro(
                page, 'idAgendamento', 505
            ).getByRole('button', {
                name: 'Arquivar',
                exact: true,
            })
        );

        await validarRedirecionamento(
            page, 'status', 'arquivado'
        );

        expect(arquivado(
            'agendamento', 505
        )).toBe('1');

        const resposta = await enviar(
            page, 'agendamento', {
                acao: 'restaurar',
                idAgendamento: '505',
                filtro: 'arquivados',
            }
        );

        expect(resposta.status()).toBe(302);

        expect(arquivado(
            'agendamento', 505
        )).toBe('0');

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=505;
        `)).toBe('CANCELADO');

    });

    test('deve arquivar e restaurar pagamento cancelado', async ({ page }) => {

        await autenticarAdministrador(page);

        await page.goto(
            '/pagamento?filtro=cancelados'
        );

        await confirmar(
            page,
            registro(
                page, 'idPagamento', 705
            ).getByRole('button', {
                name: 'Arquivar',
                exact: true,
            })
        );

        await validarRedirecionamento(
            page, 'status', 'arquivado'
        );

        expect(arquivado(
            'pagamento', 705
        )).toBe('1');

        const resposta = await enviar(
            page, 'pagamento', {
                acao: 'restaurar',
                idPagamento: '705',
                filtro: 'arquivados',
            }
        );

        expect(resposta.status()).toBe(302);

        expect(arquivado(
            'pagamento', 705
        )).toBe('0');

        expect(sql(`
            SELECT status_pagamento, valor
            FROM pagamento
            WHERE id_pagamento=705;
        `)).toBe('CANCELADO\t50.00');

    });

    test('deve bloquear arquivamento de agendamento com atendimento pendente', async ({ page }) => {

        sql(`
            UPDATE agendamento
            SET status='CANCELADO'
            WHERE id_agendamento=501;
        `);

        await autenticarAdministrador(page);

        const resposta = await enviar(
            page, 'agendamento', {
                acao: 'arquivar',
                idAgendamento: '501',
                filtro: 'cancelados',
            }
        );

        expect(resposta.status()).toBe(302);

        expect(new URL(
            resposta.headers()['location'],
            BASE
        ).searchParams.get('erro'))
            .toBe('operacaoInvalida');

        expect(arquivado(
            'agendamento', 501
        )).toBe('0');

    });

    test('deve preservar historico completo apos arquivamentos independentes', async ({ page }) => {

        await autenticarAdministrador(page);

        const consulta = `
            SELECT
                a.id_agendamento,
                a.status,
                at.id_atendimento,
                at.status,
                at.data_inicio,
                at.data_fim,
                p.id_pagamento,
                p.valor,
                p.forma_pagamento,
                p.status_pagamento,
                p.data_pagamento,
                v.id_cliente
            FROM agendamento a
            JOIN atendimento at
                ON at.id_agendamento=a.id_agendamento
            JOIN pagamento p
                ON p.id_agendamento=a.id_agendamento
            JOIN veiculo v
                ON v.id_veiculo=a.id_veiculo
            WHERE a.id_agendamento=504;
        `;

        const anterior = sql(consulta);

        const servicos = sql(`
            SELECT id_servico,valor_praticado
            FROM agendamento_servico
            WHERE id_agendamento=504
            ORDER BY id_servico;
        `);

        const colaboradores = sql(`
            SELECT id_colaborador
            FROM colaborador_atendimento
            WHERE id_atendimento=604
            ORDER BY id_colaborador;
        `);

        for (const item of historico) {

            const resposta = await enviar(
                page, item.modulo, {
                    acao: 'arquivar',
                    [item.campo]: String(item.id),
                    filtro: item.filtro,
                }
            );

            expect(resposta.status()).toBe(302);

            expect(arquivado(
                item.modulo, item.id
            )).toBe('1');

        }

        expect(sql(consulta)).toBe(anterior);

        expect(sql(`
            SELECT id_servico,valor_praticado
            FROM agendamento_servico
            WHERE id_agendamento=504
            ORDER BY id_servico;
        `)).toBe(servicos);

        expect(sql(`
            SELECT id_colaborador
            FROM colaborador_atendimento
            WHERE id_atendimento=604
            ORDER BY id_colaborador;
        `)).toBe(colaboradores);

        expect(quantidade('agendamento'))
            .toBe('6');

        expect(quantidade('atendimento'))
            .toBe('5');

        expect(quantidade('pagamento'))
            .toBe('6');

    });

    test('deve preservar indicadores historicos do dashboard', async ({ page }) => {

        await autenticarAdministrador(page);

        const antes = await page.locator(
            '.fs-grafico-coluna strong'
        ).allTextContents();

        const atendimentos = await page.locator(
            '.fs-total-atendimentos strong'
        ).innerText();

        for (const item of historico) {

            await enviar(
                page, item.modulo, {
                    acao: 'arquivar',
                    [item.campo]: String(item.id),
                }
            );

            expect(arquivado(
                item.modulo, item.id
            )).toBe('1');

        }

        await page.goto('/dashboard');

        expect(await page.locator(
            '.fs-grafico-coluna strong'
        ).allTextContents()).toEqual(antes);

        await expect(
            page.locator(
                '.fs-total-atendimentos strong'
            )
        ).toHaveText(atendimentos);

    });

});

// =============================================
// 1.8.9.15 - SEGURANCA E INTEGRACAO
// =============================================

test.describe('Seguranca integrada', () => {

    const rotasProtegidas = [
        '/dashboard',
        '/cliente',
        '/veiculo',
        '/servico',
        '/colaborador',
        '/agendamento',
        '/atendimento',
        '/pagamento',
        '/cadastro-cliente.jsp',
        '/cadastro-veiculo.jsp',
        '/cadastro-servico.jsp',
        '/cadastro-colaborador.jsp',
        '/cadastro-agendamento.jsp',
        '/cadastro-atendimento.jsp',
        '/editar-cliente.jsp',
        '/editar-veiculo.jsp',
        '/editar-servico.jsp',
        '/editar-colaborador.jsp',
        '/lista-clientes.jsp',
        '/lista-veiculos.jsp',
        '/lista-servicos.jsp',
        '/lista-colaboradores.jsp',
        '/lista-agendamentos.jsp',
        '/lista-atendimentos.jsp',
        '/lista-pagamentos.jsp',
        '/detalhes-atendimento.jsp',
    ];

    test('deve proteger todas as rotas administrativas sem sessao', async ({ request }) => {

        for (const rota of rotasProtegidas) {

            const resposta = await request.get(
                rota, { maxRedirects: 0 }
            );

            expect(
                resposta.status(), rota
            ).toBe(302);

            expect(new URL(
                resposta.headers()['location'],
                BASE
            ).pathname).toBe('/login');

        }

    });

    test('deve impedir POST administrativo sem autenticacao', async ({ request }) => {

        const operacoes = [
            ['/cliente', {
                acao: 'excluir',
                idCliente: '102',
            }],
            ['/veiculo', {
                acao: 'excluir',
                idVeiculo: '203',
            }],
            ['/servico', {
                acao: 'inativar',
                idServico: '301',
            }],
            ['/colaborador', {
                acao: 'inativar',
                idColaborador: '402',
            }],
            ['/agendamento', {
                acao: 'cancelar',
                idAgendamento: '501',
            }],
            ['/atendimento', {
                acao: 'iniciar',
                idAtendimento: '602',
            }],
            ['/pagamento', {
                acao: 'arquivar',
                idPagamento: '704',
            }],
        ] as const;

        for (const [rota, form] of operacoes) {

            const resposta = await request.post(
                rota, {
                    form,
                    maxRedirects: 0,
                }
            );

            expect(
                resposta.status(), rota
            ).toBe(302);

            expect(new URL(
                resposta.headers()['location'],
                BASE
            ).pathname).toBe('/login');

        }

        expect(sql(`
            SELECT ativo FROM cliente
            WHERE id_cliente=102;
        `)).toBe('1');

        expect(sql(`
            SELECT ativo FROM veiculo
            WHERE id_veiculo=203;
        `)).toBe('1');

        expect(sql(`
            SELECT ativo FROM servico
            WHERE id_servico=301;
        `)).toBe('1');

        expect(sql(`
            SELECT ativo FROM colaborador
            WHERE id_colaborador=402;
        `)).toBe('1');

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=501;
        `)).toBe('AGENDADO');

        expect(sql(`
            SELECT status FROM atendimento
            WHERE id_atendimento=602;
        `)).toBe('AGUARDANDO');

        expect(arquivado(
            'pagamento', 704
        )).toBe('0');

    });

    test('deve impedir atendente de abrir JSP administrativo restrito', async ({ page }) => {

        await autenticarAtendente(page);

        for (const rota of [
            '/servico',
            '/lista-servicos.jsp',
            '/cadastro-servico.jsp',
            '/editar-servico.jsp',
            '/colaborador',
            '/lista-colaboradores.jsp',
            '/cadastro-colaborador.jsp',
            '/editar-colaborador.jsp',
        ]) {

            const resposta =
                await page.request.get(
                    rota, { maxRedirects: 0 }
                );

            expect(
                resposta.status(), rota
            ).toBe(403);

        }

    });

    test('deve impedir acesso direto ao componente WEB-INF', async ({ page }) => {

        await autenticarAdministrador(page);

        const resposta = await page.request.get(
            '/WEB-INF/includes/menu-lateral.jsp',
            { maxRedirects: 0 }
        );

        expect(resposta.status()).toBe(404);

    });

    test('deve impedir sessao mobile de acessar area administrativa', async ({ request }) => {

        const login = await request.post(
            '/api/auth/login', {
                form: {
                    email: 'ativo@example.test',
                    senha: SENHA,
                },
                maxRedirects: 0,
            }
        );

        expect(login.status()).toBe(200);

        for (const rota of [
            '/dashboard',
            '/cliente',
            '/colaborador',
            '/pagamento',
        ]) {

            const resposta = await request.get(
                rota, { maxRedirects: 0 }
            );

            expect(resposta.status()).toBe(302);

            expect(new URL(
                resposta.headers()['location'],
                BASE
            ).pathname).toBe('/login');

        }

    });

    test('deve impedir sessao administrativa de acessar API privada do cliente', async ({ page }) => {

        await autenticarAdministrador(page);

        for (const rota of [
            '/api/clientes/me',
            '/api/veiculos',
            '/api/agendamentos',
            '/api/pagamentos',
            '/api/servicos',
        ]) {

            const resposta =
                await page.request.get(
                    rota, { maxRedirects: 0 }
                );

            expect(
                resposta.status(), rota
            ).toBe(401);

            expect(
                (await resposta.json()).sucesso
            ).toBe(false);

        }

    });

    for (const rota of [
        '/api/clientes/me',
        '/api/veiculos',
        '/api/agendamentos',
        '/api/pagamentos',
    ]) {

        test(`deve revogar sessao mobile em ${rota}`, async ({ page, playwright }) => {

            await autenticarAdministrador(page);

            const api =
                await playwright.request.newContext({
                    baseURL: BASE,
                });

            try {

                const login = await api.post(
                    '/api/auth/login', {
                        form: {
                            email: 'livre@example.test',
                            senha: SENHA,
                        },
                    }
                );

                expect(login.status()).toBe(200);

                const alteracao = await page.request.post(
                    '/cliente', {
                        form: {
                            acao: 'inativar',
                            idCliente: '102',
                            filtro: 'ativos',
                        },
                        maxRedirects: 0,
                    }
                );

                expect(alteracao.status())
                    .toBe(302);

                expect(sql(`
                    SELECT ativo FROM cliente
                    WHERE id_cliente=102;
                `)).toBe('0');

                const resposta = await api.get(
                    rota, { maxRedirects: 0 }
                );

                expect(resposta.status())
                    .toBe(403);

                expect(
                    (await resposta.json()).sucesso
                ).toBe(false);

                const segunda = await api.get(
                    '/api/clientes/me',
                    { maxRedirects: 0 }
                );

                expect(segunda.status())
                    .toBe(401);

            } finally {
                await api.dispose();
            }

        });

    }

    test('deve proteger dados entre duas sessoes independentes de clientes', async ({ playwright }) => {

        const clienteA =
            await playwright.request.newContext({
                baseURL: BASE,
            });

        const clienteB =
            await playwright.request.newContext({
                baseURL: BASE,
            });

        try {

            for (const [api, email] of [
                [clienteA, 'ativo@example.test'],
                [clienteB, 'livre@example.test'],
            ] as const) {

                const login = await api.post(
                    '/api/auth/login', {
                        form: { email, senha: SENHA },
                    }
                );

                expect(login.status()).toBe(200);

            }

            const a = await clienteA.get(
                '/api/veiculos'
            );

            const b = await clienteB.get(
                '/api/veiculos'
            );

            expect(a.status()).toBe(200);
            expect(b.status()).toBe(200);

            const veiculosA =
                (await a.json()).veiculos;

            const veiculosB =
                (await b.json()).veiculos;

            expect(veiculosA.map(
                (v: { idVeiculo: number }) =>
                    v.idVeiculo
            ).sort()).toEqual([201, 202]);

            expect(veiculosB.map(
                (v: { idVeiculo: number }) =>
                    v.idVeiculo
            )).toEqual([203]);

            const tentativa = await clienteB.post(
                '/api/veiculos/excluir', {
                    form: { idVeiculo: '201' },
                    maxRedirects: 0,
                }
            );

            expect(tentativa.status())
                .toBe(404);

            expect(sql(`
                SELECT ativo FROM veiculo
                WHERE id_veiculo=201;
            `)).toBe('1');

        } finally {

            await clienteA.dispose();
            await clienteB.dispose();

        }

    });

    test('deve impedir cliente de pagar ou cancelar agendamento de terceiro', async ({ request }) => {

        const login = await request.post(
            '/api/auth/login', {
                form: {
                    email: 'livre@example.test',
                    senha: SENHA,
                },
            }
        );

        expect(login.status()).toBe(200);

        const pagar = await request.post(
            '/api/pagamentos/pagar', {
                form: {
                    idAgendamento: '501',
                    formaPagamento: 'PIX',
                },
            }
        );

        expect(pagar.status()).toBe(404);

        const cancelar = await request.post(
            '/api/agendamentos/cancelar', {
                form: {
                    idAgendamento: '501',
                },
            }
        );

        expect(cancelar.status()).toBe(409);

        expect(sql(`
            SELECT status FROM agendamento
            WHERE id_agendamento=501;
        `)).toBe('AGENDADO');

        expect(sql(`
            SELECT status_pagamento
            FROM pagamento
            WHERE id_pagamento=701;
        `)).toBe('PENDENTE');

    });

    test('deve preservar identificacao do cliente contra manipulacao de parametros', async ({ request }) => {

        const login = await request.post(
            '/api/auth/login', {
                form: {
                    email: 'livre@example.test',
                    senha: SENHA,
                },
            }
        );

        expect(login.status()).toBe(200);

        const resposta = await request.post(
            '/api/clientes/me', {
                form: {
                    idCliente: '101',
                    nome: 'CLIENTE LIVRE ATUALIZADO',
                    telefone: '11900000102',
                    email: 'livre@example.test',
                },
            }
        );

        expect(resposta.status()).toBe(200);

        expect(
            (await resposta.json()).cliente.idCliente
        ).toBe(102);

        expect(sql(`
            SELECT nome FROM cliente
            WHERE id_cliente=101;
        `)).toBe('Cliente Teste Ativo');

        expect(sql(`
            SELECT nome FROM cliente
            WHERE id_cliente=102;
        `)).toBe('CLIENTE LIVRE ATUALIZADO');

    });

    test('deve rejeitar tentativa de injecao SQL no login', async ({ request }) => {

        const resposta = await request.post(
            '/api/auth/login', {
                form: {
                    email: "' OR '1'='1",
                    senha: SENHA,
                },
                maxRedirects: 0,
            }
        );

        expect(resposta.status()).toBe(401);

        expect(
            (await resposta.json()).sucesso
        ).toBe(false);

        expect(sql(`
            SELECT COUNT(*) FROM cliente;
        `)).toBe('4');

    });

    test('deve omitir hashes de senhas nas respostas da API', async ({ request }) => {

        const login = await request.post(
            '/api/auth/login', {
                form: {
                    email: 'ativo@example.test',
                    senha: SENHA,
                },
            }
        );

        expect(login.status()).toBe(200);

        const respostas = [
            login,
            await request.get('/api/clientes/me'),
            await request.get('/api/veiculos'),
            await request.get('/api/agendamentos'),
            await request.get('/api/pagamentos'),
        ];

        for (const resposta of respostas) {

            expect(resposta.status()).toBe(200);

            const texto = await resposta.text();

            expect(texto).not.toMatch(
                /senha_hash|senhaHash|pbkdf2\$/i
            );

            expect(texto).not.toContain(SENHA);

        }

    });

    test('deve preservar integridade em pagamento simultaneo', async ({ playwright }) => {

        const a =
            await playwright.request.newContext({
                baseURL: BASE,
            });

        const b =
            await playwright.request.newContext({
                baseURL: BASE,
            });

        try {

            for (const api of [a, b]) {

                const login = await api.post(
                    '/api/auth/login', {
                        form: {
                            email: 'ativo@example.test',
                            senha: SENHA,
                        },
                    }
                );

                expect(login.status()).toBe(200);

            }

            const resultados = await Promise.all([
                a.post('/api/pagamentos/pagar', {
                    form: {
                        idAgendamento: '501',
                        formaPagamento: 'PIX',
                    },
                }),
                b.post('/api/pagamentos/pagar', {
                    form: {
                        idAgendamento: '501',
                        formaPagamento: 'DEBITO',
                    },
                }),
            ]);

            expect(resultados.map(
                resposta => resposta.status()
            ).sort()).toEqual([200, 404]);

            expect(sql(`
                SELECT COUNT(*),SUM(valor)
                FROM pagamento
                WHERE id_agendamento=501
                  AND status_pagamento='PAGO';
            `)).toBe('1\t50.00');

        } finally {

            await a.dispose();
            await b.dispose();

        }

    });

});

// =============================================
// 1.8.9.16 - RESPONSIVIDADE
// =============================================

async function colunas(
    page: Page,
    seletor: string,
    esperado: number
) {
    const elemento = page.locator(seletor);

    await expect(elemento).toBeVisible();

    await expect.poll(async () =>
        elemento.evaluate(el => {
            const estilo = getComputedStyle(el);

            return estilo.gridTemplateColumns
                .trim()
                .split(/\s+/)
                .length;
        })
    ).toBe(esperado);
}

async function dentroDaTela(
    page: Page,
    seletor: string
) {
    const elemento = page.locator(seletor);

    await expect(elemento).toBeVisible();

    const caixa = await elemento.boundingBox();

    expect(caixa).not.toBeNull();

    const largura = page.viewportSize()!.width;

    expect(caixa!.x)
        .toBeGreaterThanOrEqual(-2);

    expect(caixa!.x + caixa!.width)
        .toBeLessThanOrEqual(largura + 2);
}

async function semRolagemGlobal(page: Page) {

    const medidas = await page.evaluate(() => ({
        largura: document.documentElement.clientWidth,
        conteudo: document.documentElement.scrollWidth,
    }));

    expect(medidas.conteudo)
        .toBeLessThanOrEqual(
            medidas.largura + 2
        );
}

async function loginResponsivo(
    page: Page,
    largura: number,
    altura: number,
    atendente = false
) {
    await page.setViewportSize({
        width: largura,
        height: altura,
    });

    const conta = atendente
        ? CONTAS_TESTE.atendente
        : CONTAS_TESTE.administrador;

    await preencherLogin(
        page,
        conta.email,
        conta.senha
    );

    await expect(page)
        .toHaveURL(/\/dashboard$/);
}

test.describe('Responsividade', () => {

    const telas = [
        {
            nome: 'Desktop Full HD',
            largura: 1920,
            altura: 1080,
            indicadores: 4,
            graficos: 2,
        },
        {
            nome: 'Notebook HD',
            largura: 1366,
            altura: 768,
            indicadores: 4,
            graficos: 2,
        },
        {
            nome: 'Notebook compacto',
            largura: 1024,
            altura: 768,
            indicadores: 2,
            graficos: 1,
        },
        {
            nome: 'Tablet',
            largura: 768,
            altura: 1024,
            indicadores: 2,
            graficos: 1,
        },
        {
            nome: 'Celular',
            largura: 390,
            altura: 844,
            indicadores: 1,
            graficos: 1,
        },
    ];

    for (const tela of telas) {

        test(`deve adaptar dashboard em ${tela.nome}`, async ({ page }) => {

            await loginResponsivo(
                page,
                tela.largura,
                tela.altura
            );

            await colunas(
                page,
                '.fs-indicadores',
                tela.indicadores
            );

            await colunas(
                page,
                '.fs-graficos',
                tela.graficos
            );

            await expect(
                page.locator('.fs-indicador')
            ).toHaveCount(8);

            await dentroDaTela(
                page,
                '.fs-indicadores'
            );

            await dentroDaTela(
                page,
                '.fs-graficos'
            );

            await semRolagemGlobal(page);

        });

        test(`deve adaptar pagina inicial em ${tela.nome}`, async ({ page }) => {

            await page.setViewportSize({
                width: tela.largura,
                height: tela.altura,
            });

            await page.goto('/');

            await colunas(
                page, '.hero-conteudo',
                tela.largura > 900 ? 2 : 1
            );

            await colunas(
                page, '.grade-servicos',
                tela.largura > 900 ? 3 : 1
            );

            await colunas(
                page, '.grade-beneficios',
                tela.largura > 900 ? 2 : 1
            );

            await colunas(
                page, '.app-conteudo',
                tela.largura > 900 ? 2 : 1
            );

            await dentroDaTela(
                page, '.menu-cadastro'
            );

            await dentroDaTela(
                page, '.hero-banner'
            );

            await semRolagemGlobal(page);

        });

        test(`deve adaptar login em ${tela.nome}`, async ({ page }) => {

            await page.setViewportSize({
                width: tela.largura,
                height: tela.altura,
            });

            await page.goto('/login');

            await colunas(
                page, '.login-layout',
                tela.largura > 900 ? 2 : 1
            );

            await dentroDaTela(
                page, '.login-card'
            );

            await dentroDaTela(page, '#email');
            await dentroDaTela(page, '#senha');

            await semRolagemGlobal(page);

        });

        test(`deve adaptar cadastro publico em ${tela.nome}`, async ({ page }) => {

            await page.setViewportSize({
                width: tela.largura,
                height: tela.altura,
            });

            await page.goto('/cadastro.jsp');

            await colunas(
                page, '.cadastro-layout',
                tela.largura > 900 ? 2 : 1
            );

            await colunas(
                page, '#formCadastro',
                tela.largura > 560 ? 2 : 1
            );

            await dentroDaTela(
                page, '.cadastro-card'
            );

            await dentroDaTela(
                page, '#botaoCadastrar'
            );

            await semRolagemGlobal(page);

        });

    }

    const listagens = [
        'cliente',
        'veiculo',
        'servico',
        'colaborador',
        'agendamento',
        'atendimento',
        'pagamento',
    ];

    for (const modulo of listagens) {

        test(`deve permitir rolagem da tabela mobile de ${modulo}`, async ({ page }) => {

            await loginResponsivo(
                page, 390, 844
            );

            await page.goto(`/${modulo}`);

            const tabela = page.locator(
                '.tabela-responsiva'
            );

            await expect(tabela).toBeVisible();

            await expect(tabela)
                .toHaveCSS('overflow-x', 'auto');

            await dentroDaTela(
                page, '.tabela-responsiva'
            );

            const medidas = await tabela.evaluate(
                elemento => ({
                    largura: elemento.clientWidth,
                    conteudo: elemento.scrollWidth,
                })
            );

            expect(medidas.conteudo)
                .toBeGreaterThan(medidas.largura);

            await tabela.evaluate(elemento => {
                elemento.scrollLeft =
                    elemento.scrollWidth;
            });

            await expect.poll(() =>
                tabela.evaluate(
                    elemento => elemento.scrollLeft
                )
            ).toBeGreaterThan(0);

            await semRolagemGlobal(page);

        });

    }

    const formularios = [
        '/cadastro-cliente.jsp',
        '/veiculo?acao=novo',
        '/servico?acao=novo',
        '/colaborador?acao=novo',
        '/agendamento?acao=novo',
        '/cliente?acao=editar&idCliente=102',
        '/veiculo?acao=editar&idVeiculo=203',
        '/servico?acao=editar&idServico=301',
        '/colaborador?acao=editar&idColaborador=402',
    ];

    for (const rota of formularios) {

        test(`deve adaptar formulario mobile ${rota}`, async ({ page }) => {

            await loginResponsivo(
                page, 390, 844
            );

            await page.goto(rota);

            await colunas(
                page, '.form-interno', 1
            );

            await dentroDaTela(
                page, '.form-interno-card'
            );

            await expect(
                page.locator('.form-interno-acoes')
            ).toHaveCSS(
                'flex-direction', 'column-reverse'
            );

            await semRolagemGlobal(page);

        });

    }

    for (const largura of [760, 761]) {

        test(`deve respeitar limite responsivo de ${largura}px`, async ({ page }) => {

            await loginResponsivo(
                page, largura, 900
            );

            await page.goto(
                '/cadastro-cliente.jsp'
            );

            await colunas(
                page,
                '.form-interno',
                largura <= 760 ? 1 : 2
            );

            await expect(
                page.locator('#fsMenu')
            ).toHaveCSS(
                'position',
                largura <= 760
                    ? 'relative'
                    : 'fixed'
            );

        });

    }

    for (const largura of [390, 1366]) {

        test(`deve adaptar selecao de servicos em ${largura}px`, async ({ page }) => {

            await loginResponsivo(
                page, largura, 900
            );

            await page.goto(
                '/agendamento?acao=novo'
            );

            await colunas(
                page, '.servicos-grid',
                largura <= 760 ? 1 : 2
            );

            await expect(
                page.locator('.resumo-agendamento')
            ).toHaveCSS(
                'flex-direction',
                largura <= 760 ? 'column' : 'row'
            );

        });

        test(`deve adaptar detalhes de atendimento em ${largura}px`, async ({ page }) => {

            await loginResponsivo(
                page, largura, 900
            );

            await page.goto(
                '/atendimento?acao=detalhes&idAtendimento=604'
            );

            await colunas(
                page,
                '.atendimento-detalhes-grid',
                largura <= 760 ? 1 : 2
            );

            await dentroDaTela(
                page, '.atendimento-detalhes-grid'
            );

            await semRolagemGlobal(page);

        });

    }

    test('deve permitir navegacao administrativa em celular', async ({ page }) => {

        await loginResponsivo(
            page, 390, 844
        );

        await page.locator('#fsMenuToggle')
            .click();

        await expect(
            page.locator('#fsMenuNav')
        ).toBeVisible();

        for (const [nome, rota] of [
            ['Clientes', 'cliente'],
            ['Veículos', 'veiculo'],
            ['Serviços', 'servico'],
            ['Colaboradores', 'colaborador'],
            ['Agendamentos', 'agendamento'],
            ['Atendimentos', 'atendimento'],
            ['Pagamentos', 'pagamento'],
            ['Dashboard', 'dashboard'],
        ]) {

            await page.locator('#fsMenuNav')
                .getByRole('link', {
                    name: nome,
                    exact: true,
                }).click();

            await expect(page).toHaveURL(
                `${BASE}/${rota}`
            );

            await expect(
                page.locator(
                    '#fsMenuNav [aria-current="page"]'
                )
            ).toHaveAttribute(
                'aria-label', nome
            );

        }

    });

    test('deve manter restricoes do atendente em celular', async ({ page }) => {

        await loginResponsivo(
            page, 390, 844, true
        );

        await page.locator('#fsMenuToggle')
            .click();

        await expect(
            page.locator(
                '#fsMenuNav .fs-menu-item'
            )
        ).toHaveCount(6);

        for (const nome of [
            'Serviços', 'Colaboradores',
        ]) {

            await expect(
                page.locator('#fsMenuNav')
                    .getByRole('link', {
                        name: nome,
                        exact: true,
                    })
            ).toHaveCount(0);

        }

        await expect(
            page.locator('.fs-indicador')
        ).toHaveCount(6);

    });

    test('deve permitir preencher cadastro publico em celular', async ({ page }) => {

        await page.setViewportSize({
            width: 390,
            height: 844,
        });

        await page.goto('/');

        await page.locator('.menu-cadastro')
            .click();

        const dados = {
            nome: 'Cliente Responsivo Teste',
            cpf: '98765410564',
            telefone: '11900000105',
            email: 'responsivo@example.test',
            senha: SENHA,
            confirmarSenha: SENHA,
        };

        for (const [campo, valor] of
            Object.entries(dados)) {

            await page.locator(`#${campo}`)
                .fill(valor);

        }

        await page.locator('#botaoCadastrar')
            .click();

        await expect(
            page.locator('#mensagemFormulario')
        ).toHaveClass(/\bsucesso\b/);

        expect(sql(`
            SELECT COUNT(*) FROM cliente
            WHERE email='responsivo@example.test';
        `)).toBe('1');

    });

    test('deve carregar paginas administrativas sem erros de recursos', async ({ page }) => {

        await autenticarAdministrador(page);

        const erros: string[] = [];

        page.on('pageerror', erro => {
            erros.push(erro.message);
        });

        page.on('response', resposta => {

            const url = new URL(resposta.url());

            if (
                url.origin === BASE
                && resposta.status() >= 400
                && /\.(css|js|png|jpg|jpeg|webp|svg)$/i
                    .test(url.pathname)
            ) {
                erros.push(
                    `${resposta.status()} ${url.pathname}`
                );
            }

        });

        for (const rota of [
            '/dashboard',
            ...listagens.map(m => `/${m}`),
        ]) {

            const resposta = await page.goto(rota);

            expect(resposta!.status())
                .toBe(200);

            await expect(
                page.locator('#fsMenu')
            ).toBeVisible();

        }

        expect(erros).toEqual([]);

    });

});
