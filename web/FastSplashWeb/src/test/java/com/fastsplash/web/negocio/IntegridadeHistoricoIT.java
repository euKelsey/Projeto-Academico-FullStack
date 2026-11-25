package com.fastsplash.web.negocio;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.DashboardDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;

import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Pagamento;
import com.fastsplash.web.model.Dashboard;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class IntegridadeHistoricoIT {

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private final PagamentoDAO pagamentoDAO =
        new PagamentoDAO();

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private final VeiculoDAO veiculoDAO =
        new VeiculoDAO();

    private final ServicoDAO servicoDAO =
        new ServicoDAO();

    private final DashboardDAO dashboardDAO =
        new DashboardDAO();

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

    private record FluxoConcluido(
        int idAgendamento,
        int idAtendimento,
        int idPagamento
    ) {}

    private long consultarQuantidade(
            String sql,
            int id
    ) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, id);

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                return resultado.getLong(1);
            }
        }
    }

    private Pagamento consultarPagamento(
            int idCliente,
            int idAgendamento
    ) throws Exception {

        return pagamentoDAO.listarPorCliente(idCliente)
            .stream()
            .filter(p ->
                p.getIdAgendamento() == idAgendamento
            )
            .findFirst()
            .orElseThrow();
    }

    private boolean pagamentoConstaNoFiltro(
            String filtro,
            int idPagamento
    ) throws Exception {

        return pagamentoDAO.listarPorStatus(filtro)
            .stream()
            .anyMatch(p ->
                p.getIdPagamento() == idPagamento
            );
    }

    private BigDecimal totalHistorico(
            Dashboard dashboard
    ) {

        return dashboard.faturamentoHistorico()
            .stream()
            .map(Dashboard.FaturamentoMes::valor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
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

    private void verificarIndicadoresHistoricos(
            Dashboard anterior,
            Dashboard atual
    ) {

        assertMesmoValor(
            anterior.faturamentoMensal(),
            atual.faturamentoMensal()
        );

        assertMesmoValor(
            totalHistorico(anterior),
            totalHistorico(atual)
        );

        assertMesmoValor(
            anterior.valoresAReceber(),
            atual.valoresAReceber()
        );

        assertEquals(
            anterior.pagamentosPendentes(),
            atual.pagamentosPendentes()
        );

        assertEquals(
            anterior.atendimentosFinalizados(),
            atual.atendimentosFinalizados()
        );
    }

    private FluxoConcluido criarFluxoConcluido()
            throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(LocalDate.now().plusDays(2));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(301, 302));

        agendamentoDAO.inserir(agendamento);

        int idAgendamento =
            agendamento.getIdAgendamento();

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(idAgendamento);

        atendimentoDAO.inserir(atendimento);

        int idAtendimento =
            atendimento.getIdAtendimento();

        assertTrue(
            pagamentoDAO.realizarPagamento(
                idAgendamento, 102, "PIX"
            )
        );

        atendimentoDAO.iniciarLavagem(idAtendimento);

        atendimentoDAO.finalizar(idAtendimento);

        Pagamento pagamento =
            consultarPagamento(102, idAgendamento);

        assertEquals(
            "PAGO",
            pagamento.getStatusPagamento()
        );

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(
                idAgendamento
            ).getStatus()
        );

        return new FluxoConcluido(
            idAgendamento,
            idAtendimento,
            pagamento.getIdPagamento()
        );
    }

    private void verificarVinculos(
            int idAgendamento,
            int quantidadeServicos
    ) throws Exception {

        assertEquals(
            1,
            consultarQuantidade("""
                SELECT COUNT(*)
                FROM agendamento a
                INNER JOIN veiculo v
                    ON v.id_veiculo = a.id_veiculo
                INNER JOIN cliente c
                    ON c.id_cliente = v.id_cliente
                INNER JOIN atendimento t
                    ON t.id_agendamento = a.id_agendamento
                INNER JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento
                WHERE a.id_agendamento = ?
                """, idAgendamento)
        );

        assertEquals(
            quantidadeServicos,
            consultarQuantidade("""
                SELECT COUNT(*)
                FROM agendamento_servico ags
                INNER JOIN servico s
                    ON s.id_servico = ags.id_servico
                WHERE ags.id_agendamento = ?
                """, idAgendamento)
        );
    }

    @Test
    void deveArquivarFluxoCompletoSemPerderHistorico()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Pagamento pagamentoOriginal =
            consultarPagamento(101, 504);

        Atendimento atendimentoOriginal =
            atendimentoDAO.buscarPorId(604);

        assertTrue(
            atendimentoDAO.arquivarAtendimento(604)
        );

        assertTrue(
            pagamentoDAO.arquivarPagamento(704)
        );

        assertTrue(
            agendamentoDAO.arquivarAgendamento(504)
        );

        Agendamento agendamento =
            agendamentoDAO.buscarPorId(504);

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(604);

        assertTrue(agendamento.isArquivado());
        assertTrue(atendimento.isArquivado());

        assertEquals(
            "CONCLUIDO",
            agendamento.getStatus()
        );

        assertEquals(
            "FINALIZADO",
            atendimento.getStatus()
        );

        assertTrue(
            pagamentoConstaNoFiltro("arquivados", 704)
        );

        assertFalse(
            pagamentoConstaNoFiltro("pagos", 704)
        );

        Pagamento pagamento =
            consultarPagamento(101, 504);

        assertEquals(
            pagamentoOriginal.getIdPagamento(),
            pagamento.getIdPagamento()
        );

        assertEquals(
            pagamentoOriginal.getValor(),
            pagamento.getValor(),
            0.001
        );

        assertEquals(
            pagamentoOriginal.getDataPagamento(),
            pagamento.getDataPagamento()
        );

        assertEquals(
            atendimentoOriginal.getDataInicio(),
            atendimento.getDataInicio()
        );

        assertEquals(
            atendimentoOriginal.getDataFim(),
            atendimento.getDataFim()
        );

        verificarVinculos(504, 2);

        verificarIndicadoresHistoricos(
            anterior,
            dashboardDAO.carregar()
        );
    }

    @Test
    void deveRestaurarFluxoCompletoSemReprocessarPagamento()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Pagamento pagamentoOriginal =
            consultarPagamento(104, 506);

        assertTrue(
            agendamentoDAO.restaurarAgendamento(506)
        );

        assertTrue(
            atendimentoDAO.restaurarAtendimento(605)
        );

        assertTrue(
            pagamentoDAO.restaurarPagamento(706)
        );

        Agendamento agendamento =
            agendamentoDAO.buscarPorId(506);

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(605);

        assertFalse(agendamento.isArquivado());
        assertFalse(atendimento.isArquivado());

        assertEquals(
            "CONCLUIDO",
            agendamento.getStatus()
        );

        assertEquals(
            "FINALIZADO",
            atendimento.getStatus()
        );

        assertTrue(
            pagamentoConstaNoFiltro("pagos", 706)
        );

        assertFalse(
            pagamentoConstaNoFiltro("arquivados", 706)
        );

        Pagamento pagamento =
            consultarPagamento(104, 506);

        assertEquals(
            pagamentoOriginal.getIdPagamento(),
            pagamento.getIdPagamento()
        );

        assertEquals(
            pagamentoOriginal.getValor(),
            pagamento.getValor(),
            0.001
        );

        assertEquals(
            pagamentoOriginal.getDataPagamento(),
            pagamento.getDataPagamento()
        );

        assertEquals(
            pagamentoOriginal.getFormaPagamento(),
            pagamento.getFormaPagamento()
        );

        assertFalse(
            pagamentoDAO.realizarPagamento(
                506, 104, "PIX"
            )
        );

        verificarVinculos(506, 1);

        verificarIndicadoresHistoricos(
            anterior,
            dashboardDAO.carregar()
        );
    }

    @Test
    void deveExcluirClienteEVeiculoPreservandoHistorico()
            throws Exception {

        FluxoConcluido fluxo = criarFluxoConcluido();

        Dashboard anterior = dashboardDAO.carregar();

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(203)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        assertTrue(
            clienteDAO.buscarPorId(102).isExcluido()
        );

        assertTrue(
            veiculoDAO.buscarPorId(203).isExcluido()
        );

        assertTrue(
            veiculoDAO.listarPorCliente(102).isEmpty()
        );

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(
                fluxo.idAgendamento()
            ).getStatus()
        );

        assertEquals(
            "FINALIZADO",
            atendimentoDAO.buscarPorId(
                fluxo.idAtendimento()
            ).getStatus()
        );

        Pagamento pagamento = consultarPagamento(
            102, fluxo.idAgendamento()
        );

        assertEquals("PAGO", pagamento.getStatusPagamento());

        assertEquals(130.00, pagamento.getValor(), 0.001);

        assertEquals(
            fluxo.idPagamento(),
            pagamento.getIdPagamento()
        );

        verificarVinculos(
            fluxo.idAgendamento(), 2
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.clientesAtivos() - 1,
            atual.clientesAtivos()
        );

        assertEquals(
            anterior.veiculosAtivos() - 1,
            atual.veiculosAtivos()
        );

        verificarIndicadoresHistoricos(
            anterior, atual
        );
    }

    @Test
    void deveRestaurarCadastroPreservandoHistoricoFinanceiro()
            throws Exception {

        FluxoConcluido fluxo = criarFluxoConcluido();

        Dashboard anterior = dashboardDAO.carregar();

        Pagamento original = consultarPagamento(
            102, fluxo.idAgendamento()
        );

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(203)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.CLIENTE_INATIVO,
            veiculoDAO.restaurarVeiculo(203)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.restaurarCliente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.restaurarVeiculo(203)
        );

        assertTrue(
            clienteDAO.buscarPorId(102).isAtivo()
        );

        assertTrue(
            veiculoDAO.buscarPorId(203).isAtivo()
        );

        assertEquals(
            102,
            veiculoDAO.buscarPorId(203).getIdCliente()
        );

        Pagamento atual = consultarPagamento(
            102, fluxo.idAgendamento()
        );

        assertEquals(
            original.getIdPagamento(),
            atual.getIdPagamento()
        );

        assertEquals(
            original.getValor(),
            atual.getValor(),
            0.001
        );

        assertEquals(
            original.getDataPagamento(),
            atual.getDataPagamento()
        );

        assertEquals(
            original.getFormaPagamento(),
            atual.getFormaPagamento()
        );

        assertEquals(
            "PAGO",
            atual.getStatusPagamento()
        );

        verificarVinculos(
            fluxo.idAgendamento(), 2
        );

        Dashboard restaurado = dashboardDAO.carregar();

        assertEquals(
            anterior.clientesAtivos(),
            restaurado.clientesAtivos()
        );

        assertEquals(
            anterior.veiculosAtivos(),
            restaurado.veiculosAtivos()
        );

        verificarIndicadoresHistoricos(
            anterior, restaurado
        );
    }

    @Test
    void deveExcluirServicoSemAlterarContratosHistoricos()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Pagamento original =
            consultarPagamento(101, 504);

        assertTrue(
            servicoDAO.excluirLogicamente(301)
        );

        assertTrue(
            servicoDAO.buscarPorId(301).isExcluido()
        );

        var agendamento =
            agendamentoDAO.listarPorCliente(101)
                .stream()
                .filter(a ->
                    a.getIdAgendamento() == 504
                )
                .findFirst()
                .orElseThrow();

        assertEquals(2, agendamento.getServicos().size());

        assertEquals(
            90.00,
            agendamento.getValorTotal(),
            0.001
        );

        Pagamento atual =
            consultarPagamento(101, 504);

        assertEquals(
            original.getValor(),
            atual.getValor(),
            0.001
        );

        assertEquals(
            original.getIdPagamento(),
            atual.getIdPagamento()
        );

        assertEquals(
            original.getDataPagamento(),
            atual.getDataPagamento()
        );

        assertEquals(
            "FINALIZADO",
            atendimentoDAO.buscarPorId(604).getStatus()
        );

        verificarVinculos(504, 2);

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(
            anterior.servicosAtivos() - 1,
            dashboard.servicosAtivos()
        );

        verificarIndicadoresHistoricos(
            anterior, dashboard
        );
    }

    @Test
    void devePreservarColaboradoresVinculadosAoHistorico()
            throws Exception {

        long quantidadeOriginal = consultarQuantidade("""
            SELECT COUNT(*)
            FROM colaborador_atendimento ca
            INNER JOIN colaborador c
                ON c.id_colaborador = ca.id_colaborador
            WHERE ca.id_atendimento = ?
            """, 604);

        assertEquals(2, quantidadeOriginal);

        assertTrue(
            atendimentoDAO.arquivarAtendimento(604)
        );

        assertTrue(
            pagamentoDAO.arquivarPagamento(704)
        );

        assertTrue(
            agendamentoDAO.arquivarAgendamento(504)
        );

        assertEquals(
            quantidadeOriginal,
            consultarQuantidade("""
                SELECT COUNT(*)
                FROM colaborador_atendimento
                WHERE id_atendimento = ?
                """, 604)
        );

        assertTrue(
            agendamentoDAO.restaurarAgendamento(504)
        );

        assertTrue(
            atendimentoDAO.restaurarAtendimento(604)
        );

        assertTrue(
            pagamentoDAO.restaurarPagamento(704)
        );

        assertEquals(
            quantidadeOriginal,
            consultarQuantidade("""
                SELECT COUNT(*)
                FROM colaborador_atendimento ca
                INNER JOIN colaborador c
                    ON c.id_colaborador = ca.id_colaborador
                WHERE ca.id_atendimento = ?
                  AND ca.id_colaborador IN (403, 404)
                """, 604)
        );

        verificarVinculos(504, 2);

        assertEquals(
            "FINALIZADO",
            atendimentoDAO.buscarPorId(604).getStatus()
        );

        assertEquals(
            "PAGO",
            consultarPagamento(101, 504)
                .getStatusPagamento()
        );
    }
}
