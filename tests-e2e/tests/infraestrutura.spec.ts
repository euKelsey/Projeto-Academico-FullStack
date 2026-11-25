import { test, expect } from '@playwright/test';

test.describe('Infraestrutura Playwright', () => {

    test('deve utilizar o navegador Chromium', async ({
        browserName,
    }) => {

        expect(browserName).toBe('chromium');

    });

    test('deve utilizar somente a URL autorizada', async ({
        baseURL,
    }) => {

        expect(baseURL).toBe(
            'http://127.0.0.1:8081'
        );

    });

    test('deve iniciar o navegador corretamente', async ({
        page,
    }) => {

        await page.setContent(`
            <!DOCTYPE html>
            <html lang="pt-BR">
                <head>
                    <title>Fast Splash - Testes</title>
                </head>
                <body>
                    <h1>Ambiente de testes</h1>
                </body>
            </html>
        `);

        await expect(page).toHaveTitle(
            'Fast Splash - Testes'
        );

        await expect(
            page.getByRole('heading', {
                name: 'Ambiente de testes',
            })
        ).toBeVisible();

    });

    test('deve utilizar a resolucao configurada', async ({
        page,
    }) => {

        expect(page.viewportSize()).toEqual({
            width: 1366,
            height: 768,
        });

    });

    test('deve utilizar o idioma brasileiro', async ({
        page,
    }) => {

        const idioma = await page.evaluate(
            () => navigator.language
        );

        expect(idioma).toBe('pt-BR');

    });

    test('deve utilizar o fuso horario configurado', async ({
        page,
    }) => {

        const timezone = await page.evaluate(
            () => Intl.DateTimeFormat()
                .resolvedOptions()
                .timeZone
        );

        expect(timezone).toBe(
            'America/Sao_Paulo'
        );

    });

    test('deve permitir interacao com formularios', async ({
        page,
    }) => {

        await page.setContent(`
            <label for="nome">Nome</label>

            <input id="nome" type="text">

            <button onclick="
                document.getElementById('resultado')
                    .textContent =
                    document.getElementById('nome').value
            ">
                Confirmar
            </button>

            <p id="resultado"></p>
        `);

        await page.getByLabel('Nome')
            .fill('Fast Splash');

        await page.getByRole('button', {
            name: 'Confirmar',
        }).click();

        await expect(
            page.locator('#resultado')
        ).toHaveText('Fast Splash');

    });

    test('deve iniciar sem cookies de autenticacao', async ({
        context,
    }) => {

        const cookies = await context.cookies();

        expect(cookies).toHaveLength(0);

    });

});
