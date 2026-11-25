package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Agendamento;
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
import java.time.YearMonth;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class DashboardDAOIT {

    private final DashboardDAO dao = new DashboardDAO();

    private final ClienteDAO clienteDAO = new ClienteDAO();
    private final VeiculoDAO veiculoDAO = new VeiculoDAO();
    private final ServicoDAO servicoDAO = new ServicoDAO();
    private final ColaboradorDAO colaboradorDAO = new ColaboradorDAO();
    private final AgendamentoDAO agendamentoDAO = new AgendamentoDAO();
    private final AtendimentoDAO atendimentoDAO = new AtendimentoDAO();
    private final PagamentoDAO pagamentoDAO = new PagamentoDAO();

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

    private void executarSqlTeste(String sql) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement()
        ) {
            comando.executeUpdate(sql);
        }
    }

    private void assertValor(
            String esperado,
            BigDecimal atual
    ) {
        assertNotNull(atual);

        assertEquals(
            0,
            new BigDecimal(esperado).compareTo(atual),
            "Valor financeiro diferente do esperado"
        );
    }

    private Agendamento novoAgendamento(
            LocalDate data,
            LocalTime horario,
            Integer... servicos
    ) throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(data);
        agendamento.setHorario(horario);
        agendamento.setIdsServicos(List.of(servicos));

        agendamentoDAO.inserir(agendamento);

        return agendamento;
    }

    private BigDecimal totalHistorico(Dashboard dashboard) {

        return dashboard.faturamentoHistorico()
            .stream()
            .map(Dashboard.FaturamentoMes::valor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private List<Integer> proximosIds(Dashboard dashboard) {

        return dashboard.proximosAgendamentos()
            .stream()
            .map(Dashboard.ProximoAgendamento::idAgendamento)
            .toList();
    }

    @Test
    void deveCarregarDashboard() throws Exception {

        Dashboard dashboard = dao.carregar();

        assertNotNull(dashboard);
        assertNotNull(dashboard.faturamentoHistorico());
        assertNotNull(dashboard.proximosAgendamentos());
    }

    @Test
    void deveContabilizarClientesAtivos() throws Exception {

        assertEquals(
            2,
            dao.carregar().clientesAtivos()
        );
    }

    @Test
    void deveContabilizarVeiculosAtivos() throws Exception {

        assertEquals(
            3,
            dao.carregar().veiculosAtivos()
        );
    }

    @Test
    void deveContabilizarServicosAtivos() throws Exception {

        assertEquals(
            2,
            dao.carregar().servicosAtivos()
        );
    }

    @Test
    void deveContabilizarColaboradoresAtivos() throws Exception {

        assertEquals(
            4,
            dao.carregar().colaboradoresAtivos()
        );
    }

    @Test
    void deveContabilizarAgendamentosDeHoje() throws Exception {

        assertEquals(
            1,
            dao.carregar().agendamentosHoje()
        );
    }

    @Test
    void deveContabilizarAtendimentosAguardando() throws Exception {

        assertEquals(
            2,
            dao.carregar().atendimentosAguardando()
        );
    }

    @Test
    void deveContabilizarAtendimentosEmLavagem() throws Exception {

        assertEquals(
            1,
            dao.carregar().atendimentosEmLavagem()
        );
    }

    @Test
    void deveContabilizarAtendimentosFinalizados()
            throws Exception {

        assertEquals(
            2,
            dao.carregar().atendimentosFinalizados()
        );
    }

    @Test
    void deveContabilizarPagamentosPendentes() throws Exception {

        assertEquals(
            1,
            dao.carregar().pagamentosPendentes()
        );
    }

    @Test
    void deveCalcularValoresAReceber() throws Exception {

        assertValor(
            "50.00",
            dao.carregar().valoresAReceber()
        );
    }

    @Test
    void deveAtualizarIndicadorAposInativacaoDeCliente()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(1, dashboard.clientesAtivos());
        assertEquals(2, dashboard.veiculosAtivos());
    }

    @Test
    void deveAtualizarIndicadorAposReativacaoDeCliente()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.reativarCliente(102)
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(2, dashboard.clientesAtivos());
        assertEquals(3, dashboard.veiculosAtivos());
    }

    @Test
    void deveIgnorarVeiculoAtivoDeClienteExcluido()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        assertEquals(
            2,
            dao.carregar().veiculosAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposInativacaoDeVeiculo()
            throws Exception {

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.inativarVeiculo(203)
        );

        assertEquals(
            2,
            dao.carregar().veiculosAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposInativacaoDeServico()
            throws Exception {

        assertTrue(servicoDAO.inativarServico(301));

        assertEquals(
            1,
            dao.carregar().servicosAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposReativacaoDeServico()
            throws Exception {

        assertTrue(servicoDAO.reativarServico(303));

        assertEquals(
            3,
            dao.carregar().servicosAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposExclusaoDeServico()
            throws Exception {

        assertTrue(servicoDAO.excluirLogicamente(301));

        assertEquals(
            1,
            dao.carregar().servicosAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposInativacaoDeColaborador()
            throws Exception {

        assertEquals(
            ResultadoStatusColaborador.SUCESSO,
            colaboradorDAO.inativarColaborador(404, 401)
        );

        assertEquals(
            3,
            dao.carregar().colaboradoresAtivos()
        );
    }

    @Test
    void deveAtualizarIndicadorAposReativacaoDeColaborador()
            throws Exception {

        assertEquals(
            ResultadoStatusColaborador.SUCESSO,
            colaboradorDAO.reativarColaborador(405, 401)
        );

        assertEquals(
            5,
            dao.carregar().colaboradoresAtivos()
        );
    }

    @Test
    void deveContabilizarNovoAgendamentoDeHoje()
            throws Exception {

        novoAgendamento(
            hojeBanco(),
            LocalTime.of(14, 0),
            301
        );

        assertEquals(
            2,
            dao.carregar().agendamentosHoje()
        );
    }

    @Test
    void deveIgnorarAgendamentoFuturoNaContagemDiaria()
            throws Exception {

        novoAgendamento(
            hojeBanco().plusDays(5),
            LocalTime.of(14, 0),
            301
        );

        assertEquals(
            1,
            dao.carregar().agendamentosHoje()
        );
    }

    @Test
    void deveIgnorarAgendamentoCanceladoNaContagemDiaria()
            throws Exception {

        Agendamento agendamento = novoAgendamento(
            hojeBanco(),
            LocalTime.of(14, 0),
            301
        );

        agendamentoDAO.cancelar(
            agendamento.getIdAgendamento()
        );

        assertEquals(
            1,
            dao.carregar().agendamentosHoje()
        );
    }

    @Test
    void deveAtualizarIndicadoresAposInicioDeLavagem()
            throws Exception {

        atendimentoDAO.iniciarLavagem(602);

        Dashboard dashboard = dao.carregar();

        assertEquals(1, dashboard.atendimentosAguardando());
        assertEquals(2, dashboard.atendimentosEmLavagem());
        assertEquals(2, dashboard.atendimentosFinalizados());
    }

    @Test
    void deveAtualizarIndicadoresAposFinalizacao()
            throws Exception {

        atendimentoDAO.iniciarLavagem(602);
        atendimentoDAO.finalizar(602);

        Dashboard dashboard = dao.carregar();

        assertEquals(1, dashboard.atendimentosAguardando());
        assertEquals(1, dashboard.atendimentosEmLavagem());
        assertEquals(3, dashboard.atendimentosFinalizados());
    }

    @Test
    void devePreservarContagemDeAtendimentosArquivados()
            throws Exception {

        assertTrue(
            atendimentoDAO.arquivarAtendimento(604)
        );

        assertEquals(
            2,
            dao.carregar().atendimentosFinalizados()
        );
    }

    @Test
    void deveContabilizarAgendamentoSemRegistroDePagamento()
            throws Exception {

        novoAgendamento(
            hojeBanco().plusDays(5),
            LocalTime.of(14, 0),
            301
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(2, dashboard.pagamentosPendentes());

        assertValor(
            "100.00",
            dashboard.valoresAReceber()
        );
    }

    @Test
    void deveSomarMultiplosServicosSemDuplicarPendencia()
            throws Exception {

        novoAgendamento(
            hojeBanco().plusDays(5),
            LocalTime.of(14, 0),
            301, 302
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(2, dashboard.pagamentosPendentes());

        assertValor(
            "180.00",
            dashboard.valoresAReceber()
        );
    }

    @Test
    void deveIgnorarAgendamentoCanceladoNosValoresAReceber()
            throws Exception {

        Agendamento agendamento = novoAgendamento(
            hojeBanco().plusDays(5),
            LocalTime.of(14, 0),
            301
        );

        agendamentoDAO.cancelar(
            agendamento.getIdAgendamento()
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(1, dashboard.pagamentosPendentes());
        assertValor("50.00", dashboard.valoresAReceber());
    }

    @Test
    void deveAtualizarPendenciasAposConfirmacaoDePagamento()
            throws Exception {

        assertTrue(
            pagamentoDAO.realizarPagamento(501, 101, "PIX")
        );

        Dashboard dashboard = dao.carregar();

        assertEquals(0, dashboard.pagamentosPendentes());
        assertValor("0.00", dashboard.valoresAReceber());
    }

    @Test
    void devePreservarPrecoContratadoNosValoresAReceber()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        assertValor(
            "50.00",
            dao.carregar().valoresAReceber()
        );
    }

    @Test
    void devePreservarPrecisaoDecimalNosValoresAReceber()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(79.99);

        servicoDAO.atualizar(servico);

        novoAgendamento(
            hojeBanco().plusDays(5),
            LocalTime.of(14, 0),
            301
        );

        assertValor(
            "129.99",
            dao.carregar().valoresAReceber()
        );
    }

    @Test
    void deveApresentarSeisMesesDeHistorico()
            throws Exception {

        assertEquals(
            6,
            dao.carregar().faturamentoHistorico().size()
        );
    }

    @Test
    void deveApresentarHistoricoEmOrdemCronologica()
            throws Exception {

        YearMonth atual = YearMonth.from(hojeBanco());

        List<Dashboard.FaturamentoMes> historico =
            dao.carregar().faturamentoHistorico();

        for (int i = 0; i < 6; i++) {

            assertEquals(
                atual.minusMonths(5 - i),
                historico.get(i).mes()
            );
        }
    }

    @Test
    void devePreencherMesesSemFaturamentoComZero()
            throws Exception {

        List<Dashboard.FaturamentoMes> historico =
            dao.carregar().faturamentoHistorico();

        for (int i = 0; i < 4; i++) {

            assertValor(
                "0.00",
                historico.get(i).valor()
            );
        }
    }

    @Test
    void deveCalcularFaturamentoHistoricoTotal()
            throws Exception {

        assertValor(
            "350.00",
            totalHistorico(dao.carregar())
        );
    }

    @Test
    void deveCalcularFaturamentoDoMesAtual()
            throws Exception {

        LocalDate hoje = hojeBanco();

        YearMonth atual = YearMonth.from(hoje);

        BigDecimal esperado = new BigDecimal("160.00");

        if (YearMonth.from(hoje.minusDays(2)).equals(atual)) {
            esperado = esperado.add(new BigDecimal("90.00"));
        }

        if (YearMonth.from(hoje.minusDays(20)).equals(atual)) {
            esperado = esperado.add(new BigDecimal("100.00"));
        }

        assertEquals(
            0,
            esperado.compareTo(
                dao.carregar().faturamentoMensal()
            )
        );
    }

    @Test
    void deveManterFaturamentoMensalIgualAoUltimoMesHistorico()
            throws Exception {

        Dashboard dashboard = dao.carregar();

        assertEquals(
            0,
            dashboard.faturamentoMensal().compareTo(
                dashboard.faturamentoHistorico()
                    .getLast()
                    .valor()
            )
        );
    }

    @Test
    void deveAtualizarFaturamentoAposPagamento()
            throws Exception {

        Dashboard anterior = dao.carregar();

        assertTrue(
            pagamentoDAO.realizarPagamento(501, 101, "PIX")
        );

        Dashboard atual = dao.carregar();

        assertEquals(
            0,
            anterior.faturamentoMensal()
                .add(new BigDecimal("50.00"))
                .compareTo(atual.faturamentoMensal())
        );

        assertValor(
            "400.00",
            totalHistorico(atual)
        );
    }

    @Test
    void devePreservarFaturamentoDePagamentosArquivados()
            throws Exception {

        Dashboard anterior = dao.carregar();

        assertTrue(pagamentoDAO.arquivarPagamento(704));

        Dashboard atual = dao.carregar();

        assertEquals(
            0,
            anterior.faturamentoMensal()
                .compareTo(atual.faturamentoMensal())
        );

        assertValor(
            "350.00",
            totalHistorico(atual)
        );
    }

    @Test
    void deveIgnorarPagamentosForaDosUltimosSeisMeses()
            throws Exception {

        executarSqlTeste("""
            UPDATE pagamento
            SET data_pagamento =
                DATE_SUB(CURDATE(), INTERVAL 7 MONTH)
            WHERE id_pagamento = 706
            """);

        assertValor(
            "250.00",
            totalHistorico(dao.carregar())
        );
    }

    @Test
    void deveIgnorarPagamentosDoProximoMes()
            throws Exception {

        executarSqlTeste("""
            UPDATE pagamento
            SET data_pagamento =
                DATE_ADD(LAST_DAY(CURDATE()), INTERVAL 1 DAY)
            WHERE id_pagamento = 702
            """);

        assertValor(
            "270.00",
            totalHistorico(dao.carregar())
        );
    }

    @Test
    void deveIncluirPrimeiroDiaDoPeriodoHistorico()
            throws Exception {

        LocalDate primeiroDia = YearMonth.from(hojeBanco())
            .minusMonths(5)
            .atDay(1);

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement("""
                UPDATE pagamento
                SET data_pagamento = ?
                WHERE id_pagamento = 706
                """)
        ) {

            comando.setTimestamp(
                1,
                java.sql.Timestamp.valueOf(
                    primeiroDia.atStartOfDay()
                )
            );

            assertEquals(1, comando.executeUpdate());
        }

        Dashboard dashboard = dao.carregar();

        assertValor(
            "100.00",
            dashboard.faturamentoHistorico()
                .getFirst()
                .valor()
        );

        assertValor("350.00", totalHistorico(dashboard));
    }

    @Test
    void deveListarAgendamentosFuturosDoSeed()
            throws Exception {

        List<Integer> ids = proximosIds(dao.carregar());

        assertTrue(ids.contains(501));
        assertTrue(ids.contains(502));
    }

    @Test
    void deveApresentarDadosDosProximosAgendamentos()
            throws Exception {

        Dashboard.ProximoAgendamento item =
            dao.carregar().proximosAgendamentos()
                .stream()
                .filter(a -> a.idAgendamento() == 501)
                .findFirst()
                .orElseThrow();

        assertEquals("Cliente Teste Ativo", item.cliente());

        assertEquals(
            "Volkswagen Polo - TST1A01",
            item.veiculo()
        );

        assertEquals(
            hojeBanco().plusDays(1),
            item.data()
        );

        assertEquals(
            LocalTime.of(9, 0),
            item.horario()
        );

        assertTrue(
            item.servicos().contains("Lavagem Simples Teste")
        );
    }

    @Test
    void deveOrdenarProximosAgendamentosCronologicamente()
            throws Exception {

        List<Dashboard.ProximoAgendamento> itens =
            dao.carregar().proximosAgendamentos();

        for (int i = 1; i < itens.size(); i++) {

            var anterior = itens.get(i - 1);
            var atual = itens.get(i);

            assertFalse(
                atual.data().atTime(atual.horario())
                    .isBefore(
                        anterior.data()
                            .atTime(anterior.horario())
                    )
            );
        }
    }

    @Test
    void deveLimitarProximosAgendamentosApenasCinco()
            throws Exception {

        LocalDate hoje = hojeBanco();

        for (int i = 2; i <= 8; i++) {

            novoAgendamento(
                hoje.plusDays(i),
                LocalTime.of(14, 0),
                301
            );
        }

        assertEquals(
            5,
            dao.carregar().proximosAgendamentos().size()
        );
    }

    @Test
    void deveExcluirAgendamentoCanceladoDosProximos()
            throws Exception {

        agendamentoDAO.cancelar(501);

        List<Integer> ids = proximosIds(dao.carregar());

        assertFalse(ids.contains(501));
        assertTrue(ids.contains(502));
    }

    @Test
    void deveExcluirAgendamentosConcluidosDosProximos()
            throws Exception {

        atendimentoDAO.iniciarLavagem(602);
        atendimentoDAO.finalizar(602);

        assertFalse(
            proximosIds(dao.carregar()).contains(502)
        );
    }

    @Test
    void deveExcluirAgendamentosArquivadosDosProximos()
            throws Exception {

        List<Integer> ids = proximosIds(dao.carregar());

        assertFalse(ids.contains(506));
    }

    @Test
    void deveExcluirAgendamentosDeDiasAnteriores()
            throws Exception {

        Agendamento agendamento = novoAgendamento(
            hojeBanco().minusDays(1),
            LocalTime.of(14, 0),
            301
        );

        assertFalse(
            proximosIds(dao.carregar())
                .contains(agendamento.getIdAgendamento())
        );
    }

    @Test
    void deveExibirMultiplosServicosNosProximosAgendamentos()
            throws Exception {

        Agendamento agendamento = novoAgendamento(
            hojeBanco().plusDays(2),
            LocalTime.of(14, 0),
            301, 302
        );

        Dashboard.ProximoAgendamento item =
            dao.carregar().proximosAgendamentos()
                .stream()
                .filter(a -> a.idAgendamento()
                    == agendamento.getIdAgendamento())
                .findFirst()
                .orElseThrow();

        assertTrue(
            item.servicos().contains("Lavagem Simples Teste")
        );

        assertTrue(
            item.servicos().contains("Lavagem Completa Teste")
        );
    }

    @Test
    void deveCarregarDashboardComBancoVazio()
            throws Exception {

        AmbienteTeste.validarAmbiente();

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement()
        ) {

            conexao.setAutoCommit(false);

            try {

                comando.executeUpdate(
                    "DELETE FROM colaborador_atendimento"
                );

                comando.executeUpdate("DELETE FROM pagamento");
                comando.executeUpdate("DELETE FROM atendimento");

                comando.executeUpdate(
                    "DELETE FROM agendamento_servico"
                );

                comando.executeUpdate("DELETE FROM agendamento");
                comando.executeUpdate("DELETE FROM veiculo");
                comando.executeUpdate("DELETE FROM servico");
                comando.executeUpdate("DELETE FROM colaborador");
                comando.executeUpdate("DELETE FROM cliente");

                conexao.commit();

            } catch (SQLException e) {

                conexao.rollback();
                throw e;
            }
        }

        Dashboard dashboard = dao.carregar();

        assertEquals(0, dashboard.clientesAtivos());
        assertEquals(0, dashboard.veiculosAtivos());
        assertEquals(0, dashboard.servicosAtivos());
        assertEquals(0, dashboard.colaboradoresAtivos());

        assertEquals(0, dashboard.agendamentosHoje());
        assertEquals(0, dashboard.atendimentosAguardando());
        assertEquals(0, dashboard.atendimentosEmLavagem());
        assertEquals(0, dashboard.atendimentosFinalizados());

        assertEquals(0, dashboard.pagamentosPendentes());

        assertValor("0.00", dashboard.valoresAReceber());
        assertValor("0.00", dashboard.faturamentoMensal());
        assertValor("0.00", totalHistorico(dashboard));

        assertEquals(6, dashboard.faturamentoHistorico().size());
        assertTrue(dashboard.proximosAgendamentos().isEmpty());

        for (var mes : dashboard.faturamentoHistorico()) {
            assertValor("0.00", mes.valor());
        }
    }

    @Test
    void deveRetornarHistoricoImutavel()
            throws Exception {

        Dashboard dashboard = dao.carregar();

        assertThrows(
            UnsupportedOperationException.class,
            () -> dashboard.faturamentoHistorico().clear()
        );
    }

    @Test
    void deveRetornarProximosAgendamentosImutaveis()
            throws Exception {

        Dashboard dashboard = dao.carregar();

        assertThrows(
            UnsupportedOperationException.class,
            () -> dashboard.proximosAgendamentos().clear()
        );
    }
}
