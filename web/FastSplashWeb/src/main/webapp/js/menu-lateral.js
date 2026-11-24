(function () {

    const botao = document.getElementById("fsMenuToggle");

    if (!botao) {
        return;
    }

    const chave = "fastSplashMenuRecolhido";

    let recolhido = window.innerWidth <= 1100;

    try {
        const salvo = localStorage.getItem(chave);

        if (salvo !== null) {
            recolhido = salvo === "true";
        }
    } catch (erro) {
        // Navegador sem armazenamento local.
    }

    function aplicar() {

        document.body.classList.toggle(
            "fs-menu-recolhido",
            recolhido
        );

        botao.setAttribute(
            "aria-expanded",
            String(!recolhido)
        );

        botao.setAttribute(
            "aria-label",
            recolhido
                ? "Expandir menu"
                : "Recolher menu"
        );

        botao.title = recolhido
            ? "Expandir menu"
            : "Recolher menu";
    }

    botao.addEventListener("click", function () {

        recolhido = !recolhido;

        aplicar();

        try {
            localStorage.setItem(
                chave,
                String(recolhido)
            );
        } catch (erro) {
            // Preferencia nao armazenada.
        }
    });

    aplicar();

})();
