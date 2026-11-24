<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.fastsplash.web.model.Dashboard" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>

<%!
    private String escapar(String texto) {
        if (texto == null) return "";

        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Dashboard dados =
        (Dashboard) request.getAttribute("dashboard");

    if (dados == null) {
        response.sendRedirect(
            request.getContextPath() + "/dashboard");
        return;
    }

    String nomeUsuario =
        (String) session.getAttribute("nomeUsuario");

    boolean administrador =
        "ADMINISTRADOR".equals(
            session.getAttribute("nivelAcesso"));

    Locale brasil = Locale.forLanguageTag("pt-BR");

    NumberFormat moeda =
        NumberFormat.getCurrencyInstance(brasil);

    DateTimeFormatter formatoData =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");

    DateTimeFormatter formatoHora =
        DateTimeFormatter.ofPattern("HH:mm");

    DateTimeFormatter formatoMes =
        DateTimeFormatter.ofPattern("MMM/yy", brasil);

    BigDecimal maiorValor =
        dados.faturamentoHistorico().stream()
            .map(Dashboard.FaturamentoMes::valor)
            .max(BigDecimal::compareTo)
            .orElse(BigDecimal.ZERO);

    long totalAtendimentos =
        dados.atendimentosAguardando()
        + dados.atendimentosEmLavagem()
        + dados.atendimentosFinalizados();
%>

<!DOCTYPE html>
<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Dashboard | Fast Splash</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/site.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/interno.css">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/dashboard.css?v=2">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/menu-lateral.css">

</head>

<body class="pagina-dashboard fs-layout">

    <jsp:include page="/WEB-INF/includes/menu-lateral.jsp" />

    <main class="dashboard-principal">

        <div class="container">

            <section class="fs-dashboard-cabecalho">

                <div>
                    <span class="destaque-pequeno">
                        CENTRAL DE GESTÃO
                    </span>

                    <h1>Visão geral</h1>

                    <p>
                        Olá, <%= escapar(nomeUsuario) %>.
                        Acompanhe os resultados do Fast Splash.
                    </p>
                </div>

                <a class="interna-link"
                   href="${pageContext.request.contextPath}/dashboard">
                    ↻ Atualizar dados
                </a>

            </section>

            <section class="fs-indicadores">

                <a class="fs-indicador financeiro"
                   href="${pageContext.request.contextPath}/pagamento?filtro=pagos">

                    <span>Faturamento mensal</span>
                    <strong>
                        <%= moeda.format(dados.faturamentoMensal()) %>
                    </strong>
                    <small>Pagamentos realizados neste mês</small>

                </a>

                <a class="fs-indicador pendente"
                   href="${pageContext.request.contextPath}/pagamento?filtro=pendentes">

                    <span>Valores a receber</span>
                    <strong>
                        <%= moeda.format(dados.valoresAReceber()) %>
                    </strong>
                    <small>
                        <%= dados.pagamentosPendentes() %>
                        pagamentos pendentes
                    </small>

                </a>

                <a class="fs-indicador operacional"
                   href="${pageContext.request.contextPath}/agendamento">

                    <span>Agendamentos de hoje</span>
                    <strong><%= dados.agendamentosHoje() %></strong>
                    <small>Agendamentos não cancelados</small>

                </a>

                <a class="fs-indicador operacional"
                   href="${pageContext.request.contextPath}/atendimento?filtro=emLavagem">

                    <span>Lavagens em andamento</span>
                    <strong><%= dados.atendimentosEmLavagem() %></strong>
                    <small>Atendimentos em execução</small>

                </a>

                <a class="fs-indicador"
                   href="${pageContext.request.contextPath}/cliente">

                    <span>Clientes ativos</span>
                    <strong><%= dados.clientesAtivos() %></strong>
                    <small>Cadastros disponíveis</small>

                </a>

                <a class="fs-indicador"
                   href="${pageContext.request.contextPath}/veiculo">

                    <span>Veículos disponíveis</span>
                    <strong><%= dados.veiculosAtivos() %></strong>
                    <small>Veículos e proprietários ativos</small>

                </a>

                <% if (administrador) { %>

                    <a class="fs-indicador"
                       href="${pageContext.request.contextPath}/servico">

                        <span>Serviços ativos</span>
                        <strong><%= dados.servicosAtivos() %></strong>
                        <small>Catálogo disponível</small>

                    </a>

                    <a class="fs-indicador"
                       href="${pageContext.request.contextPath}/colaborador">

                        <span>Colaboradores ativos</span>
                        <strong><%= dados.colaboradoresAtivos() %></strong>
                        <small>Equipe cadastrada</small>

                    </a>

                <% } %>

            </section>

            <section class="fs-graficos">

                <article class="fs-dashboard-card">

                    <h2>Evolução do faturamento</h2>
                    <p>Pagamentos realizados nos últimos seis meses</p>

                    <div class="fs-grafico-barras">

                        <% for (Dashboard.FaturamentoMes mes :
                                dados.faturamentoHistorico()) {

                            int altura = maiorValor.signum() == 0
                                ? 0
                                : mes.valor()
                                    .multiply(BigDecimal.valueOf(100))
                                    .divide(maiorValor, 0,
                                        RoundingMode.HALF_UP)
                                    .intValue();
                        %>

                            <div class="fs-grafico-coluna">

                                <div class="fs-barra-area">

                                    <div class="fs-barra"
                                         style="height: <%= altura %>%"
                                         title="<%= moeda.format(mes.valor()) %>">
                                    </div>

                                </div>

                                <strong>
                                    <%= moeda.format(mes.valor()) %>
                                </strong>

                                <small>
                                    <%= mes.mes().format(formatoMes) %>
                                </small>

                            </div>

                        <% } %>

                    </div>

                </article>

                <article class="fs-dashboard-card">

                    <h2>Situação dos atendimentos</h2>
                    <p>Distribuição do histórico por status</p>

                    <%
                        long[] quantidades = {
                            dados.atendimentosAguardando(),
                            dados.atendimentosEmLavagem(),
                            dados.atendimentosFinalizados()
                        };

                        String[] nomes = {
                            "Aguardando",
                            "Em lavagem",
                            "Finalizados"
                        };

                        String[] cores = {
                            "#ff9b32",
                            "#18c8ff",
                            "#38cf91"
                        };
                    %>

                    <div class="fs-total-atendimentos">

                        <strong><%= totalAtendimentos %></strong>
                        <span>Total de atendimentos</span>

                    </div>

                    <% for (int i = 0; i < nomes.length; i++) {

                        double percentual = totalAtendimentos == 0
                            ? 0
                            : quantidades[i] * 100.0 / totalAtendimentos;
                    %>

                        <div class="fs-status-linha">

                            <div class="fs-status-legenda">

                                <span><%= nomes[i] %></span>

                                <strong><%= quantidades[i] %></strong>

                            </div>

                            <div class="fs-status-trilho">

                                <div class="fs-status-progresso"
                                     style="width: <%= percentual %>%;
                                            background: <%= cores[i] %>">
                                </div>

                            </div>

                        </div>

                    <% } %>

                </article>

            </section>

            <section class="fs-dashboard-card">

                <div class="fs-proximos-topo">

                    <div>
                        <h2>Próximos agendamentos</h2>
                        <p>Os cinco próximos horários disponíveis na agenda</p>
                    </div>

                    <a class="interna-link"
                       href="${pageContext.request.contextPath}/agendamento">
                        Ver agendamentos →
                    </a>

                </div>

                <% if (dados.proximosAgendamentos().isEmpty()) { %>

                    <div class="estado-vazio">
                        Nenhum agendamento futuro encontrado.
                    </div>

                <% } else { %>

                    <div class="tabela-responsiva">

                        <table class="tabela-interna fs-tabela-dashboard">

                            <thead>
                                <tr>
                                    <th>Data / Horário</th>
                                    <th>Cliente</th>
                                    <th>Veículo</th>
                                    <th>Serviços</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>

                                <% for (Dashboard.ProximoAgendamento item :
                                        dados.proximosAgendamentos()) { %>

                                    <tr>

                                        <td>
                                            <strong>
                                                <%= item.data().format(formatoData) %>
                                            </strong>
                                            <small class="fs-horario">
                                                <%= item.horario().format(formatoHora) %>
                                            </small>
                                        </td>

                                        <td><%= escapar(item.cliente()) %></td>
                                        <td><%= escapar(item.veiculo()) %></td>
                                        <td><%= escapar(item.servicos()) %></td>

                                        <td>
                                            <span class="fs-status-agendado">
                                                Agendado
                                            </span>
                                        </td>

                                    </tr>

                                <% } %>

                            </tbody>

                        </table>

                    </div>

                <% } %>

            </section>

        </div>

    </main>

    <script src="${pageContext.request.contextPath}/js/menu-lateral.js"></script>

</body>

</html>
