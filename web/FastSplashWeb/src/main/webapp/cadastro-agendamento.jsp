<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>
<%@ page import="com.fastsplash.web.model.Veiculo" %>
<%@ page import="com.fastsplash.web.model.Servico" %>

<%
    List<Cliente> clientes =
            (List<Cliente>) request.getAttribute(
                    "clientes"
            );

    List<Veiculo> veiculos =
            (List<Veiculo>) request.getAttribute(
                    "veiculos"
            );

    List<Servico> servicos =
            (List<Servico>) request.getAttribute(
                    "servicos"
            );

    String erro =
            (String) request.getAttribute(
                    "erro"
            );

    boolean possuiClientes =
            clientes != null
            && !clientes.isEmpty();

    boolean possuiVeiculos =
            veiculos != null
            && !veiculos.isEmpty();

    boolean possuiServicos =
            servicos != null
            && !servicos.isEmpty();

    boolean podeAgendar =
            possuiClientes
            && possuiVeiculos
            && possuiServicos;
%>

<!DOCTYPE html>

<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Novo agendamento | Fast Splash</title>

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
                    href="${pageContext.request.contextPath}/agendamento"
                >
                    ← Agendamentos
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
                        Gestão de agendamentos
                    </span>

                    <h1>
                        Novo agendamento
                    </h1>

                    <p>
                        Escolha o veículo, os serviços,
                        a data e o horário do atendimento.
                    </p>

                </div>

            </section>


            <section class="form-interno-card form-agendamento-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados do agendamento
                    </h2>

                    <p>
                        O valor final abaixo é calculado
                        conforme os serviços selecionados.
                    </p>

                </div>


                <%
                    if (erro != null) {
                %>

                    <div class="mensagem-interna-erro">
                        <%= erro %>
                    </div>

                    <br>

                <%
                    }
                %>


                <%
                    if (!possuiClientes) {
                %>

                    <div class="aviso-interno">

                        Não existem clientes cadastrados.
                        Cadastre um cliente antes de criar um agendamento.

                    </div>

                <%
                    }
                %>


                <%
                    if (!possuiVeiculos) {
                %>

                    <div class="aviso-interno">

                        Não existem veículos cadastrados.
                        Cadastre um veículo antes de criar um agendamento.

                    </div>

                <%
                    }
                %>


                <%
                    if (!possuiServicos) {
                %>

                    <div class="aviso-interno">

                        Não existem serviços cadastrados.
                        Cadastre um serviço antes de criar um agendamento.

                    </div>

                <%
                    }
                %>


                <form
                    class="form-interno"
                    id="formAgendamento"
                    action="${pageContext.request.contextPath}/agendamento"
                    method="post"
                >


                    <div class="campo-interno">

                        <label for="idCliente">
                            Cliente
                        </label>

                        <select
                            id="idCliente"
                            name="idCliente"
                            required
                            <%= podeAgendar ? "" : "disabled" %>
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
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>

                    </div>


                    <div class="campo-interno">

                        <label for="idVeiculo">
                            Veículo
                        </label>

                        <select
                            id="idVeiculo"
                            name="idVeiculo"
                            required
                            disabled
                        >

                            <option value="">
                                Selecione primeiro um cliente
                            </option>


                            <%
                                if (veiculos != null) {

                                    for (
                                        Veiculo veiculo
                                        : veiculos
                                    ) {
                            %>

                                <option
                                    value="<%= veiculo.getIdVeiculo() %>"
                                    data-cliente="<%= veiculo.getIdCliente() %>"
                                    hidden
                                >
                                    <%= veiculo.getMarca() %>
                                    <%= veiculo.getModelo() %>
                                    —
                                    <%= veiculo.getPlaca() %>
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>

                    </div>


                    <div class="servicos-titulo">

                        <h3>
                            Serviços
                        </h3>

                        <p>
                            Selecione pelo menos um serviço.
                        </p>

                    </div>


                    <div class="servicos-grid">


                        <%
                            if (servicos != null) {

                                for (
                                    Servico servico
                                    : servicos
                                ) {
                        %>


                            <label class="servico-opcao">

                                <input
                                    type="checkbox"
                                    name="servicos"
                                    value="<%= servico.getIdServico() %>"
                                    data-preco="<%= servico.getPreco() %>"
                                    <%= podeAgendar ? "" : "disabled" %>
                                >

                                <span class="servico-opcao-conteudo">

                                    <span class="servico-opcao-topo">

                                        <strong>
                                            <%= servico.getNome() %>
                                        </strong>

                                        <span class="servico-opcao-preco">
                                            R$
                                            <%= String.format(
                                                    "%.2f",
                                                    servico.getPreco()
                                            ) %>
                                        </span>

                                    </span>

                                    <p>
                                        <%= servico.getDescricao() == null
                                                ? "Serviço Fast Splash."
                                                : servico.getDescricao() %>
                                    </p>

                                </span>

                            </label>


                        <%
                                }
                            }
                        %>


                    </div>


                    <div class="campo-interno">

                        <label for="data">
                            Data
                        </label>

                        <input
                            type="date"
                            id="data"
                            name="data"
                            required
                            <%= podeAgendar ? "" : "disabled" %>
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="horario">
                            Horário
                        </label>

                        <input
                            type="time"
                            id="horario"
                            name="horario"
                            required
                            <%= podeAgendar ? "" : "disabled" %>
                        >

                    </div>


                    <div class="resumo-agendamento">

                        <span>
                            Valor total dos serviços selecionados
                        </span>

                        <strong id="valorTotal">
                            R$ 0,00
                        </strong>

                    </div>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/agendamento"
                        >
                            Cancelar
                        </a>


                        <%
                            if (podeAgendar) {
                        %>

                            <button
                                class="botao-interno-principal"
                                type="submit"
                            >
                                Confirmar agendamento
                            </button>

                        <%
                            }
                        %>

                    </div>

                </form>

            </section>

        </div>

    </main>


    <script>

        const formulario =
            document.getElementById(
                "formAgendamento"
            );

        const campoCliente =
            document.getElementById(
                "idCliente"
            );

        const campoVeiculo =
            document.getElementById(
                "idVeiculo"
            );

        const campoData =
            document.getElementById(
                "data"
            );

        const campoHorario =
            document.getElementById(
                "horario"
            );

        const botaoConfirmar =
            formulario.querySelector(
                'button[type="submit"]'
            );

        const servicos =
            document.querySelectorAll(
                'input[name="servicos"]'
            );

        const valorTotal =
            document.getElementById(
                "valorTotal"
            );


        function filtrarVeiculos() {

            const idCliente =
                campoCliente.value;

            campoVeiculo.value = "";

            let possuiVeiculoDoCliente =
                false;


            Array.from(
                campoVeiculo.options
            ).forEach(
                function (opcao) {

                    if (!opcao.dataset.cliente) {
                        return;
                    }


                    const corresponde =
                        opcao.dataset.cliente ===
                        idCliente;

                    opcao.hidden =
                        !corresponde;

                    if (corresponde) {
                        possuiVeiculoDoCliente = true;
                    }
                }
            );


            if (!idCliente) {

                campoVeiculo.disabled = true;

                campoVeiculo.options[0].textContent =
                    "Selecione primeiro um cliente";

            } else {

                campoVeiculo.disabled =
                    !possuiVeiculoDoCliente;

                campoVeiculo.options[0].textContent =
                    possuiVeiculoDoCliente
                        ? "Selecione um veículo"
                        : "Cliente sem veículos cadastrados";
            }


            atualizarEstadoFormulario();
        }


        function existeServicoSelecionado() {

            return Array.from(
                servicos
            ).some(
                function (servico) {

                    return servico.checked;
                }
            );
        }


        function atualizarEstadoFormulario() {

            if (!botaoConfirmar) {
                return;
            }


            const completo =
                campoCliente.value !== ""
                && campoVeiculo.value !== ""
                && existeServicoSelecionado()
                && campoData.value !== ""
                && campoHorario.value !== "";


            botaoConfirmar.disabled =
                !completo;
        }


        function atualizarTotal() {

            let total = 0;

            servicos.forEach(
                function (servico) {

                    if (servico.checked) {

                        total +=
                            Number(
                                servico.dataset.preco
                            );
                    }
                }
            );


            valorTotal.textContent =
                total.toLocaleString(
                    "pt-BR",
                    {
                        style: "currency",
                        currency: "BRL"
                    }
                );
        }


        servicos.forEach(
            function (servico) {

                servico.addEventListener(
                    "change",
                    function () {

                        atualizarTotal();
                        atualizarEstadoFormulario();
                    }
                );
            }
        );


        campoCliente.addEventListener(
            "change",
            filtrarVeiculos
        );


        campoVeiculo.addEventListener(
            "change",
            atualizarEstadoFormulario
        );


        campoData.addEventListener(
            "change",
            atualizarEstadoFormulario
        );


        campoHorario.addEventListener(
            "change",
            atualizarEstadoFormulario
        );


        filtrarVeiculos();
        atualizarEstadoFormulario();


        formulario.addEventListener(
            "submit",
            function (evento) {

                const algumSelecionado =
                    Array.from(
                        servicos
                    ).some(
                        function (servico) {

                            return servico.checked;
                        }
                    );


                if (
                    campoCliente.value === ""
                    || campoVeiculo.value === ""
                    || !algumSelecionado
                    || campoData.value === ""
                    || campoHorario.value === ""
                ) {

                    evento.preventDefault();

                    alert(
                        "Preencha cliente, veículo, serviço, data e horário."
                    );
                }
            }
        );

    </script>


</body>

</html>
