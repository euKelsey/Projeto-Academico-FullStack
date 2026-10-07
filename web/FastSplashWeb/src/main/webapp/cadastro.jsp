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
    <title>Cadastre-se | Fast Splash</title>

    <link
        rel="stylesheet"
        href="${pageContext.request.contextPath}/css/site.css"
    >
</head>

<body class="pagina-cadastro">

    <header class="cadastro-cabecalho">
        <div class="container cadastro-cabecalho-conteudo">

            <div class="marca-cabecalho">

                <div class="marca-nome">
                    <span class="marca-fast">Fast</span>
                    <span class="marca-splash">Splash</span>
                </div>

                <span class="marca-subtitulo">
                    CAR WASH
                </span>

            </div>

            <a
                class="voltar-site"
                href="${pageContext.request.contextPath}/"
            >
                ← Voltar para o site
            </a>

        </div>
    </header>


    <main class="cadastro-principal">

        <div class="container cadastro-layout">

            <section class="cadastro-apresentacao">

                <span class="destaque-pequeno">
                    Fast Splash App
                </span>

                <h1>
                    Crie sua conta
                    e cuide do seu carro
                    pelo celular.
                </h1>

                <p>
                    O cadastro é feito pelo site e a experiência
                    do cliente continua no aplicativo Fast Splash.
                </p>

                <div class="cadastro-vantagens">

                    <div class="cadastro-vantagem">
                        <span class="cadastro-vantagem-icone">✓</span>

                        <div>
                            <strong>Cadastre seus veículos</strong>
                            <p>
                                Depois de entrar no aplicativo,
                                adicione os veículos que deseja acompanhar.
                            </p>
                        </div>
                    </div>

                    <div class="cadastro-vantagem">
                        <span class="cadastro-vantagem-icone">✓</span>

                        <div>
                            <strong>Faça agendamentos</strong>
                            <p>
                                Escolha serviço, veículo, data
                                e horário pelo aplicativo.
                            </p>
                        </div>
                    </div>

                    <div class="cadastro-vantagem">
                        <span class="cadastro-vantagem-icone">✓</span>

                        <div>
                            <strong>Acompanhe tudo em um só lugar</strong>
                            <p>
                                Consulte atendimentos,
                                pagamentos e histórico.
                            </p>
                        </div>
                    </div>

                </div>

            </section>


            <section class="cadastro-card">

                <div class="cadastro-card-topo">
                    <span>Cadastro de cliente</span>
                    <h2>Seus dados</h2>

                    <p>
                        Preencha os campos abaixo para criar sua conta.
                    </p>
                </div>

                <form
                    id="formCadastro"
                    class="form-cadastro"
                    action="${pageContext.request.contextPath}/api/clientes"
                    method="post"
                >

                    <div class="campo campo-largo">
                        <label for="nome">Nome completo</label>

                        <input
                            type="text"
                            id="nome"
                            name="nome"
                            placeholder="Digite seu nome completo"
                            autocomplete="name"
                            required
                        >
                    </div>

                    <div class="campo">
                        <label for="cpf">CPF</label>

                        <input
                            type="text"
                            id="cpf"
                            name="cpf"
                            placeholder="000.000.000-00"
                            inputmode="numeric"
                            maxlength="14"
                            required
                        >
                    </div>

                    <div class="campo">
                        <label for="telefone">Telefone</label>

                        <input
                            type="tel"
                            id="telefone"
                            name="telefone"
                            placeholder="(11) 99999-9999"
                            inputmode="tel"
                            maxlength="15"
                            autocomplete="tel"
                            required
                        >
                    </div>

                    <div class="campo campo-largo">
                        <label for="email">E-mail</label>

                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="seuemail@exemplo.com"
                            autocomplete="email"
                            required
                        >
                    </div>

                    <div class="campo">
                        <label for="senha">Senha</label>

                        <input
                            type="password"
                            id="senha"
                            name="senha"
                            placeholder="Crie uma senha"
                            autocomplete="new-password"
                            required
                        >
                    </div>

                    <div class="campo">
                        <label for="confirmarSenha">Confirmar senha</label>

                        <input
                            type="password"
                            id="confirmarSenha"
                            name="confirmarSenha"
                            placeholder="Digite a senha novamente"
                            autocomplete="new-password"
                            required
                        >
                    </div>

                    <div
                        id="mensagemFormulario"
                        class="mensagem-formulario"
                        role="status"
                        aria-live="polite"
                    ></div>

                    <div class="cadastro-acoes">
                        <button
                            id="botaoCadastrar"
                            class="botao-cadastrar"
                            type="submit"
                            data-home="${pageContext.request.contextPath}/"
                        >
                            Criar minha conta
                        </button>
                    </div>

                    <p class="cadastro-observacao">
                        Após o cadastro, utilize o mesmo e-mail
                        e senha para acessar o aplicativo Fast Splash.
                    </p>

                </form>

            </section>

        </div>

    </main>

    <script
        src="${pageContext.request.contextPath}/js/cadastro.js"
    ></script>

</body>
</html>
