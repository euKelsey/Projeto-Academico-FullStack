<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Colaborador" %>

<%
    Colaborador colaborador =
            (Colaborador)
                request.getAttribute(
                        "colaborador"
                );

    String erro =
            (String)
                request.getAttribute(
                        "erro"
                );
%>

<!DOCTYPE html>

<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Editar colaborador | Fast Splash</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/site.css"
    >

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

                <a
                    class="interna-link"
                    href="${pageContext.request.contextPath}/colaborador"
                >
                    ← Colaboradores
                </a>

                <a
                    class="interna-link"
                    href="${pageContext.request.contextPath}/dashboard.jsp"
                >
                    Dashboard
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
                        Editar colaborador
                    </h1>

                    <p>
                        Atualize os dados e permissões
                        deste colaborador.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados do colaborador
                    </h2>

                    <p>
                        Colaborador
                        #<%= colaborador.getIdColaborador() %>
                    </p>

                </div>


                <%
                    if (erro != null) {
                %>

                    <div class="mensagem-interna-erro">
                        <%= erro %>
                    </div>

                <%
                    }
                %>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/colaborador"
                    method="post"
                >


                    <input
                        type="hidden"
                        name="acao"
                        value="atualizar"
                    >


                    <input
                        type="hidden"
                        name="idColaborador"
                        value="<%= colaborador.getIdColaborador() %>"
                    >


                    <div class="campo-interno campo-interno-largo">

                        <label for="nome">
                            Nome completo
                        </label>

                        <input
                            type="text"
                            id="nome"
                            name="nome"
                            value="<%= colaborador.getNome() %>"
                            maxlength="100"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="cargo">
                            Cargo
                        </label>

                        <input
                            type="text"
                            id="cargo"
                            name="cargo"
                            value="<%= colaborador.getCargo() %>"
                            maxlength="100"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="nivelAcesso">
                            Nível de acesso
                        </label>

                        <select
                            id="nivelAcesso"
                            name="nivelAcesso"
                            required
                        >

                            <option
                                value="ADMINISTRADOR"
                                <%= "ADMINISTRADOR".equals(
                                        colaborador.getNivelAcesso()
                                    )
                                    ? "selected"
                                    : ""
                                %>
                            >
                                Administrador
                            </option>

                            <option
                                value="ATENDENTE"
                                <%= "ATENDENTE".equals(
                                        colaborador.getNivelAcesso()
                                    )
                                    ? "selected"
                                    : ""
                                %>
                            >
                                Atendente
                            </option>

                            <option
                                value="OPERACIONAL"
                                <%= "OPERACIONAL".equals(
                                        colaborador.getNivelAcesso()
                                    )
                                    ? "selected"
                                    : ""
                                %>
                            >
                                Operacional
                            </option>

                        </select>

                    </div>


                    <div class="campo-interno campo-interno-largo">

                        <label for="email">
                            E-mail
                        </label>

                        <input
                            type="email"
                            id="email"
                            name="email"
                            value="<%=
                                colaborador.getEmail() != null
                                ? colaborador.getEmail()
                                : ""
                            %>"
                            placeholder="colaborador@email.com"
                        >

                    </div>


                    <div class="campo-interno campo-interno-largo">

                        <label for="senha">
                            Nova senha
                        </label>

                        <input
                            type="password"
                            id="senha"
                            name="senha"
                            placeholder="Deixe em branco para manter a senha atual"
                            autocomplete="new-password"
                        >

                    </div>


                    <p class="form-observacao">
                        Se a senha não for alterada,
                        deixe este campo em branco.
                        Administradores e atendentes precisam
                        de e-mail e senha para acessar o sistema.
                    </p>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/colaborador"
                        >
                            Cancelar
                        </a>

                        <button
                            class="botao-interno-principal"
                            type="submit"
                        >
                            Salvar alterações
                        </button>

                    </div>


                </form>

            </section>


        </div>

    </main>


</body>

</html>