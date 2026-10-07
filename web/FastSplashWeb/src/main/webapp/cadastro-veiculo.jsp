<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>

<%
    List<Cliente> clientes =
            (List<Cliente>) request.getAttribute(
                    "clientes"
            );

    boolean possuiClientes =
            clientes != null
            && !clientes.isEmpty();
%>

<!DOCTYPE html>

<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Novo veículo | Fast Splash</title>

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
                    href="${pageContext.request.contextPath}/veiculo"
                >
                    ← Veículos
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
                        Gestão de veículos
                    </span>

                    <h1>
                        Cadastrar veículo
                    </h1>

                    <p>
                        Vincule um novo veículo
                        a um cliente já cadastrado.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados do veículo
                    </h2>

                    <p>
                        Informe o proprietário
                        e os dados principais do veículo.
                    </p>

                </div>


                <%
                    if (!possuiClientes) {
                %>

                    <div class="aviso-interno">

                        Nenhum cliente está disponível.
                        Cadastre um cliente antes de incluir um veículo.

                    </div>

                <%
                    }
                %>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/veiculo"
                    method="post"
                >


                    <div class="campo-interno campo-interno-largo">

                        <label for="idCliente">
                            Cliente proprietário
                        </label>

                        <select
                            id="idCliente"
                            name="idCliente"
                            required
                            <%= possuiClientes ? "" : "disabled" %>
                        >

                            <option value="">
                                Selecione um cliente
                            </option>


                            <%
                                if (clientes != null) {

                                    for (
                                        Cliente cliente
                                        : clientes
                                    ) {
                            %>

                                <option
                                    value="<%= cliente.getIdCliente() %>"
                                >
                                    <%= cliente.getNome() %>
                                    — ID #<%= cliente.getIdCliente() %>
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>

                    </div>


                    <div class="campo-interno">

                        <label for="placa">
                            Placa
                        </label>

                        <input
                            type="text"
                            id="placa"
                            name="placa"
                            maxlength="7"
                            minlength="7"
                            pattern="[A-Za-z]{3}([0-9]{4}|[0-9][A-Za-z][0-9]{2})"
                            title="Use uma placa brasileira válida, como ABC1234 ou ABC1D23"
                            placeholder="ABC1D23"
                            required
                            <%= possuiClientes ? "" : "disabled" %>
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="cor">
                            Cor
                        </label>

                        <input
                            type="text"
                            id="cor"
                            name="cor"
                            class="texto-maiusculo"
                            placeholder="Ex.: Preto"
                            required
                            <%= possuiClientes ? "" : "disabled" %>
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="marca">
                            Marca
                        </label>

                        <input
                            type="text"
                            id="marca"
                            name="marca"
                            class="texto-maiusculo"
                            placeholder="Ex.: Honda"
                            required
                            <%= possuiClientes ? "" : "disabled" %>
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="modelo">
                            Modelo
                        </label>

                        <input
                            type="text"
                            id="modelo"
                            name="modelo"
                            class="texto-maiusculo"
                            placeholder="Ex.: Civic"
                            required
                            <%= possuiClientes ? "" : "disabled" %>
                        >

                    </div>


                    <p class="form-observacao">
                        A placa será padronizada em letras maiúsculas
                        antes de ser gravada no banco.
                    </p>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/veiculo"
                        >
                            Cancelar
                        </a>


                        <%
                            if (possuiClientes) {
                        %>

                            <button
                                class="botao-interno-principal"
                                type="submit"
                            >
                                Cadastrar veículo
                            </button>

                        <%
                            } else {
                        %>

                            <a
                                class="botao-interno-principal"
                                href="${pageContext.request.contextPath}/cadastro-cliente.jsp"
                            >
                                Cadastrar cliente
                            </a>

                        <%
                            }
                        %>

                    </div>

                </form>

            </section>

        </div>

    </main>


    <script>

        const campoPlaca =
            document.getElementById(
                "placa"
            );


        const camposMaiusculos =
            document.querySelectorAll(
                ".texto-maiusculo"
            );

        camposMaiusculos.forEach(
            function (campo) {

                campo.addEventListener(
                    "input",
                    function () {

                        campo.value =
                            campo.value.toUpperCase();
                    }
                );
            }
        );

        if (campoPlaca) {

            campoPlaca.addEventListener(
                "input",
                function () {

                    campoPlaca.value =
                        campoPlaca.value
                            .toUpperCase()
                            .replace(
                                /[^A-Z0-9]/g,
                                ""
                            )
                            .slice(
                                0,
                                7
                            );
                }
            );
        }

    </script>


</body>

</html>
