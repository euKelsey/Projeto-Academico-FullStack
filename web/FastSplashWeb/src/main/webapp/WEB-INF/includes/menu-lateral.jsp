<%@ page pageEncoding="UTF-8" %>

<%
    String menuNivel = (String) session.getAttribute("nivelAcesso");

    boolean menuAdmin =
        "ADMINISTRADOR".equals(menuNivel);

    String menuCaminho = (String) request.getAttribute(
        "jakarta.servlet.forward.servlet_path");

    if (menuCaminho == null) {
        menuCaminho = request.getServletPath();
    }

    String[][] menuItens = {
        {"dashboard", "Dashboard", "▦", "dashboard"},
        {"cliente", "Clientes", "👤", "cliente"},
        {"veiculo", "Veículos", "🚗", "veiculo"},
        {"servico", "Serviços", "🧽", "servico"},
        {"colaborador", "Colaboradores", "👥", "colaborador"},
        {"agendamento", "Agendamentos", "📅", "agendamento"},
        {"atendimento", "Atendimentos", "💦", "atendimento"},
        {"pagamento", "Pagamentos", "💳", "pagamento"}
    };
%>

<aside class="fs-menu" id="fsMenu">

    <div class="fs-menu-topo">

        <a class="fs-menu-marca"
           href="${pageContext.request.contextPath}/dashboard">

            <span class="fs-menu-fast">Fast</span><span class="fs-menu-splash">Splash</span>

            <small>GESTÃO</small>

        </a>

        <button type="button"
                id="fsMenuToggle"
                class="fs-menu-toggle"
                aria-label="Alternar menu"
                aria-controls="fsMenuNav"
                aria-expanded="true">
            ☰
        </button>

    </div>

    <nav class="fs-menu-nav" id="fsMenuNav"
         aria-label="Menu principal">

        <span class="fs-menu-legenda">MENU PRINCIPAL</span>

        <% for (String[] item : menuItens) {

            boolean restrito =
                "servico".equals(item[0])
                || "colaborador".equals(item[0]);

            if (restrito && !menuAdmin) {
                continue;
            }

            boolean selecionado =
                menuCaminho.equals("/" + item[0])
                || menuCaminho.contains(item[3]);
        %>

            <a class="fs-menu-item <%= selecionado ? "fs-menu-ativo" : "" %>"
               href="${pageContext.request.contextPath}/<%= item[0] %>"
               title="<%= item[1] %>"
               aria-label="<%= item[1] %>"
               <%= selecionado ? "aria-current=\"page\"" : "" %>>

                <span class="fs-menu-icone" aria-hidden="true">
                    <%= item[2] %>
                </span>

                <span class="fs-menu-texto">
                    <%= item[1] %>
                </span>

            </a>

        <% } %>

    </nav>

    <div class="fs-menu-rodape">

        <div class="fs-menu-perfil">

            <span class="fs-menu-icone">👤</span>

            <div class="fs-menu-texto">

                <strong>
                    <%= menuAdmin ? "Administrador" : "Atendente" %>
                </strong>

                <small>Sessão ativa</small>

            </div>

        </div>

        <a class="fs-menu-item"
           href="${pageContext.request.contextPath}/"
           title="Ver site"
           aria-label="Ver site">

            <span class="fs-menu-icone">↗</span>
            <span class="fs-menu-texto">Ver site</span>

        </a>

        <a class="fs-menu-item fs-menu-sair"
           href="${pageContext.request.contextPath}/logout"
           title="Sair"
           aria-label="Sair">

            <span class="fs-menu-icone">⏻</span>
            <span class="fs-menu-texto">Sair do sistema</span>

        </a>

    </div>

</aside>
