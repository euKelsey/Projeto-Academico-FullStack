import type { Page } from '@playwright/test';
import { expect } from '@playwright/test';

export const CONTAS_TESTE = {

    administrador: {
        id: 401,
        email: 'admin@example.test',
        senha: 'SenhaFicticia@123',
        perfil: 'Administrador',
    },

    atendente: {
        id: 402,
        email: 'atendente@example.test',
        senha: 'SenhaFicticia@123',
        perfil: 'Atendente',
    },

} as const;

export async function preencherLogin(
    page: Page,
    email: string,
    senha: string
): Promise<void> {

    await page.goto('/login');

    await page.getByLabel('E-mail', {
        exact: true,
    }).fill(email);

    await page.getByLabel('Senha', {
        exact: true,
    }).fill(senha);

    await page.getByRole('button', {
        name: 'Entrar no sistema',
        exact: true,
    }).click();

}

export async function autenticarColaborador(
    page: Page,
    perfil: keyof typeof CONTAS_TESTE
): Promise<void> {

    const conta = CONTAS_TESTE[perfil];

    await preencherLogin(
        page,
        conta.email,
        conta.senha
    );

    await expect(page).toHaveURL(
        /\/dashboard$/
    );

    await expect(
        page.locator('#fsMenu')
    ).toBeVisible();

    await expect(
        page.locator('.fs-menu-perfil strong')
    ).toHaveText(conta.perfil);

}

export async function autenticarAdministrador(
    page: Page
): Promise<void> {

    await autenticarColaborador(
        page,
        'administrador'
    );

}

export async function autenticarAtendente(
    page: Page
): Promise<void> {

    await autenticarColaborador(
        page,
        'atendente'
    );

}
