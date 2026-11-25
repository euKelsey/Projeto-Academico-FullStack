package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static com.fastsplash.web.dao.ResultadoStatusCliente.*;

class ClienteDAOIT {

    private final ClienteDAO dao = new ClienteDAO();

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

    private Cliente novoCliente() {
        return new Cliente(
            0,
            "Novo Cliente Teste",
            "52998224725",
            "11900000999",
            "novo@example.test",
            SenhaUtil.gerarHash("SenhaFicticia@123")
        );
    }

    @Test
    void deveCadastrarCliente() throws Exception {

        Cliente cliente = novoCliente();

        dao.inserir(cliente);

        assertTrue(cliente.getIdCliente() > 0);

        Cliente salvo = dao.buscarPorId(cliente.getIdCliente());

        assertNotNull(salvo);
        assertEquals(cliente.getNome(), salvo.getNome());
        assertEquals(cliente.getCpf(), salvo.getCpf());
        assertEquals(cliente.getEmail(), salvo.getEmail());
        assertEquals(cliente.getTelefone(), salvo.getTelefone());
        assertTrue(salvo.isAtivo());
        assertFalse(salvo.isExcluido());
    }

    @Test
    void deveBuscarClientePorId() throws Exception {

        Cliente cliente = dao.buscarPorId(101);

        assertNotNull(cliente);
        assertEquals(101, cliente.getIdCliente());
        assertEquals("Cliente Teste Ativo", cliente.getNome());
    }

    @Test
    void deveBuscarClientePorEmail() throws Exception {

        Cliente cliente = dao.buscarPorEmail("ativo@example.test");

        assertNotNull(cliente);
        assertEquals(101, cliente.getIdCliente());
    }

    @Test
    void deveRetornarNuloParaIdInexistente() throws Exception {
        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveRetornarNuloParaEmailInexistente() throws Exception {
        assertNull(dao.buscarPorEmail("inexistente@example.test"));
    }

    @Test
    void deveListarSomenteClientesAtivos() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Cliente::getIdCliente)
            .toList();

        assertEquals(List.of(101, 102), ids);
    }

    @Test
    void deveAtualizarDadosCadastrais() throws Exception {

        Cliente cliente = dao.buscarPorId(102);

        String hashOriginal = cliente.getSenhaHash();

        cliente.setNome("Cliente Atualizado Teste");
        cliente.setTelefone("11900000888");
        cliente.setEmail("atualizado@example.test");

        dao.atualizar(cliente);

        Cliente atualizado = dao.buscarPorId(102);

        assertEquals("Cliente Atualizado Teste", atualizado.getNome());
        assertEquals("11900000888", atualizado.getTelefone());
        assertEquals("atualizado@example.test", atualizado.getEmail());
        assertEquals(hashOriginal, atualizado.getSenhaHash());
    }

    @Test
    void deveAtualizarSenha() throws Exception {

        String novaSenha = "NovaSenhaTeste@456";
        String novoHash = SenhaUtil.gerarHash(novaSenha);

        dao.atualizarSenhaHash(102, novoHash);

        Cliente cliente = dao.buscarPorId(102);

        assertEquals(novoHash, cliente.getSenhaHash());

        assertTrue(
            SenhaUtil.verificarSenha(
                novaSenha,
                cliente.getSenhaHash()
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                "SenhaFicticia@123",
                cliente.getSenhaHash()
            )
        );
    }

    @Test
    void deveImpedirCpfDuplicado() throws Exception {

        Cliente cliente = novoCliente();

        cliente.setCpf(dao.buscarPorId(101).getCpf());

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(cliente)
        );

        assertEquals(1062, erro.getErrorCode());
        assertNull(dao.buscarPorEmail(cliente.getEmail()));
    }

    @Test
    void deveImpedirEmailDuplicado() throws Exception {

        Cliente cliente = novoCliente();

        cliente.setEmail("ativo@example.test");

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(cliente)
        );

        assertEquals(1062, erro.getErrorCode());
        assertEquals(4, dao.listarTodosParaHistorico().size());
    }

    @Test
    void deveIdentificarClienteComPendencias() throws Exception {

        try (Connection conexao = AmbienteTeste.conectar()) {
            assertTrue(dao.possuiPendencias(conexao, 101));
        }
    }

    @Test
    void deveIdentificarClienteSemPendencias() throws Exception {

        try (Connection conexao = AmbienteTeste.conectar()) {
            assertFalse(dao.possuiPendencias(conexao, 102));
        }
    }

    @Test
    void deveImpedirInativacaoComPendencias() throws Exception {

        assertEquals(POSSUI_PENDENCIAS, dao.inativarCliente(101));
        assertTrue(dao.buscarPorId(101).isAtivo());
    }

    @Test
    void deveInativarClienteSemPendencias() throws Exception {

        assertEquals(SUCESSO, dao.inativarCliente(102));
        assertFalse(dao.buscarPorId(102).isAtivo());
        assertFalse(dao.buscarPorId(102).isExcluido());
    }

    @Test
    void deveIdentificarClienteJaInativo() throws Exception {
        assertEquals(JA_INATIVO, dao.inativarCliente(103));
    }

    @Test
    void deveReativarCliente() throws Exception {

        assertEquals(SUCESSO, dao.reativarCliente(103));
        assertTrue(dao.buscarPorId(103).isAtivo());
    }

    @Test
    void deveIdentificarClienteJaAtivo() throws Exception {
        assertEquals(JA_ATIVO, dao.reativarCliente(102));
    }

    @Test
    void deveImpedirReativacaoDiretaDeExcluido() throws Exception {

        assertEquals(JA_EXCLUIDO, dao.reativarCliente(104));
        assertTrue(dao.buscarPorId(104).isExcluido());
    }

    @Test
    void deveImpedirExclusaoComPendencias() throws Exception {

        assertEquals(POSSUI_PENDENCIAS, dao.excluirLogicamente(101));
        assertTrue(dao.buscarPorId(101).isAtivo());
        assertFalse(dao.buscarPorId(101).isExcluido());
    }

    @Test
    void deveExcluirClienteLogicamente() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(102));

        Cliente cliente = dao.buscarPorId(102);

        assertNotNull(cliente);
        assertFalse(cliente.isAtivo());
        assertTrue(cliente.isExcluido());
        assertNotNull(cliente.getExcluidoEm());
    }

    @Test
    void deveIdentificarClienteJaExcluido() throws Exception {
        assertEquals(JA_EXCLUIDO, dao.excluirLogicamente(104));
    }

    @Test
    void deveRestaurarClienteExcluido() throws Exception {

        assertEquals(SUCESSO, dao.restaurarCliente(104));

        Cliente cliente = dao.buscarPorId(104);

        assertTrue(cliente.isAtivo());
        assertFalse(cliente.isExcluido());
        assertNull(cliente.getExcluidoEm());
    }

    @Test
    void deveImpedirRestauracaoDeClienteNaoExcluido() throws Exception {
        assertEquals(NAO_EXCLUIDO, dao.restaurarCliente(102));
    }

    @Test
    void deveIdentificarClienteInexistenteNasOperacoes() throws Exception {

        assertEquals(CLIENTE_NAO_ENCONTRADO, dao.inativarCliente(999999));
        assertEquals(CLIENTE_NAO_ENCONTRADO, dao.reativarCliente(999999));
        assertEquals(CLIENTE_NAO_ENCONTRADO, dao.excluirLogicamente(999999));
        assertEquals(CLIENTE_NAO_ENCONTRADO, dao.restaurarCliente(999999));
    }

    @Test
    void deveFiltrarClientesAtivos() throws Exception {
        assertEquals(2, dao.listarPorStatus("ativos").size());
    }

    @Test
    void deveFiltrarClientesInativos() throws Exception {

        List<Cliente> clientes = dao.listarPorStatus("inativos");

        assertEquals(1, clientes.size());
        assertEquals(103, clientes.get(0).getIdCliente());
    }

    @Test
    void deveFiltrarClientesExcluidos() throws Exception {

        List<Cliente> clientes = dao.listarPorStatus("excluidos");

        assertEquals(1, clientes.size());
        assertEquals(104, clientes.get(0).getIdCliente());
    }

    @Test
    void devePreservarHistoricoAposExclusao() throws Exception {

        assertEquals(SUCESSO, dao.restaurarCliente(104));
        assertEquals(SUCESSO, dao.excluirLogicamente(104));

        assertEquals(4, dao.listarTodosParaHistorico().size());

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM cliente c
                JOIN veiculo v ON v.id_cliente = c.id_cliente
                JOIN agendamento a ON a.id_veiculo = v.id_veiculo
                JOIN atendimento at ON at.id_agendamento = a.id_agendamento
                JOIN pagamento p ON p.id_agendamento = a.id_agendamento
                WHERE c.id_cliente = 104
                  AND c.excluido_em IS NOT NULL
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
