package com.fastsplash.web.api;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.model.Cliente;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class AutenticacaoApiIT extends BaseApiTeste {

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private static final String MENSAGEM_CAMPOS =
        "Informe o e-mail e a senha.";

    private static final String MENSAGEM_CREDENCIAIS =
        "E-mail ou senha inválidos.";

    private static final String MENSAGEM_INATIVO =
        "Sua conta está inativa. Entre em contato "
        + "com o Fast Splash para regularizar o acesso.";

    private Response enviarLogin(
            Map<String, String> dados
    ) {

        return requisicaoFormulario()

            .formParams(dados)

            .when()

            .post("/api/auth/login");
    }

    private Map<String, String> credenciaisValidas() {

        Map<String, String> dados =
            new LinkedHashMap<>();

        dados.put(
            "email",
            EMAIL_CLIENTE_ATIVO
        );

        dados.put(
            "senha",
            SENHA_TESTE
        );

        return dados;
    }

    private void verificarLoginRejeitado(
            Response resposta,
            int statusEsperado,
            String mensagemEsperada
    ) {

        validarErro(
            resposta,
            statusEsperado
        );

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagemEsperada)
            )

            .body(
                "cliente",
                nullValue()
            );

        String sessao =
            resposta.getCookie(COOKIE_SESSAO);

        // Mesmo que futuramente exista uma sessao
        // anonima, ela nao pode autorizar acesso.

        if (sessao != null && !sessao.isBlank()) {

            Response perfil =
                requisicaoAutenticada(sessao)

                    .when()

                    .get("/api/clientes/me");

            validarErro(perfil, 401);
        }
    }

    @Test
    void deveAutenticarClienteAtivo() {

        String sessao =
            autenticarClienteAtivo();

        requisicaoAutenticada(sessao)

            .when()

            .get("/api/clientes/me")

            .then()

            .statusCode(200)

            .body(
                "cliente.idCliente",
                equalTo(101)
            );
    }

    @Test
    void deveAutenticarClienteSemPendencias() {

        String sessao =
            autenticarClienteLivre();

        requisicaoAutenticada(sessao)

            .when()

            .get("/api/clientes/me")

            .then()

            .statusCode(200)

            .body(
                "cliente.idCliente",
                equalTo(102)
            );
    }

    @Test
    void deveAutenticarEmailComEspacosExternos() {

        Response resposta = realizarLogin(
            "  " + EMAIL_CLIENTE_ATIVO + "  ",
            SENHA_TESTE
        );

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.idCliente",
                equalTo(101)
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_ATIVO)
            );

        assertNotNull(
            resposta.getCookie(COOKIE_SESSAO)
        );
    }

    @Test
    void deveRejeitarLoginSemEmail() {

        var dados =
            credenciaisValidas();

        dados.remove("email");

        verificarLoginRejeitado(
            enviarLogin(dados),
            400,
            MENSAGEM_CAMPOS
        );
    }

    @Test
    void deveRejeitarLoginSemSenha() {

        var dados =
            credenciaisValidas();

        dados.remove("senha");

        verificarLoginRejeitado(
            enviarLogin(dados),
            400,
            MENSAGEM_CAMPOS
        );
    }

    @Test
    void deveRejeitarLoginSemCredenciais() {

        verificarLoginRejeitado(
            enviarLogin(Map.of()),
            400,
            MENSAGEM_CAMPOS
        );
    }

    @Test
    void deveRejeitarEmailEmBranco() {

        var dados =
            credenciaisValidas();

        dados.put("email", "   ");

        verificarLoginRejeitado(
            enviarLogin(dados),
            400,
            MENSAGEM_CAMPOS
        );
    }

    @Test
    void deveRejeitarSenhaEmBranco() {

        var dados =
            credenciaisValidas();

        dados.put("senha", "   ");

        verificarLoginRejeitado(
            enviarLogin(dados),
            400,
            MENSAGEM_CAMPOS
        );
    }

    @Test
    void deveRejeitarSenhaIncorreta() {

        verificarLoginRejeitado(

            realizarLogin(
                EMAIL_CLIENTE_ATIVO,
                "SenhaIncorreta@123"
            ),

            401,
            MENSAGEM_CREDENCIAIS
        );
    }

    @Test
    void deveRejeitarEmailInexistente() {

        verificarLoginRejeitado(

            realizarLogin(
                "inexistente@example.test",
                SENHA_TESTE
            ),

            401,
            MENSAGEM_CREDENCIAIS
        );
    }

    @Test
    void deveRejeitarCredenciaisInexistentes() {

        verificarLoginRejeitado(

            realizarLogin(
                "inexistente@example.test",
                "SenhaIncorreta@123"
            ),

            401,
            MENSAGEM_CREDENCIAIS
        );
    }

    @Test
    void deveBloquearLoginDeClienteInativo() {

        verificarLoginRejeitado(

            realizarLogin(
                EMAIL_CLIENTE_INATIVO,
                SENHA_TESTE
            ),

            403,
            MENSAGEM_INATIVO
        );
    }

    @Test
    void deveBloquearLoginDeClienteExcluido() {

        verificarLoginRejeitado(

            realizarLogin(
                EMAIL_CLIENTE_EXCLUIDO,
                SENHA_TESTE
            ),

            403,
            MENSAGEM_INATIVO
        );
    }

    @Test
    void deveBloquearSessaoAposInativacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        Response resposta =
            requisicaoAutenticada(sessao)

                .when()

                .get("/api/clientes/me");

        resposta.then()

            .log().ifValidationFails()

            .statusCode(anyOf(
                is(401),
                is(403)
            ))

            .body(
                "sucesso",
                equalTo(false)
            )

            .body(
                "cliente",
                nullValue()
            );

        assertFalse(
            clienteDAO.buscarPorId(102).isAtivo()
        );
    }

    @Test
    void deveBloquearSessaoAposExclusaoLogica()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        Response resposta =
            requisicaoAutenticada(sessao)

                .when()

                .get("/api/clientes/me");

        resposta.then()

            .log().ifValidationFails()

            .statusCode(anyOf(
                is(401),
                is(403)
            ))

            .body(
                "sucesso",
                equalTo(false)
            )

            .body(
                "cliente",
                nullValue()
            );

        assertTrue(
            clienteDAO.buscarPorId(102).isExcluido()
        );
    }

    @Test
    void deveRetornarCookieDeSessaoHttpOnly() {

        Response resposta = realizarLogin(
            EMAIL_CLIENTE_ATIVO,
            SENHA_TESTE
        );

        validarSucesso(resposta, 200);

        var cookie =
            resposta.getDetailedCookie(
                COOKIE_SESSAO
            );

        assertNotNull(cookie);

        assertTrue(
            cookie.isHttpOnly(),
            "O cookie de sessao deve ser HttpOnly."
        );

        assertFalse(
            cookie.getValue().isBlank()
        );

        assertEquals(
            "/",
            cookie.getPath()
        );
    }

    @Test
    void naoDeveExporSenhaOuHashNoLogin()
            throws Exception {

        Cliente cliente =
            clienteDAO.buscarPorId(101);

        Response resposta = realizarLogin(
            EMAIL_CLIENTE_ATIVO,
            SENHA_TESTE
        );

        validarSucesso(resposta, 200);

        Map<String, Object> json =
            resposta.jsonPath().getMap("$");

        Map<String, Object> dadosCliente =
            resposta.jsonPath().getMap("cliente");

        assertEquals(
            Set.of(
                "sucesso",
                "mensagem",
                "cliente"
            ),
            json.keySet()
        );

        assertEquals(
            Set.of(
                "idCliente",
                "nome",
                "cpf",
                "telefone",
                "email"
            ),
            dadosCliente.keySet()
        );

        assertFalse(
            resposta.asString().contains(
                SENHA_TESTE
            )
        );

        assertFalse(
            resposta.asString().contains(
                cliente.getSenhaHash()
            )
        );
    }

    @Test
    void devePreservarHashPBKDF2AposLogin()
            throws Exception {

        String hashAnterior =
            clienteDAO.buscarPorId(101)
                .getSenhaHash();

        assertTrue(
            hashAnterior.startsWith("pbkdf2$")
        );

        autenticarClienteAtivo();

        verificarLoginRejeitado(

            realizarLogin(
                EMAIL_CLIENTE_ATIVO,
                "SenhaIncorreta@123"
            ),

            401,
            MENSAGEM_CREDENCIAIS
        );

        Cliente cliente =
            clienteDAO.buscarPorId(101);

        assertEquals(
            hashAnterior,
            cliente.getSenhaHash()
        );

        assertTrue(cliente.isAtivo());

        assertFalse(cliente.isExcluido());
    }
}
