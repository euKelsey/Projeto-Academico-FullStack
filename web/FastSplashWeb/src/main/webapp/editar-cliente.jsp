<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Cliente" %>

<%
    Cliente cliente =
            (Cliente) request.getAttribute(
                    "cliente"
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

    <title>Editar cliente | Fast Splash</title>

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
                    href="${pageContext.request.contextPath}/cliente"
                >
                    ← Clientes
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
                        Gestão de clientes
                    </span>

                    <h1>
                        Editar cliente
                    </h1>

                    <p>
                        Atualize os dados cadastrais
                        sem alterar a senha do cliente.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados cadastrais
                    </h2>

                    <p>
                        Cliente ID #<%= cliente.getIdCliente() %>
                    </p>

                </div>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/cliente"
                    method="post"
                >

                    <input
                        type="hidden"
                        name="acao"
                        value="atualizar"
                    >

                    <input
                        type="hidden"
                        name="idCliente"
                        value="<%= cliente.getIdCliente() %>"
                    >


                    <div class="campo-interno campo-interno-largo">

                        <label for="nome">
                            Nome completo
                        </label>

                        <input
                            type="text"
                            id="nome"
                            name="nome"
                            class="texto-maiusculo"
                            value="<%= cliente.getNome() %>"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="cpf">
                            CPF
                        </label>

                        <input
                            type="text"
                            id="cpf"
                            name="cpf"
                            value="<%= cliente.getCpf() %>"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="telefone">
                            Telefone
                        </label>

                        <input
                            type="text"
                            id="telefone"
                            name="telefone"
                            value="<%= cliente.getTelefone() %>"
                            required
                        >

                    </div>


                    <div class="campo-interno campo-interno-largo">

                        <label for="email">
                            E-mail
                        </label>

                        <input
                            type="email"
                            id="email"
                            name="email"
                            value="<%= cliente.getEmail() %>"
                            required
                        >

                    </div>


                    <p class="form-observacao">
                        A senha não é modificada nesta tela.
                    </p>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/cliente"
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


    <script>

        const nome =
            document.getElementById(
                "nome"
            );

        nome.addEventListener(
            "input",
            function () {

                nome.value =
                    nome.value.toUpperCase();
            }
        );

    </script>


</body>

</html>
