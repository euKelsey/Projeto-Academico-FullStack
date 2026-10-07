<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.fastsplash.web.model.Agendamento" %>

<%
    List<Agendamento> agendamentos =
            (List<Agendamento>) request.getAttribute(
                    "agendamentos"
            );

    String erro =
            (String) request.getAttribute(
                    "erro"
            );

    boolean possuiAgendamentos =
            agendamentos != null
            && !agendamentos.isEmpty();

    DateTimeFormatter formatoData =
            DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy"
            );

    DateTimeFormatter formatoHora =
            DateTimeFormatter.ofPattern(
                    "HH:mm"
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

    <title>Novo atendimento | Fast Splash</title>

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
                        Gestão de atendimentos
                    </span>

                    <h1>
                        Novo atendimento
                    </h1>

                    <p>
                        Selecione um agendamento ativo
                        que ainda não possui atendimento.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Agendamento
                    </h2>

                    <p>
                        Ao criar, o atendimento começa
                        com status AGUARDANDO.
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
                    if (!possuiAgendamentos) {
                %>

                    <div class="aviso-interno">

                        Não existem agendamentos disponíveis
                        para iniciar um novo atendimento.

                    </div>

                <%
                    }
                %>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/atendimento"
                    method="post"
                >


                    <div class="campo-interno campo-interno-largo">

                        <label for="idAgendamento">
                            Agendamento disponível
                        </label>

                        <select
                            id="idAgendamento"
                            name="idAgendamento"
                            required
                            <%= possuiAgendamentos ? "" : "disabled" %>
                        >

                            <option value="">
                                Selecione um agendamento
                            </option>


                            <%
                                if (agendamentos != null) {

                                    for (
                                        Agendamento agendamento
                                        : agendamentos
                                    ) {
                            %>

                                <option
                                    value="<%= agendamento.getIdAgendamento() %>"
                                >
                                    <%= agendamento.getClienteNome() %>
                                    —
                                    <%= agendamento.getVeiculoDescricao() %>
                                    —
                                    <%= agendamento.getData().format(formatoData) %>
                                    às
                                    <%= agendamento.getHorario().format(formatoHora) %>
                                </option>

                            <%
                                    }
                                }
                            %>

                        </select>

                    </div>


                    <p class="form-observacao">
                        Apenas agendamentos com status AGENDADO
                        e sem atendimento vinculado aparecem nesta lista.
                    </p>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/atendimento"
                        >
                            Cancelar
                        </a>


                        <%
                            if (possuiAgendamentos) {
                        %>

                            <button
                                class="botao-interno-principal"
                                type="submit"
                            >
                                Criar atendimento
                            </button>

                        <%
                            }
                        %>

                    </div>

                </form>

            </section>

        </div>

    </main>


</body>

</html>
