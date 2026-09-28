<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">

    <title>Cadastro de Cliente - Fast Splash</title>
</head>

<body>

    <h1>Cadastro de Cliente</h1>

    <form action="${pageContext.request.contextPath}/cliente" method="post">

        <label for="nome">Nome:</label>
        <br>

        <input
            type="text"
            id="nome"
            name="nome"
            required
        >

        <br><br>

        <label for="cpf">CPF:</label>
        <br>

        <input
            type="text"
            id="cpf"
            name="cpf"
            required
        >

        <br><br>

        <label for="telefone">Telefone:</label>
        <br>

        <input
            type="text"
            id="telefone"
            name="telefone"
            required
        >

        <br><br>

        <label for="email">E-mail:</label>
        <br>

        <input
            type="email"
            id="email"
            name="email"
            required
        >

        <br><br>

        <label for="senha">Senha:</label>
        <br>

        <input
            type="password"
            id="senha"
            name="senha"
            required
        >

        <br><br>

        <button type="submit">
            Cadastrar Cliente
        </button>

    </form>

</body>

</html>