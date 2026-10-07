<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>
<%@ page import="com.fastsplash.web.model.Veiculo" %>

<%
    Veiculo veiculo =
            (Veiculo) request.getAttribute(
                    "veiculo"
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

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Editar veículo | Fast Splash</title>

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
                        Editar veículo
                    </h1>

                    <p>
                        Atualize o proprietário
                        ou os dados do veículo selecionado.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        <%= veiculo.getMarca() %>
                        <%= veiculo.getModelo() %>
                    </h2>

                    <p>
                        Veículo ID #<%= veiculo.getIdVeiculo() %>
                        · Placa <%= veiculo.getPlaca() %>
                    </p>

                </div>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/veiculo"
                    method="post"
                >

                    <input
                        type="hidden"
                        name="acao"
                        value="atualizar"
                    >

                    <input
                        type="hidden"
                        name="idVeiculo"
                        value="<%= veiculo.getIdVeiculo() %>"
                    >


                    <div class="campo-interno campo-interno-largo">

                        <label for="idCliente">
                            Cliente proprietário
                        </label>

                        <select
                            id="idCliente"
                            name="idCliente"
                            required
                        >

                            <%
                                if (clientes != null) {

                                    for (
                                        Cliente cliente
                                        : clientes
                                    ) {

                                        boolean selecionado =
                                                cliente.getIdCliente()
                                                == veiculo.getIdCliente();
                            %>

                                <option
                                    value="<%= cliente.getIdCliente() %>"
                                    <%= selecionado ? "selected" : "" %>
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
                            value="<%= veiculo.getPlaca() %>"
                            required
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
                            value="<%= veiculo.getCor() %>"
                            required
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
                            value="<%= veiculo.getMarca() %>"
                            required
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
                            value="<%= veiculo.getModelo() %>"
                            required
                        >

                    </div>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/veiculo"
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

        const campoPlaca =
            document.getElementById(
                "placa"
            );

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

    </script>


</body>

</html>
