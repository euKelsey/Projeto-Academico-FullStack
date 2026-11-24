<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="java.time.format.DateTimeFormatter" %>
            <%@ page import="com.fastsplash.web.model.Agendamento" %>


<%
    List<Agendamento> agendamentos =
        (List<Agendamento>) request.getAttribute("agendamentos");

    DateTimeFormatter formatoData =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");

    DateTimeFormatter formatoHora =
        DateTimeFormatter.ofPattern("HH:mm");

    String filtro = request.getParameter("filtro");

    if (!"concluidos".equals(filtro)
            && !"cancelados".equals(filtro)
            && !"arquivados".equals(filtro)) {
        filtro = "agendados";
    }

    boolean administrador =
        "ADMINISTRADOR".equals(
            session.getAttribute("nivelAcesso"));

    String resultado = request.getParameter("status");
    String erro = request.getParameter("erro");

    String mensagemSucesso = switch (
        resultado == null ? "" : resultado
    ) {
        case "arquivado" ->
            "Agendamento arquivado com sucesso.";

        case "restaurado" ->
            "Agendamento restaurado com sucesso.";

        default -> "";
    };

    String mensagemErro =
        "operacaoInvalida".equals(erro)
        ? "Não foi possível realizar esta operação. Verifique o status e a existência de atendimentos ou pagamentos pendentes."
        : "";
%>


                        <!DOCTYPE html>

                        <html lang="pt-BR">

                        <head>

                            <meta charset="UTF-8">

                            <meta name="viewport" content="width=device-width, initial-scale=1.0">

                            <title>Agendamentos | Fast Splash</title>

                            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/interno.css">

                            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/agendamentos.css">

                        <style>
    .filtros-clientes {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        padding: 20px;
    }

    .filtro-cliente {
        display: inline-flex;
        align-items: center;
        padding: 10px 18px;
        border: 1px solid #d1d5db;
        border-radius: 8px;
        text-decoration: none;
        color: inherit;
        font-weight: 600;
        transition: 0.2s;
    }

    .filtro-cliente:hover {
        border-color: #f97316;
    }

    .filtro-selecionado {
        background: #ea580c;
        border-color: #ea580c;
        color: #ffffff;
    }

    .aviso-sucesso-cliente {
        padding: 16px;
        margin-bottom: 20px;
        border: 1px solid #86efac;
        border-radius: 8px;
        background: #f0fdf4;
        color: #166534;
    }

    .acoes-tabela {
        flex-wrap: wrap;
        gap: 8px;
    }

    .acoes-tabela form {
        margin: 0;
    }

    .acao-status-cliente {
        cursor: pointer;
        padding: 7px 12px;
        border: 1px solid currentColor;
        border-radius: 6px;
        font-weight: 600;
        background: transparent;
    }

    .acao-inativar-cliente {
        color: #b45309;
    }

    .acao-reativar-cliente {
        color: #15803d;
    }
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/menu-lateral.css">
</head>


                        <body class="pagina-interna fs-layout">
<jsp:include page="/WEB-INF/includes/menu-lateral.jsp" />






                            <main class="interna-principal">

                                <div class="container">



<% if (!mensagemSucesso.isEmpty()) { %>
    <div class="aviso-sucesso-cliente" role="status">
        <strong><%= mensagemSucesso %></strong>
    </div>
<% } %>

<% if (!mensagemErro.isEmpty()) { %>
    <div class="aviso-interno" role="alert">
        <strong><%= mensagemErro %></strong>
    </div>
<% } %>
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
<nav class="filtros-clientes" aria-label="Status dos agendamentos">

    <a class="filtro-cliente <%= "agendados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/agendamento?filtro=agendados">
        Agendados
    </a>

    <a class="filtro-cliente <%= "concluidos".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/agendamento?filtro=concluidos">
        Concluídos
    </a>

    <a class="filtro-cliente <%= "cancelados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/agendamento?filtro=cancelados">
        Cancelados
    </a>

    <a class="filtro-cliente <%= "arquivados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/agendamento?filtro=arquivados">
        Arquivados
    </a>
</nav>


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

    <% if (agendamento.isArquivado()) { %>
        <small> · Arquivado</small>
    <% } %>
                                                                    </span>

                                                                </td>


                                                                <td>


<div class="acoes-tabela">

    <% if ("AGENDADO".equals(status)
            && !agendamento.isArquivado()) { %>

        <form action="${pageContext.request.contextPath}/agendamento"
              method="post">

            <input type="hidden" name="acao" value="cancelar">
            <input type="hidden" name="idAgendamento"
                   value="<%= agendamento.getIdAgendamento() %>">

            <button class="acao-cancelar" type="submit"
                    onclick="return confirm('Deseja cancelar este agendamento?');">
                Cancelar
            </button>

        </form>

    <% } else if (administrador && agendamento.isArquivado()) { %>

        <form action="${pageContext.request.contextPath}/agendamento"
              method="post">

            <input type="hidden" name="acao" value="restaurar">
            <input type="hidden" name="filtro" value="<%= filtro %>">
            <input type="hidden" name="idAgendamento"
                   value="<%= agendamento.getIdAgendamento() %>">

            <button class="acao-status-cliente acao-reativar-cliente"
                    type="submit">
                Restaurar
            </button>

        </form>

    <% } else if (administrador
            && ("CONCLUIDO".equals(status)
                || "CANCELADO".equals(status))) { %>

        <form action="${pageContext.request.contextPath}/agendamento"
              method="post">

            <input type="hidden" name="acao" value="arquivar">
            <input type="hidden" name="filtro" value="<%= filtro %>">
            <input type="hidden" name="idAgendamento"
                   value="<%= agendamento.getIdAgendamento() %>">

            <button class="acao-status-cliente acao-inativar-cliente"
                    type="submit"
                    onclick="return confirm('Deseja arquivar este agendamento?');">
                Arquivar
            </button>

        </form>

    <% } else { %>

        <span class="dashboard-card-acao">—</span>

    <% } %>

</div>

</td>

                                                            </tr>


                                                            <% } %>


                                                    </tbody>

                                                </table>


                                                <% } else { %>


                                                    <div class="estado-vazio">

                                                        Nenhum agendamento encontrado nesta categoria.

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

                        <script src="${pageContext.request.contextPath}/js/menu-lateral.js"></script>
</body>

                        </html>
