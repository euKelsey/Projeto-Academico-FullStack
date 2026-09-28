<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Atendimento" %>

<%
    Atendimento atendimento =
        (Atendimento)
            request.getAttribute(
                    "atendimento"
            );
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Detalhes do Atendimento - Fast Splash
    </title>

</head>

<body>


    <h1>
        Detalhes do Atendimento
    </h1>


    <p>

        <strong>
            ID:
        </strong>

        <%= atendimento.getIdAtendimento() %>

    </p>


    <p>

        <strong>
            Agendamento:
        </strong>

        #<%= atendimento.getIdAgendamento() %>

    </p>


    <p>

        <strong>
            Veículo:
        </strong>

        <%= atendimento.getVeiculoDescricao() %>

    </p>


    <p>

        <strong>
            Serviços:
        </strong>

        <%= atendimento.getServicosDescricao() %>

    </p>


    <p>

        <strong>
            Status:
        </strong>

        <%= atendimento.getStatus() %>

    </p>


    <p>

        <strong>
            Início:
        </strong>


        <%
            if (
                atendimento.getDataInicio()
                != null
            ) {
        %>


        <%= atendimento.getDataInicio() %>


        <%
            } else {
        %>


        Não iniciado


        <%
            }
        %>


    </p>


    <p>

        <strong>
            Finalização:
        </strong>


        <%
            if (
                atendimento.getDataFim()
                != null
            ) {
        %>


        <%= atendimento.getDataFim() %>


        <%
            } else {
        %>


        Não finalizado


        <%
            }
        %>


    </p>


    <br>


    <a href="${pageContext.request.contextPath}/atendimento">
        Voltar para os atendimentos
    </a>


</body>

</html>