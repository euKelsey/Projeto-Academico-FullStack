<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="com.fastsplash.web.model.Cliente" %>

            <% List<Cliente> clientes =
                (List<Cliente>) request.getAttribute(
                    "clientes"
                    );
                    %>


<%
    String filtro = (String) request.getAttribute("filtro");

    if (!"inativos".equals(filtro)
            && !"excluidos".equals(filtro)) {
        filtro = "ativos";
    }

    boolean administrador =
        "ADMINISTRADOR".equals(
            session.getAttribute("nivelAcesso")
        );

    String status = request.getParameter("status");
    String erro = request.getParameter("erro");

    String mensagemSucesso = "";

    if ("inativado".equals(status)) {
        mensagemSucesso = "Cliente inativado com sucesso.";
    } else if ("reativado".equals(status)) {
        mensagemSucesso = "Cliente reativado com sucesso.";
    } else if ("excluido".equals(status)) {
        mensagemSucesso = "Cliente excluido com sucesso. Historico preservado.";
    } else if ("restaurado".equals(status)) {
        mensagemSucesso = "Cliente restaurado com sucesso.";
    }

    String mensagemErro = "";

    if ("pendencias".equals(erro)) {
        mensagemErro = "O cliente possui agendamentos ou atendimentos pendentes.";
    } else if ("jaInativo".equals(erro)) {
        mensagemErro = "Este cliente ja esta inativo.";
    } else if ("jaAtivo".equals(erro)) {
        mensagemErro = "Este cliente ja esta ativo.";
    } else if ("jaExcluido".equals(erro)) {
        mensagemErro = "Este cliente ja foi excluido.";
    } else if ("naoExcluido".equals(erro)) {
        mensagemErro = "Este cliente nao esta excluido.";
    } else if ("naoEncontrado".equals(erro)) {
        mensagemErro = "Cliente nao encontrado.";
    }
%>

<!DOCTYPE html>

                    <html lang="pt-BR">

                    <head>

                        <meta charset="UTF-8">

                        <meta name="viewport" content="width=device-width, initial-scale=1.0">

                        <title>Clientes | Fast Splash</title>

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
        <strong>Nao foi possivel concluir a operacao.</strong>
        <p><%= mensagemErro %></p>
    </div>
<% } %>

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

    <nav class="filtros-clientes" aria-label="Status dos clientes">

        <a class="filtro-cliente <%= "ativos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/cliente?filtro=ativos">
            Ativos
        </a>

        <% if (administrador) { %>

        <a class="filtro-cliente <%= "inativos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/cliente?filtro=inativos">
            Inativos
        </a>

        <a class="filtro-cliente <%= "excluidos".equals(filtro) ? "filtro-selecionado" : "" %>"
           href="${pageContext.request.contextPath}/cliente?filtro=excluidos">
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
                                                                nome=cliente.getNome(); String iniciais="?" ; if ( nome
                                                                !=null && !nome.isBlank() ) { String[]
                                                                partes=nome.trim() .split("\\s+"); iniciais=partes[0]
                                                                .substring(0, 1) .toUpperCase(); if ( partes.length> 1
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

    <% if ("ativos".equals(filtro)) { %>

        <a class="acao-editar"
           href="${pageContext.request.contextPath}/cliente?acao=editar&idCliente=<%= cliente.getIdCliente() %>">
            Editar
        </a>

        <% if (administrador) { %>

        <form action="${pageContext.request.contextPath}/cliente"
              method="post"
              onsubmit="return confirm('Deseja inativar este cliente?');">

            <input type="hidden" name="acao" value="inativar">
            <input type="hidden" name="filtro" value="ativos">
            <input type="hidden" name="idCliente" value="<%= cliente.getIdCliente() %>">

            <button type="submit"
                    class="acao-status-cliente acao-inativar-cliente">
                Inativar
            </button>

        </form>

        <% } %>

    <% } %>

    <% if (administrador && "inativos".equals(filtro)) { %>

        <form action="${pageContext.request.contextPath}/cliente"
              method="post"
              onsubmit="return confirm('Deseja reativar este cliente?');">

            <input type="hidden" name="acao" value="reativar">
            <input type="hidden" name="filtro" value="inativos">
            <input type="hidden" name="idCliente" value="<%= cliente.getIdCliente() %>">

            <button type="submit"
                    class="acao-status-cliente acao-reativar-cliente">
                Reativar
            </button>

        </form>

    <% } %>

    <% if (administrador && !"excluidos".equals(filtro)) { %>

        <form action="${pageContext.request.contextPath}/cliente"
              method="post"
              onsubmit="return confirm('Deseja excluir este cliente? O historico sera preservado.');">

            <input type="hidden" name="acao" value="excluir">
            <input type="hidden" name="filtro" value="<%= filtro %>">
            <input type="hidden" name="idCliente" value="<%= cliente.getIdCliente() %>">

            <button class="acao-excluir" type="submit">
                Excluir
            </button>

        </form>

    <% } %>

    <% if (administrador && "excluidos".equals(filtro)) { %>

        <form action="${pageContext.request.contextPath}/cliente"
              method="post"
              onsubmit="return confirm('Deseja restaurar este cliente?');">

            <input type="hidden" name="acao" value="restaurar">
            <input type="hidden" name="filtro" value="excluidos">
            <input type="hidden" name="idCliente" value="<%= cliente.getIdCliente() %>">

            <button type="submit"
                    class="acao-status-cliente acao-reativar-cliente">
                Restaurar
            </button>

        </form>

    <% } %>

</div>


                                                                    </td>

                                                                </tr>


                                                                <% } %>


                                                        </tbody>

                                                    </table>


                                                    <% } else { %>


                                                        <div class="estado-vazio">

                                                            Nenhum cliente encontrado nesta categoria.

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
