package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.AgendamentoCliente;
import com.fastsplash.web.model.Servico;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class AgendamentoDAOIT {

    private final AgendamentoDAO dao = new AgendamentoDAO();

    private final ClienteDAO clienteDAO = new ClienteDAO();
    private final VeiculoDAO veiculoDAO = new VeiculoDAO();
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

    private Agendamento novoAgendamento(Integer... servicos) {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(203);
        agendamento.setData(LocalDate.now().plusDays(5));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(servicos));

        return agendamento;
    }

    private int consultarQuantidade(String sql) throws Exception {

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery(sql)
        ) {
            assertTrue(resultado.next());

            return resultado.getInt(1);
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

    private void validarSeedIntacto() throws Exception {

        assertEquals(
            6,
            consultarQuantidade("SELECT COUNT(*) FROM agendamento")
        );

        assertEquals(
            7,
            consultarQuantidade(
                "SELECT COUNT(*) FROM agendamento_servico"
            )
        );
    }

    private AgendamentoCliente buscarAgendamentoDoCliente(
            int idCliente,
            int idAgendamento
    ) throws Exception {

        return dao.listarPorCliente(idCliente)
            .stream()
            .filter(a -> a.getIdAgendamento() == idAgendamento)
            .findFirst()
            .orElseThrow();
    }

    @Test
    void deveCriarAgendamento() throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        dao.inserir(agendamento);

        assertTrue(agendamento.getIdAgendamento() > 0);

        Agendamento salvo = dao.buscarPorId(
            agendamento.getIdAgendamento()
        );

        assertNotNull(salvo);
        assertEquals(203, salvo.getIdVeiculo());
        assertEquals(agendamento.getData(), salvo.getData());
        assertEquals(agendamento.getHorario(), salvo.getHorario());
        assertEquals("AGENDADO", salvo.getStatus());
        assertEquals(50.00, salvo.getValorTotal(), 0.001);
        assertFalse(salvo.isArquivado());
    }

    @Test
    void deveCriarAgendamentoComMultiplosServicos()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 302);

        dao.inserir(agendamento);

        Agendamento salvo = dao.buscarPorId(
            agendamento.getIdAgendamento()
        );

        assertEquals(130.00, salvo.getValorTotal(), 0.001);

        AgendamentoCliente item = buscarAgendamentoDoCliente(
            102,
            agendamento.getIdAgendamento()
        );

        assertEquals(2, item.getServicos().size());
        assertEquals(130.00, item.getValorTotal(), 0.001);
    }

    @Test
    void deveImpedirAgendamentoSemServicos() throws Exception {

        Agendamento agendamento = novoAgendamento();

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComListaNula() throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        agendamento.setIdsServicos(null);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoDuplicado() throws Exception {

        Agendamento primeiro = novoAgendamento(301);

        dao.inserir(primeiro);

        Agendamento duplicado = novoAgendamento(302);

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(duplicado)
        );

        assertEquals(1062, erro.getErrorCode());

        assertEquals(
            7,
            consultarQuantidade("SELECT COUNT(*) FROM agendamento")
        );

        assertEquals(
            8,
            consultarQuantidade(
                "SELECT COUNT(*) FROM agendamento_servico"
            )
        );
    }

    @Test
    void deveImpedirServicoDuplicadoNoAgendamento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 301);

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        assertEquals(1062, erro.getErrorCode());

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComVeiculoInexistente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        agendamento.setIdVeiculo(999999);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComVeiculoInativo()
            throws Exception {

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.inativarVeiculo(203)
        );

        Agendamento agendamento = novoAgendamento(301);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComVeiculoExcluido()
            throws Exception {

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(203)
        );

        Agendamento agendamento = novoAgendamento(301);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComClienteInativo()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        assertTrue(veiculoDAO.buscarPorId(203).isAtivo());

        Agendamento agendamento = novoAgendamento(301);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComClienteExcluido()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        Agendamento agendamento = novoAgendamento(301);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComServicoInexistente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(999999);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComServicoInativo()
            throws Exception {

        Agendamento agendamento = novoAgendamento(303);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveImpedirAgendamentoComServicoExcluido()
            throws Exception {

        Agendamento agendamento = novoAgendamento(304);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();
    }

    @Test
    void deveReverterTransacaoQuandoSegundoServicoForInvalido()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 999999);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(agendamento)
        );

        validarSeedIntacto();

        assertNull(
            dao.buscarPorId(agendamento.getIdAgendamento())
        );
    }

    @Test
    void devePermitirNovaTentativaAposRollback() throws Exception {

        Agendamento invalido = novoAgendamento(301, 999999);

        assertThrows(
            SQLException.class,
            () -> dao.inserir(invalido)
        );

        Agendamento valido = novoAgendamento(301, 302);

        dao.inserir(valido);

        assertNotNull(dao.buscarPorId(valido.getIdAgendamento()));

        assertEquals(
            7,
            consultarQuantidade("SELECT COUNT(*) FROM agendamento")
        );
    }

    @Test
    void deveBuscarAgendamentoPorId() throws Exception {

        Agendamento agendamento = dao.buscarPorId(501);

        assertNotNull(agendamento);
        assertEquals(501, agendamento.getIdAgendamento());
        assertEquals(201, agendamento.getIdVeiculo());
        assertEquals("AGENDADO", agendamento.getStatus());
        assertEquals("Cliente Teste Ativo", agendamento.getClienteNome());

        assertEquals(
            "Volkswagen Polo - TST1A01",
            agendamento.getVeiculoDescricao()
        );
    }

    @Test
    void deveRetornarNuloParaAgendamentoInexistente()
            throws Exception {

        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveCalcularTotalDosServicosContratados()
            throws Exception {

        Agendamento agendamento = dao.buscarPorId(504);

        assertEquals(90.00, agendamento.getValorTotal(), 0.001);

        assertTrue(
            agendamento.getServicosDescricao()
                .contains("Lavagem Simples Teste")
        );

        assertTrue(
            agendamento.getServicosDescricao()
                .contains("Enceramento Teste")
        );
    }

    @Test
    void deveListarTodosIncluindoHistorico() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Agendamento::getIdAgendamento)
            .toList();

        assertEquals(
            List.of(502, 501, 503, 504, 505, 506),
            ids
        );
    }

    @Test
    void deveFiltrarAgendamentosAgendados() throws Exception {

        List<Integer> ids = dao.listarPorStatus("agendados")
            .stream()
            .map(Agendamento::getIdAgendamento)
            .toList();

        assertEquals(List.of(502, 501, 503), ids);
    }

    @Test
    void deveFiltrarAgendamentosConcluidos() throws Exception {

        List<Agendamento> agendamentos =
            dao.listarPorStatus("concluidos");

        assertEquals(1, agendamentos.size());
        assertEquals(504, agendamentos.get(0).getIdAgendamento());
    }

    @Test
    void deveFiltrarAgendamentosCancelados() throws Exception {

        List<Agendamento> agendamentos =
            dao.listarPorStatus("cancelados");

        assertEquals(1, agendamentos.size());
        assertEquals(505, agendamentos.get(0).getIdAgendamento());
    }

    @Test
    void deveFiltrarAgendamentosArquivados() throws Exception {

        List<Agendamento> agendamentos =
            dao.listarPorStatus("arquivados");

        assertEquals(1, agendamentos.size());
        assertEquals(506, agendamentos.get(0).getIdAgendamento());
        assertTrue(agendamentos.get(0).isArquivado());
    }

    @Test
    void deveUtilizarFiltroAgendadosComoPadrao()
            throws Exception {

        assertEquals(3, dao.listarPorStatus(null).size());
        assertEquals(3, dao.listarPorStatus("desconhecido").size());
    }

    @Test
    void deveListarSomenteAgendamentosDoCliente()
            throws Exception {

        List<Integer> ids = dao.listarPorCliente(101)
            .stream()
            .map(AgendamentoCliente::getIdAgendamento)
            .toList();

        assertEquals(
            List.of(502, 501, 503, 504, 505),
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
    void devePreservarHistoricoDoClienteExcluido()
            throws Exception {

        AgendamentoCliente item =
            buscarAgendamentoDoCliente(104, 506);

        assertEquals("CONCLUIDO", item.getStatusAgendamento());
        assertEquals(100.00, item.getValorTotal(), 0.001);
    }

    @Test
    void deveRetornarDadosDoVeiculoNaConsultaDoCliente()
            throws Exception {

        AgendamentoCliente item =
            buscarAgendamentoDoCliente(101, 501);

        assertEquals("Volkswagen", item.getMarca());
        assertEquals("Polo", item.getModelo());
        assertEquals("TST1A01", item.getPlaca());
        assertEquals("Branco", item.getCor());
    }

    @Test
    void deveRetornarStatusDoAtendimento() throws Exception {

        AgendamentoCliente item =
            buscarAgendamentoDoCliente(101, 503);

        assertEquals("AGENDADO", item.getStatusAgendamento());
        assertEquals("EM_LAVAGEM", item.getStatusAtendimento());
    }

    @Test
    void deveAgruparMultiplosServicosSemDuplicarAgendamento()
            throws Exception {

        List<AgendamentoCliente> agendamentos =
            dao.listarPorCliente(101);

        long quantidade = agendamentos.stream()
            .filter(a -> a.getIdAgendamento() == 504)
            .count();

        assertEquals(1, quantidade);

        AgendamentoCliente item =
            buscarAgendamentoDoCliente(101, 504);

        assertEquals(2, item.getServicos().size());
        assertEquals(90.00, item.getValorTotal(), 0.001);
    }

    @Test
    void devePreservarPrecoHistoricoAposAlteracaoDoServico()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        assertEquals(
            50.00,
            dao.buscarPorId(501).getValorTotal(),
            0.001
        );

        assertEquals(
            50.00,
            buscarAgendamentoDoCliente(101, 501)
                .getValorTotal(),
            0.001
        );

        assertEquals(
            90.00,
            dao.buscarPorId(504).getValorTotal(),
            0.001
        );
    }

    @Test
    void deveUtilizarPrecoAtualNosNovosAgendamentos()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(65.90);

        servicoDAO.atualizar(servico);

        Agendamento agendamento = novoAgendamento(301);

        dao.inserir(agendamento);

        assertEquals(
            65.90,
            dao.buscarPorId(
                agendamento.getIdAgendamento()
            ).getValorTotal(),
            0.001
        );
    }

    @Test
    void deveArmazenarValorContratadoComPrecisaoDecimal()
            throws Exception {

        Servico servico = servicoDAO.buscarPorId(301);

        servico.setPreco(79.99);

        servicoDAO.atualizar(servico);

        Agendamento agendamento = novoAgendamento(301);

        dao.inserir(agendamento);

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.prepareStatement("""
                SELECT valor_praticado
                FROM agendamento_servico
                WHERE id_agendamento = ?
                  AND id_servico = 301
                """)
        ) {
            comando.setInt(1, agendamento.getIdAgendamento());

            try (var resultado = comando.executeQuery()) {

                assertTrue(resultado.next());

                assertEquals(
                    new BigDecimal("79.99"),
                    resultado.getBigDecimal("valor_praticado")
                );
            }
        }
    }

    @Test
    void devePreservarHistoricoDeServicoExcluido()
            throws Exception {

        assertTrue(servicoDAO.excluirLogicamente(301));

        assertEquals(
            50.00,
            dao.buscarPorId(501).getValorTotal(),
            0.001
        );

        assertEquals(
            50.00,
            buscarAgendamentoDoCliente(101, 501)
                .getValorTotal(),
            0.001
        );
    }

    @Test
    void deveCancelarAgendamentoAdministrativamente()
            throws Exception {

        dao.cancelar(501);

        assertEquals(
            "CANCELADO",
            dao.buscarPorId(501).getStatus()
        );
    }

    @Test
    void deveImpedirCancelamentoDeAgendamentoConcluido()
            throws Exception {

        dao.cancelar(504);

        assertEquals(
            "CONCLUIDO",
            dao.buscarPorId(504).getStatus()
        );
    }

    @Test
    void devePreservarStatusDeAgendamentoJaCancelado()
            throws Exception {

        dao.cancelar(505);

        assertEquals(
            "CANCELADO",
            dao.buscarPorId(505).getStatus()
        );
    }

    @Test
    void deveCancelarAgendamentoInexistenteSemAlterarBanco()
            throws Exception {

        dao.cancelar(999999);

        validarSeedIntacto();
    }

    @Test
    void devePermitirCancelamentoPeloProprioCliente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        dao.inserir(agendamento);

        assertTrue(
            dao.cancelarDoCliente(
                agendamento.getIdAgendamento(),
                102
            )
        );

        assertEquals(
            "CANCELADO",
            dao.buscarPorId(
                agendamento.getIdAgendamento()
            ).getStatus()
        );
    }

    @Test
    void deveImpedirCancelamentoPorOutroCliente()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301);

        dao.inserir(agendamento);

        assertFalse(
            dao.cancelarDoCliente(
                agendamento.getIdAgendamento(),
                101
            )
        );

        assertEquals(
            "AGENDADO",
            dao.buscarPorId(
                agendamento.getIdAgendamento()
            ).getStatus()
        );
    }

    @Test
    void deveImpedirCancelamentoDoClienteComAtendimentoAguardando()
            throws Exception {

        assertFalse(dao.cancelarDoCliente(501, 101));

        assertEquals(
            "AGENDADO",
            dao.buscarPorId(501).getStatus()
        );
    }

    @Test
    void deveImpedirCancelamentoDoClienteDuranteLavagem()
            throws Exception {

        assertFalse(dao.cancelarDoCliente(503, 101));

        assertEquals(
            "AGENDADO",
            dao.buscarPorId(503).getStatus()
        );
    }

    @Test
    void deveImpedirCancelamentoDoClienteAposConclusao()
            throws Exception {

        assertFalse(dao.cancelarDoCliente(504, 101));
    }

    @Test
    void deveImpedirNovoCancelamentoPeloCliente()
            throws Exception {

        assertFalse(dao.cancelarDoCliente(505, 101));
    }

    @Test
    void deveRetornarFalseAoCancelarAgendamentoInexistente()
            throws Exception {

        assertFalse(dao.cancelarDoCliente(999999, 101));
    }

    @Test
    void devePreservarServicosContratadosAposCancelamento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(301, 302);

        dao.inserir(agendamento);
        dao.cancelar(agendamento.getIdAgendamento());

        Agendamento salvo = dao.buscarPorId(
            agendamento.getIdAgendamento()
        );

        assertEquals("CANCELADO", salvo.getStatus());
        assertEquals(130.00, salvo.getValorTotal(), 0.001);

        assertEquals(
            2,
            buscarAgendamentoDoCliente(
                102,
                agendamento.getIdAgendamento()
            ).getServicos().size()
        );
    }

    @Test
    void deveArquivarAgendamentoConcluido() throws Exception {

        assertTrue(dao.arquivarAgendamento(504));

        Agendamento agendamento = dao.buscarPorId(504);

        assertTrue(agendamento.isArquivado());
        assertEquals("CONCLUIDO", agendamento.getStatus());
    }

    @Test
    void deveArquivarAgendamentoCancelado() throws Exception {

        assertTrue(dao.arquivarAgendamento(505));

        Agendamento agendamento = dao.buscarPorId(505);

        assertTrue(agendamento.isArquivado());
        assertEquals("CANCELADO", agendamento.getStatus());
    }

    @Test
    void deveImpedirArquivamentoDeAgendamentoAtivo()
            throws Exception {

        assertFalse(dao.arquivarAgendamento(501));

        assertFalse(dao.buscarPorId(501).isArquivado());
    }

    @Test
    void deveImpedirArquivamentoComAtendimentoPendente()
            throws Exception {

        dao.cancelar(502);

        assertEquals(
            "CANCELADO",
            dao.buscarPorId(502).getStatus()
        );

        assertFalse(dao.arquivarAgendamento(502));
        assertFalse(dao.buscarPorId(502).isArquivado());
    }

    @Test
    void deveImpedirArquivamentoComPagamentoPendente()
            throws Exception {

        executarSqlTeste("""
            UPDATE pagamento
            SET status_pagamento = 'PENDENTE',
                data_pagamento = NULL,
                forma_pagamento = NULL
            WHERE id_agendamento = 505
            """);

        assertFalse(dao.arquivarAgendamento(505));

        assertFalse(dao.buscarPorId(505).isArquivado());
    }

    @Test
    void deveImpedirArquivamentoDeAgendamentoJaArquivado()
            throws Exception {

        assertFalse(dao.arquivarAgendamento(506));
    }

    @Test
    void deveRestaurarAgendamentoArquivado() throws Exception {

        assertTrue(dao.restaurarAgendamento(506));

        Agendamento agendamento = dao.buscarPorId(506);

        assertFalse(agendamento.isArquivado());
        assertNull(agendamento.getArquivadoEm());
        assertEquals("CONCLUIDO", agendamento.getStatus());
    }

    @Test
    void deveImpedirRestauracaoDeAgendamentoNaoArquivado()
            throws Exception {

        assertFalse(dao.restaurarAgendamento(504));
    }

    @Test
    void deveRetornarFalseParaIdInexistenteNoArquivamento()
            throws Exception {

        assertFalse(dao.arquivarAgendamento(999999));
        assertFalse(dao.restaurarAgendamento(999999));
    }

    @Test
    void deveAtualizarFiltrosAposArquivamentoERestauracao()
            throws Exception {

        assertTrue(dao.arquivarAgendamento(504));

        assertEquals(0, dao.listarPorStatus("concluidos").size());
        assertEquals(2, dao.listarPorStatus("arquivados").size());

        assertTrue(dao.restaurarAgendamento(504));

        assertEquals(1, dao.listarPorStatus("concluidos").size());
        assertEquals(1, dao.listarPorStatus("arquivados").size());
    }

    @Test
    void devePreservarRelacionamentosAposArquivamento()
            throws Exception {

        assertTrue(dao.arquivarAgendamento(504));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM agendamento a
                JOIN agendamento_servico ags
                    ON ags.id_agendamento = a.id_agendamento
                JOIN atendimento at
                    ON at.id_agendamento = a.id_agendamento
                JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento
                WHERE a.id_agendamento = 504
                  AND a.arquivado_em IS NOT NULL
                  AND at.status = 'FINALIZADO'
                  AND p.status_pagamento = 'PAGO'
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(2, resultado.getInt(1));
        }
    }
}
