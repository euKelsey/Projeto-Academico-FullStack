package com.fastsplash.web.api;

import com.fastsplash.web.db.BancoTeste;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.config.RestAssuredConfig;
import io.restassured.config.RedirectConfig;
import io.restassured.config.HttpClientConfig;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

public abstract class BaseApiTeste {

    protected static final String EMAIL_CLIENTE_ATIVO =
        "ativo@example.test";

    protected static final String EMAIL_CLIENTE_LIVRE =
        "livre@example.test";

    protected static final String EMAIL_CLIENTE_INATIVO =
        "inativo@example.test";

    protected static final String EMAIL_CLIENTE_EXCLUIDO =
        "excluido@example.test";

    protected static final String SENHA_TESTE =
        "SenhaFicticia@123";

    protected static final String COOKIE_SESSAO =
        "JSESSIONID";

    @BeforeAll
    static void protegerAmbienteApi()
            throws Exception {

        AmbienteApiTeste.validarAmbiente();
    }

    @BeforeEach
    void prepararBancoApi()
            throws Exception {

        BancoTeste.restaurarSeed();
    }

    @AfterEach
    void restaurarBancoApi()
            throws Exception {

        BancoTeste.restaurarSeed();
    }

    protected RequestSpecification requisicao() {

        RestAssuredConfig configuracao =
            RestAssuredConfig.config()

                .redirect(
                    RedirectConfig.redirectConfig()
                        .followRedirects(false)
                )

                .httpClient(
                    HttpClientConfig.httpClientConfig()
                        .setParam(
                            "http.connection.timeout",
                            5000
                        )
                        .setParam(
                            "http.socket.timeout",
                            10000
                        )
                );

        RequestSpecification especificacao =
            new RequestSpecBuilder()

                .setBaseUri(
                    AmbienteApiTeste.obterUrl()
                )

                .setAccept(ContentType.JSON)

                .setConfig(configuracao)

                .build();

        return RestAssured.given()
            .spec(especificacao);
    }

    protected RequestSpecification requisicaoFormulario() {

        return requisicao()

            .contentType(
                ContentType.URLENC.withCharset("UTF-8")
            );
    }

    protected RequestSpecification requisicaoAutenticada(
            String sessao
    ) {

        assertNotNull(sessao);
        assertFalse(sessao.isBlank());

        return requisicao()

            .cookie(
                COOKIE_SESSAO,
                sessao
            );
    }

    protected RequestSpecification formularioAutenticado(
            String sessao
    ) {

        return requisicaoAutenticada(sessao)

            .contentType(
                ContentType.URLENC.withCharset("UTF-8")
            );
    }

    protected Response realizarLogin(
            String email,
            String senha
    ) {

        return requisicaoFormulario()

            .formParam("email", email)

            .formParam("senha", senha)

            .when()

            .post("/api/auth/login");
    }

    protected String autenticarCliente(
            String email,
            String senha,
            int idClienteEsperado
    ) {

        Response resposta =
            realizarLogin(email, senha);

        resposta.then()

            .statusCode(200)

            .contentType(ContentType.JSON)

            .body("sucesso", equalTo(true))

            .body(
                "cliente.idCliente",
                equalTo(idClienteEsperado)
            );

        String sessao =
            resposta.getCookie(COOKIE_SESSAO);

        assertNotNull(
            sessao,
            "O servidor precisa retornar JSESSIONID."
        );

        assertFalse(sessao.isBlank());

        return sessao;
    }

    protected String autenticarClienteAtivo() {

        return autenticarCliente(
            EMAIL_CLIENTE_ATIVO,
            SENHA_TESTE,
            101
        );
    }

    protected String autenticarClienteLivre() {

        return autenticarCliente(
            EMAIL_CLIENTE_LIVRE,
            SENHA_TESTE,
            102
        );
    }

    protected void validarErro(
            Response resposta,
            int statusEsperado
    ) {

        resposta.then()

            .log().ifValidationFails()

            .statusCode(statusEsperado)

            .contentType(ContentType.JSON)

            .body("sucesso", equalTo(false))

            .body(
                "mensagem",
                not(isEmptyOrNullString())
            );
    }

    protected void validarSucesso(
            Response resposta,
            int statusEsperado
    ) {

        resposta.then()

            .log().ifValidationFails()

            .statusCode(statusEsperado)

            .contentType(ContentType.JSON)

            .body("sucesso", equalTo(true));
    }
}
