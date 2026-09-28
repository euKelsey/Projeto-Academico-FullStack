<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Agendamento" %>

<%
    List<Agendamento> agendamentos =
        (List<Agendamento>)
            request.getAttribute(
                    "agendamentos"
            );
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Agendamentos - Fast Splash
    </title>

</head>

<body>

    <h1>Agendamentos</h1>


    <a href="${pageContext.request.contextPath}/agendamento?acao=novo">
        Novo agendamento
    </a>


    <br><br>


    <table border="1">

        <tr>

            <th>ID</th>
            <th>Veículo</th>
            <th>Serviços</th>
            <th>Data</th>
            <th>Horário</th>
            <th>Valor Total</th>
            <th>Status</th>
            <th>Ações</th>

        </tr>


        <%
            if (agendamentos != null) {

                for (
                    Agendamento agendamento :
                    agendamentos
                ) {
        %>


        <tr>


            <td>
                <%= agendamento.getIdAgendamento() %>
            </td>


            <td>
                <%= agendamento.getVeiculoDescricao() %>
            </td>


            <td>
                <%= agendamento.getServicosDescricao() %>
            </td>


            <td>
                <%= agendamento.getData() %>
            </td>


            <td>
                <%= agendamento.getHorario() %>
            </td>


            <td>
                R$
                <%= String.format(
                        "%.2f",
                        agendamento.getValorTotal()
                ) %>
            </td>


            <td>
                <%= agendamento.getStatus() %>
            </td>


            <td>


                <%
                    if (
                        "AGENDADO".equals(
                                agendamento.getStatus()
                        )
                    ) {
                %>


                <form
                    action="${pageContext.request.contextPath}/agendamento"
                    method="post"
                    style="display:inline;"
                >


                    <input
                        type="hidden"
                        name="acao"
                        value="cancelar"
                    >


                    <input
                        type="hidden"
                        name="idAgendamento"
                        value="<%= agendamento.getIdAgendamento() %>"
                    >


                    <button type="submit">
                        Cancelar
                    </button>


                </form>


                <%
                    } else {
                %>


                -


                <%
                    }
                %>


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