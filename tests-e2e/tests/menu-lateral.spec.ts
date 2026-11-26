import type { Page } from '@playwright/test';

import { test, expect } from '../support/fixtures';

import {
    CONTAS_TESTE,
    preencherLogin,
    autenticarAdministrador,
} from '../support/autenticacao';

const CHAVE_MENU =
    'fastSplashMenuRecolhido';

const URL_AUTORIZADA =
    'http://127.0.0.1:8081';

async function validarEstado(
    page: Page,
    recolhido: boolean
): Promise<void> {

    const botao = page.locator('#fsMenuToggle');

    const estado = recolhido
        ? 'Expandir menu'
        : 'Recolher menu';

    await expect(botao).toHaveAttribute(
        'aria-expanded',
        String(!recolhido)
    );

    await expect(botao).toHaveAttribute(
        'aria-label',
        estado
    );

    await expect(botao).toHaveAttribute(
        'title',
        estado
    );

    await expect(botao).toHaveAttribute(
        'aria-controls',
        'fsMenuNav'
    );

    if (recolhido) {

        await expect(
            page.locator('body')
        ).toHaveClass(/\bfs-menu-recolhido\b/);

    } else {

        await expect(
            page.locator('body')
        ).not.toHaveClass(/\bfs-menu-recolhido\b/);

    }

}

async function validarPreferencia(
    page: Page,
    recolhido: boolean
): Promise<void> {

    const salvo = await page.evaluate(
        chave => localStorage.getItem(chave),
        CHAVE_MENU
    );

    expect(salvo).toBe(
        String(recolhido)
    );

}

async function autenticarNaLargura(
    page: Page,
    largura: number
): Promise<void> {

    await page.setViewportSize({

        width: largura,
        height: 900,

    });

    await preencherLogin(
        page,
        CONTAS_TESTE.administrador.email,
        CONTAS_TESTE.administrador.senha
    );

    await expect(page)
        .toHaveURL(/\/dashboard$/);

    await expect(
        page.locator('#fsMenu')
    ).toBeVisible();

}

test.describe('Menu lateral administrativo', () => {

    // =========================================
    // EXPANSAO E RECOLHIMENTO - 3 TESTES
    // =========================================

    test('deve iniciar expandido em monitor maior', async ({
        page,
    }) => {

        await autenticarNaLargura(page, 1366);

        await validarEstado(page, false);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS('width', '235px');

        await expect(
            page.locator('body')
        ).toHaveCSS('padding-left', '235px');

        await expect(
            page.locator('.fs-menu-marca')
        ).toBeVisible();

        await expect(
            page.locator('#fsMenuNav .fs-menu-texto').first()
        ).toBeVisible();

    });

    test('deve recolher menu e preservar icones', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.locator('#fsMenuToggle')
            .click();

        await validarEstado(page, true);

        await validarPreferencia(page, true);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS('width', '72px');

        await expect(
            page.locator('body')
        ).toHaveCSS('padding-left', '72px');

        await expect(
            page.locator('.fs-menu-marca')
        ).toBeHidden();

        await expect(
            page.locator('#fsMenuNav .fs-menu-texto').first()
        ).toBeHidden();

        await expect(
            page.locator('#fsMenuNav .fs-menu-icone').first()
        ).toBeVisible();

        await expect(
            page.locator('#fsMenuNav')
        ).toBeVisible();

    });

    test('deve expandir novamente o menu', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const botao =
            page.locator('#fsMenuToggle');

        await botao.click();

        await validarEstado(page, true);

        await botao.click();

        await validarEstado(page, false);

        await validarPreferencia(page, false);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS('width', '235px');

        await expect(
            page.locator('.fs-menu-marca')
        ).toBeVisible();

        await expect(
            page.locator('#fsMenuNav .fs-menu-texto').first()
        ).toBeVisible();

    });

    // =========================================
    // PERSISTENCIA - 4 TESTES
    // =========================================

    test('deve preservar menu recolhido apos recarregar', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.locator('#fsMenuToggle')
            .click();

        await page.reload();

        await validarEstado(page, true);

        await validarPreferencia(page, true);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS('width', '72px');

    });

    test('deve preservar menu expandido apos recarregar', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const botao =
            page.locator('#fsMenuToggle');

        await botao.click();
        await botao.click();

        await page.reload();

        await validarEstado(page, false);

        await validarPreferencia(page, false);

    });

    test('deve preservar menu recolhido durante navegacao', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.locator('#fsMenuToggle')
            .click();

        await page.locator('#fsMenuNav')
            .getByRole('link', {
                name: 'Clientes',
                exact: true,
            }).click();

        await expect(page)
            .toHaveURL(/\/cliente$/);

        await validarEstado(page, true);

        await validarPreferencia(page, true);

        await page.locator('#fsMenuNav')
            .getByRole('link', {
                name: 'Dashboard',
                exact: true,
            }).click();

        await expect(page)
            .toHaveURL(/\/dashboard$/);

        await validarEstado(page, true);

    });

    test('deve isolar preferencia entre contextos do navegador', async ({
        page,
        browser,
    }) => {

        await autenticarAdministrador(page);

        await page.locator('#fsMenuToggle')
            .click();

        await validarPreferencia(page, true);

        const outroContexto =
            await browser.newContext({

                baseURL: URL_AUTORIZADA,

                viewport: {
                    width: 1366,
                    height: 900,
                },

            });

        try {

            const outraPagina =
                await outroContexto.newPage();

            await autenticarAdministrador(
                outraPagina
            );

            await validarEstado(
                outraPagina, false
            );

            const salvo =
                await outraPagina.evaluate(
                    chave => localStorage.getItem(chave),
                    CHAVE_MENU
                );

            expect(salvo).toBeNull();

            await validarEstado(page, true);

        } finally {

            await outroContexto.close();

        }

    });

    // =========================================
    // ACESSIBILIDADE - 1 TESTE
    // =========================================

    test('deve permitir alternar menu pelo teclado', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const botao =
            page.locator('#fsMenuToggle');

        await botao.focus();

        await expect(botao).toBeFocused();

        await page.keyboard.press('Enter');

        await validarEstado(page, true);

        await expect(botao).toBeFocused();

        await page.keyboard.press('Space');

        await validarEstado(page, false);

    });

    // =========================================
    // LARGURAS E LIMITES - 4 TESTES
    // =========================================

    const larguras = [

        {
            tela: 1200,
            menu: '205px',
            recolhido: false,
        },

        {
            tela: 1101,
            menu: '205px',
            recolhido: false,
        },

        {
            tela: 1100,
            menu: '72px',
            recolhido: true,
        },

        {
            tela: 761,
            menu: '72px',
            recolhido: true,
        },

    ];

    for (const item of larguras) {

        test(`deve ajustar menu em tela de ${item.tela}px`, async ({
            page,
        }) => {

            await autenticarNaLargura(
                page, item.tela
            );

            await validarEstado(
                page, item.recolhido
            );

            await expect(
                page.locator('#fsMenu')
            ).toHaveCSS(
                'width', item.menu
            );

            await expect(
                page.locator('body')
            ).toHaveCSS(
                'padding-left', item.menu
            );

        });

    }

    // =========================================
    // TELAS MENORES - 3 TESTES
    // =========================================

    test('deve apresentar menu mobile inicialmente recolhido', async ({
        page,
    }) => {

        await autenticarNaLargura(page, 390);

        await validarEstado(page, true);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS(
            'position', 'relative'
        );

        await expect(
            page.locator('body')
        ).toHaveCSS(
            'padding-left', '0px'
        );

        await expect(
            page.locator('#fsMenuNav')
        ).toBeHidden();

        await expect(
            page.locator('.fs-menu-rodape')
        ).toBeHidden();

        await expect(
            page.locator('.fs-menu-marca')
        ).toBeVisible();

    });

    test('deve expandir e recolher navegacao mobile', async ({
        page,
    }) => {

        await autenticarNaLargura(page, 390);

        const botao =
            page.locator('#fsMenuToggle');

        await botao.click();

        await validarEstado(page, false);

        await expect(
            page.locator('#fsMenuNav')
        ).toBeVisible();

        await expect(
            page.locator('#fsMenuNav')
        ).toHaveCSS('display', 'grid');

        await expect(
            page.locator('.fs-menu-rodape')
        ).toBeVisible();

        await expect(
            page.locator('#fsMenuNav .fs-menu-item')
        ).toHaveCount(8);

        await botao.click();

        await validarEstado(page, true);

        await expect(
            page.locator('#fsMenuNav')
        ).toBeHidden();

    });

    test('deve priorizar preferencia salva sobre tamanho da tela', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        await page.evaluate(chave => {

            localStorage.setItem(
                chave, 'false'
            );

        }, CHAVE_MENU);

        await page.setViewportSize({

            width: 390,
            height: 844,

        });

        await page.reload();

        await validarEstado(page, false);

        await expect(
            page.locator('#fsMenuNav')
        ).toBeVisible();

        await validarPreferencia(page, false);

    });

    // =========================================
    // MOVIMENTO REDUZIDO - 1 TESTE
    // =========================================

    test('deve respeitar preferencia de movimento reduzido', async ({
        page,
    }) => {

        await page.emulateMedia({
            reducedMotion: 'reduce',
        });

        await autenticarAdministrador(page);

        await expect(
            page.locator('#fsMenu')
        ).toHaveCSS(
            'transition-duration', '0s'
        );

        await expect(
            page.locator('body')
        ).toHaveCSS(
            'transition-duration', '0s'
        );

        await page.locator('#fsMenuToggle')
            .click();

        await validarEstado(page, true);

    });

    // =========================================
    // RECURSOS ESTATICOS - 1 TESTE
    // =========================================

    test('deve carregar recursos do menu sem erros JavaScript', async ({
        page,
    }) => {

        const erros: string[] = [];

        page.on('pageerror', erro => {

            erros.push(erro.message);

        });

        await autenticarAdministrador(page);

        const css = await page.request.get(
            '/css/menu-lateral.css',
            { maxRedirects: 0 }
        );

        expect(css.status()).toBe(200);

        expect(
            css.headers()['content-type']
        ).toContain('text/css');

        const js = await page.request.get(
            '/js/menu-lateral.js',
            { maxRedirects: 0 }
        );

        expect(js.status()).toBe(200);

        expect(
            js.headers()['content-type']
        ).toMatch(/javascript|ecmascript/i);

        await page.locator('#fsMenuToggle')
            .click();

        await validarEstado(page, true);

        await page.locator('#fsMenuToggle')
            .click();

        await validarEstado(page, false);

        expect(erros).toEqual([]);

    });

    // =========================================
    // PAGINA SELECIONADA - 1 TESTE
    // =========================================

    test('deve atualizar item ativo durante navegacao', async ({
        page,
    }) => {

        await autenticarAdministrador(page);

        const menu =
            page.locator('#fsMenuNav');

        const destinos = [

            {
                nome: 'Clientes',
                rota: '/cliente',
            },

            {
                nome: 'Veículos',
                rota: '/veiculo',
            },

            {
                nome: 'Dashboard',
                rota: '/dashboard',
            },

        ];

        for (const item of destinos) {

            await menu.getByRole('link', {

                name: item.nome,
                exact: true,

            }).click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}${item.rota}`
            );

            const selecionado = menu.locator(
                '.fs-menu-item.fs-menu-ativo'
            );

            await expect(selecionado)
                .toHaveCount(1);

            await expect(selecionado)
                .toHaveAttribute(
                    'aria-label', item.nome
                );

            await expect(selecionado)
                .toHaveAttribute(
                    'aria-current', 'page'
                );

            await expect(
                menu.locator('[aria-current="page"]')
            ).toHaveCount(1);

        }

    });

});
