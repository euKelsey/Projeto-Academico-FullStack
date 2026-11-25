package com.fastsplash.web.api;

import com.fastsplash.web.db.AmbienteTeste;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.time.Duration;

public final class AmbienteApiTeste {

    private static final String URL_ESPERADA =
        "http://127.0.0.1:8081";

    private AmbienteApiTeste() {}

    public static void validarAmbiente() throws Exception {

        AmbienteTeste.validarAmbiente();

        String url = System.getenv(
            "FASTSPLASH_API_TEST_URL"
        );

        if (!URL_ESPERADA.equals(url)) {

            throw new IllegalStateException(
                "Testes HTTP bloqueados: URL nao autorizada."
            );
        }

        try (Connection conexao = AmbienteTeste.conectar()) {

            if (!"fast_splash_test".equals(
                    conexao.getCatalog()
            )) {

                throw new IllegalStateException(
                    "Testes HTTP bloqueados: banco incorreto."
                );
            }
        }

        validarServidor();
    }

    public static String obterUrl() {

        String url = System.getenv(
            "FASTSPLASH_API_TEST_URL"
        );

        if (!URL_ESPERADA.equals(url)) {

            throw new IllegalStateException(
                "URL da API de testes nao autorizada."
            );
        }

        return url;
    }

    private static void validarServidor()
            throws Exception {

        HttpClient cliente = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .followRedirects(HttpClient.Redirect.NEVER)
            .build();

        HttpRequest requisicao = HttpRequest.newBuilder()
            .uri(URI.create(
                obterUrl() + "/api/clientes/me"
            ))
            .timeout(Duration.ofSeconds(10))
            .GET()
            .build();

        HttpResponse<String> resposta = cliente.send(
            requisicao,
            HttpResponse.BodyHandlers.ofString()
        );

        if (resposta.statusCode() != 401) {

            throw new IllegalStateException(
                "API de testes indisponivel ou inesperada. "
                + "HTTP recebido: "
                + resposta.statusCode()
            );
        }

        String contentType = resposta.headers()
            .firstValue("Content-Type")
            .orElse("");

        if (!contentType.toLowerCase()
                .contains("application/json")) {

            throw new IllegalStateException(
                "Resposta da API nao possui formato JSON."
            );
        }
    }
}
