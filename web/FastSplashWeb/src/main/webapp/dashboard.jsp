<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <% String nomeUsuario=(String) session.getAttribute( "nomeUsuario" ); String nivelAcesso=(String)
        session.getAttribute( "nivelAcesso" ); if (nomeUsuario==null) { nomeUsuario="Colaborador" ; } if
        (nivelAcesso==null) { nivelAcesso="" ; } boolean administrador="ADMINISTRADOR" .equals( nivelAcesso ); %>

        <!DOCTYPE html>

        <html lang="pt-BR">

        <head>

            <meta charset="UTF-8">

            <meta name="viewport" content="width=device-width, initial-scale=1.0">

            <title>Dashboard | Fast Splash</title>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site.css">

        </head>


        <body class="pagina-dashboard">


            <!-- =========================================
         TOPO DO PAINEL
    ========================================== -->

            <header class="dashboard-topo">

                <div class="container dashboard-topo-conteudo">

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


                    <div class="dashboard-topo-acoes">

                        <a class="dashboard-link-site" href="${pageContext.request.contextPath}/">
                            Ver site
                        </a>

                        <a class="dashboard-sair" href="${pageContext.request.contextPath}/logout">
                            Sair
                        </a>

                    </div>

                </div>

            </header>


            <main class="dashboard-principal">

                <div class="container">


                    <!-- =====================================
                 BOAS-VINDAS
            ====================================== -->

                    <section class="dashboard-boas-vindas">

                        <div class="dashboard-boas-vindas-texto">

                            <span class="destaque-pequeno">
                                Painel interno
                            </span>

                            <h1>
                                Olá, <%= nomeUsuario %>.
                            </h1>

                            <p>
                                Acesse os módulos do Fast Splash
                                para acompanhar e administrar
                                as operações do sistema.
                            </p>

                        </div>


                        <aside class="dashboard-perfil">

                            <span class="dashboard-perfil-label">
                                Usuário conectado
                            </span>

                            <strong>
                                <%= nomeUsuario %>
                            </strong>

                            <span class="dashboard-perfil-nivel">
                                <%= nivelAcesso %>
                            </span>

                        </aside>

                    </section>


                    <!-- =====================================
                 MÓDULOS
            ====================================== -->

                    <section>

                        <div class="dashboard-secao-topo">

                            <div>

                                <h2>
                                    Módulos do sistema
                                </h2>

                                <p>
                                    Escolha uma área para continuar.
                                </p>

                            </div>

                        </div>


                        <div class="dashboard-modulos">


                            <a class="dashboard-card" href="${pageContext.request.contextPath}/cliente">

                                <div class="dashboard-card-icone">
                                    👤
                                </div>

                                <h3>
                                    Clientes
                                </h3>

                                <p>
                                    Consulte e gerencie
                                    os clientes cadastrados.
                                </p>

                                <span class="dashboard-card-acao">
                                    Acessar clientes →
                                </span>

                            </a>


                            <a class="dashboard-card" href="${pageContext.request.contextPath}/veiculo">

                                <div class="dashboard-card-icone">
                                    🚗
                                </div>

                                <h3>
                                    Veículos
                                </h3>

                                <p>
                                    Consulte veículos e
                                    seus respectivos clientes.
                                </p>

                                <span class="dashboard-card-acao">
                                    Acessar veículos →
                                </span>

                            </a>


                            <a class="dashboard-card" href="${pageContext.request.contextPath}/agendamento">

                                <div class="dashboard-card-icone">
                                    📅
                                </div>

                                <h3>
                                    Agendamentos
                                </h3>

                                <p>
                                    Consulte e organize
                                    os agendamentos do lava-rápido.
                                </p>

                                <span class="dashboard-card-acao">
                                    Acessar agendamentos →
                                </span>

                            </a>


                            <a class="dashboard-card" href="${pageContext.request.contextPath}/atendimento">

                                <div class="dashboard-card-icone">
                                    💦
                                </div>

                                <h3>
                                    Atendimentos
                                </h3>

                                <p>
                                    Acompanhe os serviços
                                    em andamento e finalizados.
                                </p>

                                <span class="dashboard-card-acao">
                                    Acessar atendimentos →
                                </span>

                            </a>


                            <% if (administrador) { %>

                                <a class="dashboard-card dashboard-card-admin"
                                    href="${pageContext.request.contextPath}/servico">

                                    <div class="dashboard-card-icone">
                                        🧽
                                    </div>

                                    <h3>
                                        Serviços
                                    </h3>

                                    <p>
                                        Cadastre e gerencie
                                        os serviços oferecidos.
                                    </p>

                                    <span class="dashboard-card-acao">
                                        Acessar serviços →
                                    </span>

                                </a>


                                <a class="dashboard-card dashboard-card-admin"
                                    href="${pageContext.request.contextPath}/colaborador">

                                    <div class="dashboard-card-icone">
                                        👥
                                    </div>

                                    <h3>
                                        Colaboradores
                                    </h3>

                                    <p>
                                        Gerencie funcionários
                                        e seus níveis de acesso.
                                    </p>

                                    <span class="dashboard-card-acao">
                                        Acessar colaboradores →
                                    </span>

                                </a>

                                <% } %>


                                    <a class="dashboard-card" href="${pageContext.request.contextPath}/pagamento">

                                        <div class="dashboard-card-icone">
                                            💳
                                        </div>

                                        <h3>
                                            Pagamentos
                                        </h3>

                                        <p>
                                            Consulte pagamentos
                                            pendentes e realizados.
                                        </p>

                                        <span class="dashboard-card-acao">
                                            Acessar pagamentos →
                                        </span>

                                    </a>


                        </div>

                    </section>

                </div>

            </main>

        </body>

        </html>