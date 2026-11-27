package com.fastsplash.web.db;

import com.fastsplash.web.config.ConfiguracaoBanco;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.*;

class PoolConexaoIT {

    @BeforeAll
    static void protegerAmbiente() {
        AmbienteTeste.validarAmbiente();
    }

    @AfterEach
    void encerrarPool() {
        Conexao.encerrar();
    }

    private long identificarConexao(Connection conexao)
            throws SQLException {

        try (
            Statement comando = conexao.createStatement();
            ResultSet resultado =
                comando.executeQuery("SELECT CONNECTION_ID()")
        ) {
            assertTrue(resultado.next());
            return resultado.getLong(1);
        }
    }

    @Test
    void deveInicializarPool() throws Exception {

        Conexao.encerrar();

        assertFalse(Conexao.estaInicializado());

        Conexao.inicializar();

        assertTrue(Conexao.estaInicializado());
    }

    @Test
    void deveInicializarAutomaticamente() throws Exception {

        Conexao.encerrar();

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertTrue(Conexao.estaInicializado());
            assertTrue(conexao.isValid(5));
        }
    }

    @Test
    void deveEncerrarPool() throws Exception {

        Conexao.inicializar();

        Conexao.encerrar();

        assertFalse(Conexao.estaInicializado());

        assertDoesNotThrow(Conexao::encerrar);
    }

    @Test
    void deveReinicializarPool() throws Exception {

        Conexao.inicializar();
        Conexao.encerrar();
        Conexao.inicializar();

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertTrue(Conexao.estaInicializado());
            assertTrue(conexao.isValid(5));
        }
    }

    @Test
    void deveReutilizarConexaoFisica() throws Exception {

        long primeiroId;

        try (Connection conexao = AmbienteTeste.conectar()) {

            primeiroId = identificarConexao(conexao);
        }

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertEquals(
                primeiroId,
                identificarConexao(conexao)
            );
        }
    }

    @Test
    void deveFornecerConexoesSimultaneasDistintas()
            throws Exception {

        try (
            Connection primeira = AmbienteTeste.conectar();
            Connection segunda = AmbienteTeste.conectar()
        ) {
            assertNotEquals(
                identificarConexao(primeira),
                identificarConexao(segunda)
            );
        }
    }

    @Test
    void deveRestaurarAutoCommit() throws Exception {

        try (Connection conexao = AmbienteTeste.conectar()) {

            conexao.setAutoCommit(false);

            assertFalse(conexao.getAutoCommit());
        }

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertTrue(conexao.getAutoCommit());
        }
    }

    @Test
    void deveRestaurarReadOnly() throws Exception {

        try (Connection conexao = AmbienteTeste.conectar()) {

            conexao.setReadOnly(true);

            assertTrue(conexao.isReadOnly());
        }

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertFalse(conexao.isReadOnly());
        }
    }

    @Test
    void deveConfigurarLimitesValidos() throws Exception {

        HikariConfig config =
            ConfiguracaoBanco.criarConfiguracao();

        assertTrue(config.getMaximumPoolSize() >= 1);
        assertTrue(config.getMinimumIdle() >= 0);

        assertTrue(
            config.getMinimumIdle()
                <= config.getMaximumPoolSize()
        );

        assertTrue(config.isAutoCommit());
        assertFalse(config.isReadOnly());
    }

    @Test
    void deveConfigurarTimeoutsValidos() throws Exception {

        HikariConfig config =
            ConfiguracaoBanco.criarConfiguracao();

        assertTrue(config.getConnectionTimeout() >= 500);
        assertTrue(config.getValidationTimeout() >= 250);

        assertTrue(
            config.getValidationTimeout()
                < config.getConnectionTimeout()
        );

        assertTrue(
            config.getIdleTimeout()
                < config.getMaxLifetime()
        );
    }

    @Test
    void deveRespeitarLimiteDoPool() throws Exception {

        HikariConfig config =
            ConfiguracaoBanco.criarConfiguracao();

        config.setPoolName("FastSplashPoolTesteLimite");
        config.setMinimumIdle(0);
        config.setMaximumPoolSize(1);
        config.setConnectionTimeout(1000);
        config.setValidationTimeout(500);

        try (
            HikariDataSource pool = new HikariDataSource(config);
            Connection primeira = pool.getConnection()
        ) {
            assertThrows(
                SQLException.class,
                () -> {
                    try (Connection extra = pool.getConnection()) {
                        fail("O limite do pool foi ultrapassado.");
                    }
                }
            );

            assertTrue(primeira.isValid(5));
        }
    }

    @Test
    void deveLiberarConexaoAposTimeout() throws Exception {

        HikariConfig config =
            ConfiguracaoBanco.criarConfiguracao();

        config.setPoolName("FastSplashPoolTesteLiberacao");
        config.setMinimumIdle(0);
        config.setMaximumPoolSize(1);
        config.setConnectionTimeout(1000);
        config.setValidationTimeout(500);

        try (HikariDataSource pool = new HikariDataSource(config)) {

            try (Connection primeira = pool.getConnection()) {

                assertThrows(
                    SQLException.class,
                    () -> {
                        try (Connection extra = pool.getConnection()) {
                            fail("Conexao adicional inesperada.");
                        }
                    }
                );
            }

            try (Connection segunda = pool.getConnection()) {

                assertTrue(segunda.isValid(5));
            }
        }
    }
}
