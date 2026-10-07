<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.fastsplash.web.model.Atendimento" %>

<%
    Atendimento atendimento =
            (Atendimento) request.getAttribute(
                    "atendimento"
            );

    DateTimeFormatter formatoDataHora =
            DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy HH:mm"
            );

    String status =
            atendimento.getStatus();

    String classeStatus =
            "status-aguardando";

    if ("EM_LAVAGEM".equals(status)) {
        classeStatus = "status-em-lavagem";
    } else if ("FINALIZADO".equals(status)) {
        classeStatus = "status-finalizado";
    }
%>

<!DOCTYPE html>

<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Detalhes do atendimento | Fast Splash</title>

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
                    href="${pageContext.request.contextPath}/atendimento"
                >
                    ← Atendimentos
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
                        Atendimento #<%= atendimento.getIdAtendimento() %>
                    </span>

                    <h1>
                        Detalhes do atendimento
                    </h1>

                    <p>
                        Informações completas do serviço em andamento.
                    </p>

                </div>


                <span
                    class="status-badge <%= classeStatus %>"
                >
                    <%= status %>
                </span>

            </section>


            <section class="form-interno-card">

                <div class="atendimento-detalhes-grid">


                    <div class="detalhe-card">

                        <span>
                            Cliente
                        </span>

                        <strong>
                            <%= atendimento.getClienteNome() %>
                        </strong>

                    </div>


                    <div class="detalhe-card">

                        <span>
                            Veículo
                        </span>

                        <strong>
                            <%= atendimento.getVeiculoDescricao() %>
                        </strong>

                    </div>


                    <div class="detalhe-card detalhe-card-largo">

                        <span>
                            Serviços
                        </span>

                        <strong>
                            <%= atendimento.getServicosDescricao() %>
                        </strong>

                    </div>


                    <div class="detalhe-card">

                        <span>
                            Agendamento
                        </span>

                        <strong>
                            #<%= atendimento.getIdAgendamento() %>
                        </strong>

                    </div>


                    <div class="detalhe-card">

                        <span>
                            Status atual
                        </span>

                        <strong>
                            <%= status %>
                        </strong>

                    </div>


                    <div class="detalhe-card">

                        <span>
                            Início da lavagem
                        </span>

                        <strong>

                            <%
                                if (
                                    atendimento.getDataInicio()
                                    != null
                                ) {
                            %>

                                <%= atendimento.getDataInicio().format(formatoDataHora) %>

                            <%
                                } else {
                            %>

                                Ainda não iniciado

                            <%
                                }
                            %>

                        </strong>

                    </div>


                    <div class="detalhe-card">

                        <span>
                            Finalização
                        </span>

                        <strong>

                            <%
                                if (
                                    atendimento.getDataFim()
                                    != null
                                ) {
                            %>

                                <%= atendimento.getDataFim().format(formatoDataHora) %>

                            <%
                                } else {
                            %>

                                Ainda não finalizado

                            <%
                                }
                            %>

                        </strong>

                    </div>


                </div>


                <div class="atendimento-fluxo">

                    <span
                        class="fluxo-etapa <%= "AGUARDANDO".equals(status) ? "ativa" : "" %>"
                    >
                        Aguardando
                    </span>

                    <span class="fluxo-seta">
                        →
                    </span>

                    <span
                        class="fluxo-etapa <%= "EM_LAVAGEM".equals(status) ? "ativa" : "" %>"
                    >
                        Em lavagem
                    </span>

                    <span class="fluxo-seta">
                        →
                    </span>

                    <span
                        class="fluxo-etapa <%= "FINALIZADO".equals(status) ? "ativa" : "" %>"
                    >
                        Finalizado
                    </span>

                </div>

            </section>

        </div>

    </main>


</body>

</html>
