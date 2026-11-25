package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Servico;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ServicoDAOIT {

    private final ServicoDAO dao = new ServicoDAO();

    @BeforeAll
    static void protegerAmbiente() throws Exception {

        AmbienteTeste.validarAmbiente();

        try (Connection conexao = AmbienteTeste.conectar()) {
            assertEquals("fast_splash_test", conexao.getCatalog());
        }
    }

    @BeforeEach
    void prepararDados() throws Exception {
        BancoTeste.restaurarSeed();
    }

    @AfterEach
    void restaurarDados() throws Exception {
        BancoTeste.restaurarSeed();
    }

    private Servico novoServico() {
        return new Servico(
            0,
            "Polimento Teste",
            "Servico ficticio de polimento",
            125.90,
            true
        );
    }

    @Test
    void deveCadastrarServico() throws Exception {

        Servico servico = novoServico();

        dao.inserir(servico);

        assertTrue(servico.getIdServico() > 0);

        Servico salvo = dao.buscarPorId(servico.getIdServico());

        assertNotNull(salvo);
        assertEquals(servico.getNome(), salvo.getNome());
        assertEquals(servico.getDescricao(), salvo.getDescricao());
        assertEquals(125.90, salvo.getPreco(), 0.001);
        assertTrue(salvo.isAtivo());
        assertFalse(salvo.isExcluido());
    }

    @Test
    void deveCadastrarServicoInativo() throws Exception {

        Servico servico = novoServico();
        servico.setAtivo(false);

        dao.inserir(servico);

        Servico salvo = dao.buscarPorId(servico.getIdServico());

        assertFalse(salvo.isAtivo());
        assertFalse(salvo.isExcluido());
    }

    @Test
    void deveBuscarServicoPorId() throws Exception {

        Servico servico = dao.buscarPorId(301);

        assertNotNull(servico);
        assertEquals(301, servico.getIdServico());
        assertEquals("Lavagem Simples Teste", servico.getNome());
        assertEquals(50.00, servico.getPreco(), 0.001);
    }

    @Test
    void deveRetornarNuloParaServicoInexistente() throws Exception {
        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveListarTodosOsServicos() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Servico::getIdServico)
            .toList();

        assertEquals(List.of(301, 302, 303, 304), ids);
    }

    @Test
    void deveListarSomenteServicosAtivos() throws Exception {

        List<Integer> ids = dao.listarAtivos()
            .stream()
            .map(Servico::getIdServico)
            .toList();

        assertEquals(List.of(301, 302), ids);
    }

    @Test
    void deveAtualizarDadosDoServico() throws Exception {

        Servico servico = dao.buscarPorId(301);

        servico.setNome("Lavagem Atualizada Teste");
        servico.setDescricao("Descricao atualizada");

        dao.atualizar(servico);

        Servico atualizado = dao.buscarPorId(301);

        assertEquals(
            "Lavagem Atualizada Teste",
            atualizado.getNome()
        );

        assertEquals(
            "Descricao atualizada",
            atualizado.getDescricao()
        );

        assertEquals(50.00, atualizado.getPreco(), 0.001);
    }

    @Test
    void deveAtualizarPrecoDoServico() throws Exception {

        Servico servico = dao.buscarPorId(301);

        servico.setPreco(65.90);

        dao.atualizar(servico);

        assertEquals(
            65.90,
            dao.buscarPorId(301).getPreco(),
            0.001
        );
    }

    @Test
    void deveImpedirAtualizacaoDeServicoInativo() throws Exception {

        Servico servico = dao.buscarPorId(303);

        servico.setPreco(99.90);

        dao.atualizar(servico);

        assertEquals(
            40.00,
            dao.buscarPorId(303).getPreco(),
            0.001
        );
    }

    @Test
    void deveImpedirAtualizacaoDeServicoExcluido() throws Exception {

        Servico servico = dao.buscarPorId(304);

        servico.setPreco(199.90);

        dao.atualizar(servico);

        assertEquals(
            100.00,
            dao.buscarPorId(304).getPreco(),
            0.001
        );
    }

    @Test
    void deveImpedirCadastroComPrecoNegativo() throws Exception {

        Servico servico = novoServico();
        servico.setPreco(-10.00);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(servico)
        );

        assertEquals(4, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtualizacaoComPrecoNegativo() throws Exception {

        Servico servico = dao.buscarPorId(301);
        servico.setPreco(-20.00);

        assertThrows(
            SQLException.class,
            () -> dao.atualizar(servico)
        );

        assertEquals(
            50.00,
            dao.buscarPorId(301).getPreco(),
            0.001
        );
    }

    @Test
    void devePreservarPrecisaoDoPrecoNoBanco() throws Exception {

        Servico servico = novoServico();
        servico.setPreco(79.99);

        dao.inserir(servico);

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement(
                "SELECT preco FROM servico WHERE id_servico = ?"
            )
        ) {
            comando.setInt(1, servico.getIdServico());

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                assertEquals(
                    new BigDecimal("79.99"),
                    resultado.getBigDecimal("preco")
                );
            }
        }
    }

    @Test
    void deveIdentificarServicoComAgendamentos() throws Exception {

        assertTrue(dao.possuiAgendamentos(301));
        assertTrue(dao.possuiAgendamentos(302));
        assertTrue(dao.possuiAgendamentos(303));
        assertTrue(dao.possuiAgendamentos(304));
    }

    @Test
    void deveIdentificarServicoSemAgendamentos() throws Exception {

        Servico servico = novoServico();

        dao.inserir(servico);

        assertFalse(
            dao.possuiAgendamentos(servico.getIdServico())
        );
    }

    @Test
    void deveInativarServico() throws Exception {

        assertTrue(dao.inativarServico(301));

        Servico servico = dao.buscarPorId(301);

        assertFalse(servico.isAtivo());
        assertFalse(servico.isExcluido());
        assertTrue(dao.possuiAgendamentos(301));
    }

    @Test
    void deveRetornarFalseParaServicoJaInativo() throws Exception {
        assertFalse(dao.inativarServico(303));
    }

    @Test
    void deveReativarServico() throws Exception {

        assertTrue(dao.reativarServico(303));
        assertTrue(dao.buscarPorId(303).isAtivo());
    }

    @Test
    void deveRetornarFalseParaServicoJaAtivo() throws Exception {
        assertFalse(dao.reativarServico(301));
    }

    @Test
    void deveImpedirReativacaoDiretaDeExcluido() throws Exception {

        assertFalse(dao.reativarServico(304));
        assertTrue(dao.buscarPorId(304).isExcluido());
    }

    @Test
    void deveExcluirServicoLogicamente() throws Exception {

        assertTrue(dao.excluirLogicamente(301));

        Servico servico = dao.buscarPorId(301);

        assertNotNull(servico);
        assertFalse(servico.isAtivo());
        assertTrue(servico.isExcluido());
        assertNotNull(servico.getExcluidoEm());
    }

    @Test
    void deveExcluirServicoInativoLogicamente() throws Exception {

        assertTrue(dao.excluirLogicamente(303));

        Servico servico = dao.buscarPorId(303);

        assertFalse(servico.isAtivo());
        assertTrue(servico.isExcluido());
    }

    @Test
    void deveRetornarFalseParaServicoJaExcluido() throws Exception {
        assertFalse(dao.excluirLogicamente(304));
    }

    @Test
    void deveRestaurarServicoExcluido() throws Exception {

        assertTrue(dao.restaurarServico(304));

        Servico servico = dao.buscarPorId(304);

        assertTrue(servico.isAtivo());
        assertFalse(servico.isExcluido());
        assertNull(servico.getExcluidoEm());
    }

    @Test
    void deveImpedirRestauracaoDeServicoNaoExcluido() throws Exception {

        assertFalse(dao.restaurarServico(301));
        assertFalse(dao.restaurarServico(303));
    }

    @Test
    void deveFiltrarServicosAtivos() throws Exception {

        List<Integer> ids = dao.listarPorStatus("ativos")
            .stream()
            .map(Servico::getIdServico)
            .toList();

        assertEquals(List.of(301, 302), ids);
    }

    @Test
    void deveFiltrarServicosInativos() throws Exception {

        List<Servico> servicos = dao.listarPorStatus("inativos");

        assertEquals(1, servicos.size());
        assertEquals(303, servicos.get(0).getIdServico());
    }

    @Test
    void deveFiltrarServicosExcluidos() throws Exception {

        List<Servico> servicos = dao.listarPorStatus("excluidos");

        assertEquals(1, servicos.size());
        assertEquals(304, servicos.get(0).getIdServico());
    }

    @Test
    void deveUtilizarFiltroAtivosComoPadrao() throws Exception {

        assertEquals(2, dao.listarPorStatus(null).size());
        assertEquals(2, dao.listarPorStatus("desconhecido").size());
    }

    @Test
    void deveRetornarFalseParaServicoInexistente() throws Exception {

        assertFalse(dao.inativarServico(999999));
        assertFalse(dao.reativarServico(999999));
        assertFalse(dao.excluirLogicamente(999999));
        assertFalse(dao.restaurarServico(999999));
        assertFalse(dao.possuiAgendamentos(999999));
    }

    @Test
    void deveAlterarStatusPeloMetodoDeCompatibilidade() throws Exception {

        dao.alterarStatus(301, false);
        assertFalse(dao.buscarPorId(301).isAtivo());

        dao.alterarStatus(301, true);
        assertTrue(dao.buscarPorId(301).isAtivo());
    }

    @Test
    void deveLancarErroQuandoAlteracaoDeStatusFalhar() {

        assertThrows(
            SQLException.class,
            () -> dao.alterarStatus(999999, false)
        );
    }

    @Test
    void deveExcluirPeloMetodoDeCompatibilidade() throws Exception {

        dao.excluir(301);

        assertTrue(dao.buscarPorId(301).isExcluido());
    }

    @Test
    void deveLancarErroQuandoExclusaoFalhar() {

        assertThrows(
            SQLException.class,
            () -> dao.excluir(304)
        );
    }

    @Test
    void devePreservarValorContratadoAposAlteracaoDePreco()
            throws Exception {

        Servico servico = dao.buscarPorId(301);

        servico.setPreco(75.00);

        dao.atualizar(servico);

        assertEquals(
            75.00,
            dao.buscarPorId(301).getPreco(),
            0.001
        );

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT valor_praticado
                FROM agendamento_servico
                WHERE id_servico = 301
                ORDER BY id_agendamento
                """)
        ) {
            int total = 0;

            while (resultado.next()) {

                assertEquals(
                    new BigDecimal("50.00"),
                    resultado.getBigDecimal("valor_praticado")
                );

                total++;
            }

            assertEquals(3, total);
        }
    }

    @Test
    void devePreservarHistoricoAposExclusao() throws Exception {

        assertTrue(dao.excluirLogicamente(301));
        assertTrue(dao.possuiAgendamentos(301));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM agendamento_servico
                WHERE id_servico = 301
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(3, resultado.getInt(1));
        }
    }

    @Test
    void devePreservarPagamentoAposAlteracaoDePreco() throws Exception {

        Servico servico = dao.buscarPorId(301);

        servico.setPreco(90.00);

        dao.atualizar(servico);

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT valor, status_pagamento
                FROM pagamento
                WHERE id_agendamento = 504
                """)
        ) {
            assertTrue(resultado.next());

            assertEquals(
                new BigDecimal("90.00"),
                resultado.getBigDecimal("valor")
            );

            assertEquals(
                "PAGO",
                resultado.getString("status_pagamento")
            );
        }
    }
}
