package com.fastsplash.web.negocio;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.dao.DashboardDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;

import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.AgendamentoCliente;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Pagamento;
import com.fastsplash.web.model.Dashboard;
import com.fastsplash.web.model.Servico;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class FluxoFinanceiroOperacionalIT {

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private final PagamentoDAO pagamentoDAO =
        new PagamentoDAO();

    private final DashboardDAO dashboardDAO =
        new DashboardDAO();

    private final ServicoDAO servicoDAO =
        new ServicoDAO();

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private final VeiculoDAO veiculoDAO =
        new VeiculoDAO();

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

    private LocalDate hojeBanco() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("SELECT CURDATE()")
        ) {

            assertTrue(resultado.next());

            return resultado.getDate(1).toLocalDate();
        }
    }

    private int novoAgendamento(Integer... servicos)
            throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(hojeBanco().plusDays(2));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(servicos));

        agendamentoDAO.inserir(agendamento);

        assertTrue(agendamento.getIdAgendamento() > 0);

        return agendamento.getIdAgendamento();
    }

    private int novoAtendimento(int idAgendamento)
            throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(idAgendamento);

        atendimentoDAO.inserir(atendimento);

        assertTrue(atendimento.getIdAtendimento() > 0);

        return atendimento.getIdAtendimento();
    }

    private Pagamento consultarPagamento(int idAgendamento)
            throws Exception {

        return pagamentoDAO.listarPorCliente(102)
            .stream()
            .filter(p ->
                p.getIdAgendamento() == idAgendamento
            )
            .findFirst()
            .orElseThrow();
    }

    private AgendamentoCliente consultarAgendamento(
            int idAgendamento
    ) throws Exception {

        return agendamentoDAO.listarPorCliente(102)
            .stream()
            .filter(a ->
                a.getIdAgendamento() == idAgendamento
            )
            .findFirst()
            .orElseThrow();
    }

    private void assertValor(
            String esperado,
            BigDecimal atual
    ) {

        assertNotNull(atual);

        assertEquals(
            0,
            new BigDecimal(esperado).compareTo(atual)
        );
    }

    private void assertMesmoValor(
            BigDecimal esperado,
            BigDecimal atual
    ) {

        assertEquals(
            0,
            esperado.compareTo(atual)
        );
    }

    private long contarPagamentos(int idAgendamento)
            throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();

            var comando = conexao.prepareStatement("""
                SELECT COUNT(*)
                FROM pagamento
                WHERE id_agendamento = ?
                """)
        ) {

            comando.setInt(1, idAgendamento);

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                return resultado.getLong(1);
            }
        }
    }

    private void confirmarPagamento(int idAgendamento)
            throws Exception {

        assertTrue(
            pagamentoDAO.realizarPagamento(
                idAgendamento,
                102,
                "PIX"
            )
        );

        Pagamento pagamento =
            consultarPagamento(idAgendamento);

        assertEquals(
            "PAGO",
            pagamento.getStatusPagamento()
        );

        assertNotNull(pagamento.getDataPagamento());
        assertEquals("PIX", pagamento.getFormaPagamento());
    }

    private void concluirAtendimento(int idAtendimento)
            throws Exception {

        atendimentoDAO.iniciarLavagem(idAtendimento);
        atendimentoDAO.finalizar(idAtendimento);

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(idAtendimento);

        assertEquals("FINALIZADO", atendimento.getStatus());

        assertNotNull(atendimento.getDataInicio());
        assertNotNull(atendimento.getDataFim());

        assertFalse(
            atendimento.getDataFim()
                .isBefore(atendimento.getDataInicio())
        );
    }

    @Test
    void deveAtualizarIndicadoresDuranteTodoFluxo()
            throws Exception {

        Dashboard inicial = dashboardDAO.carregar();

        int idAgendamento = novoAgendamento(301, 302);

        Dashboard contratado = dashboardDAO.carregar();

        assertEquals(
            inicial.pagamentosPendentes() + 1,
            contratado.pagamentosPendentes()
        );

        assertMesmoValor(
            inicial.valoresAReceber()
                .add(new BigDecimal("130.00")),
            contratado.valoresAReceber()
        );

        int idAtendimento =
            novoAtendimento(idAgendamento);

        Dashboard aguardando = dashboardDAO.carregar();

        assertEquals(
            inicial.atendimentosAguardando() + 1,
            aguardando.atendimentosAguardando()
        );

        assertEquals(
            "AGUARDANDO",
            consultarAgendamento(idAgendamento)
                .getStatusAtendimento()
        );

        confirmarPagamento(idAgendamento);

        Dashboard pago = dashboardDAO.carregar();

        assertEquals(
            inicial.pagamentosPendentes(),
            pago.pagamentosPendentes()
        );

        assertMesmoValor(
            inicial.valoresAReceber(),
            pago.valoresAReceber()
        );

        assertMesmoValor(
            inicial.faturamentoMensal()
                .add(new BigDecimal("130.00")),
            pago.faturamentoMensal()
        );

        atendimentoDAO.iniciarLavagem(idAtendimento);

        Dashboard emLavagem = dashboardDAO.carregar();

        assertEquals(
            inicial.atendimentosAguardando(),
            emLavagem.atendimentosAguardando()
        );

        assertEquals(
            inicial.atendimentosEmLavagem() + 1,
            emLavagem.atendimentosEmLavagem()
        );

        assertEquals(
            "EM_LAVAGEM",
            consultarAgendamento(idAgendamento)
                .getStatusAtendimento()
        );

        atendimentoDAO.finalizar(idAtendimento);

        Dashboard finalizado = dashboardDAO.carregar();

        assertEquals(
            inicial.atendimentosEmLavagem(),
            finalizado.atendimentosEmLavagem()
        );

        assertEquals(
            inicial.atendimentosFinalizados() + 1,
            finalizado.atendimentosFinalizados()
        );

        assertEquals(
            "CONCLUIDO",
            consultarAgendamento(idAgendamento)
                .getStatusAgendamento()
        );

        assertEquals(
            "FINALIZADO",
            consultarAgendamento(idAgendamento)
                .getStatusAtendimento()
        );

        assertMesmoValor(
            pago.faturamentoMensal(),
            finalizado.faturamentoMensal()
        );

        assertEquals(
            1,
            contarPagamentos(idAgendamento)
        );

        assertFalse(
            finalizado.proximosAgendamentos()
                .stream()
                .anyMatch(a ->
                    a.idAgendamento() == idAgendamento
                )
        );
    }

    @Test
    void devePermitirPagamentoAntesDaCriacaoDoAtendimento()
            throws Exception {

        int idAgendamento = novoAgendamento(301);

        confirmarPagamento(idAgendamento);

        assertTrue(
            pagamentoDAO.listarAgendamentosPagos()
                .contains(idAgendamento)
        );

        assertTrue(
            atendimentoDAO.listarAgendamentosDisponiveis()
                .stream()
                .anyMatch(a ->
                    a.getIdAgendamento() == idAgendamento
                )
        );

        int idAtendimento =
            novoAtendimento(idAgendamento);

        concluirAtendimento(idAtendimento);

        assertEquals(
            "CONCLUIDO",
            consultarAgendamento(idAgendamento)
                .getStatusAgendamento()
        );

        assertEquals(
            "PAGO",
            consultarPagamento(idAgendamento)
                .getStatusPagamento()
        );

        assertEquals(1, contarPagamentos(idAgendamento));
    }

    @Test
    void devePreservarRegistrosQuandoLavagemNaoEstiverPaga()
            throws Exception {

        int idAgendamento = novoAgendamento(301, 302);

        int idAtendimento =
            novoAtendimento(idAgendamento);

        Dashboard anterior = dashboardDAO.carregar();

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.iniciarLavagem(idAtendimento)
        );

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.finalizar(idAtendimento)
        );

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(idAtendimento);

        assertEquals("AGUARDANDO", atendimento.getStatus());
        assertNull(atendimento.getDataInicio());
        assertNull(atendimento.getDataFim());

        assertEquals(
            "AGENDADO",
            consultarAgendamento(idAgendamento)
                .getStatusAgendamento()
        );

        assertEquals(
            "PENDENTE",
            consultarPagamento(idAgendamento)
                .getStatusPagamento()
        );

        assertEquals(0, contarPagamentos(idAgendamento));

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.atendimentosAguardando(),
            atual.atendimentosAguardando()
        );

        assertEquals(
            anterior.atendimentosEmLavagem(),
            atual.atendimentosEmLavagem()
        );

        assertEquals(
            anterior.atendimentosFinalizados(),
            atual.atendimentosFinalizados()
        );

        assertMesmoValor(
            anterior.valoresAReceber(),
            atual.valoresAReceber()
        );

        assertMesmoValor(
            anterior.faturamentoMensal(),
            atual.faturamentoMensal()
        );
    }

    @Test
    void deveBloquearPagamentoDeTerceiroSemImpactoFinanceiro()
            throws Exception {

        int idAgendamento = novoAgendamento(301, 302);

        int idAtendimento =
            novoAtendimento(idAgendamento);

        Dashboard anterior = dashboardDAO.carregar();

        assertFalse(
            pagamentoDAO.realizarPagamento(
                idAgendamento,
                101,
                "PIX"
            )
        );

        assertEquals(0, contarPagamentos(idAgendamento));

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.iniciarLavagem(idAtendimento)
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.pagamentosPendentes(),
            atual.pagamentosPendentes()
        );

        assertMesmoValor(
            anterior.valoresAReceber(),
            atual.valoresAReceber()
        );

        assertMesmoValor(
            anterior.faturamentoMensal(),
            atual.faturamentoMensal()
        );

        confirmarPagamento(idAgendamento);

        concluirAtendimento(idAtendimento);

        assertEquals(1, contarPagamentos(idAgendamento));
    }

    @Test
    void deveImpedirDuplicacaoDeFaturamento()
            throws Exception {

        Dashboard inicial = dashboardDAO.carregar();

        int idAgendamento = novoAgendamento(301, 302);

        confirmarPagamento(idAgendamento);

        Pagamento original =
            consultarPagamento(idAgendamento);

        assertFalse(
            pagamentoDAO.realizarPagamento(
                idAgendamento,
                102,
                "CREDITO"
            )
        );

        Pagamento atual =
            consultarPagamento(idAgendamento);

        assertEquals(
            original.getIdPagamento(),
            atual.getIdPagamento()
        );

        assertEquals(
            original.getDataPagamento(),
            atual.getDataPagamento()
        );

        assertEquals("PIX", atual.getFormaPagamento());

        assertEquals(130.00, atual.getValor(), 0.001);

        assertEquals(1, contarPagamentos(idAgendamento));

        Dashboard dashboard = dashboardDAO.carregar();

        assertMesmoValor(
            inicial.faturamentoMensal()
                .add(new BigDecimal("130.00")),
            dashboard.faturamentoMensal()
        );

        assertMesmoValor(
            inicial.valoresAReceber(),
            dashboard.valoresAReceber()
        );
    }

    @Test
    void deveRecuperarFluxoAposPagamentoInvalido()
            throws Exception {

        int idAgendamento = novoAgendamento(301);

        int idAtendimento =
            novoAtendimento(idAgendamento);

        Dashboard anterior = dashboardDAO.carregar();

        assertThrows(
            SQLException.class,
            () -> pagamentoDAO.realizarPagamento(
                idAgendamento,
                102,
                null
            )
        );

        assertEquals(0, contarPagamentos(idAgendamento));

        assertEquals(
            "PENDENTE",
            consultarPagamento(idAgendamento)
                .getStatusPagamento()
        );

        Dashboard aposFalha = dashboardDAO.carregar();

        assertMesmoValor(
            anterior.faturamentoMensal(),
            aposFalha.faturamentoMensal()
        );

        assertMesmoValor(
            anterior.valoresAReceber(),
            aposFalha.valoresAReceber()
        );

        assertThrows(
            SQLException.class,
            () -> atendimentoDAO.iniciarLavagem(idAtendimento)
        );

        confirmarPagamento(idAgendamento);

        concluirAtendimento(idAtendimento);

        assertEquals(1, contarPagamentos(idAgendamento));

        Dashboard finalizado = dashboardDAO.carregar();

        assertMesmoValor(
            anterior.faturamentoMensal()
                .add(new BigDecimal("50.00")),
            finalizado.faturamentoMensal()
        );

        assertMesmoValor(
            anterior.valoresAReceber()
                .subtract(new BigDecimal("50.00")),
            finalizado.valoresAReceber()
        );
    }

    @Test
    void devePreservarValorContratadoDuranteTodoAtendimento()
            throws Exception {

        Dashboard inicial = dashboardDAO.carregar();

        int idAgendamento = novoAgendamento(301, 302);

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        assertTrue(servicoDAO.excluirLogicamente(302));

        assertEquals(
            130.00,
            consultarAgendamento(idAgendamento)
                .getValorTotal(),
            0.001
        );

        assertEquals(
            130.00,
            consultarPagamento(idAgendamento)
                .getValor(),
            0.001
        );

        int idAtendimento =
            novoAtendimento(idAgendamento);

        confirmarPagamento(idAgendamento);

        concluirAtendimento(idAtendimento);

        assertEquals(
            130.00,
            consultarPagamento(idAgendamento)
                .getValor(),
            0.001
        );

        assertEquals(
            130.00,
            consultarAgendamento(idAgendamento)
                .getValorTotal(),
            0.001
        );

        assertEquals(
            "CONCLUIDO",
            consultarAgendamento(idAgendamento)
                .getStatusAgendamento()
        );

        Dashboard atual = dashboardDAO.carregar();

        assertMesmoValor(
            inicial.faturamentoMensal()
                .add(new BigDecimal("130.00")),
            atual.faturamentoMensal()
        );

        assertValor("50.00", atual.valoresAReceber());
    }

    @Test
    void deveLiberarInativacaoAposConclusaoDoServico()
            throws Exception {

        int idAgendamento = novoAgendamento(301);

        int idAtendimento =
            novoAtendimento(idAgendamento);

        assertEquals(
            ResultadoStatusCliente.POSSUI_PENDENCIAS,
            clienteDAO.inativarCliente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.POSSUI_PENDENCIAS,
            veiculoDAO.inativarVeiculo(203)
        );

        confirmarPagamento(idAgendamento);

        atendimentoDAO.iniciarLavagem(idAtendimento);

        assertEquals(
            ResultadoStatusCliente.POSSUI_PENDENCIAS,
            clienteDAO.inativarCliente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.POSSUI_PENDENCIAS,
            veiculoDAO.inativarVeiculo(203)
        );

        atendimentoDAO.finalizar(idAtendimento);

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.inativarVeiculo(203)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        assertFalse(clienteDAO.buscarPorId(102).isAtivo());

        assertFalse(veiculoDAO.buscarPorId(203).isAtivo());

        assertEquals(
            "CONCLUIDO",
            consultarAgendamento(idAgendamento)
                .getStatusAgendamento()
        );

        assertEquals(
            "PAGO",
            consultarPagamento(idAgendamento)
                .getStatusPagamento()
        );

        assertEquals(
            50.00,
            consultarPagamento(idAgendamento)
                .getValor(),
            0.001
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(1, dashboard.clientesAtivos());
        assertEquals(2, dashboard.veiculosAtivos());
        assertEquals(3, dashboard.atendimentosFinalizados());

        assertValor(
            "50.00",
            dashboard.valoresAReceber()
        );
    }
}
