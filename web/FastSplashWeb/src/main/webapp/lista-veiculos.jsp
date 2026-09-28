<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Veiculo" %>

<%
    List<Veiculo> veiculos =
        (List<Veiculo>) request.getAttribute("veiculos");
%>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Veículos - Fast Splash</title>
</head>

<body>

    <h1>Veículos Cadastrados</h1>

    <a href="${pageContext.request.contextPath}/veiculo?acao=novo">
    Cadastrar novo veículo
	</a>

    <br><br>


    <table border="1">

        <tr>

            <th>ID</th>
            <th>ID Cliente</th>
            <th>Placa</th>
            <th>Marca</th>
            <th>Modelo</th>
            <th>Cor</th>
            <th>Ações</th>

        </tr>


        <%
            if (veiculos != null) {

                for (Veiculo veiculo : veiculos) {
        %>


        <tr>

            <td>
                <%= veiculo.getIdVeiculo() %>
            </td>


            <td>
                <%= veiculo.getIdCliente() %>
            </td>


            <td>
                <%= veiculo.getPlaca() %>
            </td>


            <td>
                <%= veiculo.getMarca() %>
            </td>


            <td>
                <%= veiculo.getModelo() %>
            </td>


            <td>
                <%= veiculo.getCor() %>
            </td>


            <td>

                <a href="${pageContext.request.contextPath}/veiculo?acao=editar&idVeiculo=<%= veiculo.getIdVeiculo() %>">
                    Editar
                </a>


                <form
                    action="${pageContext.request.contextPath}/veiculo"
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
                        name="idVeiculo"
                        value="<%= veiculo.getIdVeiculo() %>"
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

    <a href="${pageContext.request.contextPath}/index.jsp">
        Voltar para o início
    </a>

</body>

</html>