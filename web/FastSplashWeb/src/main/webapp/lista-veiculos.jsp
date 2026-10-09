<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.fastsplash.web.model.Veiculo" %>
            <%@ page import="com.fastsplash.web.model.Cliente" %>

                <% List<Veiculo> veiculos =
                    (List<Veiculo>) request.getAttribute(
                        "veiculos"
                        );

                        List<Cliente> clientes =
                            (List<Cliente>) request.getAttribute(
                                "clientes"
                                );
                                %>

                                <!DOCTYPE html>

                                <html lang="pt-BR">

                                <head>

                                    <meta charset="UTF-8">

                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">

                                    <title>Veículos | Fast Splash</title>

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
                                                        Gestão de veículos
                                                    </span>

                                                    <h1>
                                                        Veículos cadastrados
                                                    </h1>

                                                    <p>
                                                        Consulte os veículos vinculados
                                                        aos clientes do Fast Splash.
                                                    </p>

                                                </div>


                                                <a class="botao-interno-principal"
                                                    href="${pageContext.request.contextPath}/veiculo?acao=novo">
                                                    + Novo veículo
                                                </a>

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


                                                    <% if ( veiculos !=null && !veiculos.isEmpty() ) { %>


                                                        <table class="tabela-interna">

                                                            <thead>

                                                                <tr>

                                                                    <th>
                                                                        Veículo
                                                                    </th>

                                                                    <th>
                                                                        Placa
                                                                    </th>

                                                                    <th>
                                                                        Cliente
                                                                    </th>

                                                                    <th>
                                                                        Cor
                                                                    </th>

                                                                    <th>
                                                                        Ações
                                                                    </th>

                                                                </tr>

                                                            </thead>


                                                            <tbody>


                                                                <% for ( Veiculo veiculo : veiculos ) { String
                                                                    nomeCliente="Cliente não encontrado" ; if (clientes
                                                                    !=null) { for ( Cliente cliente : clientes ) { if (
                                                                    cliente.getIdCliente()==veiculo.getIdCliente() ) {
                                                                    nomeCliente=cliente.getNome(); break; } } } %>


                                                                    <tr>

                                                                        <td>

                                                                            <div class="veiculo-identidade">

                                                                                <span class="veiculo-icone">
                                                                                    🚗
                                                                                </span>

                                                                                <div>

                                                                                    <strong>
                                                                                        <%= veiculo.getMarca() %>
                                                                                            <%= veiculo.getModelo() %>
                                                                                    </strong>

                                                                                    <span>
                                                                                        ID #<%= veiculo.getIdVeiculo()
                                                                                            %>
                                                                                    </span>

                                                                                </div>

                                                                            </div>

                                                                        </td>


                                                                        <td>

                                                                            <span class="placa-badge">
                                                                                <%= veiculo.getPlaca() %>
                                                                            </span>

                                                                        </td>


                                                                        <td>

                                                                            <div class="cliente-vinculo">

                                                                                <strong>
                                                                                    <%= nomeCliente %>
                                                                                </strong>

                                                                                <span>
                                                                                    Cliente ID #<%=
                                                                                        veiculo.getIdCliente() %>
                                                                                </span>

                                                                            </div>

                                                                        </td>


                                                                        <td>
                                                                            <%= veiculo.getCor() %>
                                                                        </td>


                                                                        <td>

                                                                            <div class="acoes-tabela">

                                                                                <a class="acao-editar"
                                                                                    href="${pageContext.request.contextPath}/veiculo?acao=editar&idVeiculo=<%= veiculo.getIdVeiculo() %>">
                                                                                    Editar
                                                                                </a>


                                                                                <form
                                                                                    action="${pageContext.request.contextPath}/veiculo"
                                                                                    method="post">

                                                                                    <input type="hidden" name="acao"
                                                                                        value="excluir">

                                                                                    <input type="hidden"
                                                                                        name="idVeiculo"
                                                                                        value="<%= veiculo.getIdVeiculo() %>">

                                                                                    <button class="acao-excluir"
                                                                                        type="submit"
                                                                                        onclick="return confirm('Deseja realmente excluir este veículo?');">
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

                                                                Nenhum veículo cadastrado.

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