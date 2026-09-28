<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Atendimento" %>

<%
    List<Atendimento> atendimentos =
        (List<Atendimento>)
            request.getAttribute(
                    "atendimentos"
            );
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Atendimentos - Fast Splash
    </title>

</head>

<body>


    <h1>Atendimentos</h1>


    <a href="${pageContext.request.contextPath}/atendimento?acao=novo">
        Novo atendimento
    </a>


    <br><br>


    <table border="1">


        <tr>

            <th>ID</th>
            <th>Agendamento</th>
            <th>Veículo</th>
            <th>Serviços</th>
            <th>Status</th>
            <th>Início</th>
            <th>Fim</th>
            <th>Ações</th>

        </tr>


        <%
            if (atendimentos != null) {

                for (
                    Atendimento atendimento :
                    atendimentos
                ) {
        %>


        <tr>


            <td>
                <%= atendimento.getIdAtendimento() %>
            </td>


            <td>
                #<%= atendimento.getIdAgendamento() %>
            </td>


            <td>
                <%= atendimento.getVeiculoDescricao() %>
            </td>


            <td>
                <%= atendimento.getServicosDescricao() %>
            </td>


            <td>
                <%= atendimento.getStatus() %>
            </td>


            <td>

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

                    -

                <%
                    }
                %>

            </td>


            <td>

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

                    -

                <%
                    }
                %>

            </td>


            <td>


                <a href="${pageContext.request.contextPath}/atendimento?acao=detalhes&idAtendimento=<%= atendimento.getIdAtendimento() %>">
                    Detalhes
                </a>


                <br><br>


                <% if (
                    "AGUARDANDO".equals(
                        atendimento.getStatus()
                    )
                ) { %>


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


                    <button type="submit">
                        Iniciar Lavagem
                    </button>


                </form>


                <% } %>


                <% if (
                    "EM_LAVAGEM".equals(
                        atendimento.getStatus()
                    )
                ) { %>


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


                    <button type="submit">
                        Finalizar
                    </button>


                </form>


                <% } %>


                <% if (
                    "FINALIZADO".equals(
                        atendimento.getStatus()
                    )
                ) { %>


                    Atendimento concluído


                <% } %>


            </td>


        </tr>


        <%
                }
            }
        %>


    </table>


    <br>


    <a href="${pageContext.request.contextPath}/index.jsp">
        Voltar para o início
    </a>


</body>

</html>