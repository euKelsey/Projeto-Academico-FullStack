package com.fastsplash.web.db;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class ConexaoIT {

    @BeforeAll
    static void protegerAmbiente() {
        AmbienteTeste.validarAmbiente();
    }

    @Test
    @DisplayName("Deve conectar ao MySQL de testes")
    void deveConectarAoMySQL() throws Exception {

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertNotNull(conexao);
            assertFalse(conexao.isClosed());
            assertTrue(conexao.isValid(5));
        }
    }

    @Test
    @DisplayName("Deve utilizar exclusivamente o banco de testes")
    void deveUtilizarBancoCorreto() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado =
                comando.executeQuery("SELECT DATABASE()")
        ) {
            assertTrue(resultado.next());

            assertEquals(
                "fast_splash_test",
                resultado.getString(1)
            );
        }
    }

    @Test
    @DisplayName("Deve possuir todas as nove tabelas")
    void devePossuirTodasAsTabelas() throws Exception {

        Set<String> esperadas = Set.of(
            "agendamento",
            "agendamento_servico",
            "atendimento",
            "cliente",
            "colaborador",
            "colaborador_atendimento",
            "pagamento",
            "servico",
            "veiculo"
        );

        Set<String> encontradas = new HashSet<>();

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado =
                comando.executeQuery("SHOW TABLES")
        ) {
            while (resultado.next()) {
                encontradas.add(resultado.getString(1));
            }
        }

        assertEquals(esperadas, encontradas);
    }

    @Test
    @DisplayName("Deve manter verificacao de chaves estrangeiras")
    void deveManterIntegridadeReferencial() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(
                "SELECT @@SESSION.FOREIGN_KEY_CHECKS"
            )
        ) {
            assertTrue(resultado.next());
            assertEquals(1, resultado.getInt(1));
        }
    }
}
