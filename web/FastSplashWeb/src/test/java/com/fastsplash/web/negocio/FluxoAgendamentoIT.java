package com.fastsplash.web.negocio;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.DashboardDAO;
import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.dao.ServicoDAO;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;

import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.AgendamentoCliente;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Dashboard;
import com.fastsplash.web.model.Pagamento;
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

class FluxoAgendamentoIT {

    private final AgendamentoDAO agendamentoDAO = new AgendamentoDAO();
    private final AtendimentoDAO atendimentoDAO = new AtendimentoDAO();
    private final PagamentoDAO pagamentoDAO = new PagamentoDAO();
    private final DashboardDAO dashboardDAO = new DashboardDAO();
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

    private Agendamento novoAgendamento(
            int idVeiculo,
            int dias,
            Integer... servicos
    ) throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(idVeiculo);
        agendamento.setData(hojeBanco().plusDays(dias));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(servicos));

        agendamentoDAO.inserir(agendamento);

        assertTrue(agendamento.getIdAgendamento() > 0);

        return agendamento;
    }

    private AgendamentoCliente consultarAgendamentoCliente(
            int idCliente,
            int idAgendamento
    ) throws Exception {

        return agendamentoDAO.listarPorCliente(idCliente)
            .stream()
            .filter(a -> a.getIdAgendamento() == idAgendamento)
            .findFirst()
            .orElseThrow();
    }

    private Pagamento consultarPagamentoCliente(
            int idCliente,
            int idAgendamento
    ) throws Exception {

        return pagamentoDAO.listarPorCliente(idCliente)
            .stream()
            .filter(p -> p.getIdAgendamento() == idAgendamento)
            .findFirst()
            .orElseThrow();
    }

    private boolean disponivelParaAtendimento(
            int idAgendamento
    ) throws Exception {

        return atendimentoDAO.listarAgendamentosDisponiveis()
            .stream()
            .anyMatch(a ->
                a.getIdAgendamento() == idAgendamento
            );
    }

    private boolean constaNosProximosAgendamentos(
            Dashboard dashboard,
            int idAgendamento
    ) {

        return dashboard.proximosAgendamentos()
            .stream()
            .anyMatch(a ->
                a.idAgendamento() == idAgendamento
            );
    }

    private void assertValor(
            String esperado,
            BigDecimal atual
    ) {

        assertEquals(
            0,
            new BigDecimal(esperado).compareTo(atual)
        );
    }

    private long contarRegistros(String tabela)
            throws Exception {

        if (!List.of(
                "agendamento",
                "agendamento_servico",
                "pagamento",
                "atendimento"
        ).contains(tabela)) {

            throw new IllegalArgumentException(
                "Tabela de teste invalida."
            );
        }

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery(
                "SELECT COUNT(*) FROM " + tabela
            )
        ) {
            assertTrue(resultado.next());
            return resultado.getLong(1);
        }
    }

    @Test
    void deveManterConsistenciaEntreConsultasDeAgendamento()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Agendamento agendamento = novoAgendamento(
            203, 2, 301, 302
        );

        int id = agendamento.getIdAgendamento();

        Agendamento administrativo =
            agendamentoDAO.buscarPorId(id);

        AgendamentoCliente cliente =
            consultarAgendamentoCliente(102, id);

        Pagamento pagamento =
            consultarPagamentoCliente(102, id);

        assertEquals(
            "AGENDADO",
            administrativo.getStatus()
        );

        assertEquals(
            administrativo.getStatus(),
            cliente.getStatusAgendamento()
        );

        assertEquals(2, cliente.getServicos().size());
        assertEquals(130.00, cliente.getValorTotal(), 0.001);

        assertEquals(
            cliente.getValorTotal(),
            pagamento.getValor(),
            0.001
        );

        assertEquals("PENDENTE", pagamento.getStatusPagamento());
        assertEquals(0, pagamento.getIdPagamento());

        assertTrue(disponivelParaAtendimento(id));

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.pagamentosPendentes() + 1,
            atual.pagamentosPendentes()
        );

        assertEquals(
            0,
            anterior.valoresAReceber()
                .add(new BigDecimal("130.00"))
                .compareTo(atual.valoresAReceber())
        );

        assertTrue(
            constaNosProximosAgendamentos(atual, id)
        );
    }

    @Test
    void deveDiferenciarPrecoHistoricoDePrecoAtual()
            throws Exception {

        Agendamento primeiro = novoAgendamento(
            203, 2, 301
        );

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(75.90);

        servicoDAO.atualizar(servico);

        Agendamento segundo = novoAgendamento(
            203, 3, 301
        );

        assertEquals(
            50.00,
            consultarAgendamentoCliente(
                102,
                primeiro.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );

        assertEquals(
            75.90,
            consultarAgendamentoCliente(
                102,
                segundo.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );

        assertEquals(
            50.00,
            consultarPagamentoCliente(
                102,
                primeiro.getIdAgendamento()
            ).getValor(),
            0.001
        );

        assertEquals(
            75.90,
            consultarPagamentoCliente(
                102,
                segundo.getIdAgendamento()
            ).getValor(),
            0.001
        );

        assertValor(
            "175.90",
            dashboardDAO.carregar().valoresAReceber()
        );
    }

    @Test
    void devePreservarContratacaoAposInativacaoDoServico()
            throws Exception {

        Agendamento anterior = novoAgendamento(
            203, 2, 301, 302
        );

        assertTrue(servicoDAO.inativarServico(301));

        assertThrows(
            SQLException.class,
            () -> novoAgendamento(203, 3, 301)
        );

        assertEquals(
            130.00,
            consultarAgendamentoCliente(
                102,
                anterior.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );

        assertEquals(
            130.00,
            consultarPagamentoCliente(
                102,
                anterior.getIdAgendamento()
            ).getValor(),
            0.001
        );

        assertTrue(
            disponivelParaAtendimento(
                anterior.getIdAgendamento()
            )
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(1, dashboard.servicosAtivos());
        assertEquals(2, dashboard.pagamentosPendentes());

        assertValor(
            "180.00",
            dashboard.valoresAReceber()
        );
    }

    @Test
    void devePreservarValoresAposExclusaoERestauracaoDoServico()
            throws Exception {

        Agendamento primeiro = novoAgendamento(
            203, 2, 301
        );

        assertTrue(servicoDAO.excluirLogicamente(301));

        assertThrows(
            SQLException.class,
            () -> novoAgendamento(203, 3, 301)
        );

        assertEquals(
            50.00,
            consultarPagamentoCliente(
                102,
                primeiro.getIdAgendamento()
            ).getValor(),
            0.001
        );

        assertTrue(servicoDAO.restaurarServico(301));

        Servico restaurado = servicoDAO.buscarPorId(301);

        restaurado.setPreco(65.00);

        servicoDAO.atualizar(restaurado);

        Agendamento segundo = novoAgendamento(
            203, 3, 301
        );

        assertEquals(
            50.00,
            consultarAgendamentoCliente(
                102,
                primeiro.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );

        assertEquals(
            65.00,
            consultarAgendamentoCliente(
                102,
                segundo.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(2, dashboard.servicosAtivos());
        assertValor("165.00", dashboard.valoresAReceber());
    }

    @Test
    void deveIsolarAgendamentosEPagamentosDeClientesDiferentes()
            throws Exception {

        Agendamento primeiro = novoAgendamento(
            201, 2, 301
        );

        Agendamento segundo = novoAgendamento(
            203, 2, 302
        );

        int idPrimeiro = primeiro.getIdAgendamento();
        int idSegundo = segundo.getIdAgendamento();

        assertNotEquals(idPrimeiro, idSegundo);

        assertFalse(
            agendamentoDAO.listarPorCliente(101)
                .stream()
                .anyMatch(a ->
                    a.getIdAgendamento() == idSegundo
                )
        );

        assertFalse(
            agendamentoDAO.listarPorCliente(102)
                .stream()
                .anyMatch(a ->
                    a.getIdAgendamento() == idPrimeiro
                )
        );

        assertFalse(
            pagamentoDAO.listarPorCliente(101)
                .stream()
                .anyMatch(p ->
                    p.getIdAgendamento() == idSegundo
                )
        );

        assertFalse(
            pagamentoDAO.listarPorCliente(102)
                .stream()
                .anyMatch(p ->
                    p.getIdAgendamento() == idPrimeiro
                )
        );

        assertFalse(
            agendamentoDAO.cancelarDoCliente(
                idPrimeiro, 102
            )
        );

        assertFalse(
            pagamentoDAO.realizarPagamento(
                idSegundo, 101, "PIX"
            )
        );

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(
                idPrimeiro
            ).getStatus()
        );

        assertEquals(
            "PENDENTE",
            consultarPagamentoCliente(
                102, idSegundo
            ).getStatusPagamento()
        );

        assertValor(
            "180.00",
            dashboardDAO.carregar().valoresAReceber()
        );
    }

    @Test
    void deveSincronizarConsultasAposCancelamento()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Agendamento agendamento = novoAgendamento(
            203, 2, 301, 302
        );

        int id = agendamento.getIdAgendamento();

        assertTrue(disponivelParaAtendimento(id));

        assertTrue(
            constaNosProximosAgendamentos(
                dashboardDAO.carregar(), id
            )
        );

        assertTrue(
            agendamentoDAO.cancelarDoCliente(id, 102)
        );

        assertEquals(
            "CANCELADO",
            consultarAgendamentoCliente(
                102, id
            ).getStatusAgendamento()
        );

        assertFalse(disponivelParaAtendimento(id));

        assertFalse(
            pagamentoDAO.listarPorCliente(102)
                .stream()
                .anyMatch(p ->
                    p.getIdAgendamento() == id
                )
        );

        assertFalse(
            pagamentoDAO.realizarPagamento(
                id, 102, "PIX"
            )
        );

        Dashboard atual = dashboardDAO.carregar();

        assertFalse(
            constaNosProximosAgendamentos(atual, id)
        );

        assertEquals(
            anterior.pagamentosPendentes(),
            atual.pagamentosPendentes()
        );

        assertEquals(
            0,
            anterior.valoresAReceber()
                .compareTo(atual.valoresAReceber())
        );

        assertEquals(
            130.00,
            consultarAgendamentoCliente(
                102, id
            ).getValorTotal(),
            0.001
        );
    }

    @Test
    void deveBloquearCancelamentoAposCriacaoDeAtendimento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(
            203, 2, 301, 302
        );

        int id = agendamento.getIdAgendamento();

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(id);

        atendimentoDAO.inserir(atendimento);

        int idAtendimento = atendimento.getIdAtendimento();

        assertFalse(
            agendamentoDAO.cancelarDoCliente(id, 102)
        );

        assertFalse(disponivelParaAtendimento(id));

        AgendamentoCliente consulta =
            consultarAgendamentoCliente(102, id);

        assertEquals(
            "AGENDADO",
            consulta.getStatusAgendamento()
        );

        assertEquals(
            "AGUARDANDO",
            consulta.getStatusAtendimento()
        );

        assertEquals(
            "AGUARDANDO",
            atendimentoDAO.buscarPorId(
                idAtendimento
            ).getStatus()
        );

        assertEquals(
            "PENDENTE",
            consultarPagamentoCliente(
                102, id
            ).getStatusPagamento()
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(3, dashboard.atendimentosAguardando());
        assertEquals(2, dashboard.pagamentosPendentes());

        assertValor(
            "180.00",
            dashboard.valoresAReceber()
        );
    }

    @Test
    void devePreservarTodosIndicadoresAposRollback()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        long totalAgendamentos =
            contarRegistros("agendamento");

        long totalServicos =
            contarRegistros("agendamento_servico");

        long totalPagamentos =
            contarRegistros("pagamento");

        long totalAtendimentos =
            contarRegistros("atendimento");

        assertThrows(
            SQLException.class,
            () -> novoAgendamento(
                203, 2, 301, 999999
            )
        );

        assertEquals(
            totalAgendamentos,
            contarRegistros("agendamento")
        );

        assertEquals(
            totalServicos,
            contarRegistros("agendamento_servico")
        );

        assertEquals(
            totalPagamentos,
            contarRegistros("pagamento")
        );

        assertEquals(
            totalAtendimentos,
            contarRegistros("atendimento")
        );

        assertTrue(
            agendamentoDAO.listarPorCliente(102).isEmpty()
        );

        assertTrue(
            pagamentoDAO.listarPorCliente(102).isEmpty()
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(anterior, atual);

        // Confirma que o rollback nao impede uma nova
        // tentativa valida na mesma data e horario.

        Agendamento valido = novoAgendamento(
            203, 2, 301, 302
        );

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(
                valido.getIdAgendamento()
            ).getStatus()
        );

        assertEquals(
            totalAgendamentos + 1,
            contarRegistros("agendamento")
        );

        assertEquals(
            totalServicos + 2,
            contarRegistros("agendamento_servico")
        );

        assertValor(
            "180.00",
            dashboardDAO.carregar().valoresAReceber()
        );
    }
}
