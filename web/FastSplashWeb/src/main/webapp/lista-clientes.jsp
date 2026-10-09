<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.fastsplash.web.model.Cliente" %>

            <% List<Cliente> clientes =
                (List<Cliente>) request.getAttribute(
                    "clientes"
                    );
                    %>

                    <!DOCTYPE html>

                    <html lang="pt-BR">

                    <head>

                        <meta charset="UTF-8">

                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                        <title>Clientes | Fast Splash</title>

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
                                            Gestão de clientes
                                        </span>

                                        <h1>
                                            Clientes cadastrados
                                        </h1>

                                        <p>
                                            Consulte, edite ou cadastre clientes
                                            no sistema interno do Fast Splash.
                                        </p>

                                    </div>


                                    <a class="botao-interno-principal"
                                        href="${pageContext.request.contextPath}/cadastro-cliente.jsp">
                                        + Novo cliente
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


                                        <% if ( clientes !=null && !clientes.isEmpty() ) { %>


                                            <table class="tabela-interna">

                                                <thead>

                                                    <tr>

                                                        <th>
                                                            Cliente
                                                        </th>

                                                        <th>
                                                            CPF
                                                        </th>

                                                        <th>
                                                            Telefone
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


                                                    <% for ( Cliente cliente : clientes ) { String
                                                        nome=cliente.getNome(); String iniciais="?" ; if ( nome !=null
                                                        && !nome.isBlank() ) { String[] partes=nome.trim()
                                                        .split("\\s+"); iniciais=partes[0] .substring(0, 1)
                                                        .toUpperCase(); if ( partes.length> 1
                                                        ) {

                                                        iniciais +=
                                                        partes[
                                                        partes.length - 1
                                                        ]
                                                        .substring(0, 1)
                                                        .toUpperCase();
                                                        }
                                                        }
                                                        %>


                                                        <tr>

                                                            <td>

                                                                <div class="cliente-identidade">

                                                                    <span class="cliente-avatar">
                                                                        <%= iniciais %>
                                                                    </span>

                                                                    <div>

                                                                        <strong>
                                                                            <%= cliente.getNome() %>
                                                                        </strong>

                                                                        <span>
                                                                            ID #<%= cliente.getIdCliente() %>
                                                                        </span>

                                                                    </div>

                                                                </div>

                                                            </td>


                                                            <td>
                                                                <%= cliente.getCpf() %>
                                                            </td>


                                                            <td>
                                                                <%= cliente.getTelefone() %>
                                                            </td>


                                                            <td>
                                                                <%= cliente.getEmail() %>
                                                            </td>


                                                            <td>

                                                                <div class="acoes-tabela">

                                                                    <a class="acao-editar"
                                                                        href="${pageContext.request.contextPath}/cliente?acao=editar&idCliente=<%= cliente.getIdCliente() %>">
                                                                        Editar
                                                                    </a>


                                                                    <form
                                                                        action="${pageContext.request.contextPath}/cliente"
                                                                        method="post">

                                                                        <input type="hidden" name="acao"
                                                                            value="excluir">

                                                                        <input type="hidden" name="idCliente"
                                                                            value="<%= cliente.getIdCliente() %>">

                                                                        <button class="acao-excluir" type="submit"
                                                                            onclick="return confirm('Deseja realmente excluir este cliente?');">
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

                                                    Nenhum cliente cadastrado.

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