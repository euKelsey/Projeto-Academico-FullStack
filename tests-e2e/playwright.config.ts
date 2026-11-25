import { defineConfig, devices } from '@playwright/test';

const URL_AUTORIZADA = 'http://127.0.0.1:8081';

const baseURL =
    process.env.FASTSPLASH_E2E_BASE_URL
    ?? URL_AUTORIZADA;

if (baseURL !== URL_AUTORIZADA) {
    throw new Error(
        'Ambiente HTTP nao autorizado para testes E2E.'
    );
}

export default defineConfig({

    testDir: './tests',

    globalSetup: './support/global-setup.ts',

    fullyParallel: false,

    workers: 1,

    forbidOnly: true,

    retries: 0,

    timeout: 30_000,

    expect: {
        timeout: 5_000,
    },

    reporter: [
        ['list'],
        ['html', {
            open: 'never',
            outputFolder: 'playwright-report',
        }],
    ],

    outputDir: 'test-results',

    use: {

        baseURL,

        headless: true,

        actionTimeout: 10_000,

        navigationTimeout: 15_000,

        screenshot: 'only-on-failure',

        video: 'retain-on-failure',

        trace: 'retain-on-failure',

        locale: 'pt-BR',

        timezoneId: 'America/Sao_Paulo',

    },

    projects: [

        {
            name: 'chromium',

            use: {
                ...devices['Desktop Chrome'],

                viewport: {
                    width: 1366,
                    height: 768,
                },
            },
        },

    ],

});
