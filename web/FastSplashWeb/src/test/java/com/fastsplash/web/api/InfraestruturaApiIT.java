package com.fastsplash.web.api;

import io.restassured.http.ContentType;
import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class InfraestruturaApiIT extends BaseApiTeste {

    @Test
    void deveResponderPaginaInicial() {

        requisicao()

            .accept(ContentType.HTML)

            .when()

            .get("/")

            .then()

            .log().ifValidationFails()

            .statusCode(200)

            .contentType(ContentType.HTML);
    }

    @Test
    void deveBloquearPerfilSemAutenticacao() {

        Response resposta = requisicao()

            .when()

            .get("/api/clientes/me");

        validarErro(resposta, 401);
    }

    @Test
    void deveBloquearVeiculosSemAutenticacao() {

        Response resposta = requisicao()

            .when()

            .get("/api/veiculos");

        validarErro(resposta, 401);
    }

    @Test
    void deveBloquearServicosSemAutenticacao() {

        Response resposta = requisicao()

            .when()

            .get("/api/servicos");

        validarErro(resposta, 401);
    }

    @Test
    void deveBloquearAgendamentosSemAutenticacao() {

        Response resposta = requisicao()

            .when()

            .get("/api/agendamentos");

        validarErro(resposta, 401);
    }

    @Test
    void deveBloquearPagamentosSemAutenticacao() {

        Response resposta = requisicao()

            .when()

            .get("/api/pagamentos");

        validarErro(resposta, 401);
    }

    @Test
    void deveAutenticarClienteFicticio() {

        Response resposta = realizarLogin(
            EMAIL_CLIENTE_ATIVO,
            SENHA_TESTE
        );

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.idCliente",
                equalTo(101)
            )

            .body(
                "cliente.nome",
                equalTo("Cliente Teste Ativo")
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_ATIVO)
            );

        String sessao =
            resposta.getCookie(COOKIE_SESSAO);

        assertNotNull(sessao);
        assertFalse(sessao.isBlank());
    }

    @Test
    void deveConsultarPerfilComSessaoAutenticada() {

        String sessao = autenticarClienteAtivo();

        Response resposta =
            requisicaoAutenticada(sessao)

                .when()

                .get("/api/clientes/me");

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.idCliente",
                equalTo(101)
            )

            .body(
                "cliente.nome",
                equalTo("Cliente Teste Ativo")
            )

            .body(
                "cliente.cpf",
                equalTo("98765410130")
            )

            .body(
                "cliente.telefone",
                equalTo("11900000101")
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_ATIVO)
            )

            .body(
                "cliente.senhaHash",
                nullValue()
            );
    }

    @Test
    void deveManterSessoesIndependentes() {

        String sessaoAtivo =
            autenticarClienteAtivo();

        String sessaoLivre =
            autenticarClienteLivre();

        assertNotEquals(
            sessaoAtivo,
            sessaoLivre
        );

        requisicaoAutenticada(sessaoAtivo)

            .when()

            .get("/api/clientes/me")

            .then()

            .statusCode(200)

            .body("sucesso", equalTo(true))

            .body(
                "cliente.idCliente",
                equalTo(101)
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_ATIVO)
            );

        requisicaoAutenticada(sessaoLivre)

            .when()

            .get("/api/clientes/me")

            .then()

            .statusCode(200)

            .body("sucesso", equalTo(true))

            .body(
                "cliente.idCliente",
                equalTo(102)
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_LIVRE)
            );
    }

    @Test
    void deveRejeitarSessaoInvalida() {

        Response resposta =
            requisicaoAutenticada(
                "SESSAO_INVALIDA_TESTE_123456"
            )

            .when()

            .get("/api/clientes/me");

        validarErro(resposta, 401);
    }
}
