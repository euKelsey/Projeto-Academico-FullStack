<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>

<head>

    <meta charset="UTF-8">

    <title>
        Cadastrar Serviço - Fast Splash
    </title>

</head>

<body>

    <h1>Cadastrar Serviço</h1>


    <form
        action="${pageContext.request.contextPath}/servico"
        method="post"
    >


        <label for="nome">
            Nome:
        </label>

        <br>


        <input
            type="text"
            id="nome"
            name="nome"
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
        ></textarea>


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
            required
        >


        <br><br>


        <button type="submit">
            Cadastrar Serviço
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/servico">
        Voltar para a lista
    </a>


</body>

</html>