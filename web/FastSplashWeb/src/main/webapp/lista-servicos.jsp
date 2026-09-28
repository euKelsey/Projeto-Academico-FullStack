<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.fastsplash.web.model.Servico" %>

<%
    List<Servico> servicos =
        (List<Servico>) request.getAttribute("servicos");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Serviços - Fast Splash
    </title>

</head>

<body>

    <h1>Serviços Cadastrados</h1>


    <a href="${pageContext.request.contextPath}/servico?acao=novo">
        Cadastrar novo serviço
    </a>


    <br><br>


    <table border="1">

        <tr>

            <th>ID</th>
            <th>Nome</th>
            <th>Descrição</th>
            <th>Preço</th>
            <th>Ações</th>

        </tr>


        <%
            if (servicos != null) {

                for (Servico servico : servicos) {
        %>


        <tr>

            <td>
                <%= servico.getIdServico() %>
            </td>


            <td>
                <%= servico.getNome() %>
            </td>


            <td>
                <%= servico.getDescricao() %>
            </td>


            <td>
                R$ <%= String.format("%.2f", servico.getPreco()) %>
            </td>


            <td>


                <a href="${pageContext.request.contextPath}/servico?acao=editar&idServico=<%= servico.getIdServico() %>">
                    Editar
                </a>


                <form
                    action="${pageContext.request.contextPath}/servico"
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
                        name="idServico"
                        value="<%= servico.getIdServico() %>"
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