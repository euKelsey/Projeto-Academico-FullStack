package com.fastsplash.web.negocio;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.dao.DashboardDAO;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;

import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Veiculo;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Dashboard;

import com.fastsplash.web.util.SenhaUtil;

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

import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

class ConcorrenciaIT {

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private final VeiculoDAO veiculoDAO =
        new VeiculoDAO();

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private final PagamentoDAO pagamentoDAO =
        new PagamentoDAO();

    private final DashboardDAO dashboardDAO =
        new DashboardDAO();

    @BeforeAll
    static void protegerAmbiente() throws Exception {

        AmbienteTeste.validarAmbiente();

        try (Connection conexao = AmbienteTeste.conectar()) {

            assertEquals(
                "fast_splash_test",
                conexao.getCatalog()
            );
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

    @FunctionalInterface
    private interface OperacaoSQL {
        void executar() throws SQLException;
    }

    private List<Boolean> executarSimultaneamente(
            Callable<Boolean> primeira,
            Callable<Boolean> segunda
    ) throws Exception {

        ExecutorService executor =
            Executors.newFixedThreadPool(2);

        CountDownLatch preparadas =
            new CountDownLatch(2);

        CountDownLatch iniciar =
            new CountDownLatch(1);

        Future<Boolean> resultadoA = null;
        Future<Boolean> resultadoB = null;

        try {

            resultadoA = executor.submit(() -> {

                preparadas.countDown();

                if (!iniciar.await(10, TimeUnit.SECONDS)) {

                    throw new IllegalStateException(
                        "Thread A nao recebeu liberacao."
                    );
                }

                return primeira.call();
            });

            resultadoB = executor.submit(() -> {

                preparadas.countDown();

                if (!iniciar.await(10, TimeUnit.SECONDS)) {

                    throw new IllegalStateException(
                        "Thread B nao recebeu liberacao."
                    );
                }

                return segunda.call();
            });

            assertTrue(
                preparadas.await(10, TimeUnit.SECONDS),
                "As duas threads precisam estar preparadas."
            );

            iniciar.countDown();

            return List.of(
                resultadoA.get(30, TimeUnit.SECONDS),
                resultadoB.get(30, TimeUnit.SECONDS)
            );

        } finally {

            iniciar.countDown();

            if (resultadoA != null) {
                resultadoA.cancel(true);
            }

            if (resultadoB != null) {
                resultadoB.cancel(true);
            }

            executor.shutdownNow();

            assertTrue(
                executor.awaitTermination(
                    60, TimeUnit.SECONDS
                ),
                "As threads nao foram encerradas."
            );
        }
    }

    private boolean tentarInsercao(
            OperacaoSQL operacao
    ) throws SQLException {

        try {

            operacao.executar();

            return true;

        } catch (SQLException e) {

            // 1062: violacao de chave unica no MySQL.
            // Outros erros nao devem ser considerados sucesso.

            if (e.getErrorCode() == 1062) {
                return false;
            }

            throw e;
        }
    }

    private boolean tentarTransicao(
            OperacaoSQL operacao
    ) throws SQLException {

        try {

            operacao.executar();

            return true;

        } catch (SQLException e) {

            // Rejeicao de negocio gerada pelo proprio DAO,
            // sem codigo de erro do servidor MySQL.

            if (e.getErrorCode() == 0
                    && e.getSQLState() == null
                    && e.getCause() == null) {

                return false;
            }

            throw e;
        }
    }

    private void assertApenasUmSucesso(
            List<Boolean> resultados
    ) {

        assertEquals(2, resultados.size());

        assertEquals(
            1L,
            resultados.stream()
                .filter(Boolean.TRUE::equals)
                .count()
        );

        assertEquals(
            1L,
            resultados.stream()
                .filter(Boolean.FALSE::equals)
                .count()
        );
    }

    private long contar(
            String sql,
            Object... parametros
    ) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement(sql)
        ) {

            for (int i = 0; i < parametros.length; i++) {

                comando.setObject(
                    i + 1,
                    parametros[i]
                );
            }

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                return resultado.getLong(1);
            }
        }
    }

    private LocalDate hojeBanco() throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery(
                "SELECT CURDATE()"
            )
        ) {

            assertTrue(resultado.next());

            return resultado.getDate(1).toLocalDate();
        }
    }

    private Cliente prepararCliente(
            String nome,
            String email,
            String hash
    ) {

        Cliente cliente = new Cliente();

        cliente.setNome(nome);
        cliente.setCpf("98765410564");
        cliente.setTelefone("11900000105");
        cliente.setEmail(email);
        cliente.setSenhaHash(hash);

        return cliente;
    }

    private Veiculo prepararVeiculo(
            int idCliente
    ) {

        Veiculo veiculo = new Veiculo();

        veiculo.setIdCliente(idCliente);
        veiculo.setPlaca("TST1B01");
        veiculo.setMarca("FIAT");
        veiculo.setModelo("ARGO");
        veiculo.setCor("PRATA");

        return veiculo;
    }

    private Agendamento prepararAgendamento(
            int idVeiculo,
            LocalDate data
    ) {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(idVeiculo);
        agendamento.setData(data);
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(301, 302));

        return agendamento;
    }

    private int novoAgendamento() throws Exception {

        Agendamento agendamento = prepararAgendamento(
            203,
            hojeBanco().plusDays(2)
        );

        agendamentoDAO.inserir(agendamento);

        return agendamento.getIdAgendamento();
    }

    private int novoAtendimento(
            int idAgendamento
    ) throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(idAgendamento);

        atendimentoDAO.inserir(atendimento);

        return atendimento.getIdAtendimento();
    }

    @Test
    void deveImpedirCpfDuplicadoEmCadastrosSimultaneos()
            throws Exception {

        String hash = SenhaUtil.gerarHash(
            "SenhaFicticia@123"
        );

        Cliente primeiro = prepararCliente(
            "CLIENTE CONCORRENTE A",
            "concorrente.a@example.test",
            hash
        );

        Cliente segundo = prepararCliente(
            "CLIENTE CONCORRENTE B",
            "concorrente.b@example.test",
            hash
        );

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarInsercao(
                () -> new ClienteDAO().inserir(primeiro)
            ),

            () -> tentarInsercao(
                () -> new ClienteDAO().inserir(segundo)
            )
        );

        assertApenasUmSucesso(resultados);

        assertEquals(
            1L,
            contar("""
                SELECT COUNT(*)
                FROM cliente
                WHERE cpf = ?
                """, "98765410564")
        );

        assertEquals(
            3,
            dashboardDAO.carregar().clientesAtivos()
        );

        String emailVencedor = resultados.get(0)
            ? primeiro.getEmail()
            : segundo.getEmail();

        assertNotNull(
            clienteDAO.buscarPorEmail(emailVencedor)
        );
    }

    @Test
    void deveImpedirPlacaDuplicadaEmCadastrosSimultaneos()
            throws Exception {

        Veiculo primeiro = prepararVeiculo(101);
        Veiculo segundo = prepararVeiculo(102);

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarInsercao(
                () -> new VeiculoDAO().inserir(primeiro)
            ),

            () -> tentarInsercao(
                () -> new VeiculoDAO().inserir(segundo)
            )
        );

        assertApenasUmSucesso(resultados);

        assertEquals(
            1L,
            contar("""
                SELECT COUNT(*)
                FROM veiculo
                WHERE placa = ?
                """, "TST1B01")
        );

        assertEquals(
            4,
            dashboardDAO.carregar().veiculosAtivos()
        );

        Veiculo vencedor = resultados.get(0)
            ? primeiro
            : segundo;

        assertEquals(
            vencedor.getIdCliente(),
            veiculoDAO.buscarPorId(
                vencedor.getIdVeiculo()
            ).getIdCliente()
        );
    }

    @Test
    void deveImpedirAgendamentosDuplicadosSimultaneos()
            throws Exception {

        LocalDate data = hojeBanco().plusDays(2);

        Agendamento primeiro =
            prepararAgendamento(203, data);

        Agendamento segundo =
            prepararAgendamento(203, data);

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarInsercao(
                () -> new AgendamentoDAO().inserir(primeiro)
            ),

            () -> tentarInsercao(
                () -> new AgendamentoDAO().inserir(segundo)
            )
        );

        assertApenasUmSucesso(resultados);

        assertEquals(
            1L,
            contar("""
                SELECT COUNT(*)
                FROM agendamento
                WHERE id_veiculo = ?
                  AND data = ?
                  AND horario = ?
                """,
                203,
                data,
                LocalTime.of(14, 0)
            )
        );

        assertEquals(
            2L,
            contar("""
                SELECT COUNT(*)
                FROM agendamento_servico ags
                INNER JOIN agendamento a
                    ON a.id_agendamento = ags.id_agendamento
                WHERE a.id_veiculo = ?
                  AND a.data = ?
                  AND a.horario = ?
                """,
                203,
                data,
                LocalTime.of(14, 0)
            )
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(2, dashboard.pagamentosPendentes());

        assertEquals(
            0,
            new BigDecimal("180.00")
                .compareTo(dashboard.valoresAReceber())
        );
    }

    @Test
    void deveImpedirPagamentosDuplicadosSimultaneos()
            throws Exception {

        Dashboard inicial = dashboardDAO.carregar();

        int idAgendamento = novoAgendamento();

        List<Boolean> resultados = executarSimultaneamente(

            () -> new PagamentoDAO().realizarPagamento(
                idAgendamento, 102, "PIX"
            ),

            () -> new PagamentoDAO().realizarPagamento(
                idAgendamento, 102, "CREDITO"
            )
        );

        assertApenasUmSucesso(resultados);

        assertEquals(
            1L,
            contar("""
                SELECT COUNT(*)
                FROM pagamento
                WHERE id_agendamento = ?
                  AND status_pagamento = 'PAGO'
                """, idAgendamento)
        );

        var pagamento = pagamentoDAO.listarPorCliente(102)
            .stream()
            .filter(p ->
                p.getIdAgendamento() == idAgendamento
            )
            .findFirst()
            .orElseThrow();

        assertEquals(
            resultados.get(0) ? "PIX" : "CREDITO",
            pagamento.getFormaPagamento()
        );

        assertEquals(
            130.00,
            pagamento.getValor(),
            0.001
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            0,
            inicial.faturamentoMensal()
                .add(new BigDecimal("130.00"))
                .compareTo(atual.faturamentoMensal())
        );

        assertEquals(
            inicial.pagamentosPendentes(),
            atual.pagamentosPendentes()
        );

        assertEquals(
            0,
            inicial.valoresAReceber()
                .compareTo(atual.valoresAReceber())
        );
    }

    @Test
    void deveImpedirAtendimentosDuplicadosSimultaneos()
            throws Exception {

        int idAgendamento = novoAgendamento();

        Atendimento primeiro = new Atendimento();
        primeiro.setIdAgendamento(idAgendamento);

        Atendimento segundo = new Atendimento();
        segundo.setIdAgendamento(idAgendamento);

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarInsercao(
                () -> new AtendimentoDAO().inserir(primeiro)
            ),

            () -> tentarInsercao(
                () -> new AtendimentoDAO().inserir(segundo)
            )
        );

        assertApenasUmSucesso(resultados);

        assertEquals(
            1L,
            contar("""
                SELECT COUNT(*)
                FROM atendimento
                WHERE id_agendamento = ?
                """, idAgendamento)
        );

        assertEquals(
            3,
            dashboardDAO.carregar()
                .atendimentosAguardando()
        );
    }

    @Test
    void devePermitirSomenteUmInicioSimultaneo()
            throws Exception {

        int idAgendamento = novoAgendamento();

        int idAtendimento =
            novoAtendimento(idAgendamento);

        assertTrue(
            pagamentoDAO.realizarPagamento(
                idAgendamento, 102, "PIX"
            )
        );

        Dashboard anterior = dashboardDAO.carregar();

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarTransicao(
                () -> new AtendimentoDAO()
                    .iniciarLavagem(idAtendimento)
            ),

            () -> tentarTransicao(
                () -> new AtendimentoDAO()
                    .iniciarLavagem(idAtendimento)
            )
        );

        assertApenasUmSucesso(resultados);

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(idAtendimento);

        assertEquals("EM_LAVAGEM", atendimento.getStatus());
        assertNotNull(atendimento.getDataInicio());
        assertNull(atendimento.getDataFim());

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.atendimentosAguardando() - 1,
            atual.atendimentosAguardando()
        );

        assertEquals(
            anterior.atendimentosEmLavagem() + 1,
            atual.atendimentosEmLavagem()
        );
    }

    @Test
    void devePermitirSomenteUmaFinalizacaoSimultanea()
            throws Exception {

        int idAgendamento = novoAgendamento();

        int idAtendimento =
            novoAtendimento(idAgendamento);

        assertTrue(
            pagamentoDAO.realizarPagamento(
                idAgendamento, 102, "PIX"
            )
        );

        atendimentoDAO.iniciarLavagem(idAtendimento);

        var inicio = atendimentoDAO
            .buscarPorId(idAtendimento)
            .getDataInicio();

        Dashboard anterior = dashboardDAO.carregar();

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarTransicao(
                () -> new AtendimentoDAO()
                    .finalizar(idAtendimento)
            ),

            () -> tentarTransicao(
                () -> new AtendimentoDAO()
                    .finalizar(idAtendimento)
            )
        );

        assertApenasUmSucesso(resultados);

        Atendimento atendimento =
            atendimentoDAO.buscarPorId(idAtendimento);

        assertEquals(
            "FINALIZADO",
            atendimento.getStatus()
        );

        assertEquals(
            inicio,
            atendimento.getDataInicio()
        );

        assertNotNull(atendimento.getDataFim());

        assertFalse(
            atendimento.getDataFim().isBefore(inicio)
        );

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(
                idAgendamento
            ).getStatus()
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.atendimentosEmLavagem() - 1,
            atual.atendimentosEmLavagem()
        );

        assertEquals(
            anterior.atendimentosFinalizados() + 1,
            atual.atendimentosFinalizados()
        );

        assertEquals(
            0,
            anterior.faturamentoMensal()
                .compareTo(atual.faturamentoMensal())
        );
    }

    @Test
    void devePermitirAgendamentosIndependentesSimultaneos()
            throws Exception {

        LocalDate data = hojeBanco().plusDays(2);

        Agendamento primeiro =
            prepararAgendamento(201, data);

        Agendamento segundo =
            prepararAgendamento(203, data);

        List<Boolean> resultados = executarSimultaneamente(

            () -> tentarInsercao(
                () -> new AgendamentoDAO().inserir(primeiro)
            ),

            () -> tentarInsercao(
                () -> new AgendamentoDAO().inserir(segundo)
            )
        );

        assertEquals(
            List.of(true, true),
            resultados
        );

        assertNotEquals(
            primeiro.getIdAgendamento(),
            segundo.getIdAgendamento()
        );

        assertNotNull(
            agendamentoDAO.buscarPorId(
                primeiro.getIdAgendamento()
            )
        );

        assertNotNull(
            agendamentoDAO.buscarPorId(
                segundo.getIdAgendamento()
            )
        );

        assertEquals(
            2L,
            contar("""
                SELECT COUNT(*)
                FROM agendamento
                WHERE id_veiculo IN (201, 203)
                  AND data = ?
                  AND horario = ?
                """,
                data,
                LocalTime.of(14, 0)
            )
        );

        assertEquals(
            4L,
            contar("""
                SELECT COUNT(*)
                FROM agendamento_servico ags
                INNER JOIN agendamento a
                    ON a.id_agendamento = ags.id_agendamento
                WHERE a.id_veiculo IN (201, 203)
                  AND a.data = ?
                  AND a.horario = ?
                """,
                data,
                LocalTime.of(14, 0)
            )
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(
            3,
            dashboard.pagamentosPendentes()
        );

        assertEquals(
            0,
            new BigDecimal("310.00")
                .compareTo(dashboard.valoresAReceber())
        );
    }
}
