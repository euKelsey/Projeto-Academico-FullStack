<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Servico" %>

<%
    Servico servico =
        (Servico) request.getAttribute("servico");
%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Editar Serviço - Fast Splash
    </title>

</head>

<body>

    <h1>Editar Serviço</h1>


    <form
        action="${pageContext.request.contextPath}/servico"
        method="post"
    >


        <input
            type="hidden"
            name="acao"
            value="atualizar"
        >


        <input
            type="hidden"
            name="idServico"
            value="<%= servico.getIdServico() %>"
        >


        <label for="nome">
            Nome:
        </label>

        <br>


        <input
            type="text"
            id="nome"
            name="nome"
            value="<%= servico.getNome() %>"
            required
        >


        <br><br>


        <label for="descricao">
            Descrição:
        </label>

        <br>


        <textarea
            id="descricao"
            name="descricao"
            rows="4"
            cols="40"
        ><%= servico.getDescricao() %></textarea>


        <br><br>


        <label for="preco">
            Preço:
        </label>

        <br>


        <input
            type="number"
            id="preco"
            name="preco"
            min="0"
            step="0.01"
            value="<%= servico.getPreco() %>"
            required
        >


        <br><br>


        <button type="submit">
            Salvar Alterações
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/servico">
        Voltar para a lista
    </a>


</body>

</html>