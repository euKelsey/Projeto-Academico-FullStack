<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String erro =
        (String)
            request.getAttribute(
                    "erro"
            );
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Login - Fast Splash
    </title>

</head>

<body>


    <h1>Fast Splash</h1>

    <h2>Acesso ao Sistema</h2>


    <% if (erro != null) { %>

        <p>
            <strong>
                <%= erro %>
            </strong>
        </p>

    <% } %>


    <form
        action="${pageContext.request.contextPath}/login"
        method="post"
    >


        <label for="email">
            E-mail:
        </label>

        <br>


        <input
            type="email"
            id="email"
            name="email"
            required
        >


        <br><br>


        <label for="senha">
            Senha:
        </label>

        <br>


        <input
            type="password"
            id="senha"
            name="senha"
            required
        >


        <br><br>


        <button type="submit">
            Entrar
        </button>


    </form>


</body>

</html>