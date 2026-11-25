package com.fastsplash.web.db;

import java.sql.Connection;
import java.sql.SQLException;

public final class AmbienteTeste {

    private static final String URL_ESPERADA =
        "jdbc:mysql://127.0.0.1:3308/fast_splash_test";

    private static final String USUARIO_ESPERADO =
        "fastsplash_test";

    private AmbienteTeste() {
    }

    public static void validarAmbiente() {

        String url = System.getenv("FASTSPLASH_DB_URL");
        String usuario = System.getenv("FASTSPLASH_DB_USER");
        String senha = System.getenv("FASTSPLASH_DB_PASSWORD");

        if (!URL_ESPERADA.equals(url)) {
            throw new IllegalStateException(
                "Testes bloqueados: URL do banco nao autorizada."
            );
        }

        if (!USUARIO_ESPERADO.equals(usuario)) {
            throw new IllegalStateException(
                "Testes bloqueados: usuario nao autorizado."
            );
        }

        if (senha == null || senha.isBlank()) {
            throw new IllegalStateException(
                "Testes bloqueados: senha nao configurada."
            );
        }
    }

    public static Connection conectar() throws SQLException {

        validarAmbiente();

        Connection conexao = Conexao.conectar();

        if (!"fast_splash_test".equals(conexao.getCatalog())) {
            conexao.close();

            throw new IllegalStateException(
                "Testes bloqueados: banco incorreto."
            );
        }

        return conexao;
    }
}
