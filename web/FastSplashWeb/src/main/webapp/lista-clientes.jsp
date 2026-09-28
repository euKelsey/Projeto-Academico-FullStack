<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Cliente" %>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Clientes - Fast Splash</title>
</head>

<body>

    <h1>Clientes cadastrados</h1>

    <%
        List<Cliente> clientes =
            (List<Cliente>) request.getAttribute("clientes");
    %>

    <table border="1">

    <tr>
        <th>ID</th>
        <th>Nome</th>
        <th>CPF</th>
        <th>Telefone</th>
        <th>E-mail</th>
        <th>Ações</th>
    </tr>

    <%
        if (clientes != null) {

            for (Cliente cliente : clientes) {
    %>

    <tr>

        <td>
            <%= cliente.getIdCliente() %>
        </td>

        <td>
            <%= cliente.getNome() %>
        </td>

        <td>
            <%= cliente.getCpf() %>
        </td>

        <td>
            <%= cliente.getTelefone() %>
        </td>

        <td>
            <%= cliente.getEmail() %>
        </td>

        <td>
        
         <a href="${pageContext.request.contextPath}/cliente?acao=editar&idCliente=<%= cliente.getIdCliente() %>">
        Editar
    </a>

            <form
                action="${pageContext.request.contextPath}/cliente"
                method="post"
                style="display:inline;"
            >

                <input
                    type="hidden"
                    name="acao"
                    value="excluir"
                >

                <input
                    type="hidden"
                    name="idCliente"
                    value="<%= cliente.getIdCliente() %>"
                >

                <button type="submit">
                    Excluir
                </button>

            </form>

        </td>

    </tr>

    <%
            }
        }
    %>

</table>

    <br>

    <a href="cadastro-cliente.jsp">
        Cadastrar novo cliente
    </a>

</body>

</html>