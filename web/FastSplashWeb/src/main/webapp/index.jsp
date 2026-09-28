<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Colaborador" %>

<%
    Colaborador usuarioLogado =
        (Colaborador)
            session.getAttribute(
                    "usuarioLogado"
            );

    String nivelAcesso =
        usuarioLogado != null
        ? usuarioLogado.getNivelAcesso()
        : null;

    String nomeUsuario =
        usuarioLogado != null
        ? usuarioLogado.getNome()
        : "";
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Fast Splash
    </title>

</head>

<body>


    <h1>
        Fast Splash
    </h1>


    <h2>
        Sistema Administrativo
    </h2>


    <p>
        Bem-vindo,
        <strong>
            <%= nomeUsuario %>
        </strong>
    </p>


    <p>
        Nível de acesso:
        <strong>
            <%= nivelAcesso %>
        </strong>
    </p>


    <hr>


    <h3>
        Menu
    </h3>


    <p>

        <a href="${pageContext.request.contextPath}/cliente">
            Clientes
        </a>

    </p>


    <p>

        <a href="${pageContext.request.contextPath}/veiculo">
            Veículos
        </a>

    </p>


    <p>

        <a href="${pageContext.request.contextPath}/agendamento">
            Agendamentos
        </a>

    </p>


    <p>

        <a href="${pageContext.request.contextPath}/atendimento">
            Atendimentos
        </a>

    </p>


    <% if (
        "ADMINISTRADOR".equals(
                nivelAcesso
        )
    ) { %>


        <p>

            <a href="${pageContext.request.contextPath}/servico">
                Serviços
            </a>

        </p>


        <p>

            <a href="${pageContext.request.contextPath}/colaborador">
                Funcionários
            </a>

        </p>


    <% } %>


    <hr>


    <p>

        <a href="${pageContext.request.contextPath}/logout">
            Sair
        </a>

    </p>


</body>

</html>