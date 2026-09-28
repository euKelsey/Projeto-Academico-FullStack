<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Cliente" %>

<%
    Cliente cliente =
        (Cliente) request.getAttribute("cliente");
%>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Editar Cliente - Fast Splash</title>
</head>

<body>

    <h1>Editar Cliente</h1>

    <form
        action="${pageContext.request.contextPath}/cliente"
        method="post"
    >

        <input
            type="hidden"
            name="acao"
            value="atualizar"
        >

        <input
            type="hidden"
            name="idCliente"
            value="<%= cliente.getIdCliente() %>"
        >

        <label for="nome">Nome:</label>
        <br>

        <input
            type="text"
            id="nome"
            name="nome"
            value="<%= cliente.getNome() %>"
            required
        >

        <br><br>

        <label for="cpf">CPF:</label>
        <br>

        <input
            type="text"
            id="cpf"
            name="cpf"
            value="<%= cliente.getCpf() %>"
            required
        >

        <br><br>

        <label for="telefone">Telefone:</label>
        <br>

        <input
            type="text"
            id="telefone"
            name="telefone"
            value="<%= cliente.getTelefone() %>"
            required
        >

        <br><br>

        <label for="email">E-mail:</label>
        <br>

        <input
            type="email"
            id="email"
            name="email"
            value="<%= cliente.getEmail() %>"
            required
        >

        <br><br>

        <button type="submit">
            Salvar Alterações
        </button>

    </form>

    <br>

    <a href="${pageContext.request.contextPath}/cliente">
        Voltar para a lista
    </a>

</body>

</html>