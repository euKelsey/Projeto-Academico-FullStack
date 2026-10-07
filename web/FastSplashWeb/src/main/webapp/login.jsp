<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String erro =
            (String) request.getAttribute(
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

    <title>Área interna | Fast Splash</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/site.css"
    >

</head>


<body class="pagina-login">


    <!-- =========================================
         CABEÇALHO
    ========================================== -->

    <header class="login-cabecalho">

        <div class="container login-cabecalho-conteudo">

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
                    CAR WASH
                </span>

            </div>


            <a
                class="login-voltar"
                href="${pageContext.request.contextPath}/"
            >
                ← Voltar para o site
            </a>

        </div>

    </header>


    <!-- =========================================
         LOGIN
    ========================================== -->

    <main class="login-principal">

        <div class="container login-layout">


            <!-- APRESENTAÇÃO -->

            <section class="login-apresentacao">

                <span class="destaque-pequeno">
                    Área interna
                </span>

                <h1>
                    Gestão Fast Splash
                    para a equipe.
                </h1>

                <p>
                    Este ambiente é exclusivo para colaboradores
                    autorizados do Fast Splash.
                </p>


                <div class="login-informacoes">


                    <div class="login-informacao">

                        <span class="login-informacao-icone">
                            01
                        </span>

                        <div>

                            <strong>
                                Acesso restrito
                            </strong>

                            <p>
                                Somente funcionários com permissão
                                podem acessar o sistema.
                            </p>

                        </div>

                    </div>


                    <div class="login-informacao">

                        <span class="login-informacao-icone">
                            02
                        </span>

                        <div>

                            <strong>
                                Gestão centralizada
                            </strong>

                            <p>
                                Clientes, veículos, agendamentos,
                                atendimentos e pagamentos em um só lugar.
                            </p>

                        </div>

                    </div>


                    <div class="login-informacao">

                        <span class="login-informacao-icone">
                            03
                        </span>

                        <div>

                            <strong>
                                Acesso por perfil
                            </strong>

                            <p>
                                As funcionalidades disponíveis dependem
                                do nível de acesso do colaborador.
                            </p>

                        </div>

                    </div>


                </div>

            </section>


            <!-- FORMULÁRIO -->

            <section class="login-card">

                <div class="login-card-topo">

                    <span class="login-card-tag">
                        Colaboradores
                    </span>

                    <h2>
                        Entrar no sistema
                    </h2>

                    <p>
                        Utilize seu e-mail e senha de funcionário.
                    </p>

                </div>


                <form
                    class="form-login"
                    action="${pageContext.request.contextPath}/login"
                    method="post"
                >

                    <div class="login-campo">

                        <label for="email">
                            E-mail
                        </label>

                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="seuemail@fastsplash.com"
                            autocomplete="username"
                            required
                        >

                    </div>


                    <div class="login-campo">

                        <label for="senha">
                            Senha
                        </label>

                        <input
                            type="password"
                            id="senha"
                            name="senha"
                            placeholder="Digite sua senha"
                            autocomplete="current-password"
                            required
                        >

                    </div>


                    <% if (erro != null && !erro.isBlank()) { %>

                        <div
                            class="login-erro"
                            role="alert"
                        >
                            <%= erro %>
                        </div>

                    <% } %>


                    <button
                        class="botao-login"
                        type="submit"
                    >
                        Entrar no sistema
                    </button>


                    <div class="login-seguranca">
                        Acesso exclusivo para colaboradores autorizados.
                    </div>

                </form>

            </section>


        </div>

    </main>


</body>

</html>
