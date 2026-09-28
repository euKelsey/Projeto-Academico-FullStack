<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Colaborador" %>

<%
    List<Colaborador> colaboradores =
        (List<Colaborador>)
            request.getAttribute(
                    "colaboradores"
            );
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Funcionários - Fast Splash
    </title>

</head>

<body>


    <h1>
        Funcionários
    </h1>


    <a href="${pageContext.request.contextPath}/colaborador?acao=novo">
        Cadastrar funcionário
    </a>


    <br><br>


    <table border="1">


        <tr>

            <th>ID</th>
            <th>Nome</th>
            <th>Cargo</th>
            <th>Nível de acesso</th>
            <th>E-mail</th>
            <th>Ações</th>

        </tr>


        <%
            if (colaboradores != null) {

                for (
                    Colaborador colaborador :
                    colaboradores
                ) {
        %>


        <tr>


            <td>
                <%= colaborador.getIdColaborador() %>
            </td>


            <td>
                <%= colaborador.getNome() %>
            </td>


            <td>
                <%= colaborador.getCargo() %>
            </td>


            <td>
                <%= colaborador.getNivelAcesso() %>
            </td>


            <td>

                <%
                    if (
                        colaborador.getEmail()
                        != null
                    ) {
                %>

                    <%= colaborador.getEmail() %>

                <%
                    } else {
                %>

                    -

                <%
                    }
                %>

            </td>


            <td>


                <a href="${pageContext.request.contextPath}/colaborador?acao=editar&idColaborador=<%= colaborador.getIdColaborador() %>">
                    Editar
                </a>


                <form
                    action="${pageContext.request.contextPath}/colaborador"
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
                        name="idColaborador"
                        value="<%= colaborador.getIdColaborador() %>"
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