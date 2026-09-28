<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>

<%
    List<Cliente> clientes =
        (List<Cliente>) request.getAttribute("clientes");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Cadastrar Veículo - Fast Splash
    </title>

</head>

<body>

    <h1>Cadastrar Veículo</h1>


    <form
        action="${pageContext.request.contextPath}/veiculo"
        method="post"
    >


        <label for="idCliente">
            Cliente:
        </label>

        <br>


        <select
            id="idCliente"
            name="idCliente"
            required
        >

            <option value="">
                Selecione um cliente
            </option>


            <%
                if (clientes != null) {

                    for (Cliente cliente : clientes) {
            %>


            <option
                value="<%= cliente.getIdCliente() %>"
            >

                <%= cliente.getNome() %>

            </option>


            <%
                    }
                }
            %>


        </select>


        <br><br>


        <label for="placa">
            Placa:
        </label>

        <br>


        <input
            type="text"
            id="placa"
            name="placa"
            required
        >


        <br><br>


        <label for="marca">
            Marca:
        </label>

        <br>


        <input
            type="text"
            id="marca"
            name="marca"
            required
        >


        <br><br>


        <label for="modelo">
            Modelo:
        </label>

        <br>


        <input
            type="text"
            id="modelo"
            name="modelo"
            required
        >


        <br><br>


        <label for="cor">
            Cor:
        </label>

        <br>


        <input
            type="text"
            id="cor"
            name="cor"
            required
        >


        <br><br>


        <button type="submit">
            Cadastrar Veículo
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/veiculo">
        Voltar para a lista
    </a>


</body>

</html>