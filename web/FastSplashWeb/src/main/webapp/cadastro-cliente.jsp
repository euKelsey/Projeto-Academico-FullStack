<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html lang="pt-BR">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>Novo cliente | Fast Splash</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/site.css"
    >

</head>


<body class="pagina-interna">


    <header class="interna-topo">

        <div class="container interna-topo-conteudo">

            <div class="marca-cabecalho">

                <div class="marca-nome">

                    <span class="marca-fast">
                        Fast
                    </span>

                    <span class="marca-splash">
                        Splash
                    </span>

                </div>

                <span class="marca-subtitulo">
                    GESTÃO
                </span>

            </div>


            <div class="interna-topo-acoes">

                <a
                    class="interna-link"
                    href="${pageContext.request.contextPath}/cliente"
                >
                    ← Clientes
                </a>

                <a
                    class="interna-link"
                    href="${pageContext.request.contextPath}/dashboard.jsp"
                >
                    Dashboard
                </a>

            </div>

        </div>

    </header>


    <main class="interna-principal">

        <div class="container">


            <section class="interna-cabecalho">

                <div>

                    <span class="destaque-pequeno">
                        Gestão de clientes
                    </span>

                    <h1>
                        Cadastrar cliente
                    </h1>

                    <p>
                        Inclua um novo cliente no sistema Fast Splash.
                    </p>

                </div>

            </section>


            <section class="form-interno-card">

                <div class="form-interno-topo">

                    <h2>
                        Dados do cliente
                    </h2>

                    <p>
                        Preencha os dados abaixo para criar a conta.
                    </p>

                </div>


                <form
                    class="form-interno"
                    action="${pageContext.request.contextPath}/cliente"
                    method="post"
                >


                    <div class="campo-interno campo-interno-largo">

                        <label for="nome">
                            Nome completo
                        </label>

                        <input
                            type="text"
                            id="nome"
                            name="nome"
                            class="texto-maiusculo"
                            placeholder="Nome do cliente"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="cpf">
                            CPF
                        </label>

                        <input
                            type="text"
                            id="cpf"
                            name="cpf"
                            inputmode="numeric"
                            maxlength="14"
                            placeholder="000.000.000-00"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="telefone">
                            Telefone
                        </label>

                        <input
                            type="text"
                            id="telefone"
                            name="telefone"
                            inputmode="tel"
                            maxlength="15"
                            placeholder="(00) 00000-0000"
                            required
                        >

                    </div>


                    <div class="campo-interno campo-interno-largo">

                        <label for="email">
                            E-mail
                        </label>

                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="cliente@email.com"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="senha">
                            Senha inicial
                        </label>

                        <input
                            type="password"
                            id="senha"
                            name="senha"
                            placeholder="Digite a senha"
                            autocomplete="new-password"
                            required
                        >

                    </div>


                    <div class="campo-interno">

                        <label for="confirmarSenha">
                            Confirmar senha
                        </label>

                        <input
                            type="password"
                            id="confirmarSenha"
                            name="confirmarSenha"
                            placeholder="Digite novamente"
                            autocomplete="new-password"
                            required
                        >

                    </div>


                    <p class="form-observacao">
                        O cliente poderá utilizar este mesmo e-mail
                        e senha para acessar o aplicativo Fast Splash.
                    </p>


                    <div class="form-interno-acoes">

                        <a
                            class="botao-interno-secundario"
                            href="${pageContext.request.contextPath}/cliente"
                        >
                            Cancelar
                        </a>

                        <button
                            class="botao-interno-principal"
                            type="submit"
                        >
                            Cadastrar cliente
                        </button>

                    </div>

                </form>

            </section>

        </div>

    </main>


    <script>

        const formulario =
            document.querySelector(
                ".form-interno"
            );

        const nome =
            document.getElementById(
                "nome"
            );

        const cpf =
            document.getElementById(
                "cpf"
            );

        const telefone =
            document.getElementById(
                "telefone"
            );

        const senha =
            document.getElementById(
                "senha"
            );

        const confirmarSenha =
            document.getElementById(
                "confirmarSenha"
            );


        function somenteNumeros(valor) {

            return valor.replace(
                /\D/g,
                ""
            );
        }


        nome.addEventListener(
            "input",
            function () {

                nome.value =
                    nome.value.toUpperCase();
            }
        );


        cpf.addEventListener(
            "input",
            function () {

                const numeros =
                    somenteNumeros(
                        cpf.value
                    ).slice(
                        0,
                        11
                    );

                cpf.value =
                    numeros
                        .replace(
                            /(\d{3})(\d)/,
                            "$1.$2"
                        )
                        .replace(
                            /(\d{3})(\d)/,
                            "$1.$2"
                        )
                        .replace(
                            /(\d{3})(\d{1,2})$/,
                            "$1-$2"
                        );
            }
        );


        telefone.addEventListener(
            "input",
            function () {

                const numeros =
                    somenteNumeros(
                        telefone.value
                    ).slice(
                        0,
                        11
                    );

                if (
                    numeros.length <= 10
                ) {

                    telefone.value =
                        numeros
                            .replace(
                                /(\d{2})(\d)/,
                                "($1) $2"
                            )
                            .replace(
                                /(\d{4})(\d)/,
                                "$1-$2"
                            );

                    return;
                }


                telefone.value =
                    numeros
                        .replace(
                            /(\d{2})(\d)/,
                            "($1) $2"
                        )
                        .replace(
                            /(\d{5})(\d)/,
                            "$1-$2"
                        );
            }
        );


        formulario.addEventListener(
            "submit",
            function (evento) {

                if (
                    senha.value !==
                    confirmarSenha.value
                ) {

                    evento.preventDefault();

                    alert(
                        "As senhas não coincidem."
                    );

                    confirmarSenha.focus();
                }
            }
        );

    </script>


</body>

</html>
