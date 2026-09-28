<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>
<%@ page import="com.fastsplash.web.model.Veiculo" %>

<%
    Veiculo veiculo =
        (Veiculo) request.getAttribute("veiculo");

    List<Cliente> clientes =
        (List<Cliente>) request.getAttribute("clientes");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Editar Veículo - Fast Splash
    </title>

</head>

<body>

    <h1>Editar Veículo</h1>


    <form
        action="${pageContext.request.contextPath}/veiculo"
        method="post"
    >


        <input
            type="hidden"
            name="acao"
            value="atualizar"
        >


        <input
            type="hidden"
            name="idVeiculo"
            value="<%= veiculo.getIdVeiculo() %>"
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


            <%
                if (clientes != null) {

                    for (Cliente cliente : clientes) {

                        boolean selecionado =
                            cliente.getIdCliente()
                            == veiculo.getIdCliente();
            %>


            <option
                value="<%= cliente.getIdCliente() %>"
                <%= selecionado ? "selected" : "" %>
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
            value="<%= veiculo.getPlaca() %>"
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
            value="<%= veiculo.getMarca() %>"
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
            value="<%= veiculo.getModelo() %>"
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
            value="<%= veiculo.getCor() %>"
            required
        >


        <br><br>


        <button type="submit">
            Salvar Alterações
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/veiculo">
        Voltar para a lista
    </a>


</body>

</html>