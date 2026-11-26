import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    autenticarAdministrador,
    autenticarAtendente,
} from '../support/autenticacao';

import {
    executarSqlTeste,
} from '../support/ambiente';

function indicador(page: Page, nome: string) {

    return page.locator('.fs-indicador').filter({
        has: page.getByText(nome, {
            exact: true,
        }),
    });

}

async function validarIndicador(
    page: Page,
    nome: string,
    valor: string
): Promise<void> {

    const card = indicador(page, nome);

    await expect(card).toBeVisible();

    await expect(
        card.locator('strong')
    ).toHaveText(valor);

}

function formatarMoeda(valor: number): string {

    return new Intl.NumberFormat('pt-BR', {

        style: 'currency',
        currency: 'BRL',

    }).format(valor);

}

function converterMoeda(texto: string): number {

    return Number(
        texto
            .replace(/[^\d,.-]/g, '')
            .replace(/\./g, '')
            .replace(',', '.')
    );

}

function faturamentoEsperado(): number {

    const dia = Number(
        executarSqlTeste(
            'SELECT DAY(CURDATE());'
        )
    );

    let valor = 160;

    if (dia > 2) valor += 90;

    if (dia > 20) valor += 100;

    return valor;

}

async function atualizarDashboard(
    page: Page
): Promise<void> {

    await page.getByRole('link', {
        name: /Atualizar dados/,
    }).click();

    await expect(page)
        .toHaveURL(/\/dashboard$/);

}

async function valoresHistorico(
    page: Page
): Promise<number[]> {

    const textos = await page.locator(
        '.fs-grafico-coluna strong'
    ).allTextContents();

    return textos.map(converterMoeda);

}

test.describe('Painel administrativo e dashboard', () => {

    // =========================================
    // IDENTIDADE E PERMISSOES - 2 TESTES
    // =========================================

    test('deve apresentar dashboard do administrador', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await expect(page)
            .toHaveTitle('Dashboard | Fast Splash');

        await expect(
            page.locator('h1')
        ).toHaveText('Visão geral');

        await expect(
            page.locator('.fs-dashboard-cabecalho')
        ).toContainText(
            'Olá, Administrador Teste.'
        );

        await expect(
            page.locator('.fs-indicador')
        ).toHaveCount(8);

        await expect(
            page.locator('#fsMenuNav')
                .getByRole('link', {
                    name: 'Dashboard',
                    exact: true,
                })
        ).toHaveAttribute(
            'aria-current',
            'page'
        );

    });

    test('deve apresentar dashboard do atendente sem indicadores restritos', async ({
        page,
    }) => {

        await autenticarAtendente(page);

        await expect(
            page.locator('.fs-dashboard-cabecalho')
        ).toContainText(
            'Olá, Atendente Teste.'
        );

        await expect(
            page.locator('.fs-indicador')
        ).toHaveCount(6);

        await expect(
            indicador(page, 'Serviços ativos')
        ).toHaveCount(0);

        await expect(
            indicador(page, 'Colaboradores ativos')
        ).toHaveCount(0);

        await expect(
            page.locator('.fs-grafico-coluna')
        ).toHaveCount(6);

    });

    // =========================================
    // INDICADORES PRINCIPAIS - 8 TESTES
    // =========================================

    const indicadores = [

        {
            nome: 'Faturamento mensal',
            valor: () => formatarMoeda(
                faturamentoEsperado()
            ),
        },

        {
            nome: 'Valores a receber',
            valor: () => formatarMoeda(50),
        },

        {
            nome: 'Agendamentos de hoje',
            valor: () => '1',
        },

        {
            nome: 'Lavagens em andamento',
            valor: () => '1',
        },

        {
            nome: 'Clientes ativos',
            valor: () => '2',
        },

        {
            nome: 'Veículos disponíveis',
            valor: () => '3',
        },

        {
            nome: 'Serviços ativos',
            valor: () => '2',
        },

        {
            nome: 'Colaboradores ativos',
            valor: () => '4',
        },

    ];

    for (const item of indicadores) {

        test(`deve apresentar indicador ${item.nome}`, async ({
            page,
        }) => {

            await autenticarAdministrador(page);

            await validarIndicador(
                page,
                item.nome,
                item.valor()
            );

        });

    }

    // =========================================
    // PENDENCIAS FINANCEIRAS - 1 TESTE
    // =========================================

    test('deve apresentar quantidade de pagamentos pendentes', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await expect(
            indicador(page, 'Valores a receber')
                .locator('small')
        ).toHaveText(
            '1 pagamentos pendentes'
        );

    });

    // =========================================
    // HISTORICO FINANCEIRO - 4 TESTES
    // =========================================

    test('deve apresentar seis meses de faturamento', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await expect(
            page.getByRole('heading', {
                name: 'Evolução do faturamento',
                exact: true,
            })
        ).toBeVisible();

        await expect(
            page.locator('.fs-grafico-coluna')
        ).toHaveCount(6);

        await expect(
            page.locator('.fs-grafico-coluna small')
        ).toHaveCount(6);

        const valores =
            await valoresHistorico(page);

        expect(valores.slice(0, 4))
            .toEqual([0, 0, 0, 0]);

        expect(
            valores.reduce(
                (total, valor) => total + valor,
                0
            )
        ).toBe(350);

    });

    test('deve apresentar faturamento mensal igual ao ultimo mes do grafico', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const valorCard =
            await indicador(
                page,
                'Faturamento mensal'
            ).locator('strong').innerText();

        const valores =
            await valoresHistorico(page);

        expect(converterMoeda(valorCard))
            .toBe(valores[5]);

        expect(valores[5])
            .toBe(faturamentoEsperado());

    });

    test('deve calcular proporcionalmente a altura das barras', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const valores =
            await valoresHistorico(page);

        const maior = Math.max(...valores);

        const barras =
            await page.locator('.fs-barra').all();

        expect(barras).toHaveLength(6);

        for (let i = 0; i < barras.length; i++) {

            const alturaEsperada = maior === 0
                ? 0
                : Math.round(
                    valores[i] * 100 / maior
                );

            const alturaAtual =
                await barras[i].evaluate(
                    elemento =>
                        (elemento as HTMLElement)
                            .style.height
                );

            expect(alturaAtual)
                .toBe(`${alturaEsperada}%`);

        }

    });

    test('deve preservar faturamento historico de pagamentos arquivados', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const valoresAntes =
            await valoresHistorico(page);

        executarSqlTeste(`
            UPDATE pagamento
            SET arquivado_em = NOW()
            WHERE id_pagamento = 704;
        `);

        await atualizarDashboard(page);

        expect(
            await valoresHistorico(page)
        ).toEqual(valoresAntes);

    });

    // =========================================
    // SITUACAO DOS ATENDIMENTOS - 4 TESTES
    // =========================================

    test('deve apresentar total de atendimentos', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await expect(
            page.locator(
                '.fs-total-atendimentos strong'
            )
        ).toHaveText('5');

    });

    const statusAtendimento = [

        {
            nome: 'Aguardando',
            quantidade: 2,
            percentual: 40,
        },

        {
            nome: 'Em lavagem',
            quantidade: 1,
            percentual: 20,
        },

        {
            nome: 'Finalizados',
            quantidade: 2,
            percentual: 40,
        },

    ];

    for (const item of statusAtendimento) {

        test(`deve apresentar quantidade e percentual de ${item.nome}`, async ({
            page,
        }) => {

            await autenticarAdministrador(page);

            const linha = page.locator(
                '.fs-status-linha'
            ).filter({

                has: page.getByText(item.nome, {
                    exact: true,
                }),

            });

            await expect(
                linha.locator('strong')
            ).toHaveText(
                String(item.quantidade)
            );

            const largura =
                await linha.locator(
                    '.fs-status-progresso'
                ).evaluate(
                    elemento =>
                        (elemento as HTMLElement)
                            .style.width
                );

            expect(parseFloat(largura))
                .toBeCloseTo(item.percentual);

        });

    }

    // =========================================
    // PROXIMOS AGENDAMENTOS - 4 TESTES
    // =========================================

    test('deve apresentar os dados dos agendamentos futuros', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const tabela = page.locator(
            '.fs-tabela-dashboard'
        );

        await expect(tabela).toBeVisible();

        const amanha = executarSqlTeste(`
            SELECT DATE_FORMAT(
                DATE_ADD(
                    CURDATE(),
                    INTERVAL 1 DAY
                ),
                '%d/%m/%Y'
            );
        `);

        const linha = tabela.locator(
            'tbody tr'
        ).filter({

            hasText: 'Volkswagen Polo - TST1A01',

        }).filter({

            has: page.getByText('09:00', {
                exact: true,
            }),

        });

        await expect(linha).toHaveCount(1);

        await expect(linha)
            .toContainText(amanha);

        await expect(linha)
            .toContainText('Cliente Teste Ativo');

        await expect(linha)
            .toContainText('Lavagem Simples Teste');

        await expect(
            linha.locator('.fs-status-agendado')
        ).toHaveText('Agendado');

    });

    test('deve ordenar e limitar os proximos agendamentos a cinco', async ({
        page,
    }) => {

        executarSqlTeste(`
            INSERT INTO agendamento
                (id_veiculo, data, horario, status)
            VALUES
                (203, DATE_ADD(CURDATE(), INTERVAL 2 DAY),
                    '09:00:00', 'AGENDADO'),
                (203, DATE_ADD(CURDATE(), INTERVAL 3 DAY),
                    '09:00:00', 'AGENDADO'),
                (203, DATE_ADD(CURDATE(), INTERVAL 4 DAY),
                    '09:00:00', 'AGENDADO'),
                (203, DATE_ADD(CURDATE(), INTERVAL 5 DAY),
                    '09:00:00', 'AGENDADO'),
                (203, DATE_ADD(CURDATE(), INTERVAL 6 DAY),
                    '09:00:00', 'AGENDADO');
        `);

        await autenticarAdministrador(page);

        const linhas = page.locator(
            '.fs-tabela-dashboard tbody tr'
        );

        await expect(linhas)
            .toHaveCount(5);

        const datas: string[] = [];

        for (const linha of await linhas.all()) {

            const data =
                await linha.locator(
                    'td strong'
                ).innerText();

            const hora =
                await linha.locator(
                    '.fs-horario'
                ).innerText();

            const [dia, mes, ano] =
                data.trim().split('/');

            datas.push(
                `${ano}-${mes}-${dia}T${hora.trim()}`
            );

        }

        expect(datas)
            .toEqual([...datas].sort());

    });

    test('nao deve apresentar agendamentos cancelados ou arquivados', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE agendamento
            SET status = 'CANCELADO'
            WHERE id_agendamento = 501;

            UPDATE agendamento
            SET data = DATE_ADD(
                CURDATE(), INTERVAL 3 DAY
            )
            WHERE id_agendamento = 506;
        `);

        await autenticarAdministrador(page);

        const tabela = page.locator(
            '.fs-tabela-dashboard'
        );

        await expect(
            tabela.getByText('09:00', {
                exact: true,
            })
        ).toHaveCount(0);

        await expect(
            tabela.getByText(
                'Chevrolet Onix - TST1A05',
                { exact: true }
            )
        ).toHaveCount(0);

        await expect(tabela)
            .toContainText(
                'Honda Civic - TST1A02'
            );

    });

    test('deve apresentar estado vazio sem agendamentos futuros', async ({
        page,
    }) => {

        executarSqlTeste(`
            UPDATE agendamento
            SET status = 'CANCELADO'
            WHERE status = 'AGENDADO';
        `);

        await autenticarAdministrador(page);

        await expect(
            page.locator('.estado-vazio')
        ).toHaveText(
            'Nenhum agendamento futuro encontrado.'
        );

        await expect(
            page.locator('.fs-tabela-dashboard')
        ).toHaveCount(0);

    });

    // =========================================
    // ATUALIZACAO DOS INDICADORES - 4 TESTES
    // =========================================

    test('deve atualizar clientes e veiculos apos inativacao', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        executarSqlTeste(`
            UPDATE cliente
            SET ativo = 0
            WHERE id_cliente = 102;
        `);

        await atualizarDashboard(page);

        await validarIndicador(
            page, 'Clientes ativos', '1'
        );

        await validarIndicador(
            page, 'Veículos disponíveis', '2'
        );

    });

    test('deve atualizar indicador apos inativacao de servico', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        executarSqlTeste(`
            UPDATE servico
            SET ativo = 0
            WHERE id_servico = 301;
        `);

        await atualizarDashboard(page);

        await validarIndicador(
            page, 'Serviços ativos', '1'
        );

    });

    test('deve atualizar faturamento e pendencias apos pagamento', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const anterior =
            faturamentoEsperado();

        executarSqlTeste(`
            UPDATE pagamento
            SET status_pagamento = 'PAGO',
                forma_pagamento = 'PIX',
                data_pagamento = NOW()
            WHERE id_pagamento = 701;
        `);

        await atualizarDashboard(page);

        await validarIndicador(
            page,
            'Faturamento mensal',
            formatarMoeda(anterior + 50)
        );

        await validarIndicador(
            page,
            'Valores a receber',
            formatarMoeda(0)
        );

        await expect(
            indicador(page, 'Valores a receber')
                .locator('small')
        ).toHaveText(
            '0 pagamentos pendentes'
        );

    });

    test('deve apresentar indicadores zerados sem dados operacionais', async ({
        page,
    }) => {

        executarSqlTeste(`
            START TRANSACTION;

            DELETE FROM colaborador_atendimento;
            DELETE FROM pagamento;
            DELETE FROM atendimento;
            DELETE FROM agendamento_servico;
            DELETE FROM agendamento;
            DELETE FROM veiculo;
            DELETE FROM servico;
            DELETE FROM cliente;

            DELETE FROM colaborador
            WHERE id_colaborador <> 401;

            COMMIT;
        `);

        await autenticarAdministrador(page);

        for (const nome of [

            'Clientes ativos',
            'Veículos disponíveis',
            'Serviços ativos',
            'Agendamentos de hoje',
            'Lavagens em andamento',

        ]) {

            await validarIndicador(
                page, nome, '0'
            );

        }

        await validarIndicador(
            page,
            'Colaboradores ativos',
            '1'
        );

        await validarIndicador(
            page,
            'Faturamento mensal',
            formatarMoeda(0)
        );

        await validarIndicador(
            page,
            'Valores a receber',
            formatarMoeda(0)
        );

        expect(
            await valoresHistorico(page)
        ).toEqual([0, 0, 0, 0, 0, 0]);

        await expect(
            page.locator('.fs-total-atendimentos strong')
        ).toHaveText('0');

        await expect(
            page.locator('.estado-vazio')
        ).toBeVisible();

        for (const barra of await page.locator(
            '.fs-barra'
        ).all()) {

            expect(

                await barra.evaluate(
                    elemento =>
                        (elemento as HTMLElement)
                            .style.height
                )

            ).toBe('0%');

        }

        for (const progresso of await page.locator(
            '.fs-status-progresso'
        ).all()) {

            expect(

                await progresso.evaluate(
                    elemento =>
                        (elemento as HTMLElement)
                            .style.width
                )

            ).toBe('0%');

        }

    });

    // =========================================
    // NAVEGACAO E SEGURANCA - 3 TESTES
    // =========================================

    test('deve apresentar destinos corretos nos indicadores', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const destinos = [

            ['Faturamento mensal',
                '/pagamento?filtro=pagos'],

            ['Valores a receber',
                '/pagamento?filtro=pendentes'],

            ['Agendamentos de hoje',
                '/agendamento'],

            ['Lavagens em andamento',
                '/atendimento?filtro=emLavagem'],

            ['Clientes ativos',
                '/cliente'],

            ['Veículos disponíveis',
                '/veiculo'],

            ['Serviços ativos',
                '/servico'],

            ['Colaboradores ativos',
                '/colaborador'],

        ];

        for (const [nome, destino] of destinos) {

            await expect(
                indicador(page, nome)
            ).toHaveAttribute(
                'href',
                destino
            );

        }

        await indicador(
            page,
            'Clientes ativos'
        ).click();

        await expect(page)
            .toHaveURL(/\/cliente$/);

    });

    test('deve impedir armazenamento em cache do dashboard', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const resposta =
            await page.reload();

        expect(resposta)
            .not.toBeNull();

        expect(resposta!.status())
            .toBe(200);

        expect(
            resposta!.headers()['cache-control']
        ).toContain('no-store');

    });

    test('deve redirecionar acesso direto ao JSP para o servlet', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.goto('/dashboard.jsp');

        await expect(page)
            .toHaveURL(/\/dashboard$/);

        await expect(
            page.locator('.fs-indicador')
        ).toHaveCount(8);

    });

});
