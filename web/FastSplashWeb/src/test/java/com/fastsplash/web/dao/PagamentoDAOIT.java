package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Pagamento;
import com.fastsplash.web.model.Servico;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class PagamentoDAOIT {

    private final PagamentoDAO dao = new PagamentoDAO();

    private final AgendamentoDAO agendamentoDAO = new AgendamentoDAO();
    private final AtendimentoDAO atendimentoDAO = new AtendimentoDAO();
    private final ServicoDAO servicoDAO = new ServicoDAO();

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

    private Agendamento novoAgendamento(Integer... servicos)
            throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(LocalDate.now().plusDays(5));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(servicos));

        agendamentoDAO.inserir(agendamento);

        return agendamento;
    }

    private Pagamento buscarNaListagem(
            int idAgendamento
    ) throws Exception {

        return dao.listarTodos()
            .stream()
            .filter(p -> p.getIdAgendamento() == idAgendamento)
            .findFirst()
            .orElseThrow();
    }

    private Pagamento buscarPorFiltro(
            String filtro,
            int idPagamento
    ) throws Exception {

        return dao.listarPorStatus(filtro)
            .stream()
            .filter(p -> p.getIdPagamento() == idPagamento)
            .findFirst()
            .orElseThrow();
    }

    private List<Integer> idsPorStatus(
            String filtro
    ) throws Exception {

        return dao.listarPorStatus(filtro)
            .stream()
            .map(Pagamento::getIdPagamento)
            .toList();
    }

    private void executarSqlTeste(String sql) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement()
        ) {
            comando.executeUpdate(sql);
        }
    }

    private int contarPagamentos() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery(
                "SELECT COUNT(*) FROM pagamento"
            )
        ) {
            assertTrue(resultado.next());

            return resultado.getInt(1);
        }
    }

    private void confirmarPagamento(
            String forma
    ) throws Exception {

        assertTrue(dao.realizarPagamento(501, 101, forma));

        Pagamento pagamento = buscarNaListagem(501);

        assertEquals(701, pagamento.getIdPagamento());
        assertEquals("PAGO", pagamento.getStatusPagamento());
        assertEquals(forma, pagamento.getFormaPagamento());
        assertEquals(50.00, pagamento.getValor(), 0.001);
        assertNotNull(pagamento.getDataPagamento());
        assertEquals(6, contarPagamentos());
    }

    @Test
    void deveListarPagamentos() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Pagamento::getIdPagamento)
            .toList();

        assertEquals(
            List.of(702, 701, 703, 704, 706),
            ids
        );
    }

    @Test
    void deveListarSomentePagamentosDoCliente()
            throws Exception {

        List<Integer> ids = dao.listarPorCliente(101)
            .stream()
            .map(Pagamento::getIdPagamento)
            .toList();

        assertEquals(
            List.of(702, 701, 703, 704),
            ids
        );
    }

    @Test
    void deveRetornarListaVaziaParaClienteSemAgendamentos()
            throws Exception {

        assertTrue(dao.listarPorCliente(102).isEmpty());
    }

    @Test
    void deveRetornarListaVaziaParaClienteInexistente()
            throws Exception {

        assertTrue(dao.listarPorCliente(999999).isEmpty());
    }

    @Test
    void deveOcultarAgendamentoCanceladoNaListagemGeral()
            throws Exception {

        assertFalse(
            dao.listarTodos()
                .stream()
                .anyMatch(p -> p.getIdAgendamento() == 505)
        );
    }

    @Test
    void deveOcultarAgendamentoCanceladoNaListagemDoCliente()
            throws Exception {

        assertFalse(
            dao.listarPorCliente(101)
                .stream()
                .anyMatch(p -> p.getIdAgendamento() == 505)
        );
    }

    @Test
    void devePreservarHistoricoDoClienteExcluido()
            throws Exception {

        List<Pagamento> pagamentos = dao.listarPorCliente(104);

        assertEquals(1, pagamentos.size());
        assertEquals(706, pagamentos.get(0).getIdPagamento());
        assertEquals(100.00, pagamentos.get(0).getValor(), 0.001);
        assertEquals("PAGO", pagamentos.get(0).getStatusPagamento());
    }

    @Test
    void deveRetornarDadosDoClienteEVeiculo()
            throws Exception {

        Pagamento pagamento = buscarNaListagem(501);

        assertEquals(
            "Cliente Teste Ativo",
            pagamento.getClienteNome()
        );

        assertEquals(
            "Volkswagen Polo - TST1A01",
            pagamento.getVeiculoDescricao()
        );

        assertNotNull(pagamento.getDataAgendamento());
        assertEquals(
            LocalTime.of(9, 0),
            pagamento.getHorarioAgendamento()
        );
    }

    @Test
    void deveRetornarDescricaoDosServicos()
            throws Exception {

        Pagamento pagamento = buscarNaListagem(504);

        assertTrue(
            pagamento.getServicosDescricao()
                .contains("Lavagem Simples Teste")
        );

        assertTrue(
            pagamento.getServicosDescricao()
                .contains("Enceramento Teste")
        );

        assertEquals(90.00, pagamento.getValor(), 0.001);
    }

    @Test
    void deveExibirAgendamentoSemPagamentoComoPendente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 302);

        Pagamento pagamento = buscarNaListagem(
            agendamento.getIdAgendamento()
        );

        assertEquals(0, pagamento.getIdPagamento());
        assertEquals("PENDENTE", pagamento.getStatusPagamento());
        assertEquals(130.00, pagamento.getValor(), 0.001);
        assertNull(pagamento.getFormaPagamento());
        assertNull(pagamento.getDataPagamento());
        assertEquals(6, contarPagamentos());
    }

    @Test
    void deveExibirPagamentoVirtualNaListagemDoCliente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        List<Pagamento> pagamentos = dao.listarPorCliente(102);

        assertEquals(1, pagamentos.size());

        Pagamento pagamento = pagamentos.get(0);

        assertEquals(
            agendamento.getIdAgendamento(),
            pagamento.getIdAgendamento()
        );

        assertEquals(0, pagamento.getIdPagamento());
        assertEquals("PENDENTE", pagamento.getStatusPagamento());
        assertEquals(50.00, pagamento.getValor(), 0.001);
    }

    @Test
    void deveConfirmarPagamentoPorPix() throws Exception {
        confirmarPagamento("PIX");
    }

    @Test
    void deveConfirmarPagamentoEmDinheiro() throws Exception {
        confirmarPagamento("DINHEIRO");
    }

    @Test
    void deveConfirmarPagamentoPorCredito() throws Exception {
        confirmarPagamento("CREDITO");
    }

    @Test
    void deveConfirmarPagamentoPorDebito() throws Exception {
        confirmarPagamento("DEBITO");
    }

    @Test
    void deveCriarRegistroDePagamentoQuandoNaoExistir()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        assertTrue(
            dao.realizarPagamento(
                agendamento.getIdAgendamento(),
                102,
                "PIX"
            )
        );

        Pagamento pagamento = buscarNaListagem(
            agendamento.getIdAgendamento()
        );

        assertTrue(pagamento.getIdPagamento() > 0);
        assertEquals("PAGO", pagamento.getStatusPagamento());
        assertEquals(50.00, pagamento.getValor(), 0.001);
        assertNotNull(pagamento.getDataPagamento());
        assertEquals(7, contarPagamentos());
    }

    @Test
    void deveCalcularPagamentoComMultiplosServicos()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 302);

        assertTrue(
            dao.realizarPagamento(
                agendamento.getIdAgendamento(),
                102,
                "PIX"
            )
        );

        assertEquals(
            130.00,
            buscarNaListagem(
                agendamento.getIdAgendamento()
            ).getValor(),
            0.001
        );
    }

    @Test
    void devePreservarIdDoPagamentoPendente()
            throws Exception {

        assertTrue(dao.realizarPagamento(501, 101, "PIX"));

        assertEquals(
            701,
            buscarNaListagem(501).getIdPagamento()
        );

        assertEquals(6, contarPagamentos());
    }

    @Test
    void deveImpedirPagamentoDuplicado()
            throws Exception {

        assertTrue(dao.realizarPagamento(501, 101, "PIX"));

        Pagamento original = buscarNaListagem(501);

        assertFalse(
            dao.realizarPagamento(501, 101, "DINHEIRO")
        );

        Pagamento atual = buscarNaListagem(501);

        assertEquals(
            original.getDataPagamento(),
            atual.getDataPagamento()
        );

        assertEquals("PIX", atual.getFormaPagamento());
        assertEquals(6, contarPagamentos());
    }

    @Test
    void deveImpedirNovoPagamentoDeRegistroJaPago()
            throws Exception {

        Pagamento original = buscarNaListagem(502);

        assertFalse(
            dao.realizarPagamento(502, 101, "DEBITO")
        );

        Pagamento atual = buscarNaListagem(502);

        assertEquals(
            original.getDataPagamento(),
            atual.getDataPagamento()
        );

        assertEquals("PIX", atual.getFormaPagamento());
    }

    @Test
    void deveImpedirPagamentoPorOutroCliente()
            throws Exception {

        assertFalse(
            dao.realizarPagamento(501, 102, "PIX")
        );

        assertEquals(
            "PENDENTE",
            buscarNaListagem(501).getStatusPagamento()
        );
    }

    @Test
    void deveImpedirCriacaoDePagamentoPorOutroCliente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        assertFalse(
            dao.realizarPagamento(
                agendamento.getIdAgendamento(),
                101,
                "PIX"
            )
        );

        assertEquals(6, contarPagamentos());

        assertEquals(
            0,
            buscarNaListagem(
                agendamento.getIdAgendamento()
            ).getIdPagamento()
        );
    }

    @Test
    void deveImpedirPagamentoDeAgendamentoInexistente()
            throws Exception {

        assertFalse(
            dao.realizarPagamento(999999, 101, "PIX")
        );

        assertEquals(6, contarPagamentos());
    }

    @Test
    void deveImpedirPagamentoPorClienteInexistente()
            throws Exception {

        assertFalse(
            dao.realizarPagamento(501, 999999, "PIX")
        );

        assertEquals(
            "PENDENTE",
            buscarNaListagem(501).getStatusPagamento()
        );
    }

    @Test
    void deveImpedirPagamentoDeAgendamentoCancelado()
            throws Exception {

        agendamentoDAO.cancelar(501);

        assertFalse(
            dao.realizarPagamento(501, 101, "PIX")
        );

        assertEquals(6, contarPagamentos());
        assertFalse(dao.listarAgendamentosPagos().contains(501));
    }

    @Test
    void deveImpedirPagamentoDeAgendamentoArquivado()
            throws Exception {

        assertTrue(agendamentoDAO.arquivarAgendamento(504));

        // Remove o pagamento apenas para isolar
        // a restricao de arquivamento do agendamento.
        executarSqlTeste("""
            DELETE FROM pagamento
            WHERE id_agendamento = 504
            """);

        assertFalse(
            dao.realizarPagamento(504, 101, "PIX")
        );

        assertEquals(5, contarPagamentos());
    }

    @Test
    void deveImpedirReprocessamentoDePagamentoCancelado()
            throws Exception {

        executarSqlTeste("""
            UPDATE pagamento
            SET status_pagamento = 'CANCELADO'
            WHERE id_agendamento = 501
            """);

        assertFalse(
            dao.realizarPagamento(501, 101, "PIX")
        );

        Pagamento pagamento = buscarNaListagem(501);

        assertEquals("CANCELADO", pagamento.getStatusPagamento());
        assertNull(pagamento.getDataPagamento());
    }

    @Test
    void deveImpedirReprocessamentoDePagamentoArquivado()
            throws Exception {

        assertTrue(dao.arquivarPagamento(702));

        assertFalse(
            dao.realizarPagamento(502, 101, "DEBITO")
        );

        Pagamento pagamento = buscarPorFiltro(
            "arquivados",
            702
        );

        assertTrue(pagamento.isArquivado());
        assertEquals("PIX", pagamento.getFormaPagamento());
    }

    @Test
    void deveRejeitarFormaDePagamentoInvalida()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.realizarPagamento(501, 101, "INVALIDO")
        );

        assertEquals(
            "PENDENTE",
            buscarNaListagem(501).getStatusPagamento()
        );
    }

    @Test
    void deveRejeitarFormaDePagamentoNula()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.realizarPagamento(501, 101, null)
        );

        Pagamento pagamento = buscarNaListagem(501);

        assertEquals("PENDENTE", pagamento.getStatusPagamento());
        assertNull(pagamento.getDataPagamento());
        assertNull(pagamento.getFormaPagamento());
    }

    @Test
    void deveReverterCriacaoComFormaInvalida()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        assertThrows(
            SQLException.class,
            () -> dao.realizarPagamento(
                agendamento.getIdAgendamento(),
                102,
                "INVALIDO"
            )
        );

        assertEquals(6, contarPagamentos());

        Pagamento pagamento = buscarNaListagem(
            agendamento.getIdAgendamento()
        );

        assertEquals(0, pagamento.getIdPagamento());
        assertEquals("PENDENTE", pagamento.getStatusPagamento());
    }

    @Test
    void devePermitirNovaTentativaAposRollback()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.realizarPagamento(501, 101, null)
        );

        assertTrue(
            dao.realizarPagamento(501, 101, "PIX")
        );

        assertEquals(
            "PAGO",
            buscarNaListagem(501).getStatusPagamento()
        );
    }

    @Test
    void devePreservarValorContratadoAposMudancaDePreco()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        assertTrue(
            dao.realizarPagamento(501, 101, "PIX")
        );

        assertEquals(
            50.00,
            buscarNaListagem(501).getValor(),
            0.001
        );
    }

    @Test
    void devePreservarValorDeServicoExcluido()
            throws Exception {

        assertTrue(servicoDAO.excluirLogicamente(301));

        assertTrue(
            dao.realizarPagamento(501, 101, "PIX")
        );

        assertEquals(
            50.00,
            buscarNaListagem(501).getValor(),
            0.001
        );
    }

    @Test
    void deveArmazenarValorComPrecisaoDecimal()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(79.99);

        servicoDAO.atualizar(servico);

        Agendamento agendamento = novoAgendamento(301, 302);

        assertTrue(
            dao.realizarPagamento(
                agendamento.getIdAgendamento(),
                102,
                "PIX"
            )
        );

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement("""
                SELECT valor
                FROM pagamento
                WHERE id_agendamento = ?
                """)
        ) {
            comando.setInt(1, agendamento.getIdAgendamento());

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                assertEquals(
                    new BigDecimal("159.99"),
                    resultado.getBigDecimal("valor")
                );
            }
        }
    }

    @Test
    void deveImpedirValorNegativoNoBanco()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> executarSqlTeste("""
                UPDATE pagamento
                SET valor = -10.00
                WHERE id_pagamento = 701
                """)
        );

        assertEquals(
            50.00,
            buscarNaListagem(501).getValor(),
            0.001
        );
    }

    @Test
    void deveListarAgendamentosPagos()
            throws Exception {

        assertEquals(
            Set.of(502, 503, 504, 506),
            dao.listarAgendamentosPagos()
        );
    }

    @Test
    void deveAtualizarConjuntoDeAgendamentosPagos()
            throws Exception {

        assertTrue(
            dao.realizarPagamento(501, 101, "PIX")
        );

        assertEquals(
            Set.of(501, 502, 503, 504, 506),
            dao.listarAgendamentosPagos()
        );
    }

    @Test
    void deveFiltrarPagamentosPendentes()
            throws Exception {

        assertEquals(
            List.of(701),
            idsPorStatus("pendentes")
        );
    }

    @Test
    void deveIncluirAgendamentoSemRegistroNoFiltroPendentes()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        List<Pagamento> pendentes = dao.listarPorStatus(
            "pendentes"
        );

        assertEquals(2, pendentes.size());

        assertTrue(
            pendentes.stream().anyMatch(
                p -> p.getIdAgendamento()
                    == agendamento.getIdAgendamento()
                    && p.getIdPagamento() == 0
            )
        );
    }

    @Test
    void deveFiltrarPagamentosPagos()
            throws Exception {

        assertEquals(
            List.of(702, 703, 704),
            idsPorStatus("pagos")
        );
    }

    @Test
    void deveFiltrarPagamentosCancelados()
            throws Exception {

        assertEquals(
            List.of(705),
            idsPorStatus("cancelados")
        );
    }

    @Test
    void deveFiltrarPagamentosArquivados()
            throws Exception {

        assertEquals(
            List.of(706),
            idsPorStatus("arquivados")
        );

        assertTrue(
            buscarPorFiltro("arquivados", 706).isArquivado()
        );
    }

    @Test
    void deveUtilizarFiltroPendentesComoPadrao()
            throws Exception {

        assertEquals(
            List.of(701),
            idsPorStatus(null)
        );

        assertEquals(
            List.of(701),
            idsPorStatus("desconhecido")
        );
    }

    @Test
    void deveArquivarPagamentoPago()
            throws Exception {

        assertTrue(dao.arquivarPagamento(704));

        Pagamento pagamento = buscarPorFiltro(
            "arquivados",
            704
        );

        assertTrue(pagamento.isArquivado());
        assertEquals("PAGO", pagamento.getStatusPagamento());
        assertEquals(90.00, pagamento.getValor(), 0.001);
    }

    @Test
    void deveArquivarPagamentoCancelado()
            throws Exception {

        assertTrue(dao.arquivarPagamento(705));

        Pagamento pagamento = buscarPorFiltro(
            "arquivados",
            705
        );

        assertTrue(pagamento.isArquivado());
        assertEquals(
            "CANCELADO",
            pagamento.getStatusPagamento()
        );
    }

    @Test
    void deveImpedirArquivamentoDePagamentoPendente()
            throws Exception {

        assertFalse(dao.arquivarPagamento(701));

        assertEquals(
            List.of(701),
            idsPorStatus("pendentes")
        );
    }

    @Test
    void deveImpedirArquivamentoDuplicado()
            throws Exception {

        assertFalse(dao.arquivarPagamento(706));
    }

    @Test
    void deveRestaurarPagamentoArquivado()
            throws Exception {

        assertTrue(dao.restaurarPagamento(706));

        Pagamento pagamento = buscarPorFiltro(
            "pagos",
            706
        );

        assertFalse(pagamento.isArquivado());
        assertNull(pagamento.getArquivadoEm());
        assertEquals("PAGO", pagamento.getStatusPagamento());
    }

    @Test
    void deveImpedirRestauracaoDePagamentoNaoArquivado()
            throws Exception {

        assertFalse(dao.restaurarPagamento(704));
    }

    @Test
    void deveRetornarFalseParaIdInexistenteNoArquivamento()
            throws Exception {

        assertFalse(dao.arquivarPagamento(999999));
        assertFalse(dao.restaurarPagamento(999999));
    }

    @Test
    void deveAtualizarFiltrosAposArquivamentoERestauracao()
            throws Exception {

        assertTrue(dao.arquivarPagamento(704));

        assertEquals(2, idsPorStatus("pagos").size());
        assertEquals(2, idsPorStatus("arquivados").size());

        assertTrue(dao.restaurarPagamento(704));

        assertEquals(3, idsPorStatus("pagos").size());
        assertEquals(1, idsPorStatus("arquivados").size());
    }

    @Test
    void devePreservarDadosFinanceirosAposRestauracao()
            throws Exception {

        Pagamento original = buscarPorFiltro("pagos", 704);

        assertTrue(dao.arquivarPagamento(704));
        assertTrue(dao.restaurarPagamento(704));

        Pagamento restaurado = buscarPorFiltro(
            "pagos",
            704
        );

        assertEquals(
            original.getDataPagamento(),
            restaurado.getDataPagamento()
        );

        assertEquals(
            original.getFormaPagamento(),
            restaurado.getFormaPagamento()
        );

        assertEquals(
            original.getValor(),
            restaurado.getValor(),
            0.001
        );

        assertEquals(
            original.getIdAgendamento(),
            restaurado.getIdAgendamento()
        );
    }

    @Test
    void devePreservarRelacionamentosAposArquivamento()
            throws Exception {

        assertTrue(dao.arquivarPagamento(704));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM pagamento p
                JOIN agendamento a
                    ON a.id_agendamento = p.id_agendamento
                JOIN atendimento at
                    ON at.id_agendamento = a.id_agendamento
                WHERE p.id_pagamento = 704
                  AND p.arquivado_em IS NOT NULL
                  AND a.status = 'CONCLUIDO'
                  AND at.status = 'FINALIZADO'
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(1, resultado.getInt(1));
        }
    }

    @Test
    void deveLiberarLavagemAposConfirmacaoDoPagamento()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.iniciarLavagem(601)
        );

        assertTrue(
            dao.realizarPagamento(501, 101, "PIX")
        );

        atendimentoDAO.iniciarLavagem(601);

        assertEquals(
            "EM_LAVAGEM",
            atendimentoDAO.buscarPorId(601).getStatus()
        );
    }

    @Test
    void deveExecutarFluxoCompletoDeAgendamentoPagamentoELavagem()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 302);

        int idAgendamento = agendamento.getIdAgendamento();

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(idAgendamento);

        atendimentoDAO.inserir(atendimento);

        int idAtendimento = atendimento.getIdAtendimento();

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.iniciarLavagem(idAtendimento)
        );

        assertTrue(
            dao.realizarPagamento(idAgendamento, 102, "PIX")
        );

        atendimentoDAO.iniciarLavagem(idAtendimento);
        atendimentoDAO.finalizar(idAtendimento);

        assertEquals(
            "FINALIZADO",
            atendimentoDAO.buscarPorId(idAtendimento)
                .getStatus()
        );

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(idAgendamento)
                .getStatus()
        );

        Pagamento pagamento = buscarNaListagem(idAgendamento);

        assertEquals("PAGO", pagamento.getStatusPagamento());
        assertEquals(130.00, pagamento.getValor(), 0.001);
    }
}
