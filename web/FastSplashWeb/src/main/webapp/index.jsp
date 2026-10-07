<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >
    <title>Fast Splash</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/site.css"
    >
</head>

<body>

    <!-- CABEÇALHO -->
    <header class="cabecalho">
        <div class="container cabecalho-conteudo">

            <div class="marca-cabecalho">

                <div class="marca-nome">
                    <span class="marca-fast">
                        Fast
                    </span>

                    <span class="marca-splash">
                        Splash
                    </span>
                </div>

                <span class="marca-subtitulo">
                    CAR WASH
                </span>

            </div>

            <nav class="menu">
                <a href="#inicio">Início</a>
                <a href="#servicos">Serviços</a>
                <a href="#promocoes">Promoções</a>
                <a href="#aplicativo">Aplicativo</a>
            </nav>

        </div>
    </header>


    <main>

        <!-- HERO -->
        <section
            id="inicio"
            class="hero"
        >

            <div class="container hero-conteudo">

                <div class="hero-texto">

                    <span class="destaque-pequeno">
                        Cuidado para o seu veículo
                    </span>

                    <h1>
                        Seu carro limpo,
                        rápido e com cuidado.
                    </h1>

                    <p>
                        Serviços de lavagem pensados para
                        deixar seu veículo sempre bem cuidado.
                    </p>

                    <div class="hero-acoes">

                        <a
                            class="botao-principal"
                            href="#servicos"
                        >
                            Conheça nossos serviços
                        </a>

                        <a
                            class="botao-secundario"
                            href="${pageContext.request.contextPath}/cadastro.jsp"
                        >
                            Cadastre-se
                        </a>

                    </div>

                </div>


                <div class="hero-visual">

                    <div class="hero-banner">

                        <img
                            class="hero-imagem"
                            src="${pageContext.request.contextPath}/img/banners/banner-fast-splash.png"
                            alt="Fast Splash - lavagem automotiva"
                        >

                        <div class="hero-banner-overlay">
                            <span class="hero-banner-tag">
                                Fast Splash
                            </span>

                            <strong>
                                Velocidade no atendimento.
                            </strong>

                            <span>
                                Impacto no resultado.
                            </span>
                        </div>

                        <div class="hero-banner-selo">
                            <span>FAST</span>
                            <strong>+ SPLASH</strong>
                        </div>

                    </div>

                </div>

            </div>

        </section>


        <!-- SERVIÇOS -->
        <section
            id="servicos"
            class="secao secao-servicos"
        >

            <div class="container">

                <div class="titulo-secao">
                    <span>Nossos serviços</span>

                    <h2>
                        Escolha o cuidado ideal para o seu carro
                    </h2>

                    <p>
                        Opções para diferentes momentos,
                        desde uma limpeza rápida até um
                        cuidado mais completo.
                    </p>
                </div>


                <div class="grade-servicos">

                    <article class="card-servico">

                        <div class="servico-topo">
                            <span class="servico-categoria">
                                Rápido
                            </span>

                            <span class="servico-numero">
                                01
                            </span>
                        </div>

                        <img
                            class="servico-imagem"
                            src="${pageContext.request.contextPath}/img/servicos/lavagem-expressa.png"
                            alt="Lavagem Expressa Fast Splash"
                        >

                        <h3>
                            Lavagem Expressa
                        </h3>

                        <p class="descricao-servico">
                            Uma opção prática para manter
                            o veículo limpo no dia a dia.
                        </p>

                        <ul class="lista-servico">
                            <li>Limpeza externa</li>
                            <li>Enxágue completo</li>
                            <li>Secagem</li>
                        </ul>

                        <div class="servico-rodape">
                            <span class="servico-preco-label">
                                A partir de
                            </span>

                            <strong class="servico-preco">
                                R$ 30,00
                            </strong>
                        </div>

                    </article>


                    <article class="card-servico destaque-card">

                        <div class="servico-topo">
                            <span class="servico-categoria categoria-destaque">
                                Mais escolhido
                            </span>

                            <span class="servico-numero">
                                02
                            </span>
                        </div>

                        <img
                            class="servico-imagem"
                            src="${pageContext.request.contextPath}/img/servicos/lavagem-completa.png"
                            alt="Lavagem Completa Fast Splash"
                        >

                        <h3>
                            Lavagem Completa
                        </h3>

                        <p class="descricao-servico">
                            Um cuidado mais detalhado para
                            deixar o veículo renovado.
                        </p>

                        <ul class="lista-servico">
                            <li>Limpeza externa</li>
                            <li>Limpeza interna</li>
                            <li>Aspiração</li>
                        </ul>

                        <div class="servico-rodape">
                            <span class="servico-preco-label">
                                A partir de
                            </span>

                            <strong class="servico-preco">
                                R$ 50,00
                            </strong>
                        </div>

                    </article>


                    <article class="card-servico">

                        <div class="servico-topo">
                            <span class="servico-categoria">
                                Especial
                            </span>

                            <span class="servico-numero">
                                03
                            </span>
                        </div>

                        <img
                            class="servico-imagem"
                            src="${pageContext.request.contextPath}/img/servicos/cuidados-especiais.png"
                            alt="Cuidados Especiais Fast Splash"
                        >

                        <h3>
                            Cuidados Especiais
                        </h3>

                        <p class="descricao-servico">
                            Serviços adicionais para quem
                            busca um cuidado ainda maior.
                        </p>

                        <ul class="lista-servico">
                            <li>Acabamento detalhado</li>
                            <li>Cuidados adicionais</li>
                            <li>Proteção visual</li>
                        </ul>

                        <div class="servico-rodape">
                            <span class="servico-preco-label">
                                Consulte
                            </span>

                            <strong class="servico-preco">
                                Valores
                            </strong>
                        </div>

                    </article>

                </div>

            </div>

        </section>


        <!-- PROMOÇÕES -->
        <section
            id="promocoes"
            class="secao-promocao"
        >

            <div class="container">

                <div class="titulo-secao titulo-promocao">
                    <span>Promoções</span>

                    <h2>
                        Ofertas para cuidar do seu carro
                    </h2>

                    <p>
                        Confira algumas condições especiais
                        disponíveis no Fast Splash.
                    </p>
                </div>


                <div class="promocoes-grid">

                    <article class="promocao-principal">

                        <div class="promocao-principal-texto">

                            <span class="promocao-tag">
                                Promoção do mês
                            </span>

                            <h3>
                                Lavagem Completa
                                <span>
                                    com 20% OFF neste mês
                                </span>
                            </h3>

                            <p>
                                Limpeza externa, interna e acabamento
                                em uma condição especial válida durante
                                a campanha promocional do mês.
                            </p>

                            <div class="promocao-beneficios">
                                <span>✓ Lavagem externa</span>
                                <span>✓ Limpeza interna</span>
                                <span>✓ Aspiração</span>
                            </div>

                            <a
                                class="botao-promocao"
                                href="#aplicativo"
                            >
                                Confira no aplicativo
                            </a>

                        </div>


                        <div class="promocao-principal-desconto">
                            <span>NESTE MÊS</span>
                            <strong>20%</strong>
                            <small>OFF</small>
                        </div>

                    </article>


                    <article class="promocao-menor">

                        <div class="promocao-menor-icone">
                            ⚡
                        </div>

                        <span class="promocao-menor-tag">
                            Rápido
                        </span>

                        <h3>
                            Combo Express
                        </h3>

                        <p>
                            Para quem quer deixar o carro limpo
                            sem perder tempo.
                        </p>

                        <div class="promocao-menor-destaque">
                            Lavagem Expressa
                        </div>

                    </article>


                    <article class="promocao-menor promocao-app">

                        <div class="promocao-menor-icone">
                            📱
                        </div>

                        <span class="promocao-menor-tag">
                            Aplicativo
                        </span>

                        <h3>
                            Tudo na palma da mão
                        </h3>

                        <p>
                            Cadastre seus veículos, faça agendamentos
                            e acompanhe seus serviços pelo app.
                        </p>

                        <a
                            href="#aplicativo"
                            class="promocao-link"
                        >
                            Conheça o aplicativo →
                        </a>

                    </article>

                </div>

            </div>

        </section>


        <!-- POR QUE FAST SPLASH -->
        <section class="secao beneficios">

            <div class="container">

                <div class="titulo-secao">
                    <span>
                        Por que Fast Splash?
                    </span>

                    <h2>
                        Mais praticidade do início ao fim
                    </h2>

                    <p>
                        Unimos agilidade, cuidado e tecnologia
                        para tornar a experiência mais simples
                        tanto para o cliente quanto para a equipe.
                    </p>
                </div>


                <div class="grade-beneficios">

                    <article class="beneficio">
                        <div class="beneficio-icone">⚡</div>

                        <div class="beneficio-conteudo">
                            <span class="beneficio-numero">01</span>

                            <h3>Agilidade</h3>

                            <p>
                                Um fluxo de atendimento pensado para
                                tornar cada etapa mais rápida e prática.
                            </p>
                        </div>
                    </article>


                    <article class="beneficio">
                        <div class="beneficio-icone">✨</div>

                        <div class="beneficio-conteudo">
                            <span class="beneficio-numero">02</span>

                            <h3>Qualidade</h3>

                            <p>
                                Cuidado em cada etapa do serviço,
                                desde a lavagem até a finalização.
                            </p>
                        </div>
                    </article>


                    <article class="beneficio">
                        <div class="beneficio-icone">📱</div>

                        <div class="beneficio-conteudo">
                            <span class="beneficio-numero">03</span>

                            <h3>Acompanhamento</h3>

                            <p>
                                Pelo aplicativo, o cliente pode acompanhar
                                seus serviços e consultar informações
                                importantes com mais facilidade.
                            </p>
                        </div>
                    </article>


                    <article class="beneficio beneficio-tecnologia">
                        <div class="beneficio-icone">💻</div>

                        <div class="beneficio-conteudo">
                            <span class="beneficio-numero">04</span>

                            <h3>Tecnologia</h3>

                            <p>
                                Aplicativo para o cliente e sistema Web
                                para a equipe trabalhando de forma integrada.
                            </p>
                        </div>
                    </article>

                </div>

            </div>

        </section>


        <!-- APLICATIVO -->
        <section
            id="aplicativo"
            class="secao-app"
        >

            <div class="container app-conteudo">

                <div class="app-texto">

                    <span class="destaque-pequeno">
                        Fast Splash App
                    </span>

                    <h2>
                        Seu lava-rápido
                        também no celular
                    </h2>

                    <p class="app-descricao">
                        Depois de criar seu cadastro,
                        utilize o aplicativo Fast Splash
                        para acompanhar seus serviços
                        de forma simples e prática.
                    </p>


                    <div class="app-recursos">

                        <div class="app-recurso">
                            <span class="app-check">✓</span>

                            <div>
                                <strong>
                                    Cadastre seus veículos
                                </strong>

                                <p>
                                    Tenha seus veículos disponíveis
                                    para novos agendamentos.
                                </p>
                            </div>
                        </div>


                        <div class="app-recurso">
                            <span class="app-check">✓</span>

                            <div>
                                <strong>
                                    Faça agendamentos
                                </strong>

                                <p>
                                    Escolha seu veículo,
                                    serviço, data e horário.
                                </p>
                            </div>
                        </div>


                        <div class="app-recurso">
                            <span class="app-check">✓</span>

                            <div>
                                <strong>
                                    Acompanhe o atendimento
                                </strong>

                                <p>
                                    Consulte o andamento
                                    do serviço realizado.
                                </p>
                            </div>
                        </div>


                        <div class="app-recurso">
                            <span class="app-check">✓</span>

                            <div>
                                <strong>
                                    Pagamentos e histórico
                                </strong>

                                <p>
                                    Consulte pagamentos
                                    e serviços anteriores.
                                </p>
                            </div>
                        </div>

                    </div>


                    <button
                        class="botao-app"
                        type="button"
                    >
                        Conheça o aplicativo
                    </button>

                </div>


                <div class="app-mockup-area">

                    <div class="app-luz"></div>

                    <div class="celular">

                        <div class="celular-topo">
                            <div class="celular-camera"></div>
                        </div>

                        <div class="celular-tela">

                            <div class="app-logo">
                                Fast Splash
                            </div>

                            <span class="app-saude">
                                Olá, cliente!
                            </span>

                            <h3>
                                O que deseja fazer?
                            </h3>

                            <div class="mockup-opcoes">

                                <div class="mockup-item">
                                    🚗
                                    <span>Meus Veículos</span>
                                </div>

                                <div class="mockup-item">
                                    📅
                                    <span>Agendar</span>
                                </div>

                                <div class="mockup-item">
                                    💦
                                    <span>Acompanhar</span>
                                </div>

                                <div class="mockup-item">
                                    💳
                                    <span>Pagamentos</span>
                                </div>

                                <div class="mockup-item mockup-item-largo">
                                    🕘
                                    <span>Histórico</span>
                                </div>

                            </div>

                        </div>

                    </div>


                    <div class="app-selo">
                        <span>Cliente</span>
                        <strong>100% pelo App</strong>
                    </div>

                </div>

            </div>

        </section>

    </main>


    <!-- RODAPÉ -->
    <footer class="rodape">

        <div class="container rodape-grid">

            <div class="rodape-marca">

                <div class="marca">
                    Fast Splash
                </div>

                <p>
                    Cuidado, agilidade e tecnologia
                    para deixar seu veículo sempre em dia.
                </p>

            </div>


            <div class="rodape-coluna">

                <h4>Navegação</h4>

                <a href="#inicio">Início</a>
                <a href="#servicos">Serviços</a>
                <a href="#promocoes">Promoções</a>
                <a href="#aplicativo">Aplicativo</a>

            </div>


            <div class="rodape-coluna">

                <h4>Fast Splash</h4>

                <span>Aplicativo para clientes</span>
                <span>Sistema Web para funcionários</span>
                <span>Projeto acadêmico</span>

            </div>


            <div class="rodape-coluna">

                <h4>Área interna</h4>

                <p>
                    Acesso exclusivo para colaboradores.
                </p>

                <a
                    class="rodape-login"
                    href="${pageContext.request.contextPath}/login.jsp"
                >
                    Entrar
                </a>

            </div>

        </div>


        <div class="rodape-base">

            <div class="container rodape-base-conteudo">

                <span>
                    © 2026 Fast Splash
                </span>

                <span>
                    Desenvolvido para fins acadêmicos
                </span>

            </div>

        </div>

    </footer>

</body>

</html>
