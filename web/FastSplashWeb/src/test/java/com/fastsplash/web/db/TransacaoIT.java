package com.fastsplash.web.db;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.*;

class TransacaoIT {

    @BeforeAll
    static void prepararAmbiente() throws Exception {

        AmbienteTeste.validarAmbiente();

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement()
        ) {
            comando.execute("""
                CREATE TABLE IF NOT EXISTS teste_transacao (
                    id INT PRIMARY KEY,
                    descricao VARCHAR(100) NOT NULL
                ) ENGINE=InnoDB
                """);
        }
    }

    @BeforeEach
    void limparTabela() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement()
        ) {
            comando.executeUpdate(
                "DELETE FROM teste_transacao"
            );
        }
    }

    @AfterAll
    static void removerTabela() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement()
        ) {
            comando.execute(
                "DROP TABLE IF EXISTS teste_transacao"
            );
        }
    }

    private void inserir(Connection conexao, int id)
            throws SQLException {

        String sql = """
            INSERT INTO teste_transacao (id, descricao)
            VALUES (?, ?)
            """;

        try (
            PreparedStatement comando =
                conexao.prepareStatement(sql)
        ) {
            comando.setInt(1, id);
            comando.setString(2, "Registro de teste");

            comando.executeUpdate();
        }
    }

    private int contarRegistros() throws SQLException {

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(
                "SELECT COUNT(*) FROM teste_transacao"
            )
        ) {
            assertTrue(resultado.next());

            return resultado.getInt(1);
        }
    }

    @Test
    void deveConfirmarTransacaoComSucesso() throws Exception {

        Transacao.executar((conexao, controle) -> {

            inserir(conexao, 1);

            return null;
        });

        assertEquals(1, contarRegistros());
    }

    @Test
    void deveRetornarResultadoDaOperacao() throws Exception {

        String resultado = Transacao.executar(
            (conexao, controle) -> "SUCESSO"
        );

        assertEquals("SUCESSO", resultado);
    }

    @Test
    void deveCancelarTransacaoExplicitamente() throws Exception {

        String resultado = Transacao.executar(
            (conexao, controle) -> {

                inserir(conexao, 1);

                controle.cancelar();

                return "CANCELADO";
            }
        );

        assertEquals("CANCELADO", resultado);
        assertEquals(0, contarRegistros());
    }

    @Test
    void deveExecutarRollbackPorSQLException()
            throws Exception {

        SQLException esperada =
            new SQLException("Falha SQL simulada.");

        SQLException recebida = assertThrows(
            SQLException.class,
            () -> Transacao.executar(
                (conexao, controle) -> {

                    inserir(conexao, 1);

                    throw esperada;
                }
            )
        );

        assertSame(esperada, recebida);
        assertEquals(0, contarRegistros());
    }

    @Test
    void deveExecutarRollbackPorRuntimeException()
            throws Exception {

        IllegalStateException esperada =
            new IllegalStateException("Falha simulada.");

        IllegalStateException recebida = assertThrows(
            IllegalStateException.class,
            () -> Transacao.executar(
                (conexao, controle) -> {

                    inserir(conexao, 1);

                    throw esperada;
                }
            )
        );

        assertSame(esperada, recebida);
        assertEquals(0, contarRegistros());
    }

    @Test
    void deveExecutarRollbackPorError() throws Exception {

        AssertionError esperado =
            new AssertionError("Erro simulado.");

        AssertionError recebido = assertThrows(
            AssertionError.class,
            () -> Transacao.executar(
                (conexao, controle) -> {

                    inserir(conexao, 1);

                    throw esperado;
                }
            )
        );

        assertSame(esperado, recebido);
        assertEquals(0, contarRegistros());
    }

    @Test
    void deveManterAtomicidadeEmMultiplasOperacoes()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> Transacao.executar(
                (conexao, controle) -> {

                    inserir(conexao, 1);
                    inserir(conexao, 2);
                    inserir(conexao, 1);

                    return null;
                }
            )
        );

        assertEquals(0, contarRegistros());
    }

    @Test
    void deveDevolverConexaoAposFalha() throws Exception {

        assertThrows(
            SQLException.class,
            () -> Transacao.executar(
                (conexao, controle) -> {

                    inserir(conexao, 1);

                    throw new SQLException("Falha simulada.");
                }
            )
        );

        Transacao.executar((conexao, controle) -> {

            assertFalse(conexao.getAutoCommit());

            inserir(conexao, 2);

            return null;
        });

        assertEquals(1, contarRegistros());

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertTrue(conexao.getAutoCommit());
            assertTrue(conexao.isValid(5));
        }
    }
}
