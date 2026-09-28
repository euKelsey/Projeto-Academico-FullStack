<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.fastsplash.web.model.Colaborador" %>

<%
    Colaborador colaborador =
        (Colaborador)
            request.getAttribute(
                    "colaborador"
            );

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
        Editar Funcionário - Fast Splash
    </title>

</head>

<body>


    <h1>
        Editar Funcionário
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


        <input
            type="hidden"
            name="acao"
            value="atualizar"
        >


        <input
            type="hidden"
            name="idColaborador"
            value="<%= colaborador.getIdColaborador() %>"
        >


        <label for="nome">
            Nome:
        </label>

        <br>


        <input
            type="text"
            id="nome"
            name="nome"
            value="<%= colaborador.getNome() %>"
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
            value="<%= colaborador.getCargo() %>"
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


            <option
                value="ADMINISTRADOR"
                <%= "ADMINISTRADOR".equals(
                        colaborador.getNivelAcesso()
                    )
                    ? "selected"
                    : ""
                %>
            >
                Administrador
            </option>


            <option
                value="ATENDENTE"
                <%= "ATENDENTE".equals(
                        colaborador.getNivelAcesso()
                    )
                    ? "selected"
                    : ""
                %>
            >
                Atendente
            </option>


            <option
                value="OPERACIONAL"
                <%= "OPERACIONAL".equals(
                        colaborador.getNivelAcesso()
                    )
                    ? "selected"
                    : ""
                %>
            >
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

            value="<%=
                colaborador.getEmail() != null
                ? colaborador.getEmail()
                : ""
            %>"
        >


        <br>

        <small>
            Obrigatório para Administrador e Atendente.
        </small>


        <br><br>


        <label for="senha">
            Nova senha:
        </label>

        <br>


        <input
            type="password"
            id="senha"
            name="senha"
        >


        <br>

        <small>
            Deixe em branco para manter a senha atual.
        </small>


        <br><br>


        <button type="submit">
            Salvar Alterações
        </button>


    </form>


    <br>


    <a href="${pageContext.request.contextPath}/colaborador">
        Voltar para a lista
    </a>


</body>

</html>