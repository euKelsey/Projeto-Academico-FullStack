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

    String erro =
        (String)
            request.getAttribute(
                    "erro"
            );
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Novo Atendimento - Fast Splash
    </title>

</head>

<body>


    <h1>Novo Atendimento</h1>


    <% if (erro != null) { %>

        <p>
            <strong>
                <%= erro %>
            </strong>
        </p>

    <% } %>


    <form
        action="${pageContext.request.contextPath}/atendimento"
        method="post"
    >


        <label for="idAgendamento">
            Agendamento:
        </label>

        <br>


        <select
            id="idAgendamento"
            name="idAgendamento"
            required
        >


            <option value="">
                Selecione um agendamento
            </option>


            <%
                if (agendamentos != null) {

                    for (
                        Agendamento agendamento :
                        agendamentos
                    ) {
            %>


            <option
                value="<%= agendamento.getIdAgendamento() %>"
            >

                #<%= agendamento.getIdAgendamento() %>

                -

                <%= agendamento.getVeiculoDescricao() %>

                -

                <%= agendamento.getData() %>

                <%= agendamento.getHorario() %>

            </option>


            <%
                    }
                }
            %>


        </select>


        <br><br>


        <button type="submit">
            Criar Atendimento
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/atendimento">
        Voltar para a lista
    </a>


</body>

</html>