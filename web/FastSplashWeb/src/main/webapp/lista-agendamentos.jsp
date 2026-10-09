<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="java.time.format.DateTimeFormatter" %>
            <%@ page import="com.fastsplash.web.model.Agendamento" %>

                <% List<Agendamento> agendamentos =
                    (List<Agendamento>) request.getAttribute(
                        "agendamentos"
                        );

                        DateTimeFormatter formatoData =
                        DateTimeFormatter.ofPattern(
                        "dd/MM/yyyy"
                        );

                        DateTimeFormatter formatoHora =
                        DateTimeFormatter.ofPattern(
                        "HH:mm"
                        );
                        %>

                        <!DOCTYPE html>

                        <html lang="pt-BR">

                        <head>

                            <meta charset="UTF-8">

                            <meta name="viewport" content="width=device-width, initial-scale=1.0">

                            <title>Agendamentos | Fast Splash</title>

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

                                        <a class="interna-link" href="${pageContext.request.contextPath}/dashboard.jsp">
                                            ← Dashboard
                                        </a>

                                        <a class="interna-link" href="${pageContext.request.contextPath}/logout">
                                            Sair
                                        </a>

                                    </div>

                                </div>

                            </header>


                            <main class="interna-principal">

                                <div class="container">


                                    <section class="interna-cabecalho">

                                        <div>

                                            <span class="destaque-pequeno">
                                                Gestão de agendamentos
                                            </span>

                                            <h1>
                                                Agendamentos
                                            </h1>

                                            <p>
                                                Consulte horários, serviços,
                                                valores e status dos agendamentos.
                                            </p>

                                        </div>


                                        <a class="botao-interno-principal"
                                            href="${pageContext.request.contextPath}/agendamento?acao=novo">
                                            + Novo agendamento
                                        </a>

                                    </section>


                                    <section class="tabela-card">

                                        <div class="tabela-pesquisa">

                                            <input class="tabela-pesquisa-campo" type="search" id="pesquisaTabela"
                                                placeholder="Pesquisar na tabela..." autocomplete="off">

                                            <span class="tabela-pesquisa-resultado" id="resultadoPesquisa">
                                            </span>

                                        </div>

                                        <div class="tabela-responsiva">


                                            <% if ( agendamentos !=null && !agendamentos.isEmpty() ) { %>


                                                <table class="tabela-interna">

                                                    <thead>

                                                        <tr>

                                                            <th class="tabela-ordenavel" data-sort="cliente"
                                                                tabindex="0" role="button">
                                                                Cliente / Veículo
                                                                <span class="icone-ordenacao">
                                                                    ↕
                                                                </span>
                                                            </th>

                                                            <th class="tabela-ordenavel" data-sort="servicos"
                                                                tabindex="0" role="button">
                                                                Serviços
                                                                <span class="icone-ordenacao">
                                                                    ↕
                                                                </span>
                                                            </th>

                                                            <th class="tabela-ordenavel" data-sort="data" tabindex="0"
                                                                role="button">
                                                                Data / Horário
                                                                <span class="icone-ordenacao">
                                                                    ↕
                                                                </span>
                                                            </th>

                                                            <th class="tabela-ordenavel" data-sort="valor" tabindex="0"
                                                                role="button">
                                                                Valor
                                                                <span class="icone-ordenacao">
                                                                    ↕
                                                                </span>
                                                            </th>

                                                            <th class="tabela-ordenavel" data-sort="status" tabindex="0"
                                                                role="button">
                                                                Status
                                                                <span class="icone-ordenacao">
                                                                    ↕
                                                                </span>
                                                            </th>

                                                            <th>
                                                                Ações
                                                            </th>

                                                        </tr>

                                                    </thead>


                                                    <tbody>


                                                        <% for ( Agendamento agendamento : agendamentos ) { String
                                                            status=agendamento.getStatus(); String
                                                            classeStatus="status-agendado" ; if ( "CANCELADO" .equals(
                                                            status ) ) { classeStatus="status-cancelado" ; } else if
                                                            ( "CONCLUIDO" .equals( status ) ) {
                                                            classeStatus="status-concluido" ; } %>


                                                            <tr data-cliente="<%= agendamento.getClienteNome() == null ? "" : agendamento.getClienteNome().toLowerCase() %>"
                                                                data-servicos="<%= agendamento.getServicosDescricao() == null ? "" : agendamento.getServicosDescricao().toLowerCase() %>"
                                                                data-data="<%= agendamento.getData().toString() %> <%= agendamento.getHorario().toString() %>"
                                                                data-valor="<%= agendamento.getValorTotal() %>"
                                                                data-status="<%= status.toLowerCase() %>">

                                                                <td>

                                                                    <div class="agendamento-identidade">

                                                                        <strong>
                                                                            <%= agendamento.getClienteNome() %>
                                                                        </strong>

                                                                        <span>
                                                                            <%= agendamento.getVeiculoDescricao() %>
                                                                        </span>

                                                                        <span>
                                                                            Agendamento #<%=
                                                                                agendamento.getIdAgendamento() %>
                                                                        </span>

                                                                    </div>

                                                                </td>


                                                                <td>

                                                                    <div class="agendamento-servicos">

                                                                        <%= agendamento.getServicosDescricao() %>

                                                                    </div>

                                                                </td>


                                                                <td>

                                                                    <div class="agendamento-data">

                                                                        <strong>
                                                                            <%= agendamento.getData().format(formatoData)
                                                                                %>
                                                                        </strong>

                                                                        <span>
                                                                            <%= agendamento.getHorario().format(formatoHora)
                                                                                %>
                                                                        </span>

                                                                    </div>

                                                                </td>


                                                                <td>

                                                                    <span class="valor-destaque">

                                                                        R$
                                                                        <%= String.format( "%.2f" ,
                                                                            agendamento.getValorTotal() ) %>

                                                                    </span>

                                                                </td>


                                                                <td>

                                                                    <span class="status-badge <%= classeStatus %>">
                                                                        <%= status %>
                                                                    </span>

                                                                </td>


                                                                <td>

                                                                    <% if ( "AGENDADO" .equals( status ) ) { %>


                                                                        <form
                                                                            action="${pageContext.request.contextPath}/agendamento"
                                                                            method="post">

                                                                            <input type="hidden" name="acao"
                                                                                value="cancelar">

                                                                            <input type="hidden" name="idAgendamento"
                                                                                value="<%= agendamento.getIdAgendamento() %>">

                                                                            <button class="acao-cancelar" type="submit"
                                                                                onclick="return confirm('Deseja realmente cancelar este agendamento?');">
                                                                                Cancelar
                                                                            </button>

                                                                        </form>


                                                                        <% } else { %>


                                                                            <span class="dashboard-card-acao">
                                                                                —
                                                                            </span>


                                                                            <% } %>

                                                                </td>

                                                            </tr>


                                                            <% } %>


                                                    </tbody>

                                                </table>


                                                <% } else { %>


                                                    <div class="estado-vazio">

                                                        Nenhum agendamento cadastrado.

                                                    </div>


                                                    <% } %>


                                        </div>

                                    </section>

                                </div>

                            </main>



                            <script>

                                const tabela =
                                    document.querySelector(
                                        ".tabela-interna"
                                    );

                                const cabecalhosOrdenaveis =
                                    document.querySelectorAll(
                                        ".tabela-ordenavel"
                                    );


                                function ordenarTabela(
                                    cabecalho
                                ) {

                                    const chave =
                                        cabecalho.dataset.sort;

                                    const corpo =
                                        tabela.querySelector(
                                            "tbody"
                                        );

                                    const linhas =
                                        Array.from(
                                            corpo.querySelectorAll(
                                                "tr"
                                            )
                                        );

                                    const direcaoAtual =
                                        cabecalho.dataset.direcao;

                                    const crescente =
                                        direcaoAtual !== "asc";


                                    cabecalhosOrdenaveis.forEach(
                                        function (item) {

                                            item.dataset.direcao = "";

                                            const icone =
                                                item.querySelector(
                                                    ".icone-ordenacao"
                                                );

                                            if (icone) {
                                                icone.textContent = "↕";
                                            }
                                        }
                                    );


                                    cabecalho.dataset.direcao =
                                        crescente
                                            ? "asc"
                                            : "desc";

                                    cabecalho.querySelector(
                                        ".icone-ordenacao"
                                    ).textContent =
                                        crescente
                                            ? "↑"
                                            : "↓";


                                    linhas.sort(
                                        function (linhaA, linhaB) {

                                            let valorA =
                                                linhaA.dataset[chave] || "";

                                            let valorB =
                                                linhaB.dataset[chave] || "";


                                            if (chave === "valor") {

                                                valorA =
                                                    Number(valorA);

                                                valorB =
                                                    Number(valorB);

                                            } else {

                                                valorA =
                                                    valorA.toString();

                                                valorB =
                                                    valorB.toString();
                                            }


                                            if (valorA < valorB) {
                                                return crescente ? -1 : 1;
                                            }

                                            if (valorA > valorB) {
                                                return crescente ? 1 : -1;
                                            }

                                            return 0;
                                        }
                                    );


                                    linhas.forEach(
                                        function (linha) {

                                            corpo.appendChild(
                                                linha
                                            );
                                        }
                                    );
                                }


                                cabecalhosOrdenaveis.forEach(
                                    function (cabecalho) {

                                        cabecalho.addEventListener(
                                            "click",
                                            function () {

                                                ordenarTabela(
                                                    cabecalho
                                                );
                                            }
                                        );


                                        cabecalho.addEventListener(
                                            "keydown",
                                            function (evento) {

                                                if (
                                                    evento.key === "Enter"
                                                    || evento.key === " "
                                                ) {

                                                    evento.preventDefault();

                                                    ordenarTabela(
                                                        cabecalho
                                                    );
                                                }
                                            }
                                        );
                                    }
                                );

                            </script>

                            <script>

                                const pesquisaTabela =
                                    document.getElementById(
                                        "pesquisaTabela"
                                    );

                                const resultadoPesquisa =
                                    document.getElementById(
                                        "resultadoPesquisa"
                                    );


                                if (pesquisaTabela) {

                                    pesquisaTabela.addEventListener(
                                        "input",
                                        function () {

                                            const termo =
                                                pesquisaTabela
                                                    .value
                                                    .toLowerCase()
                                                    .trim();

                                            const linhas =
                                                document.querySelectorAll(
                                                    ".tabela-interna tbody tr"
                                                );

                                            let encontrados = 0;


                                            linhas.forEach(
                                                function (linha) {

                                                    const textoLinha =
                                                        linha
                                                            .innerText
                                                            .toLowerCase();

                                                    const encontrou =
                                                        textoLinha.includes(
                                                            termo
                                                        );


                                                    linha.style.display =
                                                        encontrou
                                                            ? ""
                                                            : "none";


                                                    if (encontrou) {
                                                        encontrados++;
                                                    }

                                                }
                                            );


                                            if (termo === "") {

                                                resultadoPesquisa.textContent =
                                                    "";

                                            } else {

                                                resultadoPesquisa.textContent =
                                                    encontrados === 1
                                                        ? "1 resultado encontrado"
                                                        : encontrados
                                                        + " resultados encontrados";
                                            }

                                        }
                                    );

                                }

                            </script>

                        </body>

                        </html>