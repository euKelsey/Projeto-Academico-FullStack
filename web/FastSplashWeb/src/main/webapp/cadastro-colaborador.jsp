<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
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

    <title>Novo colaborador | Fast Splash</title>

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
                        Cadastrar colaborador
                    </h1>

                    <p>
                        Inclua um novo colaborador
                        na equipe do Fast Splash.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados do colaborador
                    </h2>

                    <p>
                        Preencha os dados e defina
                        o nível de acesso ao sistema.
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


                    <div class="campo-interno campo-interno-largo">

                        <label for="nome">
                            Nome completo
                        </label>

                        <input
                            type="text"
                            id="nome"
                            name="nome"
                            value="${param.nome}"
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
                            value="${param.cargo}"
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

                            <option value="">
                                Selecione
                            </option>

                            <option value="ADMINISTRADOR">
                                Administrador
                            </option>

                            <option value="ATENDENTE">
                                Atendente
                            </option>

                            <option value="OPERACIONAL">
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
                            value="${param.email}"
                            placeholder="colaborador@email.com"
                        >

                    </div>


                    <div class="campo-interno campo-interno-largo">

                        <label for="senha">
                            Senha
                        </label>

                        <input
                            type="password"
                            id="senha"
                            name="senha"
                            placeholder="Digite a senha de acesso"
                            autocomplete="new-password"
                        >

                    </div>


                    <p class="form-observacao">
                        Administradores e atendentes precisam
                        de e-mail e senha para acessar o sistema.
                        O nível Operacional não utiliza o painel Web.
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
                            Cadastrar colaborador
                        </button>

                    </div>


                </form>

            </section>


        </div>

    </main>


</body>

</html>