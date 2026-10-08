<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.fastsplash.web.model.Atendimento" %>

<%
    List<Atendimento> atendimentos =
            (List<Atendimento>) request.getAttribute(
                    "atendimentos"
            );

    Set<Integer> agendamentosPagos =
            (Set<Integer>) request.getAttribute(
                    "agendamentosPagos"
            );

    String erro =
            (String) request.getAttribute(
                    "erro"
            );

    DateTimeFormatter formatoDataHora =
            DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy HH:mm"
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

    <title>Atendimentos | Fast Splash</title>

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
                    href="${pageContext.request.contextPath}/dashboard.jsp"
                >
                    ← Dashboard
                </a>

            </div>

        </div>

    </header>


    <main class="interna-principal">

        <div class="container">


            <section class="interna-cabecalho">

                <div>

                    <span class="destaque-pequeno">
                        Gestão de atendimentos
                    </span>

                    <h1>
                        Atendimentos
                    </h1>

                    <p>
                        Acompanhe o fluxo da lavagem,
                        do aguardo até a finalização.
                    </p>

                </div>


                <a
                    class="botao-interno-principal"
                    href="${pageContext.request.contextPath}/atendimento?acao=novo"
                >
                    + Novo atendimento
                </a>

            </section>


            <%
                if (
                    erro != null
                    && !erro.isBlank()
                ) {
            %>

                <div
                    class="estado-vazio"
                    style="margin-bottom: 18px; border: 1px solid rgba(255, 138, 31, 0.45);"
                >
                    <strong>Não foi possível iniciar o atendimento.</strong>
                    <br>
                    <%= erro %>
                </div>

            <%
                }
            %>


            <section class="tabela-card">

                <div class="tabela-responsiva">


                    <%
                        if (
                            atendimentos != null
                            && !atendimentos.isEmpty()
                        ) {
                    %>


                        <table class="tabela-interna">

                            <thead>

                                <tr>

                                    <th>
                                        Cliente / Veículo
                                    </th>

                                    <th>
                                        Serviços
                                    </th>

                                    <th>
                                        Status
                                    </th>

                                    <th>
                                        Pagamento
                                    </th>

                                    <th>
                                        Início
                                    </th>

                                    <th>
                                        Fim
                                    </th>

                                    <th>
                                        Ações
                                    </th>

                                </tr>

                            </thead>


                            <tbody>


                                <%
                                    for (
                                        Atendimento atendimento
                                        : atendimentos
                                    ) {

                                        String status =
                                                atendimento.getStatus();

                                        boolean pagamentoPago =
                                                agendamentosPagos != null
                                                && agendamentosPagos.contains(
                                                        atendimento.getIdAgendamento()
                                                );

                                        String classeStatus =
                                                "status-aguardando";

                                        if (
                                            "EM_LAVAGEM".equals(
                                                    status
                                            )
                                        ) {

                                            classeStatus =
                                                    "status-em-lavagem";

                                        } else if (
                                            "FINALIZADO".equals(
                                                    status
                                            )
                                        ) {

                                            classeStatus =
                                                    "status-finalizado";
                                        }
                                %>


                                <tr>

                                    <td>

                                        <div class="atendimento-identidade">

                                            <strong>
                                                <%= atendimento.getClienteNome() %>
                                            </strong>

                                            <span>
                                                <%= atendimento.getVeiculoDescricao() %>
                                            </span>

                                            <span>
                                                Atendimento #<%= atendimento.getIdAtendimento() %>
                                                · Agendamento #<%= atendimento.getIdAgendamento() %>
                                            </span>

                                        </div>

                                    </td>


                                    <td>

                                        <div class="agendamento-servicos">
                                            <%= atendimento.getServicosDescricao() %>
                                        </div>

                                    </td>


                                    <td>

                                        <span
                                            class="status-badge <%= classeStatus %>"
                                        >
                                            <%= status %>
                                        </span>

                                    </td>


                                    <td>

                                        <span
                                            class="status-badge <%= pagamentoPago ? "status-finalizado" : "status-aguardando" %>"
                                        >
                                            <%= pagamentoPago ? "PAGO" : "PENDENTE" %>
                                        </span>

                                    </td>


                                    <td>

                                        <div class="atendimento-data">

                                            <%
                                                if (
                                                    atendimento.getDataInicio()
                                                    != null
                                                ) {
                                            %>

                                                <strong>
                                                    <%= atendimento.getDataInicio().format(formatoDataHora) %>
                                                </strong>

                                            <%
                                                } else {
                                            %>

                                                <span>
                                                    Ainda não iniciado
                                                </span>

                                            <%
                                                }
                                            %>

                                        </div>

                                    </td>


                                    <td>

                                        <div class="atendimento-data">

                                            <%
                                                if (
                                                    atendimento.getDataFim()
                                                    != null
                                                ) {
                                            %>

                                                <strong>
                                                    <%= atendimento.getDataFim().format(formatoDataHora) %>
                                                </strong>

                                            <%
                                                } else {
                                            %>

                                                <span>
                                                    —
                                                </span>

                                            <%
                                                }
                                            %>

                                        </div>

                                    </td>


                                    <td>

                                        <div class="acoes-tabela">

                                            <a
                                                class="acao-detalhes"
                                                href="${pageContext.request.contextPath}/atendimento?acao=detalhes&idAtendimento=<%= atendimento.getIdAtendimento() %>"
                                            >
                                                Detalhes
                                            </a>


                                            <%
                                                if (
                                                    "AGUARDANDO".equals(
                                                            status
                                                    )
                                                    && pagamentoPago
                                                ) {
                                            %>

                                                <form
                                                    action="${pageContext.request.contextPath}/atendimento"
                                                    method="post"
                                                >

                                                    <input
                                                        type="hidden"
                                                        name="acao"
                                                        value="iniciar"
                                                    >

                                                    <input
                                                        type="hidden"
                                                        name="idAtendimento"
                                                        value="<%= atendimento.getIdAtendimento() %>"
                                                    >

                                                    <button
                                                        class="acao-iniciar"
                                                        type="submit"
                                                    >
                                                        Iniciar
                                                    </button>

                                                </form>

                                            <%
                                                } else if (
                                                    "AGUARDANDO".equals(
                                                            status
                                                    )
                                                    && !pagamentoPago
                                                ) {
                                            %>

                                                <span
                                                    class="status-badge status-aguardando"
                                                    title="O atendimento só pode começar após o pagamento."
                                                >
                                                    Aguardando pagamento
                                                </span>

                                            <%
                                                }
                                            %>


                                            <%
                                                if (
                                                    "EM_LAVAGEM".equals(
                                                            status
                                                    )
                                                ) {
                                            %>

                                                <form
                                                    action="${pageContext.request.contextPath}/atendimento"
                                                    method="post"
                                                >

                                                    <input
                                                        type="hidden"
                                                        name="acao"
                                                        value="finalizar"
                                                    >

                                                    <input
                                                        type="hidden"
                                                        name="idAtendimento"
                                                        value="<%= atendimento.getIdAtendimento() %>"
                                                    >

                                                    <button
                                                        class="acao-finalizar"
                                                        type="submit"
                                                    >
                                                        Finalizar
                                                    </button>

                                                </form>

                                            <%
                                                }
                                            %>

                                        </div>

                                    </td>

                                </tr>


                                <%
                                    }
                                %>


                            </tbody>

                        </table>


                    <%
                        } else {
                    %>

                        <div class="estado-vazio">
                            Nenhum atendimento cadastrado.
                        </div>

                    <%
                        }
                    %>


                </div>

            </section>

        </div>

    </main>


</body>

</html>
