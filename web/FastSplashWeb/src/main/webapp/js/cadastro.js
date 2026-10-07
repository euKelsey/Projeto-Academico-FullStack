const formulario = document.getElementById("formCadastro");
const campoCpf = document.getElementById("cpf");
const campoTelefone = document.getElementById("telefone");
const campoSenha = document.getElementById("senha");
const campoConfirmarSenha = document.getElementById("confirmarSenha");
const mensagemFormulario = document.getElementById("mensagemFormulario");
const botaoCadastrar = document.getElementById("botaoCadastrar");

function mostrarMensagem(texto, tipo) {
    mensagemFormulario.textContent = texto;

    mensagemFormulario.className =
        "mensagem-formulario visivel " + tipo;
}

function limparMensagem() {
    mensagemFormulario.textContent = "";

    mensagemFormulario.className =
        "mensagem-formulario";
}

function somenteNumeros(valor) {
    return valor.replace(/\D/g, "");
}

function formatarCpf(valor) {
    const numeros =
        somenteNumeros(valor).slice(0, 11);

    return numeros
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d{1,2})$/, "$1-$2");
}

function formatarTelefone(valor) {
    const numeros =
        somenteNumeros(valor).slice(0, 11);

    if (numeros.length <= 10) {
        return numeros
            .replace(/(\d{2})(\d)/, "($1) $2")
            .replace(/(\d{4})(\d)/, "$1-$2");
    }

    return numeros
        .replace(/(\d{2})(\d)/, "($1) $2")
        .replace(/(\d{5})(\d)/, "$1-$2");
}

function bloquearFormularioAposSucesso() {
    const campos =
        formulario.querySelectorAll("input");

    campos.forEach(
        function (campo) {
            campo.disabled = true;
        }
    );

    botaoCadastrar.disabled = false;

    botaoCadastrar.type =
        "button";

    botaoCadastrar.textContent =
        "Voltar para o site";

    botaoCadastrar.onclick =
        function () {
            window.location.href =
                botaoCadastrar.dataset.home;
        };
}

campoCpf.addEventListener(
    "input",
    function () {
        campoCpf.value =
            formatarCpf(
                campoCpf.value
            );
    }
);

campoTelefone.addEventListener(
    "input",
    function () {
        campoTelefone.value =
            formatarTelefone(
                campoTelefone.value
            );
    }
);

formulario.addEventListener(
    "submit",
    async function (evento) {

        evento.preventDefault();

        limparMensagem();

        if (
            campoSenha.value !==
            campoConfirmarSenha.value
        ) {
            mostrarMensagem(
                "As senhas não coincidem.",
                "erro"
            );

            campoConfirmarSenha.focus();

            return;
        }

        botaoCadastrar.disabled =
            true;

        botaoCadastrar.textContent =
            "Criando conta...";

        const dados =
            new URLSearchParams(
                new FormData(
                    formulario
                )
            );

        try {
            const resposta =
                await fetch(
                    formulario.action,
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/x-www-form-urlencoded;charset=UTF-8"
                        },

                        body:
                            dados.toString()
                    }
                );

            let resultado = {};

            try {
                resultado =
                    await resposta.json();
            } catch (erroJson) {
                console.warn(
                    "A resposta do servidor não veio em JSON.",
                    erroJson
                );
            }

            if (!resposta.ok) {
                mostrarMensagem(
                    resultado.mensagem ||
                    "Não foi possível realizar o cadastro.",
                    "erro"
                );

                return;
            }

            formulario.reset();

            mostrarMensagem(
                "Cadastro realizado com sucesso. Agora você já pode usar sua conta no aplicativo Fast Splash.",
                "sucesso"
            );

            bloquearFormularioAposSucesso();

        } catch (erro) {
            console.error(
                "Erro ao cadastrar cliente:",
                erro
            );

            mostrarMensagem(
                "Não foi possível comunicar com o servidor. Tente novamente.",
                "erro"
            );

        } finally {
            if (
                botaoCadastrar.type ===
                "submit"
            ) {
                botaoCadastrar.disabled =
                    false;

                botaoCadastrar.textContent =
                    "Criar minha conta";
            }
        }
    }
);