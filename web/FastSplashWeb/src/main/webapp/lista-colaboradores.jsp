<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.fastsplash.web.model.Colaborador" %>


<%
    List<Colaborador> colaboradores =
        (List<Colaborador>) request.getAttribute("colaboradores");

    String filtro = request.getParameter("filtro");

    if (!"inativos".equals(filtro)
            && !"excluidos".equals(filtro)) {
        filtro = "ativos";
    }

    boolean administrador =
        "ADMINISTRADOR".equals(
            session.getAttribute("nivelAcesso"));

    Colaborador usuarioAtual =
        (Colaborador) session.getAttribute("usuarioLogado");

    int idUsuarioLogado = usuarioAtual != null
        ? usuarioAtual.getIdColaborador()
        : -1;

    String status = request.getParameter("status");
    String erro = request.getParameter("erro");

    String mensagemSucesso = switch (
        status == null ? "" : status
    ) {
        case "inativado" ->
            "Colaborador inativado com sucesso.";

        case "reativado" ->
            "Colaborador reativado com sucesso.";

        case "excluido" ->
            "Colaborador excluído com sucesso. Histórico preservado.";

        case "restaurado" ->
            "Colaborador restaurado com sucesso.";

        default -> "";
    };

    String mensagemErro = switch (
        erro == null ? "" : erro
    ) {
        case "ultimoAdministrador" ->
            "O sistema precisa manter pelo menos um administrador ativo.";

        case "proprioUsuario" ->
            "Você não pode inativar ou excluir sua própria conta.";

        case "pendencias" ->
            "Este colaborador possui atendimentos pendentes.";

        case "naoEncontrado" ->
            "Colaborador não encontrado.";

        case "jaAtivo" ->
            "Este colaborador já está ativo.";

        case "jaInativo" ->
            "Este colaborador já está inativo.";

        case "jaExcluido" ->
            "Este colaborador já está excluído.";

        case "naoExcluido" ->
            "Este colaborador não está excluído.";

        case "operacaoInvalida" ->
            "Não foi possível realizar esta operação.";

        default -> "";
    };
%>


                    <!DOCTYPE html>

                    <html lang="pt-BR">

                    <head>

                        <meta charset="UTF-8">

                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                        <title>Colaboradores | Fast Splash</title>

                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/interno.css">

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
                                            Gestão de equipe
                                        </span>

                                        <h1>
                                            Colaboradores
                                        </h1>

                                        <p>
                                            Consulte e gerencie os colaboradores
                                            cadastrados no Fast Splash.
                                        </p>

                                    </div>


                                    <a class="botao-interno-principal"
                                        href="${pageContext.request.contextPath}/colaborador?acao=novo">
                                        + Novo colaborador
                                    </a>

                                </section>


                                <section class="tabela-card">
<nav class="filtros-clientes" aria-label="Status dos colaboradores">

        <a class="filtro-cliente <%= "ativos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/colaborador?filtro=ativos">
            Ativos
        </a>

        <% if (administrador) { %>

        <a class="filtro-cliente <%= "inativos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/colaborador?filtro=inativos">
            Inativos
        </a>

        <a class="filtro-cliente <%= "excluidos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/colaborador?filtro=excluidos">
            Excluídos
        </a>

        <% } %>

    </nav>

                                    <div class="tabela-pesquisa">

                                        <input class="tabela-pesquisa-campo" type="search" id="pesquisaTabela"
                                            placeholder="Pesquisar na tabela..." autocomplete="off">

                                        <span class="tabela-pesquisa-resultado" id="resultadoPesquisa">
                                        </span>

                                    </div>

                                    <div class="tabela-responsiva">


                                        <% if ( colaboradores !=null && !colaboradores.isEmpty() ) { %>


                                            <table class="tabela-interna">

                                                <thead>

                                                    <tr>

                                                        <th>
                                                            Colaborador
                                                        </th>

                                                        <th>
                                                            Cargo
                                                        </th>

                                                        <th>
                                                            Nível de acesso
                                                        </th>

                                                        <th>
                                                            E-mail
                                                        </th>

                                                        <th>Status</th>
<th>Ações</th>

                                                    </tr>

                                                </thead>


                                                <tbody>


                                                    <% for ( Colaborador colaborador : colaboradores ) { String
                                                        nivel=colaborador .getNivelAcesso(); String
                                                        classeNivel="status-agendado" ; if ( "ADMINISTRADOR" .equals(
                                                        nivel ) ) { classeNivel="status-pagamento-pago" ; } else if
                                                        ( "ATENDENTE" .equals( nivel ) ) { classeNivel="status-agendado"
                                                        ; } else if ( "OPERACIONAL" .equals( nivel ) ) {
                                                        classeNivel="status-pagamento-pendente" ; } %>


                                                        <tr>

                                                            <td>

                                                                <div class="cliente-identidade">

                                                                    <span class="cliente-avatar">
                                                                        <%= colaborador .getNome() .substring(0, 1)
                                                                            .toUpperCase() %>
                                                                    </span>

                                                                    <div>

                                                                        <strong>
                                                                            <%= colaborador.getNome() %>
                                                                        </strong>

                                                                        <span>
                                                                            ID #<%= colaborador.getIdColaborador() %>
                                                                        </span>

                                                                    </div>

                                                                </div>

                                                            </td>


                                                            <td>
                                                                <%= colaborador.getCargo() %>
                                                            </td>


                                                            <td>

                                                                <span class="status-badge <%= classeNivel %>">
                                                                    <%= nivel %>
                                                                </span>

                                                            </td>


                                                            <td>

                                                                <% if ( colaborador.getEmail() !=null &&
                                                                    !colaborador.getEmail().isBlank() ) { %>

                                                                    <%= colaborador.getEmail() %>

                                                                        <% } else { %>

                                                                            —

                                                                            <% } %>

                                                            </td>



<td>
    <span class="status-badge <%= colaborador.isAtivo()
        ? "status-pagamento-pago"
        : "status-pagamento-pendente" %>">

        <%= colaborador.isExcluido()
            ? "Excluído"
            : colaborador.isAtivo()
                ? "Ativo"
                : "Inativo" %>

    </span>
</td>

<td>

<div class="acoes-tabela">

    <% if ("ativos".equals(filtro)) { %>

        <a class="acao-editar"
           href="${pageContext.request.contextPath}/colaborador?acao=editar&idColaborador=<%= colaborador.getIdColaborador() %>">
            Editar
        </a>

    <% } %>

    <% if (administrador) { %>

        <% if ("ativos".equals(filtro)
                && colaborador.getIdColaborador() != idUsuarioLogado) { %>

            <form action="${pageContext.request.contextPath}/colaborador"
                  method="post">

                <input type="hidden" name="acao" value="inativar">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idColaborador"
                       value="<%= colaborador.getIdColaborador() %>">

                <button class="acao-status-cliente acao-inativar-cliente"
                        type="submit"
                        onclick="return confirm('Deseja inativar este colaborador?');">
                    Inativar
                </button>

            </form>

        <% } %>

        <% if ("inativos".equals(filtro)) { %>

            <form action="${pageContext.request.contextPath}/colaborador"
                  method="post">

                <input type="hidden" name="acao" value="reativar">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idColaborador"
                       value="<%= colaborador.getIdColaborador() %>">

                <button class="acao-status-cliente acao-reativar-cliente"
                        type="submit">
                    Reativar
                </button>

            </form>

        <% } %>

        <% if (!"excluidos".equals(filtro)
                && colaborador.getIdColaborador() != idUsuarioLogado) { %>

            <form action="${pageContext.request.contextPath}/colaborador"
                  method="post">

                <input type="hidden" name="acao" value="excluir">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idColaborador"
                       value="<%= colaborador.getIdColaborador() %>">

                <button class="acao-excluir"
                        type="submit"
                        onclick="return confirm('Deseja excluir este colaborador?');">
                    Excluir
                </button>

            </form>

        <% } %>

        <% if ("excluidos".equals(filtro)) { %>

            <form action="${pageContext.request.contextPath}/colaborador"
                  method="post">

                <input type="hidden" name="acao" value="restaurar">
                <input type="hidden" name="filtro" value="<%= filtro %>">
                <input type="hidden" name="idColaborador"
                       value="<%= colaborador.getIdColaborador() %>">

                <button class="acao-status-cliente acao-reativar-cliente"
                        type="submit"
                        onclick="return confirm('Deseja restaurar este colaborador?');">
                    Restaurar
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

                                                    Nenhum colaborador encontrado nesta categoria.

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
