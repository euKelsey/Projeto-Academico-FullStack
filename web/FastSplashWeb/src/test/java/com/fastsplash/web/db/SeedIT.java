package com.fastsplash.web.db;

import com.fastsplash.web.util.SenhaUtil;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class SeedIT {

    @BeforeAll
    static void protegerAmbiente() {
        AmbienteTeste.validarAmbiente();
    }

    private int consultarInteiro(String sql) throws Exception {
        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(sql)
        ) {
            assertTrue(resultado.next());
            return resultado.getInt(1);
        }
    }

    private BigDecimal consultarDecimal(String sql) throws Exception {
        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(sql)
        ) {
            assertTrue(resultado.next());
            return resultado.getBigDecimal(1);
        }
    }

    @Test
    @DisplayName("Deve possuir quatro clientes de teste")
    void devePossuirClientes() throws Exception {
        assertEquals(
            4, consultarInteiro("SELECT COUNT(*) FROM cliente")
        );
    }

    @Test
    @DisplayName("Deve possuir dois clientes ativos")
    void devePossuirClientesAtivos() throws Exception {
        assertEquals(
            2, consultarInteiro(
                "SELECT COUNT(*) FROM cliente WHERE ativo = 1"
            )
        );
    }

    @Test
    @DisplayName("Deve possuir um cliente inativo nao excluido")
    void devePossuirClienteInativo() throws Exception {
        assertEquals(
            1, consultarInteiro(
                "SELECT COUNT(*) FROM cliente " +
                "WHERE ativo = 0 AND excluido_em IS NULL"
            )
        );
    }

    @Test
    @DisplayName("Deve possuir um cliente excluido logicamente")
    void devePossuirClienteExcluido() throws Exception {
        assertEquals(
            1, consultarInteiro(
                "SELECT COUNT(*) FROM cliente " +
                "WHERE ativo = 0 AND excluido_em IS NOT NULL"
            )
        );
    }

    @Test
    @DisplayName("Deve possuir seis agendamentos")
    void devePossuirAgendamentos() throws Exception {
        assertEquals(
            6, consultarInteiro("SELECT COUNT(*) FROM agendamento")
        );
    }

    @Test
    @DisplayName("Deve possuir quatro pagamentos realizados")
    void devePossuirPagamentosRealizados() throws Exception {
        assertEquals(
            4, consultarInteiro(
                "SELECT COUNT(*) FROM pagamento " +
                "WHERE status_pagamento = 'PAGO'"
            )
        );
    }

    @Test
    @DisplayName("Deve totalizar 350 reais em pagamentos realizados")
    void deveValidarTotalPago() throws Exception {
        assertEquals(
            new BigDecimal("350.00"),
            consultarDecimal(
                "SELECT SUM(valor) FROM pagamento " +
                "WHERE status_pagamento = 'PAGO'"
            )
        );
    }

    @Test
    @DisplayName("Deve totalizar 50 reais em pagamentos pendentes")
    void deveValidarTotalPendente() throws Exception {
        assertEquals(
            new BigDecimal("50.00"),
            consultarDecimal(
                "SELECT SUM(valor) FROM pagamento " +
                "WHERE status_pagamento = 'PENDENTE'"
            )
        );
    }

    @Test
    @DisplayName("Deve possuir um atendimento arquivado")
    void devePossuirAtendimentoArquivado() throws Exception {
        assertEquals(
            1, consultarInteiro(
                "SELECT COUNT(*) FROM atendimento " +
                "WHERE arquivado_em IS NOT NULL"
            )
        );
    }

    @Test
    @DisplayName("Deve possuir precos consistentes nos agendamentos")
    void deveValidarValoresDosAgendamentos() throws Exception {
        assertEquals(
            0, consultarInteiro("""
                SELECT COUNT(*)
                FROM pagamento p
                WHERE p.valor <> (
                    SELECT COALESCE(SUM(s.valor_praticado), 0)
                    FROM agendamento_servico s
                    WHERE s.id_agendamento = p.id_agendamento
                )
                """)
        );
    }

    @Test
    @DisplayName("Deve verificar as senhas dos clientes")
    void deveValidarSenhasDosClientes() throws Exception {

        int total = 0;

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(
                "SELECT senha_hash FROM cliente"
            )
        ) {
            while (resultado.next()) {
                assertTrue(
                    SenhaUtil.verificarSenha(
                        "SenhaFicticia@123",
                        resultado.getString("senha_hash")
                    )
                );

                total++;
            }
        }

        assertEquals(4, total);
    }

    @Test
    @DisplayName("Deve verificar as senhas dos colaboradores")
    void deveValidarSenhasDosColaboradores() throws Exception {

        int total = 0;

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado = comando.executeQuery(
                "SELECT senha_hash FROM colaborador " +
                "WHERE senha_hash IS NOT NULL"
            )
        ) {
            while (resultado.next()) {
                assertTrue(
                    SenhaUtil.verificarSenha(
                        "SenhaFicticia@123",
                        resultado.getString("senha_hash")
                    )
                );

                total++;
            }
        }

        assertEquals(2, total);
    }

    @Test
    @DisplayName("Deve possuir CPFs matematicamente validos")
    void deveValidarCPFs() throws Exception {

        int total = 0;

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement();
            ResultSet resultado =
                comando.executeQuery("SELECT cpf FROM cliente")
        ) {
            while (resultado.next()) {
                String cpf = resultado.getString("cpf");

                assertTrue(cpfValido(cpf), "CPF de teste invalido");

                total++;
            }
        }

        assertEquals(4, total);
    }

    private boolean cpfValido(String cpf) {

        if (cpf == null || !cpf.matches("[0-9]{11}")) {
            return false;
        }

        if (cpf.chars().distinct().count() == 1) {
            return false;
        }

        for (int tamanho = 9; tamanho <= 10; tamanho++) {

            int soma = 0;

            for (int i = 0; i < tamanho; i++) {
                soma += (cpf.charAt(i) - '0') * (tamanho + 1 - i);
            }

            int resto = soma % 11;
            int digito = resto < 2 ? 0 : 11 - resto;

            if (digito != cpf.charAt(tamanho) - '0') {
                return false;
            }
        }

        return true;
    }
}
