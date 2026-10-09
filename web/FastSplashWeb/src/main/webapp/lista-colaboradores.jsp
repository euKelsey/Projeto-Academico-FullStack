<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.fastsplash.web.model.Colaborador" %>

            <% List<Colaborador> colaboradores =
                (List<Colaborador>)
                    request.getAttribute(
                    "colaboradores"
                    );
                    %>

                    <!DOCTYPE html>

                    <html lang="pt-BR">

                    <head>

                        <meta charset="UTF-8">

                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                        <title>Colaboradores | Fast Splash</title>

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

                                                        <th>
                                                            Ações
                                                        </th>

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

                                                                <div class="acoes-tabela">

                                                                    <a class="acao-editar"
                                                                        href="${pageContext.request.contextPath}/colaborador?acao=editar&idColaborador=<%= colaborador.getIdColaborador() %>">
                                                                        Editar
                                                                    </a>


                                                                    <form
                                                                        action="${pageContext.request.contextPath}/colaborador"
                                                                        method="post">

                                                                        <input type="hidden" name="acao"
                                                                            value="excluir">

                                                                        <input type="hidden" name="idColaborador"
                                                                            value="<%= colaborador.getIdColaborador() %>">

                                                                        <button class="acao-excluir" type="submit"
                                                                            onclick="return confirm('Deseja realmente excluir este colaborador?');">
                                                                            Excluir
                                                                        </button>

                                                                    </form>

                                                                </div>

                                                            </td>

                                                        </tr>


                                                        <% } %>


                                                </tbody>

                                            </table>


                                            <% } else { %>


                                                <div class="estado-vazio">

                                                    Nenhum colaborador cadastrado.

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

                    </body>

                    </html>