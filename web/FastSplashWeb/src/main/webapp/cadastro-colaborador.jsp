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
        Cadastrar Funcionário - Fast Splash
    </title>

</head>

<body>


    <h1>
        Cadastrar Funcionário
    </h1>


    <% if (erro != null) { %>

        <p>
            <strong>
                <%= erro %>
            </strong>
        </p>

    <% } %>


    <form
        action="${pageContext.request.contextPath}/colaborador"
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
            value="${param.nome}"
            required
        >


        <br><br>


        <label for="cargo">
            Cargo:
        </label>

        <br>


        <input
            type="text"
            id="cargo"
            name="cargo"
            value="${param.cargo}"
            required
        >


        <br><br>


        <label for="nivelAcesso">
            Nível de acesso:
        </label>

        <br>


        <select
            id="nivelAcesso"
            name="nivelAcesso"
            required
        >

            <option value="">
                Selecione
            </option>


            <option value="ADMINISTRADOR">
                Administrador
            </option>


            <option value="ATENDENTE">
                Atendente
            </option>


            <option value="OPERACIONAL">
                Operacional
            </option>


        </select>


        <br><br>


        <label for="email">
            E-mail:
        </label>

        <br>


        <input
            type="email"
            id="email"
            name="email"
            value="${param.email}"
        >


        <br>

        <small>
            Obrigatório para Administrador e Atendente.
            Opcional para Operacional.
        </small>


        <br><br>


        <label for="senha">
            Senha:
        </label>

        <br>


        <input
            type="password"
            id="senha"
            name="senha"
        >


        <br>

        <small>
            Obrigatória para Administrador e Atendente.
            Opcional para Operacional.
        </small>


        <br><br>


        <button type="submit">
            Cadastrar Funcionário
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/colaborador">
        Voltar para a lista
    </a>


</body>

</html>