import { test, expect } from '../support/fixtures';

const URL_AUTORIZADA = 'http://127.0.0.1:8081';

test.describe('Pagina inicial e navegacao', () => {

    test.beforeEach(async ({ page }) => {

        const resposta = await page.goto('/');

        expect(resposta).not.toBeNull();

        expect(resposta!.status()).toBe(200);

    });

    // =========================================
    // IDENTIDADE E APRESENTACAO
    // =========================================

    test('deve apresentar titulo e idioma corretos', async ({
        page,
    }) => {

        await expect(page).toHaveTitle('Fast Splash');

        await expect(
            page.locator('html')
        ).toHaveAttribute('lang', 'pt-BR');

    });

    test('deve apresentar a marca no cabecalho', async ({
        page,
    }) => {

        const marca = page.locator('.marca-cabecalho');

        await expect(marca).toBeVisible();

        await expect(
            marca.locator('.marca-fast')
        ).toHaveText('Fast');

        await expect(
            marca.locator('.marca-splash')
        ).toHaveText('Splash');

    });

    test('deve apresentar o conteudo principal e banner', async ({
        page,
    }) => {

        const hero = page.locator('#inicio');

        await expect(hero).toBeVisible();

        await expect(
            hero.getByRole('heading', { level: 1 })
        ).toHaveText(
            'Seu carro limpo, rápido e com cuidado.'
        );

        const banner = hero.getByRole('img', {
            name: 'Fast Splash - lavagem automotiva',
        });

        await expect(banner).toBeVisible();

        expect(
            await banner.evaluate(
                (imagem: HTMLImageElement) =>
                    imagem.complete &&
                    imagem.naturalWidth > 0
            )
        ).toBe(true);

    });

    // =========================================
    // NAVEGACAO DO CABECALHO
    // =========================================

    const linksMenu = [

        { nome: 'Início', destino: 'inicio' },

        { nome: 'Serviços', destino: 'servicos' },

        { nome: 'Promoções', destino: 'promocoes' },

        { nome: 'Aplicativo', destino: 'aplicativo' },

    ];

    for (const item of linksMenu) {

        test(`deve navegar pelo menu para ${item.nome}`, async ({
            page,
        }) => {

            const link = page.locator('header .menu')
                .getByRole('link', {
                    name: item.nome,
                    exact: true,
                });

            await expect(link).toHaveAttribute(
                'href',
                `#${item.destino}`
            );

            await link.click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}/#${item.destino}`
            );

            await expect(
                page.locator(`#${item.destino}`)
            ).toBeVisible();

            await expect(
                page.locator(`#${item.destino}`)
            ).toBeInViewport();

        });

    }

    test('deve navegar pelos links do rodape', async ({
        page,
    }) => {

        const rodape = page.locator('footer');

        for (const item of linksMenu) {

            const link = rodape.getByRole('link', {
                name: item.nome,
                exact: true,
            });

            await expect(link).toHaveAttribute(
                'href',
                `#${item.destino}`
            );

            await link.click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}/#${item.destino}`
            );

            await expect(
                page.locator(`#${item.destino}`)
            ).toBeInViewport();

        }

    });

    test('deve navegar para servicos pelo botao principal', async ({
        page,
    }) => {

        await page.locator('#inicio')
            .getByRole('link', {
                name: 'Conheça nossos serviços',
                exact: true,
            })
            .click();

        await expect(page).toHaveURL(
            `${URL_AUTORIZADA}/#servicos`
        );

        await expect(
            page.locator('#servicos')
        ).toBeInViewport();

    });

    // =========================================
    // NAVEGACAO PARA CADASTRO
    // =========================================

    test('deve acessar cadastro pelo cabecalho', async ({
        page,
    }) => {

        const link = page.locator('header')
            .getByRole('link', {
                name: 'Criar minha conta',
                exact: true,
            });

        await expect(link).toHaveAttribute(
            'href',
            '/cadastro.jsp'
        );

        const [resposta] = await Promise.all([

            page.waitForResponse(resposta =>
                new URL(resposta.url()).pathname
                    === '/cadastro.jsp' &&
                resposta.request().isNavigationRequest()
            ),

            link.click(),

        ]);

        expect(resposta.status()).toBe(200);

        await expect(page).toHaveURL(
            `${URL_AUTORIZADA}/cadastro.jsp`
        );

    });

    test('deve acessar cadastro pelo destaque principal', async ({
        page,
    }) => {

        const link = page.locator(
            '#inicio .botao-cadastro-destaque'
        );

        await expect(link).toContainText(
            'Criar minha conta'
        );

        await expect(link).toHaveAttribute(
            'href',
            '/cadastro.jsp'
        );

        const [resposta] = await Promise.all([

            page.waitForResponse(resposta =>
                new URL(resposta.url()).pathname
                    === '/cadastro.jsp' &&
                resposta.request().isNavigationRequest()
            ),

            link.click(),

        ]);

        expect(resposta.status()).toBe(200);

        await expect(page).toHaveURL(
            `${URL_AUTORIZADA}/cadastro.jsp`
        );

    });

    // =========================================
    // SERVICOS
    // =========================================

    test('deve apresentar os servicos divulgados', async ({
        page,
    }) => {

        const secao = page.locator('#servicos');

        await expect(
            secao.getByRole('heading', { level: 2 })
        ).toHaveText(
            'Escolha o cuidado ideal para o seu carro'
        );

        await expect(
            secao.locator('.card-servico')
        ).toHaveCount(3);

        for (const nome of [

            'Lavagem Expressa Fast Splash',

            'Lavagem Completa Fast Splash',

            'Cuidados Especiais Fast Splash',

        ]) {

            await expect(
                secao.getByRole('img', { name: nome })
            ).toBeVisible();

        }

    });

    // =========================================
    // PROMOCOES
    // =========================================

    test('deve apresentar a secao de promocoes', async ({
        page,
    }) => {

        const secao = page.locator('#promocoes');

        await expect(
            secao.getByRole('heading', { level: 2 })
        ).toHaveText(
            'Ofertas para cuidar do seu carro'
        );

        await expect(
            secao.locator('.promocao-principal')
        ).toBeVisible();

        await expect(
            secao.locator('.promocao-menor')
        ).toHaveCount(2);

        await expect(
            secao.getByRole('heading', {
                name: 'Combo Express',
                exact: true,
            })
        ).toBeVisible();

    });

    test('deve navegar das promocoes para o aplicativo', async ({
        page,
    }) => {

        const links = [

            '.botao-promocao',

            '.promocao-link',

        ];

        for (const seletor of links) {

            const link = page.locator(
                `#promocoes ${seletor}`
            );

            await expect(link).toHaveAttribute(
                'href',
                '#aplicativo'
            );

            await link.click();

            await expect(page).toHaveURL(
                `${URL_AUTORIZADA}/#aplicativo`
            );

            await expect(
                page.locator('#aplicativo')
            ).toBeInViewport();

        }

    });

    // =========================================
    // BENEFICIOS E APLICATIVO
    // =========================================

    test('deve apresentar os quatro beneficios', async ({
        page,
    }) => {

        const beneficios = page.locator(
            '.beneficios'
        );

        await expect(
            beneficios.locator('.beneficio')
        ).toHaveCount(4);

        for (const nome of [

            'Agilidade',

            'Qualidade',

            'Acompanhamento',

            'Tecnologia',

        ]) {

            await expect(
                beneficios.getByRole('heading', {
                    name: nome,
                    exact: true,
                })
            ).toBeVisible();

        }

    });

    test('deve apresentar os recursos e mockup do aplicativo', async ({
        page,
    }) => {

        const aplicativo = page.locator(
            '#aplicativo'
        );

        await expect(
            aplicativo.getByRole('heading', {
                level: 2,
            })
        ).toHaveText(
            'Seu lava-rápido também no celular'
        );

        await expect(
            aplicativo.locator('.app-recurso')
        ).toHaveCount(4);

        for (const recurso of [

            'Cadastre seus veículos',

            'Faça agendamentos',

            'Acompanhe o atendimento',

            'Pagamentos e histórico',

        ]) {

            await expect(
                aplicativo.locator('.app-recursos')
                    .getByText(recurso, {
                        exact: true,
                    })
            ).toBeVisible();

        }

        const mockup = aplicativo.locator(
            '.celular-tela'
        );

        await expect(mockup).toBeVisible();

        await expect(
            mockup.locator('.mockup-item')
        ).toHaveCount(5);

        for (const opcao of [

            'Meus Veículos',

            'Agendar',

            'Acompanhar',

            'Pagamentos',

            'Histórico',

        ]) {

            await expect(
                mockup.getByText(opcao, {
                    exact: true,
                })
            ).toBeVisible();

        }

    });

    test('deve apresentar o botao do aplicativo', async ({
        page,
    }) => {

        const botao = page.locator('#aplicativo')
            .getByRole('button', {
                name: 'Conheça o aplicativo',
                exact: true,
            });

        await expect(botao).toBeVisible();

        await expect(botao).toBeEnabled();

    });

    // =========================================
    // RODAPE E AREA INTERNA
    // =========================================

    test('deve apresentar informacoes institucionais', async ({
        page,
    }) => {

        const rodape = page.locator('footer');

        await expect(rodape).toBeVisible();

        for (const texto of [

            'Aplicativo para clientes',

            'Sistema Web para funcionários',

            'Projeto acadêmico',

            'Acesso exclusivo para colaboradores.',

            'Desenvolvido para fins acadêmicos',

        ]) {

            await expect(
                rodape.getByText(texto, {
                    exact: true,
                })
            ).toBeVisible();

        }

    });

    test('deve acessar login dos colaboradores pelo rodape', async ({
        page,
    }) => {

        const link = page.locator('footer')
            .getByRole('link', {
                name: 'Entrar',
                exact: true,
            });

        await expect(link).toHaveAttribute(
            'href',
            '/login.jsp'
        );

        const [resposta] = await Promise.all([

            page.waitForResponse(resposta =>
                new URL(resposta.url()).pathname
                    === '/login.jsp' &&
                resposta.request().isNavigationRequest()
            ),

            link.click(),

        ]);

        expect(resposta.status()).toBe(200);

        await expect(page).toHaveURL(
            `${URL_AUTORIZADA}/login.jsp`
        );

    });

    test('nao deve exibir painel administrativo para visitante', async ({
        page,
    }) => {

        await expect(
            page.getByRole('link', {
                name: 'Painel administrativo',
                exact: true,
            })
        ).toHaveCount(0);

    });

    // =========================================
    // RECURSOS ESTATICOS
    // =========================================

    test('deve carregar todas as imagens da pagina', async ({
        page,
    }) => {

        const imagens = page.locator('main img');

        await expect(imagens).toHaveCount(4);

        for (const imagem of await imagens.all()) {

            await imagem.scrollIntoViewIfNeeded();

            await expect(imagem).toBeVisible();

            await expect.poll(async () => {

                return imagem.evaluate(
                    (elemento: HTMLImageElement) =>
                        elemento.complete &&
                        elemento.naturalWidth > 0
                );

            }).toBe(true);

        }

    });

    test('deve carregar as folhas de estilo locais', async ({
        page,
    }) => {

        const estilos = [

            '/css/site.css',

            '/css/interno.css',

            '/css/site-publico.css?v=2',

        ];

        for (const caminho of estilos) {

            const resposta = await page.request.get(
                caminho,
                { maxRedirects: 0 }
            );

            expect(
                resposta.status(),
                caminho
            ).toBe(200);

            expect(
                resposta.headers()['content-type']
            ).toContain('text/css');

            const carregado = await page.evaluate(
                caminhoEsperado => {

                    return Array.from(
                        document.styleSheets
                    ).some(estilo => {

                        return estilo.href === new URL(
                            caminhoEsperado,
                            location.origin
                        ).href;

                    });

                },
                caminho
            );

            expect(carregado, caminho).toBe(true);

        }

    });

    // =========================================
    // ERROS DO NAVEGADOR
    // =========================================

    test('deve carregar a pagina sem erros JavaScript', async ({
        page,
    }) => {

        const erros: string[] = [];

        page.on('pageerror', erro => {

            erros.push(erro.message);

        });

        await page.reload({
            waitUntil: 'load',
        });

        expect(erros).toEqual([]);

    });

    test('deve carregar recursos locais sem falhas HTTP', async ({
        page,
    }) => {

        const falhas: string[] = [];

        page.on('response', resposta => {

            if (
                new URL(resposta.url()).origin
                    === URL_AUTORIZADA &&
                resposta.status() >= 400
            ) {

                falhas.push(
                    `${resposta.status()} ${resposta.url()}`
                );

            }

        });

        page.on('requestfailed', requisicao => {

            if (
                new URL(requisicao.url()).origin
                    === URL_AUTORIZADA
            ) {

                falhas.push(
                    `${requisicao.url()} - ${
                        requisicao.failure()?.errorText
                    }`
                );

            }

        });

        await page.reload({
            waitUntil: 'load',
        });

        expect(falhas).toEqual([]);

    });

});
