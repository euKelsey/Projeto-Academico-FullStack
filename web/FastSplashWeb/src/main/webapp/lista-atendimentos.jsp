<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="java.util.Set" %>
            <%@ page import="java.time.format.DateTimeFormatter" %>
                <%@ page import="com.fastsplash.web.model.Atendimento" %>

                    <% List<Atendimento> atendimentos =
                        (List<Atendimento>) request.getAttribute(
                            "atendimentos"
                            );

                            Set<Integer> agendamentosPagos =
                                (Set<Integer>) request.getAttribute(
                                    "agendamentosPagos"
                                    );

                                    String erro =
                                    (String) request.getAttribute(
                                    "erro"
                                    );

                                    DateTimeFormatter formatoDataHora =
                                    DateTimeFormatter.ofPattern(
                                    "dd/MM/yyyy HH:mm"
                                    );

    String filtro = request.getParameter("filtro");

    if (!"emLavagem".equals(filtro)
            && !"finalizados".equals(filtro)
            && !"arquivados".equals(filtro)) {

        filtro = "aguardando";
    }

    boolean administrador =
        "ADMINISTRADOR".equals(
            session.getAttribute("nivelAcesso"));

    String resultado = request.getParameter("status");

    String mensagemSucesso = switch (
        resultado == null ? "" : resultado
    ) {
        case "arquivado" ->
            "Atendimento arquivado com sucesso.";

        case "restaurado" ->
            "Atendimento restaurado com sucesso.";

        default -> "";
    };

    if ("operacaoInvalida".equals(
            request.getParameter("erro"))) {

        erro = "Somente atendimentos finalizados podem ser arquivados ou restaurados conforme seu estado atual.";
    }
%>

                                    <!DOCTYPE html>

                                    <html lang="pt-BR">

                                    <head>

                                        <meta charset="UTF-8">

                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                                        <title>Atendimentos | Fast Splash</title>

                                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/interno.css">

                                        <link rel="stylesheet"
                                            href="${pageContext.request.contextPath}/css/atendimentos.css">

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

<section class="interna-cabecalho">

                                                    <div>

                                                        <span class="destaque-pequeno">
                                                            Gestão de atendimentos
                                                        </span>

                                                        <h1>
                                                            Atendimentos
                                                        </h1>

                                                        <p>
                                                            Acompanhe o fluxo da lavagem,
                                                            do aguardo até a finalização.
                                                        </p>

                                                    </div>


                                                    <a class="botao-interno-principal"
                                                        href="${pageContext.request.contextPath}/atendimento?acao=novo">
                                                        + Novo atendimento
                                                    </a>

                                                </section>


                                                <% if ( erro !=null && !erro.isBlank() ) { %>

                                                    <div class="estado-vazio"
                                                        style="margin-bottom: 18px; border: 1px solid rgba(255, 138, 31, 0.45);">
                                                        <strong>Não foi possível realizar a operação.</strong>
                                                        <br>
                                                        <%= erro %>
                                                    </div>

                                                    <% } %>


                                                        <section class="tabela-card">
<nav class="filtros-clientes" aria-label="Status dos atendimentos">

    <a class="filtro-cliente <%= "aguardando".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/atendimento?filtro=aguardando">
        Aguardando
    </a>

    <a class="filtro-cliente <%= "emLavagem".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/atendimento?filtro=emLavagem">
        Em lavagem
    </a>

    <a class="filtro-cliente <%= "finalizados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/atendimento?filtro=finalizados">
        Finalizados
    </a>

    <a class="filtro-cliente <%= "arquivados".equals(filtro)
        ? "filtro-selecionado" : "" %>"
       href="${pageContext.request.contextPath}/atendimento?filtro=arquivados">
        Arquivados
    </a>
</nav>


                                                            <div class="tabela-pesquisa">

                                                                <input class="tabela-pesquisa-campo" type="search"
                                                                    id="pesquisaTabela"
                                                                    placeholder="Pesquisar na tabela..."
                                                                    autocomplete="off">

                                                                <span class="tabela-pesquisa-resultado"
                                                                    id="resultadoPesquisa">
                                                                </span>

                                                            </div>

                                                            <div class="tabela-responsiva">


                                                                <% if ( atendimentos !=null && !atendimentos.isEmpty() )
                                                                    { %>


                                                                    <table class="tabela-interna">

                                                                        <thead>

                                                                            <tr>

                                                                                <th>
                                                                                    Cliente / Veículo
                                                                                </th>

                                                                                <th>
                                                                                    Serviços
                                                                                </th>

                                                                                <th>
                                                                                    Status
                                                                                </th>

                                                                                <th>
                                                                                    Pagamento
                                                                                </th>

                                                                                <th>
                                                                                    Início
                                                                                </th>

                                                                                <th>
                                                                                    Fim
                                                                                </th>

                                                                                <th>
                                                                                    Ações
                                                                                </th>

                                                                            </tr>

                                                                        </thead>


                                                                        <tbody>


                                                                            <% for ( Atendimento atendimento :
                                                                                atendimentos ) { String
                                                                                status=atendimento.getStatus(); boolean
                                                                                pagamentoPago=agendamentosPagos !=null
                                                                                && agendamentosPagos.contains(
                                                                                atendimento.getIdAgendamento() ); String
                                                                                classeStatus="status-aguardando" ; if
                                                                                ( "EM_LAVAGEM" .equals( status ) ) {
                                                                                classeStatus="status-em-lavagem" ; }
                                                                                else if ( "FINALIZADO" .equals( status )
                                                                                ) { classeStatus="status-finalizado" ; }
                                                                                %>


                                                                                <tr>

                                                                                    <td>

                                                                                        <div
                                                                                            class="atendimento-identidade">

                                                                                            <strong>
                                                                                                <%= atendimento.getClienteNome()
                                                                                                    %>
                                                                                            </strong>

                                                                                            <span>
                                                                                                <%= atendimento.getVeiculoDescricao()
                                                                                                    %>
                                                                                            </span>

                                                                                            <span>
                                                                                                Atendimento #<%=
                                                                                                    atendimento.getIdAtendimento()
                                                                                                    %>
                                                                                                    · Agendamento #<%=
                                                                                                        atendimento.getIdAgendamento()
                                                                                                        %>
                                                                                            </span>

                                                                                        </div>

                                                                                    </td>


                                                                                    <td>

                                                                                        <div
                                                                                            class="agendamento-servicos">
                                                                                            <%= atendimento.getServicosDescricao()
                                                                                                %>
                                                                                        </div>

                                                                                    </td>


                                                                                    <td>

                                                                                        <span
                                                                                            class="status-badge <%= classeStatus %>">
                                                                                            <%= status %>
        <% if (atendimento.isArquivado()) { %>
            <small> · Arquivado</small>
        <% } %>
                                                                                        </span>

                                                                                    </td>


                                                                                    <td>

                                                                                        <% String classePagamento=pagamentoPago
                                                                                            ? "status-finalizado"
                                                                                            : "status-aguardando" ; %>

                                                                                            <span
                                                                                                class="status-badge <%= classePagamento %>">

                                                                                                <%= pagamentoPago
                                                                                                    ? "PAGO"
                                                                                                    : "PENDENTE" %>
                                                                                            </span>

                                                                                    </td>


                                                                                    <td>

                                                                                        <div class="atendimento-data">

                                                                                            <% if (
                                                                                                atendimento.getDataInicio()
                                                                                                !=null ) { %>

                                                                                                <strong>
                                                                                                    <%= atendimento.getDataInicio().format(formatoDataHora)
                                                                                                        %>
                                                                                                </strong>

                                                                                                <% } else { %>

                                                                                                    <span>
                                                                                                        Ainda não
                                                                                                        iniciado
                                                                                                    </span>

                                                                                                    <% } %>

                                                                                        </div>

                                                                                    </td>


                                                                                    <td>

                                                                                        <div class="atendimento-data">

                                                                                            <% if (
                                                                                                atendimento.getDataFim()
                                                                                                !=null ) { %>

                                                                                                <strong>
                                                                                                    <%= atendimento.getDataFim().format(formatoDataHora)
                                                                                                        %>
                                                                                                </strong>

                                                                                                <% } else { %>

                                                                                                    <span>
                                                                                                        —
                                                                                                    </span>

                                                                                                    <% } %>

                                                                                        </div>

                                                                                    </td>


                                                                                    <td>

                                                                                        <div class="acoes-tabela">

                                                                                            <a class="acao-detalhes"
                                                                                                href="${pageContext.request.contextPath}/atendimento?acao=detalhes&idAtendimento=<%= atendimento.getIdAtendimento() %>">
                                                                                                Detalhes
                                                                                            </a>


                                                                                            <% if ( "AGUARDANDO"
                                                                                                .equals( status ) &&
                                                                                                pagamentoPago ) { %>

                                                                                                <form
                                                                                                    action="${pageContext.request.contextPath}/atendimento"
                                                                                                    method="post">

                                                                                                    <input type="hidden"
                                                                                                        name="acao"
                                                                                                        value="iniciar">

                                                                                                    <input type="hidden"
                                                                                                        name="idAtendimento"
                                                                                                        value="<%= atendimento.getIdAtendimento() %>">

                                                                                                    <button
                                                                                                        class="acao-iniciar"
                                                                                                        type="submit">
                                                                                                        Iniciar
                                                                                                    </button>

                                                                                                </form>

                                                                                                <% } else if
                                                                                                    ( "AGUARDANDO"
                                                                                                    .equals( status ) &&
                                                                                                    !pagamentoPago ) {
                                                                                                    %>

                                                                                                    <span
                                                                                                        class="status-badge status-aguardando"
                                                                                                        title="O atendimento só pode começar após o pagamento.">
                                                                                                        Aguardando
                                                                                                        pagamento
                                                                                                    </span>

                                                                                                    <% } %>


                                                                                                        <% if
                                                                                                            ( "EM_LAVAGEM"
                                                                                                            .equals(
                                                                                                            status ) ) {
                                                                                                            %>

                                                                                                            <form
                                                                                                                action="${pageContext.request.contextPath}/atendimento"
                                                                                                                method="post">

                                                                                                                <input
                                                                                                                    type="hidden"
                                                                                                                    name="acao"
                                                                                                                    value="finalizar">

                                                                                                                <input
                                                                                                                    type="hidden"
                                                                                                                    name="idAtendimento"
                                                                                                                    value="<%= atendimento.getIdAtendimento() %>">

                                                                                                                <button
                                                                                                                    class="acao-finalizar"
                                                                                                                    type="submit">
                                                                                                                    Finalizar
                                                                                                                </button>

                                                                                                            </form>

                                                                                                            <% } %>


    <% if (administrador
            && "FINALIZADO".equals(status)) { %>

        <% if (atendimento.isArquivado()) { %>

            <form action="${pageContext.request.contextPath}/atendimento"
                  method="post">

                <input type="hidden" name="acao" value="restaurar">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idAtendimento"
                       value="<%= atendimento.getIdAtendimento() %>">

                <button class="acao-status-cliente acao-reativar-cliente"
                        type="submit">
                    Restaurar
                </button>

            </form>

        <% } else { %>

            <form action="${pageContext.request.contextPath}/atendimento"
                  method="post">

                <input type="hidden" name="acao" value="arquivar">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idAtendimento"
                       value="<%= atendimento.getIdAtendimento() %>">

                <button class="acao-status-cliente acao-inativar-cliente"
                        type="submit"
                        onclick="return confirm('Deseja arquivar este atendimento?');">
                    Arquivar
                </button>

            </form>

        <% } %>

    <% } %>
</div>

                                                                                    </td>

                                                                                </tr>


                                                                                <% } %>


                                                                        </tbody>

                                                                    </table>


                                                                    <% } else { %>

                                                                        <div class="estado-vazio">
                                                                            Nenhum atendimento encontrado nesta categoria.
                                                                        </div>

                                                                        <% } %>


                                                            </div>

                                                        </section>

                                            </div>

                                        </main>

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
