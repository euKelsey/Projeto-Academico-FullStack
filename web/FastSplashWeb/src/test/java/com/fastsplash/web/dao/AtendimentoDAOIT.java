package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class AtendimentoDAOIT {

    private final AtendimentoDAO dao = new AtendimentoDAO();
    private final AgendamentoDAO agendamentoDAO = new AgendamentoDAO();

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

    private Agendamento novoAgendamento(
            int dias,
            Integer... servicos
    ) throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(LocalDate.now().plusDays(dias));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(servicos));

        agendamentoDAO.inserir(agendamento);

        return agendamento;
    }

    private Atendimento criarAtendimento(
            int idAgendamento
    ) throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(idAgendamento);

        dao.inserir(atendimento);

        return atendimento;
    }

    private void executarSqlTeste(String sql) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement()
        ) {
            comando.executeUpdate(sql);
        }
    }

    private List<Integer> idsPorStatus(
            String status
    ) throws Exception {

        return dao.listarPorStatus(status)
            .stream()
            .map(Atendimento::getIdAtendimento)
            .toList();
    }

    @Test
    void deveCriarAtendimento() throws Exception {

        Agendamento agendamento = novoAgendamento(5, 301);

        Atendimento atendimento = criarAtendimento(
            agendamento.getIdAgendamento()
        );

        assertTrue(atendimento.getIdAtendimento() > 0);

        Atendimento salvo = dao.buscarPorId(
            atendimento.getIdAtendimento()
        );

        assertNotNull(salvo);

        assertEquals(
            agendamento.getIdAgendamento(),
            salvo.getIdAgendamento()
        );

        assertEquals("AGUARDANDO", salvo.getStatus());
        assertNull(salvo.getDataInicio());
        assertNull(salvo.getDataFim());
        assertFalse(salvo.isArquivado());
    }

    @Test
    void deveImpedirAtendimentoDuplicado() throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(501);

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(atendimento)
        );

        assertEquals(1062, erro.getErrorCode());
        assertEquals(5, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtendimentoDeAgendamentoInexistente()
            throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(999999);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(atendimento)
        );

        assertEquals(5, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtendimentoDeAgendamentoCancelado()
            throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(505);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(atendimento)
        );

        assertEquals(5, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtendimentoDeAgendamentoConcluido()
            throws Exception {

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(504);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(atendimento)
        );

        assertEquals(5, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtendimentoDeAgendamentoArquivado()
            throws Exception {

        assertTrue(agendamentoDAO.arquivarAgendamento(505));

        Atendimento atendimento = new Atendimento();

        atendimento.setIdAgendamento(505);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(atendimento)
        );
    }

    @Test
    void deveBuscarAtendimentoPorId() throws Exception {

        Atendimento atendimento = dao.buscarPorId(601);

        assertNotNull(atendimento);
        assertEquals(601, atendimento.getIdAtendimento());
        assertEquals(501, atendimento.getIdAgendamento());
        assertEquals("AGUARDANDO", atendimento.getStatus());
    }

    @Test
    void deveRetornarNuloParaAtendimentoInexistente()
            throws Exception {

        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveRetornarDadosDoClienteEVeiculo() throws Exception {

        Atendimento atendimento = dao.buscarPorId(601);

        assertEquals(
            "Cliente Teste Ativo",
            atendimento.getClienteNome()
        );

        assertEquals(
            "Volkswagen Polo - TST1A01",
            atendimento.getVeiculoDescricao()
        );
    }

    @Test
    void deveRetornarMultiplosServicosContratados()
            throws Exception {

        Atendimento atendimento = dao.buscarPorId(604);

        assertTrue(
            atendimento.getServicosDescricao()
                .contains("Lavagem Simples Teste")
        );

        assertTrue(
            atendimento.getServicosDescricao()
                .contains("Enceramento Teste")
        );
    }

    @Test
    void deveListarTodosIncluindoArquivados()
            throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Atendimento::getIdAtendimento)
            .toList();

        assertEquals(
            List.of(605, 604, 603, 602, 601),
            ids
        );
    }

    @Test
    void deveFiltrarAtendimentosAguardando() throws Exception {

        assertEquals(
            List.of(602, 601),
            idsPorStatus("aguardando")
        );
    }

    @Test
    void deveFiltrarAtendimentosEmLavagem() throws Exception {

        assertEquals(
            List.of(603),
            idsPorStatus("emLavagem")
        );
    }

    @Test
    void deveFiltrarAtendimentosFinalizados() throws Exception {

        assertEquals(
            List.of(604),
            idsPorStatus("finalizados")
        );
    }

    @Test
    void deveFiltrarAtendimentosArquivados() throws Exception {

        assertEquals(
            List.of(605),
            idsPorStatus("arquivados")
        );
    }

    @Test
    void deveUtilizarFiltroAguardandoComoPadrao()
            throws Exception {

        assertEquals(
            List.of(602, 601),
            idsPorStatus(null)
        );

        assertEquals(
            List.of(602, 601),
            idsPorStatus("desconhecido")
        );
    }

    @Test
    void deveRetornarListaVaziaSemAgendamentosDisponiveis()
            throws Exception {

        assertTrue(
            dao.listarAgendamentosDisponiveis().isEmpty()
        );
    }

    @Test
    void deveListarNovoAgendamentoDisponivel()
            throws Exception {

        Agendamento agendamento = novoAgendamento(5, 301);

        List<Agendamento> disponiveis =
            dao.listarAgendamentosDisponiveis();

        assertEquals(1, disponiveis.size());

        Agendamento item = disponiveis.get(0);

        assertEquals(
            agendamento.getIdAgendamento(),
            item.getIdAgendamento()
        );

        assertEquals(203, item.getIdVeiculo());
        assertEquals("AGENDADO", item.getStatus());
        assertEquals(50.00, item.getValorTotal(), 0.001);
    }

    @Test
    void deveListarAgendamentosDisponiveisEmOrdemCronologica()
            throws Exception {

        Agendamento posterior = novoAgendamento(6, 301);
        Agendamento anterior = novoAgendamento(5, 302);

        List<Integer> ids =
            dao.listarAgendamentosDisponiveis()
                .stream()
                .map(Agendamento::getIdAgendamento)
                .toList();

        assertEquals(
            List.of(
                anterior.getIdAgendamento(),
                posterior.getIdAgendamento()
            ),
            ids
        );
    }

    @Test
    void deveRemoverAgendamentoDaListaAposCriarAtendimento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(5, 301);

        assertEquals(
            1,
            dao.listarAgendamentosDisponiveis().size()
        );

        criarAtendimento(agendamento.getIdAgendamento());

        assertTrue(
            dao.listarAgendamentosDisponiveis().isEmpty()
        );
    }

    @Test
    void deveRemoverAgendamentoCanceladoDaListaDisponivel()
            throws Exception {

        Agendamento agendamento = novoAgendamento(5, 301);

        agendamentoDAO.cancelar(
            agendamento.getIdAgendamento()
        );

        assertTrue(
            dao.listarAgendamentosDisponiveis().isEmpty()
        );
    }

    @Test
    void deveSomarServicosDoAgendamentoDisponivel()
            throws Exception {

        novoAgendamento(5, 301, 302);

        Agendamento agendamento =
            dao.listarAgendamentosDisponiveis().get(0);

        assertEquals(
            130.00,
            agendamento.getValorTotal(),
            0.001
        );
    }

    @Test
    void deveImpedirInicioComPagamentoPendente()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(601)
        );

        Atendimento atendimento = dao.buscarPorId(601);

        assertEquals("AGUARDANDO", atendimento.getStatus());
        assertNull(atendimento.getDataInicio());
    }

    @Test
    void deveImpedirInicioSemRegistroDePagamento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(5, 301);

        Atendimento atendimento = criarAtendimento(
            agendamento.getIdAgendamento()
        );

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(
                atendimento.getIdAtendimento()
            )
        );

        assertEquals(
            "AGUARDANDO",
            dao.buscarPorId(
                atendimento.getIdAtendimento()
            ).getStatus()
        );
    }

    @Test
    void deveImpedirInicioComPagamentoCancelado()
            throws Exception {

        executarSqlTeste("""
            UPDATE pagamento
            SET status_pagamento = 'CANCELADO',
                data_pagamento = NULL,
                forma_pagamento = NULL
            WHERE id_agendamento = 501
            """);

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(601)
        );

        assertEquals(
            "AGUARDANDO",
            dao.buscarPorId(601).getStatus()
        );
    }

    @Test
    void deveIniciarLavagemComPagamentoConfirmado()
            throws Exception {

        dao.iniciarLavagem(602);

        Atendimento atendimento = dao.buscarPorId(602);

        assertEquals("EM_LAVAGEM", atendimento.getStatus());
        assertNotNull(atendimento.getDataInicio());
        assertNull(atendimento.getDataFim());
    }

    @Test
    void devePermitirInicioAposConfirmacaoDoPagamento()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(601)
        );

        executarSqlTeste("""
            UPDATE pagamento
            SET status_pagamento = 'PAGO',
                data_pagamento = NOW(),
                forma_pagamento = 'PIX'
            WHERE id_agendamento = 501
            """);

        dao.iniciarLavagem(601);

        assertEquals(
            "EM_LAVAGEM",
            dao.buscarPorId(601).getStatus()
        );
    }

    @Test
    void deveImpedirInicioDuplicado() throws Exception {

        dao.iniciarLavagem(602);

        LocalDateTime inicio =
            dao.buscarPorId(602).getDataInicio();

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(602)
        );

        assertEquals(
            inicio,
            dao.buscarPorId(602).getDataInicio()
        );
    }

    @Test
    void deveImpedirInicioDeAtendimentoFinalizado()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(604)
        );

        assertEquals(
            "FINALIZADO",
            dao.buscarPorId(604).getStatus()
        );
    }

    @Test
    void deveImpedirInicioDeAtendimentoArquivado()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(605)
        );

        assertTrue(dao.buscarPorId(605).isArquivado());
    }

    @Test
    void deveImpedirInicioDeAtendimentoInexistente() {

        assertThrows(
            SQLException.class,
            () -> dao.iniciarLavagem(999999)
        );
    }

    @Test
    void deveImpedirFinalizacaoSemInicio()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.finalizar(602)
        );

        Atendimento atendimento = dao.buscarPorId(602);

        assertEquals("AGUARDANDO", atendimento.getStatus());
        assertNull(atendimento.getDataFim());

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(502).getStatus()
        );
    }

    @Test
    void deveFinalizarLavagem() throws Exception {

        dao.iniciarLavagem(602);
        dao.finalizar(602);

        Atendimento atendimento = dao.buscarPorId(602);

        assertEquals("FINALIZADO", atendimento.getStatus());
        assertNotNull(atendimento.getDataInicio());
        assertNotNull(atendimento.getDataFim());

        assertFalse(
            atendimento.getDataFim()
                .isBefore(atendimento.getDataInicio())
        );
    }

    @Test
    void deveConcluirAgendamentoAposFinalizacao()
            throws Exception {

        dao.iniciarLavagem(602);
        dao.finalizar(602);

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(502).getStatus()
        );
    }

    @Test
    void devePreservarHorarioDeInicioAposFinalizacao()
            throws Exception {

        dao.iniciarLavagem(602);

        LocalDateTime inicio =
            dao.buscarPorId(602).getDataInicio();

        dao.finalizar(602);

        assertEquals(
            inicio,
            dao.buscarPorId(602).getDataInicio()
        );
    }

    @Test
    void deveImpedirFinalizacaoDuplicada()
            throws Exception {

        dao.iniciarLavagem(602);
        dao.finalizar(602);

        LocalDateTime fim =
            dao.buscarPorId(602).getDataFim();

        assertThrows(
            SQLException.class,
            () -> dao.finalizar(602)
        );

        assertEquals(
            fim,
            dao.buscarPorId(602).getDataFim()
        );
    }

    @Test
    void deveImpedirFinalizacaoDeAtendimentoArquivado()
            throws Exception {

        assertThrows(
            SQLException.class,
            () -> dao.finalizar(605)
        );

        assertTrue(dao.buscarPorId(605).isArquivado());
    }

    @Test
    void deveImpedirFinalizacaoDeAtendimentoInexistente() {

        assertThrows(
            SQLException.class,
            () -> dao.finalizar(999999)
        );
    }

    @Test
    void deveReverterFinalizacaoQuandoAgendamentoFalhar()
            throws Exception {

        dao.iniciarLavagem(602);

        // Restricao temporaria exclusiva do banco de testes.
        executarSqlTeste("""
            ALTER TABLE agendamento
            ADD CONSTRAINT chk_teste_falha_finalizacao
            CHECK (
                horario <> '10:00:00'
                OR status <> 'CONCLUIDO'
            )
            """);

        try {

            assertThrows(
                SQLException.class,
                () -> dao.finalizar(602)
            );

            Atendimento atendimento = dao.buscarPorId(602);

            assertEquals(
                "EM_LAVAGEM",
                atendimento.getStatus()
            );

            assertNotNull(atendimento.getDataInicio());
            assertNull(atendimento.getDataFim());

            assertEquals(
                "AGENDADO",
                agendamentoDAO.buscarPorId(502).getStatus()
            );

        } finally {

            executarSqlTeste("""
                ALTER TABLE agendamento
                DROP CHECK chk_teste_falha_finalizacao
                """);
        }

        // Confirma que o atendimento pode ser concluido
        // normalmente depois da remocao da restricao.
        dao.finalizar(602);

        assertEquals(
            "FINALIZADO",
            dao.buscarPorId(602).getStatus()
        );

        assertEquals(
            "CONCLUIDO",
            agendamentoDAO.buscarPorId(502).getStatus()
        );
    }

    @Test
    void deveArquivarAtendimentoFinalizado()
            throws Exception {

        assertTrue(dao.arquivarAtendimento(604));

        Atendimento atendimento = dao.buscarPorId(604);

        assertTrue(atendimento.isArquivado());
        assertNotNull(atendimento.getArquivadoEm());
        assertEquals("FINALIZADO", atendimento.getStatus());
    }

    @Test
    void deveImpedirArquivamentoDeAtendimentoAguardando()
            throws Exception {

        assertFalse(dao.arquivarAtendimento(601));

        assertFalse(dao.buscarPorId(601).isArquivado());
    }

    @Test
    void deveImpedirArquivamentoDuranteLavagem()
            throws Exception {

        assertFalse(dao.arquivarAtendimento(603));

        assertFalse(dao.buscarPorId(603).isArquivado());
    }

    @Test
    void deveImpedirArquivamentoDuplicado()
            throws Exception {

        assertFalse(dao.arquivarAtendimento(605));
    }

    @Test
    void deveRestaurarAtendimentoArquivado()
            throws Exception {

        assertTrue(dao.restaurarAtendimento(605));

        Atendimento atendimento = dao.buscarPorId(605);

        assertFalse(atendimento.isArquivado());
        assertNull(atendimento.getArquivadoEm());
        assertEquals("FINALIZADO", atendimento.getStatus());
    }

    @Test
    void deveImpedirRestauracaoDeAtendimentoNaoArquivado()
            throws Exception {

        assertFalse(dao.restaurarAtendimento(604));
    }

    @Test
    void deveRetornarFalseParaIdInexistenteNoArquivamento()
            throws Exception {

        assertFalse(dao.arquivarAtendimento(999999));
        assertFalse(dao.restaurarAtendimento(999999));
    }

    @Test
    void deveAtualizarFiltrosAposArquivamentoERestauracao()
            throws Exception {

        assertTrue(dao.arquivarAtendimento(604));

        assertTrue(
            dao.listarPorStatus("finalizados").isEmpty()
        );

        assertEquals(
            2,
            dao.listarPorStatus("arquivados").size()
        );

        assertTrue(dao.restaurarAtendimento(604));

        assertEquals(
            1,
            dao.listarPorStatus("finalizados").size()
        );

        assertEquals(
            1,
            dao.listarPorStatus("arquivados").size()
        );
    }

    @Test
    void devePreservarDatasHistoricasAposArquivamento()
            throws Exception {

        Atendimento original = dao.buscarPorId(604);

        assertTrue(dao.arquivarAtendimento(604));
        assertTrue(dao.restaurarAtendimento(604));

        Atendimento restaurado = dao.buscarPorId(604);

        assertEquals(
            original.getDataInicio(),
            restaurado.getDataInicio()
        );

        assertEquals(
            original.getDataFim(),
            restaurado.getDataFim()
        );
    }

    @Test
    void devePreservarRelacionamentosAposArquivamento()
            throws Exception {

        assertTrue(dao.arquivarAtendimento(604));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM atendimento at
                JOIN agendamento a
                    ON a.id_agendamento = at.id_agendamento
                JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento
                JOIN colaborador_atendimento ca
                    ON ca.id_atendimento = at.id_atendimento
                WHERE at.id_atendimento = 604
                  AND at.arquivado_em IS NOT NULL
                  AND a.status = 'CONCLUIDO'
                  AND p.status_pagamento = 'PAGO'
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(2, resultado.getInt(1));
        }
    }

    @Test
    void devePreservarHistoricoDeClienteEVeiculoExcluidos()
            throws Exception {

        Atendimento atendimento = dao.buscarPorId(605);

        assertNotNull(atendimento);
        assertTrue(atendimento.isArquivado());

        assertEquals(
            "Cliente Teste Excluido",
            atendimento.getClienteNome()
        );

        assertEquals(
            "Chevrolet Onix - TST1A05",
            atendimento.getVeiculoDescricao()
        );

        assertEquals(
            "FINALIZADO",
            atendimento.getStatus()
        );
    }
}
