<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Veiculo" %>
<%@ page import="com.fastsplash.web.model.Servico" %>

<%
    List<Veiculo> veiculos =
        (List<Veiculo>) request.getAttribute("veiculos");

    List<Servico> servicos =
        (List<Servico>) request.getAttribute("servicos");

    String erro =
        (String) request.getAttribute("erro");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Novo Agendamento - Fast Splash
    </title>

</head>

<body>

    <h1>Novo Agendamento</h1>


    <% if (erro != null) { %>

        <p>
            <strong>
                <%= erro %>
            </strong>
        </p>

    <% } %>


    <form
        action="${pageContext.request.contextPath}/agendamento"
        method="post"
    >


        <label for="idVeiculo">
            Veículo:
        </label>

        <br>


        <select
            id="idVeiculo"
            name="idVeiculo"
            required
        >

            <option value="">
                Selecione um veículo
            </option>


            <%
                if (veiculos != null) {

                    for (Veiculo veiculo : veiculos) {
            %>


            <option
                value="<%= veiculo.getIdVeiculo() %>"
            >

                <%= veiculo.getMarca() %>
                <%= veiculo.getModelo() %>
                -
                <%= veiculo.getPlaca() %>

            </option>


            <%
                    }
                }
            %>


        </select>


        <br><br>


        <label>
            Serviços:
        </label>

        <br>


        <%
            if (servicos != null) {

                for (Servico servico : servicos) {
        %>


        <label>

            <input
                type="checkbox"
                name="servicos"
                value="<%= servico.getIdServico() %>"
            >

            <%= servico.getNome() %>

            -
            R$
            <%= String.format(
                    "%.2f",
                    servico.getPreco()
            ) %>

        </label>


        <br>


        <%
                }
            }
        %>


        <br>


        <label for="data">
            Data:
        </label>

        <br>


        <input
            type="date"
            id="data"
            name="data"
            required
        >


        <br><br>


        <label for="horario">
            Horário:
        </label>

        <br>


        <input
            type="time"
            id="horario"
            name="horario"
            required
        >


        <br><br>


        <button type="submit">
            Confirmar Agendamento
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/agendamento">
        Voltar para a lista
    </a>


</body>

</html>