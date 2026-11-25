package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Veiculo;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static com.fastsplash.web.dao.ResultadoStatusVeiculo.*;

class VeiculoDAOIT {

    private final VeiculoDAO dao = new VeiculoDAO();
    private final ClienteDAO clienteDAO = new ClienteDAO();

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

    private Veiculo novoVeiculo() {
        return new Veiculo(
            0,
            102,
            "TST9A99",
            "Hyundai",
            "HB20",
            "Branco"
        );
    }

    @Test
    void deveCadastrarVeiculo() throws Exception {

        Veiculo veiculo = novoVeiculo();

        dao.inserir(veiculo);

        assertTrue(veiculo.getIdVeiculo() > 0);

        Veiculo salvo = dao.buscarPorId(veiculo.getIdVeiculo());

        assertNotNull(salvo);
        assertEquals(102, salvo.getIdCliente());
        assertEquals("TST9A99", salvo.getPlaca());
        assertEquals("Hyundai", salvo.getMarca());
        assertEquals("HB20", salvo.getModelo());
        assertEquals("Branco", salvo.getCor());
        assertTrue(salvo.isAtivo());
        assertFalse(salvo.isExcluido());
    }

    @Test
    void deveBuscarVeiculoPorId() throws Exception {

        Veiculo veiculo = dao.buscarPorId(201);

        assertNotNull(veiculo);
        assertEquals(201, veiculo.getIdVeiculo());
        assertEquals(101, veiculo.getIdCliente());
        assertEquals("Volkswagen", veiculo.getMarca());
        assertEquals("Polo", veiculo.getModelo());
    }

    @Test
    void deveRetornarNuloParaVeiculoInexistente() throws Exception {
        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveListarSomenteVeiculosAtivos() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Veiculo::getIdVeiculo)
            .toList();

        assertEquals(List.of(201, 202, 203), ids);
    }

    @Test
    void deveListarVeiculosDoCliente() throws Exception {

        List<Integer> ids = dao.listarPorCliente(101)
            .stream()
            .map(Veiculo::getIdVeiculo)
            .toList();

        assertEquals(List.of(201, 202), ids);
    }

    @Test
    void deveRetornarListaVaziaParaClienteInexistente() throws Exception {
        assertTrue(dao.listarPorCliente(999999).isEmpty());
    }

    @Test
    void deveOcultarVeiculosInativosDoCliente() throws Exception {
        assertTrue(dao.listarPorCliente(103).isEmpty());
    }

    @Test
    void deveOcultarVeiculosExcluidosDoCliente() throws Exception {
        assertTrue(dao.listarPorCliente(104).isEmpty());
    }

    @Test
    void deveOcultarVeiculoDeProprietarioInativo() throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Veiculo::getIdVeiculo)
            .toList();

        assertEquals(List.of(201, 202), ids);
    }

    @Test
    void deveAtualizarDadosDoVeiculo() throws Exception {

        Veiculo veiculo = dao.buscarPorId(203);

        veiculo.setMarca("Ford");
        veiculo.setModelo("Ka");
        veiculo.setCor("Vermelho");
        veiculo.setPlaca("TST9A98");

        dao.atualizar(veiculo);

        Veiculo atualizado = dao.buscarPorId(203);

        assertEquals("Ford", atualizado.getMarca());
        assertEquals("Ka", atualizado.getModelo());
        assertEquals("Vermelho", atualizado.getCor());
        assertEquals("TST9A98", atualizado.getPlaca());
        assertEquals(102, atualizado.getIdCliente());
    }

    @Test
    void deveImpedirAtualizacaoDeVeiculoInativo() throws Exception {

        Veiculo veiculo = dao.buscarPorId(204);
        String corOriginal = veiculo.getCor();

        veiculo.setCor("Vermelho");

        dao.atualizar(veiculo);

        assertEquals(corOriginal, dao.buscarPorId(204).getCor());
    }

    @Test
    void deveImpedirAtualizacaoDeVeiculoExcluido() throws Exception {

        Veiculo veiculo = dao.buscarPorId(205);
        String corOriginal = veiculo.getCor();

        veiculo.setCor("Vermelho");

        dao.atualizar(veiculo);

        assertEquals(corOriginal, dao.buscarPorId(205).getCor());
    }

    @Test
    void deveImpedirPlacaDuplicada() throws Exception {

        Veiculo veiculo = novoVeiculo();
        veiculo.setPlaca("TST1A01");

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(veiculo)
        );

        assertEquals(1062, erro.getErrorCode());
        assertEquals(3, dao.listarTodos().size());
    }

    @Test
    void deveImpedirAtualizacaoComPlacaDuplicada() throws Exception {

        Veiculo veiculo = dao.buscarPorId(203);
        veiculo.setPlaca("TST1A01");

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.atualizar(veiculo)
        );

        assertEquals(1062, erro.getErrorCode());
        assertEquals("TST1A03", dao.buscarPorId(203).getPlaca());
    }

    @Test
    void deveImpedirCadastroComClienteInexistente() throws Exception {

        Veiculo veiculo = novoVeiculo();
        veiculo.setIdCliente(999999);

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(veiculo)
        );

        assertEquals(1452, erro.getErrorCode());
    }

    @Test
    void deveImpedirInativacaoComPendencias() throws Exception {

        assertEquals(POSSUI_PENDENCIAS, dao.inativarVeiculo(201));
        assertTrue(dao.buscarPorId(201).isAtivo());
    }

    @Test
    void deveInativarVeiculoSemPendencias() throws Exception {

        assertEquals(SUCESSO, dao.inativarVeiculo(203));

        Veiculo veiculo = dao.buscarPorId(203);

        assertFalse(veiculo.isAtivo());
        assertFalse(veiculo.isExcluido());
    }

    @Test
    void deveIdentificarVeiculoJaInativo() throws Exception {
        assertEquals(JA_INATIVO, dao.inativarVeiculo(204));
    }

    @Test
    void deveReativarVeiculo() throws Exception {

        assertEquals(SUCESSO, dao.inativarVeiculo(203));
        assertEquals(SUCESSO, dao.reativarVeiculo(203));
        assertTrue(dao.buscarPorId(203).isAtivo());
    }

    @Test
    void deveIdentificarVeiculoJaAtivo() throws Exception {
        assertEquals(JA_ATIVO, dao.reativarVeiculo(203));
    }

    @Test
    void deveImpedirReativacaoComClienteInativo() throws Exception {

        assertEquals(CLIENTE_INATIVO, dao.reativarVeiculo(204));
        assertFalse(dao.buscarPorId(204).isAtivo());
    }

    @Test
    void deveReativarAposReativacaoDoProprietario() throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.reativarCliente(103)
        );

        assertEquals(SUCESSO, dao.reativarVeiculo(204));
        assertTrue(dao.buscarPorId(204).isAtivo());
    }

    @Test
    void deveImpedirReativacaoDiretaDeExcluido() throws Exception {

        assertEquals(JA_EXCLUIDO, dao.reativarVeiculo(205));
        assertTrue(dao.buscarPorId(205).isExcluido());
    }

    @Test
    void deveImpedirExclusaoComPendencias() throws Exception {

        assertEquals(POSSUI_PENDENCIAS, dao.excluirLogicamente(201));
        assertTrue(dao.buscarPorId(201).isAtivo());
        assertFalse(dao.buscarPorId(201).isExcluido());
    }

    @Test
    void deveExcluirVeiculoLogicamente() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(203));

        Veiculo veiculo = dao.buscarPorId(203);

        assertNotNull(veiculo);
        assertFalse(veiculo.isAtivo());
        assertTrue(veiculo.isExcluido());
        assertNotNull(veiculo.getExcluidoEm());
    }

    @Test
    void deveIdentificarVeiculoJaExcluido() throws Exception {
        assertEquals(JA_EXCLUIDO, dao.excluirLogicamente(205));
    }

    @Test
    void deveImpedirRestauracaoComProprietarioExcluido() throws Exception {

        assertEquals(CLIENTE_INATIVO, dao.restaurarVeiculo(205));
        assertTrue(dao.buscarPorId(205).isExcluido());
    }

    @Test
    void deveRestaurarVeiculoExcluido() throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.restaurarCliente(104)
        );

        assertEquals(SUCESSO, dao.restaurarVeiculo(205));

        Veiculo veiculo = dao.buscarPorId(205);

        assertTrue(veiculo.isAtivo());
        assertFalse(veiculo.isExcluido());
        assertNull(veiculo.getExcluidoEm());
    }

    @Test
    void deveImpedirRestauracaoDeVeiculoNaoExcluido() throws Exception {
        assertEquals(NAO_EXCLUIDO, dao.restaurarVeiculo(203));
    }

    @Test
    void deveIdentificarVeiculoInexistenteNasOperacoes() throws Exception {

        assertEquals(VEICULO_NAO_ENCONTRADO, dao.inativarVeiculo(999999));
        assertEquals(VEICULO_NAO_ENCONTRADO, dao.reativarVeiculo(999999));
        assertEquals(VEICULO_NAO_ENCONTRADO, dao.excluirLogicamente(999999));
        assertEquals(VEICULO_NAO_ENCONTRADO, dao.restaurarVeiculo(999999));
    }

    @Test
    void deveFiltrarVeiculosAtivos() throws Exception {

        List<Integer> ids = dao.listarPorStatus("ativos")
            .stream()
            .map(Veiculo::getIdVeiculo)
            .toList();

        assertEquals(List.of(201, 202, 203), ids);
    }

    @Test
    void deveFiltrarVeiculosInativos() throws Exception {

        List<Veiculo> veiculos = dao.listarPorStatus("inativos");

        assertEquals(1, veiculos.size());
        assertEquals(204, veiculos.get(0).getIdVeiculo());
    }

    @Test
    void deveFiltrarVeiculosExcluidos() throws Exception {

        List<Veiculo> veiculos = dao.listarPorStatus("excluidos");

        assertEquals(1, veiculos.size());
        assertEquals(205, veiculos.get(0).getIdVeiculo());
    }

    @Test
    void devePreservarHistoricoAposExclusao() throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.restaurarCliente(104)
        );

        assertEquals(SUCESSO, dao.restaurarVeiculo(205));
        assertEquals(SUCESSO, dao.excluirLogicamente(205));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM veiculo v
                JOIN agendamento a ON a.id_veiculo = v.id_veiculo
                JOIN atendimento at ON at.id_agendamento = a.id_agendamento
                JOIN pagamento p ON p.id_agendamento = a.id_agendamento
                WHERE v.id_veiculo = 205
                  AND v.excluido_em IS NOT NULL
                  AND a.id_agendamento = 506
                  AND at.status = 'FINALIZADO'
                  AND p.status_pagamento = 'PAGO'
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(1, resultado.getInt(1));
        }
    }
}
