<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>Fast Splash</title>

    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/css/site.css"
    />
  </head>

  <body>
    <!-- =========================================
         CABEÇALHO
    ========================================== -->

    <header class="cabecalho">
      <div class="container cabecalho-conteudo">
        <div class="marca">Fast Splash</div>

        <nav class="menu">
          <a href="#inicio"> Início </a>

          <a href="#servicos"> Serviços </a>

          <a href="#promocoes"> Promoções </a>

          <a href="#aplicativo"> Aplicativo </a>

          <a
            class="area-interna"
            href="${pageContext.request.contextPath}/login.jsp"
          >
            Área interna
          </a>
        </nav>
      </div>
    </header>

    <main>
      <!-- =========================================
             HERO
        ========================================== -->

      <section id="inicio" class="hero">
        <div class="container hero-conteudo">
          <div class="hero-texto">
            <span class="destaque-pequeno"> Cuidado para o seu veículo </span>

            <h1>Seu carro limpo, rápido e com cuidado.</h1>

            <p>
              Serviços de lavagem pensados para deixar seu veículo sempre bem
              cuidado.
            </p>

            <a class="botao-principal" href="#servicos">
              Conheça nossos serviços
            </a>
          </div>

          <div class="hero-visual">
            <img
              class="hero-imagem"
              src="${pageContext.request.contextPath}/img/banners/banner-fast-splash.png"
              alt="Fast Splash - lavagem automotiva"
            />
          </div>
        </div>
      </section>

      <!-- =========================================
             SERVIÇOS
        ========================================== -->

      <section id="servicos" class="secao secao-servicos">
        <div class="container">
          <div class="titulo-secao">
            <span> Nossos serviços </span>

            <h2>Escolha o cuidado ideal para o seu carro</h2>

            <p>
              Opções para diferentes momentos, desde uma limpeza rápida até um
              cuidado mais completo.
            </p>
          </div>

          <div class="grade-servicos">
            <!-- SERVIÇO 1 -->

            <article class="card-servico">
              <div class="servico-topo">
                <span class="servico-categoria"> Rápido </span>

                <span class="servico-numero"> 01 </span>
              </div>

              <div class="icone-servico">💦</div>

              <h3>Lavagem Expressa</h3>

              <p class="descricao-servico">
                Uma opção prática para manter o veículo limpo no dia a dia.
              </p>

              <ul class="lista-servico">
                <li>Limpeza externa</li>

                <li>Enxágue completo</li>

                <li>Secagem</li>
              </ul>

              <div class="servico-rodape">
                <span class="servico-preco-label"> A partir de </span>

                <strong class="servico-preco"> R$ 30,00 </strong>
              </div>
            </article>

            <!-- SERVIÇO 2 -->

            <article class="card-servico destaque-card">
              <div class="servico-topo">
                <span class="servico-categoria categoria-destaque">
                  Mais escolhido
                </span>

                <span class="servico-numero"> 02 </span>
              </div>

              <div class="icone-servico">✨</div>

              <h3>Lavagem Completa</h3>

              <p class="descricao-servico">
                Um cuidado mais detalhado para deixar o veículo renovado.
              </p>

              <ul class="lista-servico">
                <li>Limpeza externa</li>

                <li>Limpeza interna</li>

                <li>Aspiração</li>
              </ul>

              <div class="servico-rodape">
                <span class="servico-preco-label"> A partir de </span>

                <strong class="servico-preco"> R$ 50,00 </strong>
              </div>
            </article>

            <!-- SERVIÇO 3 -->

            <article class="card-servico">
              <div class="servico-topo">
                <span class="servico-categoria"> Especial </span>

                <span class="servico-numero"> 03 </span>
              </div>

              <div class="icone-servico">🧽</div>

              <h3>Cuidados Especiais</h3>

              <p class="descricao-servico">
                Serviços adicionais para quem busca um cuidado ainda maior.
              </p>

              <ul class="lista-servico">
                <li>Acabamento detalhado</li>

                <li>Cuidados adicionais</li>

                <li>Proteção visual</li>
              </ul>

              <div class="servico-rodape">
                <span class="servico-preco-label"> Consulte </span>

                <strong class="servico-preco"> Valores </strong>
              </div>
            </article>
          </div>
        </div>
      </section>

            <!-- =========================================
                        PROMOÇÕES
            ========================================== -->

            <section id="promocoes" class="secao-promocao">
                <div class="container">
                <div class="promocao-card">
                    <div class="promocao-conteudo">
                    <div class="promocao-texto">
                        <span class="promocao-tag"> Oferta da semana </span>

                        <h2>
                        Lavagem Completa
                        <span>com cuidado extra</span>
                        </h2>

                        <p>
                        Aproveite uma condição especial para deixar seu veículo ainda
                        mais limpo e bem cuidado.
                        </p>

                        <div class="promocao-detalhes">
                        <div class="promocao-item">
                            <strong>Lavagem externa</strong>
                            <span>Limpeza completa da carroceria</span>
                        </div>

                        <div class="promocao-item">
                            <strong>Limpeza interna</strong>
                            <span>Mais cuidado dentro do veículo</span>
                        </div>

                        <div class="promocao-item">
                            <strong>Acabamento</strong>
                            <span>Detalhes para finalizar o serviço</span>
                        </div>
                        </div>

                        <a class="botao-promocao" href="#aplicativo">
                        Confira no aplicativo
                        </a>
                    </div>

                    <div class="promocao-destaque">
                        <span class="promocao-economia"> ECONOMIZE </span>

                        <strong> 20% </strong>

                        <span class="promocao-off"> OFF </span>

                        <small> Oferta promocional </small>
                    </div>
                    </div>

                    <div class="linha-velocidade linha-1"></div>

                    <div class="linha-velocidade linha-2"></div>
                </div>
                </div>
            </section>

      <!-- =========================================
             BENEFÍCIOS
        ========================================== -->

      <section class="secao beneficios">
        <div class="container">
          <div class="titulo-secao">
            <span> Fast Splash </span>

            <h2>Por que escolher nossos serviços?</h2>
          </div>

          <div class="grade-beneficios">
            <div class="beneficio">
              <strong> Agilidade </strong>

              <p>Um processo pensado para tornar o atendimento mais prático.</p>
            </div>

            <div class="beneficio">
              <strong> Qualidade </strong>

              <p>Cuidado em cada etapa do serviço.</p>
            </div>

            <div class="beneficio">
              <strong> Tecnologia </strong>

              <p>
                Acompanhe seus serviços utilizando o aplicativo Fast Splash.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- =========================================
             APLICATIVO
        ========================================== -->

      <section id="aplicativo" class="secao-app">
        <div class="container app-conteudo">
          <div>
            <span class="destaque-pequeno"> Fast Splash App </span>

            <h2>Seu lava-rápido também no celular</h2>

            <p>
              Pelo aplicativo você pode cadastrar veículos, realizar
              agendamentos, acompanhar serviços, pagamentos e consultar seu
              histórico.
            </p>
          </div>

          <div class="app-acoes">
            <button class="botao-secundario" type="button">
              Conheça o aplicativo
            </button>

            <p>Em breve teremos o acesso para novos clientes por aqui.</p>
          </div>
        </div>
      </section>
    </main>

    <!-- =========================================
         RODAPÉ
    ========================================== -->

    <footer class="rodape">
      <div class="container rodape-conteudo">
        <strong> Fast Splash </strong>

        <span> Projeto acadêmico </span>
      </div>
    </footer>
  </body>
</html>
