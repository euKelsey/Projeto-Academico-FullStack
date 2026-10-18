<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <%@ page import="java.util.List" %>
        <%@ page import="java.util.Map" %>
            <%@ page import="com.fastsplash.web.model.Servico" %>

                <% List<Servico> servicos =
                    (List<Servico>) request.getAttribute(
                        "servicos"
                        );

                        Map<Integer, Boolean> servicosEmUso =
                            (Map<Integer, Boolean>) request.getAttribute(
                                "servicosEmUso"
                                );

                                String erro =
                                request.getParameter(
                                "erro"
                                );

                                String sucesso =
                                request.getParameter(
                                "sucesso"
                                );
                                %>

                                <!DOCTYPE html>

                                <html lang="pt-BR">

                                <head>

                                    <meta charset="UTF-8">

                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">

                                    <title>
                                        Serviços | Fast Splash
                                    </title>

                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">

                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/servicos.css">

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
                                                        Gestão de serviços
                                                    </span>

                                                    <h1>
                                                        Serviços cadastrados
                                                    </h1>

                                                    <p>
                                                        Consulte, edite ou cadastre os serviços
                                                        disponíveis no Fast Splash.
                                                    </p>

                                                </div>


                                                <a class="botao-interno-principal"
                                                    href="${pageContext.request.contextPath}/servico?acao=novo">
                                                    + Novo serviço
                                                </a>

                                            </section>


                                            <% if ("servicoEmUso".equals(erro)) { %>

                                                <div class="aviso-interno">

                                                    Este serviço não pode ser excluído porque
                                                    já está vinculado a um ou mais agendamentos.

                                                </div>

                                                <% } %>


                                                    <% if ("excluido".equals(sucesso)) { %>

                                                        <div class="mensagem-interna-sucesso">

                                                            Serviço excluído com sucesso.

                                                        </div>

                                                        <% } %>


                                                            <% if ("inativado".equals(sucesso)) { %>

                                                                <div class="mensagem-interna-sucesso">

                                                                    Serviço inativado com sucesso.

                                                                </div>

                                                                <% } %>


                                                                    <% if ("ativado".equals(sucesso)) { %>

                                                                        <div class="mensagem-interna-sucesso">

                                                                            Serviço ativado com sucesso.

                                                                        </div>

                                                                        <% } %>


                                                                            <section class="tabela-card">

                                                                                <div class="tabela-responsiva">


                                                                                    <% if ( servicos !=null &&
                                                                                        !servicos.isEmpty() ) { %>


                                                                                        <table class="tabela-interna">

                                                                                            <thead>

                                                                                                <tr>

                                                                                                    <th>
                                                                                                        Serviço
                                                                                                    </th>

                                                                                                    <th>
                                                                                                        Descrição
                                                                                                    </th>

                                                                                                    <th>
                                                                                                        Preço
                                                                                                    </th>

                                                                                                    <th>
                                                                                                        Status
                                                                                                    </th>

                                                                                                    <th>
                                                                                                        Ações
                                                                                                    </th>

                                                                                                </tr>

                                                                                            </thead>


                                                                                            <tbody>


                                                                                                <% for ( Servico servico
                                                                                                    : servicos ) {
                                                                                                    boolean
                                                                                                    servicoEmUso=servicosEmUso
                                                                                                    !=null &&
                                                                                                    Boolean.TRUE.equals(
                                                                                                    servicosEmUso.get(
                                                                                                    servico.getIdServico()
                                                                                                    ) ); %>


                                                                                                    <% String
                                                                                                        classeServico=servico.isAtivo()
                                                                                                        ? ""
                                                                                                        : "servico-inativo"
                                                                                                        ; %>

                                                                                                        <tr
                                                                                                            class="<%= classeServico %>">

                                                                                                            <td>

                                                                                                                <div
                                                                                                                    class="cliente-identidade">

                                                                                                                    <span
                                                                                                                        class="cliente-avatar">
                                                                                                                        S
                                                                                                                    </span>

                                                                                                                    <div>

                                                                                                                        <strong>
                                                                                                                            <%= servico.getNome()
                                                                                                                                %>
                                                                                                                        </strong>

                                                                                                                        <span>
                                                                                                                            ID
                                                                                                                            #
                                                                                                                            <%= servico.getIdServico()
                                                                                                                                %>
                                                                                                                        </span>

                                                                                                                    </div>

                                                                                                                </div>

                                                                                                            </td>


                                                                                                            <td>

                                                                                                                <% if (
                                                                                                                    servico.getDescricao()
                                                                                                                    !=null
                                                                                                                    &&
                                                                                                                    !servico.getDescricao().isBlank()
                                                                                                                    ) {
                                                                                                                    %>

                                                                                                                    <%= servico.getDescricao()
                                                                                                                        %>

                                                                                                                        <% } else
                                                                                                                            {
                                                                                                                            %>

                                                                                                                            -

                                                                                                                            <% }
                                                                                                                                %>

                                                                                                            </td>


                                                                                                            <td>

                                                                                                                R$ <%=
                                                                                                                    String.format( "%.2f"
                                                                                                                    ,
                                                                                                                    servico.getPreco()
                                                                                                                    ) %>

                                                                                                            </td>


                                                                                                            <td>

                                                                                                                <% if
                                                                                                                    (servico.isAtivo())
                                                                                                                    { %>

                                                                                                                    <span>
                                                                                                                        Ativo
                                                                                                                    </span>

                                                                                                                    <% } else
                                                                                                                        {
                                                                                                                        %>

                                                                                                                        <span>
                                                                                                                            Inativo
                                                                                                                        </span>

                                                                                                                        <% }
                                                                                                                            %>

                                                                                                            </td>


                                                                                                            <td>

                                                                                                                <div
                                                                                                                    class="acoes-tabela">


                                                                                                                    <a class="acao-editar"
                                                                                                                        href="${pageContext.request.contextPath}/servico?acao=editar&idServico=<%= servico.getIdServico() %>">
                                                                                                                        Editar
                                                                                                                    </a>


                                                                                                                    <% if
                                                                                                                        (servicoEmUso)
                                                                                                                        {
                                                                                                                        %>


                                                                                                                        <% if
                                                                                                                            (servico.isAtivo())
                                                                                                                            {
                                                                                                                            %>

                                                                                                                            <form
                                                                                                                                action="${pageContext.request.contextPath}/servico"
                                                                                                                                method="post">

                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="acao"
                                                                                                                                    value="inativar">

                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="idServico"
                                                                                                                                    value="<%= servico.getIdServico() %>">

                                                                                                                                <button
                                                                                                                                    class="acao-editar"
                                                                                                                                    type="submit"
                                                                                                                                    onclick="return confirm('Deseja realmente inativar este serviço?');">
                                                                                                                                    Inativar
                                                                                                                                </button>

                                                                                                                            </form>


                                                                                                                            <% } else
                                                                                                                                {
                                                                                                                                %>


                                                                                                                                <form
                                                                                                                                    action="${pageContext.request.contextPath}/servico"
                                                                                                                                    method="post">

                                                                                                                                    <input
                                                                                                                                        type="hidden"
                                                                                                                                        name="acao"
                                                                                                                                        value="ativar">

                                                                                                                                    <input
                                                                                                                                        type="hidden"
                                                                                                                                        name="idServico"
                                                                                                                                        value="<%= servico.getIdServico() %>">

                                                                                                                                    <button
                                                                                                                                        class="acao-editar"
                                                                                                                                        type="submit">
                                                                                                                                        Ativar
                                                                                                                                    </button>

                                                                                                                                </form>


                                                                                                                                <% }
                                                                                                                                    %>


                                                                                                                                    <% } else
                                                                                                                                        {
                                                                                                                                        %>


                                                                                                                                        <form
                                                                                                                                            action="${pageContext.request.contextPath}/servico"
                                                                                                                                            method="post">

                                                                                                                                            <input
                                                                                                                                                type="hidden"
                                                                                                                                                name="acao"
                                                                                                                                                value="excluir">

                                                                                                                                            <input
                                                                                                                                                type="hidden"
                                                                                                                                                name="idServico"
                                                                                                                                                value="<%= servico.getIdServico() %>">

                                                                                                                                            <button
                                                                                                                                                class="acao-excluir"
                                                                                                                                                type="submit"
                                                                                                                                                onclick="return confirm('Deseja realmente excluir este serviço?');">
                                                                                                                                                Excluir
                                                                                                                                            </button>

                                                                                                                                        </form>


                                                                                                                                        <% }
                                                                                                                                            %>


                                                                                                                </div>

                                                                                                            </td>

                                                                                                        </tr>


                                                                                                        <% } %>


                                                                                            </tbody>

                                                                                        </table>


                                                                                        <% } else { %>


                                                                                            <div class="estado-vazio">

                                                                                                Nenhum serviço
                                                                                                cadastrado.

                                                                                            </div>


                                                                                            <% } %>


                                                                                </div>

                                                                            </section>

                                        </div>

                                    </main>

                                </body>

                                </html>