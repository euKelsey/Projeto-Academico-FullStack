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

    String filtro = (String) request.getAttribute("filtro");

    if (!"pagos".equals(filtro)
            && !"cancelados".equals(filtro)
            && !"arquivados".equals(filtro)) {

        filtro = "pendentes";
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
            "Pagamento arquivado com sucesso. Registro financeiro preservado.";

        case "restaurado" ->
            "Pagamento restaurado com sucesso.";

        default -> "";
    };

    String mensagemErro =
        "operacaoInvalida".equals(erro)
        ? "Não foi possível alterar o arquivamento deste pagamento."
        : "";
%>

                                <!DOCTYPE html>

                                <html lang="pt-BR">

                                <head>

                                    <meta charset="UTF-8">

                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">

                                    <title>Pagamentos | Fast Splash</title>

                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/interno.css">

                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/pagamentos.css">

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
<nav class="filtros-clientes" aria-label="Status dos pagamentos">

    <a class="filtro-cliente <%= "pendentes".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/pagamento?filtro=pendentes">
        Pendentes
    </a>

    <a class="filtro-cliente <%= "pagos".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/pagamento?filtro=pagos">
        Pagos
    </a>

    <a class="filtro-cliente <%= "cancelados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/pagamento?filtro=cancelados">
        Cancelados
    </a>

    <a class="filtro-cliente <%= "arquivados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/pagamento?filtro=arquivados">
        Arquivados
    </a>
</nav>


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

                                                                <th>Ações</th>
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
                                                                                        <%= "CANCELADO".equals(status)
        ? "—" : "Aguardando pagamento" %>
                                                                                    </span>

                                                                                    <% } %>

                                                                        </td>


                                                                        <td>

                                                                            <span
                                                                                class="status-badge <%= classeStatus %>">
                                                                                <%= status %>

        <% if (pagamento.isArquivado()) { %>
            <small> · Arquivado</small>
        <% } %>
                                                                            </span>

                                                                        </td>



<td>
    <div class="acoes-tabela">

        <% if (administrador
                && pagamento.getIdPagamento() > 0) { %>

            <% if (pagamento.isArquivado()) { %>

                <form action="${pageContext.request.contextPath}/pagamento"
                      method="post">

                    <input type="hidden" name="acao" value="restaurar">
                    <input type="hidden" name="filtro" value="<%= filtro %>">
                    <input type="hidden" name="idPagamento"
                           value="<%= pagamento.getIdPagamento() %>">

                    <button class="acao-status-cliente acao-reativar-cliente"
                            type="submit">
                        Restaurar
                    </button>

                </form>

            <% } else if ("PAGO".equals(status)
                    || "CANCELADO".equals(status)) { %>

                <form action="${pageContext.request.contextPath}/pagamento"
                      method="post">

                    <input type="hidden" name="acao" value="arquivar">
                    <input type="hidden" name="filtro" value="<%= filtro %>">
                    <input type="hidden" name="idPagamento"
                           value="<%= pagamento.getIdPagamento() %>">

                    <button class="acao-status-cliente acao-inativar-cliente"
                            type="submit"
                            onclick="return confirm('Deseja arquivar este pagamento? O registro financeiro sera preservado.');">
                        Arquivar
                    </button>

                </form>

            <% } else { %>

                <span class="dashboard-card-acao">—</span>

            <% } %>

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

                                                                Nenhum pagamento encontrado nesta categoria.

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

                                <script src="${pageContext.request.contextPath}/js/menu-lateral.js"></script>
</body>

                                </html>
