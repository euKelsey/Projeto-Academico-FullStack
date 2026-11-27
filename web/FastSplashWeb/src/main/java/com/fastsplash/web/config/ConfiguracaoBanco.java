package com.fastsplash.web.config;

import java.sql.SQLException;

import com.zaxxer.hikari.HikariConfig;

public final class ConfiguracaoBanco {

    private ConfiguracaoBanco() {
    }

    public static HikariConfig criarConfiguracao()
            throws SQLException {

        String url = obterVariavel(
                "FASTSPLASH_DB_URL",
                "jdbc:mysql://localhost:3306/fast_splash");

        String usuario = obterVariavel(
                "FASTSPLASH_DB_USER",
                "root");

        String senha = obterVariavel(
                "FASTSPLASH_DB_PASSWORD",
                null);

        if (senha == null || senha.isBlank()) {

            throw new SQLException(
                    "A variavel de ambiente "
                    + "FASTSPLASH_DB_PASSWORD "
                    + "nao foi configurada.");
        }

        if (!url.startsWith("jdbc:mysql://")) {
            throw new SQLException(
                    "URL JDBC do MySQL invalida.");
        }

        int maximo = obterInteiro(
                "FASTSPLASH_DB_POOL_MAX",
                5, 1, 50);

        int minimo = obterInteiro(
                "FASTSPLASH_DB_POOL_MIN",
                1, 0, maximo);

        int timeoutConexao = obterInteiro(
                "FASTSPLASH_DB_POOL_CONNECTION_TIMEOUT",
                10000, 500, 120000);

        int timeoutValidacao = obterInteiro(
                "FASTSPLASH_DB_POOL_VALIDATION_TIMEOUT",
                5000, 250, timeoutConexao - 1);

        int vidaMaxima = obterInteiro(
                "FASTSPLASH_DB_POOL_MAX_LIFETIME",
                600000, 30000, 3600000);

        int tempoOcioso = obterInteiro(
                "FASTSPLASH_DB_POOL_IDLE_TIMEOUT",
                60000, 10000, vidaMaxima);

        if (tempoOcioso >= vidaMaxima - 1000) {
            throw new SQLException(
                    "Tempo ocioso deve ser inferior "
                    + "a vida maxima do pool.");
        }

        HikariConfig config = new HikariConfig();

        config.setPoolName("FastSplashPool");

        config.setJdbcUrl(url);
        config.setUsername(usuario);
        config.setPassword(senha);

        config.setDriverClassName(
                "com.mysql.cj.jdbc.Driver");

        config.setMaximumPoolSize(maximo);
        config.setMinimumIdle(minimo);

        config.setConnectionTimeout(timeoutConexao);
        config.setValidationTimeout(timeoutValidacao);

        config.setIdleTimeout(tempoOcioso);
        config.setMaxLifetime(vidaMaxima);

        config.setAutoCommit(true);
        config.setReadOnly(false);

        config.setInitializationFailTimeout(10000);

        config.addDataSourceProperty(
                "connectTimeout", "10000");

        config.addDataSourceProperty(
                "socketTimeout", "30000");

        return config;
    }

    private static String obterVariavel(
            String nome,
            String valorPadrao) {

        String valor = System.getenv(nome);

        if (valor == null || valor.isBlank()) {
            return valorPadrao;
        }

        return valor;
    }

    private static int obterInteiro(
            String nome,
            int valorPadrao,
            int minimo,
            int maximo) throws SQLException {

        String valor = obterVariavel(
                nome,
                String.valueOf(valorPadrao));

        try {

            int numero = Integer.parseInt(valor.trim());

            if (numero < minimo || numero > maximo) {

                throw new SQLException(
                        "Configuracao fora do limite: "
                        + nome);
            }

            return numero;

        } catch (NumberFormatException e) {

            throw new SQLException(
                    "Configuracao numerica invalida: "
                    + nome,
                    e);
        }
    }
}
