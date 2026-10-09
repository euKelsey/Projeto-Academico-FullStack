<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>

    <html lang="pt-BR">

    <head>

        <meta charset="UTF-8">

        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Novo serviço | Fast Splash</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">

    </head>


    <body class="pagina-interna">


        <header class="interna-topo">

            <div class="container interna-topo-conteudo">

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
                        GESTÃO
                    </span>

                </div>


                <div class="interna-topo-acoes">

                    <a class="interna-link" href="${pageContext.request.contextPath}/servico">
                        ← Serviços
                    </a>

                    <a class="interna-link" href="${pageContext.request.contextPath}/dashboard.jsp">
                        Dashboard
                    </a>

                </div>

            </div>

        </header>


        <main class="interna-principal">

            <div class="container">


                <section class="interna-cabecalho">

                    <div>

                        <span class="destaque-pequeno">
                            Gestão de serviços
                        </span>

                        <h1>
                            Cadastrar serviço
                        </h1>

                        <p>
                            Inclua um novo serviço disponível
                            no Fast Splash.
                        </p>

                    </div>

                </section>


                <section class="form-interno-card">

                    <div class="form-interno-topo">

                        <h2>
                            Dados do serviço
                        </h2>

                        <p>
                            Preencha os dados abaixo para cadastrar
                            um novo serviço.
                        </p>

                    </div>


                    <form class="form-interno" action="${pageContext.request.contextPath}/servico" method="post">


                        <div class="campo-interno campo-interno-largo">

                            <label for="nome">
                                Nome do serviço
                            </label>

                            <input type="text" id="nome" name="nome" maxlength="100" placeholder="Ex.: Lavagem completa"
                                required>

                        </div>


                        <div class="campo-interno campo-interno-largo">

                            <label for="descricao">
                                Descrição
                            </label>

                            <textarea id="descricao" name="descricao" rows="5" maxlength="255"
                                placeholder="Descreva o que está incluído neste serviço."></textarea>

                        </div>


                        <div class="campo-interno">

                            <label for="precoExibicao">
                                Preço
                            </label>

                            <input type="text" id="precoExibicao" inputmode="numeric" placeholder="R$ 0,00"
                                autocomplete="off" required>

                            <input type="hidden" id="preco" name="preco">

                        </div>


                        <p class="form-observacao">
                            O valor informado será utilizado
                            nos novos agendamentos.
                        </p>


                        <div class="form-interno-acoes">

                            <a class="botao-interno-secundario" href="${pageContext.request.contextPath}/servico">
                                Cancelar
                            </a>

                            <button class="botao-interno-principal" type="submit">
                                Cadastrar serviço
                            </button>

                        </div>


                    </form>

                </section>


            </div>

        </main>

        <script>

            const precoExibicao =
                document.getElementById(
                    "precoExibicao"
                );

            const preco =
                document.getElementById(
                    "preco"
                );


            precoExibicao.addEventListener(
                "input",
                function () {

                    let numeros =
                        precoExibicao.value.replace(
                            /\D/g,
                            ""
                        );


                    if (numeros === "") {

                        precoExibicao.value = "";

                        preco.value = "";

                        return;
                    }


                    const valor =
                        Number(numeros) / 100;


                    precoExibicao.value =
                        valor.toLocaleString(
                            "pt-BR",
                            {
                                style: "currency",
                                currency: "BRL"
                            }
                        );


                    preco.value =
                        valor.toFixed(2);

                }
            );

        </script>

    </body>

    </html>