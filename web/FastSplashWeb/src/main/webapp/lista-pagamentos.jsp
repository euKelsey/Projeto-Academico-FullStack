<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="java.util.Locale" %>
            <%@ page import="java.text.NumberFormat" %>
                <%@ page import="java.time.format.DateTimeFormatter" %>
                    <%@ page import="com.fastsplash.web.model.Pagamento" %>

                        <% List<Pagamento> pagamentos =
                            (List<Pagamento>) request.getAttribute(
                                "pagamentos"
                                );

                                DateTimeFormatter formatoData =
                                DateTimeFormatter.ofPattern(
                                "dd/MM/yyyy"
                                );

                                DateTimeFormatter formatoHora =
                                DateTimeFormatter.ofPattern(
                                "HH:mm"
                                );

                                DateTimeFormatter formatoDataPagamento =
                                DateTimeFormatter.ofPattern(
                                "dd/MM/yyyy HH:mm"
                                );

                                NumberFormat formatoMoeda =
                                NumberFormat.getCurrencyInstance(
                                new Locale(
                                "pt",
                                "BR"
                                )
                                );
                                %>

                                <!DOCTYPE html>

                                <html lang="pt-BR">

                                <head>

                                    <meta charset="UTF-8">

                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">

                                    <title>Pagamentos | Fast Splash</title>

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

                                                <a class="interna-link"
                                                    href="${pageContext.request.contextPath}/dashboard.jsp">
                                                    ← Dashboard
                                                </a>

                                                <a class="interna-link"
                                                    href="${pageContext.request.contextPath}/logout">
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
                                                        Gestão financeira
                                                    </span>

                                                    <h1>
                                                        Pagamentos
                                                    </h1>

                                                    <p>
                                                        Consulte os pagamentos pendentes
                                                        e realizados pelos clientes.
                                                    </p>

                                                </div>

                                            </section>


                                            <section class="tabela-card">

                                                <div class="tabela-pesquisa">

                                                    <input class="tabela-pesquisa-campo" type="search"
                                                        id="pesquisaTabela" placeholder="Pesquisar na tabela..."
                                                        autocomplete="off">

                                                    <span class="tabela-pesquisa-resultado" id="resultadoPesquisa">
                                                    </span>

                                                </div>

                                                <div class="tabela-responsiva">


                                                    <% if ( pagamentos !=null && !pagamentos.isEmpty() ) { %>


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


                                                                    <th>
                                                                        Serviços
                                                                    </th>


                                                                    <th class="tabela-ordenavel" data-sort="agendamento"
                                                                        tabindex="0" role="button">
                                                                        Agendamento

                                                                        <span class="icone-ordenacao">
                                                                            ↕
                                                                        </span>
                                                                    </th>


                                                                    <th class="tabela-ordenavel" data-sort="valor"
                                                                        tabindex="0" role="button">
                                                                        Valor

                                                                        <span class="icone-ordenacao">
                                                                            ↕
                                                                        </span>
                                                                    </th>


                                                                    <th>
                                                                        Forma
                                                                    </th>


                                                                    <th>
                                                                        Data do pagamento
                                                                    </th>


                                                                    <th class="tabela-ordenavel" data-sort="status"
                                                                        tabindex="0" role="button">
                                                                        Status

                                                                        <span class="icone-ordenacao">
                                                                            ↕
                                                                        </span>
                                                                    </th>

                                                                </tr>

                                                            </thead>


                                                            <tbody>


                                                                <% for ( Pagamento pagamento : pagamentos ) { String
                                                                    status=pagamento .getStatusPagamento(); String
                                                                    classeStatus="status-pagamento-pendente" ; if
                                                                    ( "PAGO" .equals( status ) ) {
                                                                    classeStatus="status-pagamento-pago" ; } else if
                                                                    ( "CANCELADO" .equals( status ) ) {
                                                                    classeStatus="status-pagamento-cancelado" ; } String
                                                                    formaPagamento=pagamento .getFormaPagamento(); if (
                                                                    formaPagamento==null || formaPagamento.isBlank() ) {
                                                                    formaPagamento="—" ; } %>


                                                                    <tr data-cliente="<%= pagamento.getClienteNome() == null ? "" : pagamento.getClienteNome().toLowerCase() %>"
                                                                        data-agendamento="<%= pagamento.getDataAgendamento() %> <%= pagamento.getHorarioAgendamento() %>"
                                                                        data-valor="<%= pagamento.getValor() %>"
                                                                        data-status="<%= status == null ? "" : status.toLowerCase() %>">


                                                                        <td>

                                                                            <div class="agendamento-identidade">

                                                                                <strong>
                                                                                    <%= pagamento.getClienteNome() %>
                                                                                </strong>

                                                                                <span>
                                                                                    <%= pagamento.getVeiculoDescricao()
                                                                                        %>
                                                                                </span>

                                                                                <span>
                                                                                    Agendamento #<%=
                                                                                        pagamento.getIdAgendamento() %>
                                                                                </span>

                                                                            </div>

                                                                        </td>


                                                                        <td>

                                                                            <div class="agendamento-servicos">

                                                                                <% if ( pagamento
                                                                                    .getServicosDescricao() !=null ) {
                                                                                    %>

                                                                                    <%= pagamento.getServicosDescricao()
                                                                                        %>

                                                                                        <% } else { %>

                                                                                            —

                                                                                            <% } %>

                                                                            </div>

                                                                        </td>


                                                                        <td>

                                                                            <div class="agendamento-data">

                                                                                <strong>
                                                                                    <%= pagamento .getDataAgendamento()
                                                                                        .format( formatoData ) %>
                                                                                </strong>

                                                                                <span>
                                                                                    <%= pagamento
                                                                                        .getHorarioAgendamento()
                                                                                        .format( formatoHora ) %>
                                                                                </span>

                                                                            </div>

                                                                        </td>


                                                                        <td>

                                                                            <span class="valor-destaque">

                                                                                <%= formatoMoeda.format(
                                                                                    pagamento.getValor() ) %>

                                                                            </span>

                                                                        </td>


                                                                        <td>

                                                                            <span class="pagamento-forma">

                                                                                <%= formaPagamento %>

                                                                            </span>

                                                                        </td>


                                                                        <td>

                                                                            <% if ( pagamento .getDataPagamento() !=null
                                                                                ) { %>

                                                                                <div class="pagamento-data">

                                                                                    <%= pagamento .getDataPagamento()
                                                                                        .format( formatoDataPagamento )
                                                                                        %>

                                                                                </div>

                                                                                <% } else { %>

                                                                                    <span
                                                                                        class="pagamento-pendente-texto">
                                                                                        Aguardando pagamento
                                                                                    </span>

                                                                                    <% } %>

                                                                        </td>


                                                                        <td>

                                                                            <span
                                                                                class="status-badge <%= classeStatus %>">
                                                                                <%= status %>
                                                                            </span>

                                                                        </td>


                                                                    </tr>


                                                                    <% } %>


                                                            </tbody>

                                                        </table>


                                                        <% } else { %>


                                                            <div class="estado-vazio">

                                                                Nenhum pagamento encontrado.

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

                                            if (!tabela) {
                                                return;
                                            }


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


                                            const icone =
                                                cabecalho.querySelector(
                                                    ".icone-ordenacao"
                                                );

                                            if (icone) {

                                                icone.textContent =
                                                    crescente
                                                        ? "↑"
                                                        : "↓";
                                            }


                                            linhas.sort(
                                                function (
                                                    linhaA,
                                                    linhaB
                                                ) {

                                                    let valorA =
                                                        linhaA.dataset[chave]
                                                        || "";

                                                    let valorB =
                                                        linhaB.dataset[chave]
                                                        || "";


                                                    if (
                                                        chave === "valor"
                                                    ) {

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

                                                        return crescente
                                                            ? -1
                                                            : 1;
                                                    }


                                                    if (valorA > valorB) {

                                                        return crescente
                                                            ? 1
                                                            : -1;
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