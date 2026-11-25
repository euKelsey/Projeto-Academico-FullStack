package com.fastsplash.web.negocio;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.DashboardDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;

import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Veiculo;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Dashboard;

import com.fastsplash.web.util.SenhaUtil;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class CicloClienteIT {

    private final ClienteDAO clienteDAO = new ClienteDAO();
    private final VeiculoDAO veiculoDAO = new VeiculoDAO();
    private final AgendamentoDAO agendamentoDAO = new AgendamentoDAO();
    private final DashboardDAO dashboardDAO = new DashboardDAO();

    private static final String SENHA_TESTE = "SenhaFicticia@123";

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

    private Cliente novoCliente() throws Exception {

        Cliente cliente = new Cliente();

        cliente.setNome("CLIENTE CICLO INTEGRADO");
        cliente.setCpf("98765410564");
        cliente.setTelefone("11900000105");
        cliente.setEmail("ciclo@example.test");

        cliente.setSenhaHash(
            SenhaUtil.gerarHash(SENHA_TESTE)
        );

        clienteDAO.inserir(cliente);

        assertTrue(cliente.getIdCliente() > 0);

        return cliente;
    }

    private Veiculo novoVeiculo(int idCliente)
            throws Exception {

        Veiculo veiculo = new Veiculo();

        veiculo.setIdCliente(idCliente);
        veiculo.setPlaca("TST1B01");
        veiculo.setMarca("FIAT");
        veiculo.setModelo("ARGO");
        veiculo.setCor("PRATA");

        veiculoDAO.inserir(veiculo);

        assertTrue(veiculo.getIdVeiculo() > 0);

        return veiculo;
    }

    private Agendamento novoAgendamento(int idVeiculo)
            throws Exception {

        Agendamento agendamento = new Agendamento();

        agendamento.setIdVeiculo(idVeiculo);
        agendamento.setData(LocalDate.now().plusDays(5));
        agendamento.setHorario(LocalTime.of(14, 0));
        agendamento.setIdsServicos(List.of(301, 302));

        agendamentoDAO.inserir(agendamento);

        assertTrue(agendamento.getIdAgendamento() > 0);

        return agendamento;
    }

    private boolean veiculoDisponivel(int idVeiculo)
            throws Exception {

        return veiculoDAO.listarTodos()
            .stream()
            .anyMatch(v -> v.getIdVeiculo() == idVeiculo);
    }

    @Test
    void deveCadastrarClienteComSenhaProtegida()
            throws Exception {

        Cliente novo = novoCliente();

        Cliente cadastrado = clienteDAO.buscarPorEmail(
            "ciclo@example.test"
        );

        assertNotNull(cadastrado);

        assertEquals(
            novo.getIdCliente(),
            cadastrado.getIdCliente()
        );

        assertTrue(cadastrado.isAtivo());
        assertFalse(cadastrado.isExcluido());

        assertNotEquals(
            SENHA_TESTE,
            cadastrado.getSenhaHash()
        );

        assertTrue(
            cadastrado.getSenhaHash().startsWith("pbkdf2$")
        );

        assertTrue(
            SenhaUtil.verificarSenha(
                SENHA_TESTE,
                cadastrado.getSenhaHash()
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                "SenhaIncorreta",
                cadastrado.getSenhaHash()
            )
        );
    }

    @Test
    void deveCadastrarClienteEVeiculoAtualizandoDashboard()
            throws Exception {

        Dashboard anterior = dashboardDAO.carregar();

        Cliente cliente = novoCliente();

        Veiculo veiculo = novoVeiculo(
            cliente.getIdCliente()
        );

        Dashboard atual = dashboardDAO.carregar();

        assertEquals(
            anterior.clientesAtivos() + 1,
            atual.clientesAtivos()
        );

        assertEquals(
            anterior.veiculosAtivos() + 1,
            atual.veiculosAtivos()
        );

        List<Veiculo> veiculos = veiculoDAO.listarPorCliente(
            cliente.getIdCliente()
        );

        assertEquals(1, veiculos.size());

        assertEquals(
            veiculo.getIdVeiculo(),
            veiculos.getFirst().getIdVeiculo()
        );
    }

    @Test
    void deveAtualizarClientePreservandoVeiculos()
            throws Exception {

        Cliente cliente = novoCliente();

        Veiculo veiculo = novoVeiculo(
            cliente.getIdCliente()
        );

        String hashOriginal = clienteDAO
            .buscarPorId(cliente.getIdCliente())
            .getSenhaHash();

        cliente.setNome("CLIENTE ATUALIZADO");
        cliente.setTelefone("11999990105");
        cliente.setEmail("ciclo.atualizado@example.test");

        clienteDAO.atualizar(cliente);

        Cliente atualizado = clienteDAO.buscarPorEmail(
            "ciclo.atualizado@example.test"
        );

        assertNotNull(atualizado);

        assertEquals(
            cliente.getIdCliente(),
            atualizado.getIdCliente()
        );

        assertEquals(
            "CLIENTE ATUALIZADO",
            atualizado.getNome()
        );

        assertEquals(
            "11999990105",
            atualizado.getTelefone()
        );

        assertEquals(
            hashOriginal,
            atualizado.getSenhaHash()
        );

        assertNull(
            clienteDAO.buscarPorEmail("ciclo@example.test")
        );

        Veiculo vinculado = veiculoDAO.buscarPorId(
            veiculo.getIdVeiculo()
        );

        assertEquals(
            atualizado.getIdCliente(),
            vinculado.getIdCliente()
        );

        assertEquals(
            1,
            veiculoDAO.listarPorCliente(
                atualizado.getIdCliente()
            ).size()
        );
    }

    @Test
    void deveAlterarSenhaPreservandoCadastroEVeiculo()
            throws Exception {

        Cliente cliente = novoCliente();

        Veiculo veiculo = novoVeiculo(
            cliente.getIdCliente()
        );

        String novaSenha = "NovaSenhaFicticia@456";

        clienteDAO.atualizarSenhaHash(
            cliente.getIdCliente(),
            SenhaUtil.gerarHash(novaSenha)
        );

        Cliente atualizado = clienteDAO.buscarPorId(
            cliente.getIdCliente()
        );

        assertTrue(
            SenhaUtil.verificarSenha(
                novaSenha,
                atualizado.getSenhaHash()
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                SENHA_TESTE,
                atualizado.getSenhaHash()
            )
        );

        assertEquals(cliente.getNome(), atualizado.getNome());
        assertEquals(cliente.getCpf(), atualizado.getCpf());
        assertEquals(cliente.getEmail(), atualizado.getEmail());

        assertEquals(
            cliente.getIdCliente(),
            veiculoDAO.buscarPorId(
                veiculo.getIdVeiculo()
            ).getIdCliente()
        );
    }

    @Test
    void deveBloquearAgendamentoAposInativacaoDoCliente()
            throws Exception {

        assertTrue(veiculoDisponivel(203));

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        assertFalse(veiculoDisponivel(203));

        assertThrows(
            SQLException.class,
            () -> novoAgendamento(203)
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(1, dashboard.clientesAtivos());
        assertEquals(2, dashboard.veiculosAtivos());
    }

    @Test
    void deveLiberarAgendamentoAposReativacaoDoCliente()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        assertFalse(veiculoDisponivel(203));

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.reativarCliente(102)
        );

        assertTrue(veiculoDisponivel(203));

        Agendamento agendamento = novoAgendamento(203);

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(
                agendamento.getIdAgendamento()
            ).getStatus()
        );
    }

    @Test
    void deveBloquearAgendamentoAposExclusaoDoCliente()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        Cliente cliente = clienteDAO.buscarPorId(102);

        assertTrue(cliente.isExcluido());
        assertFalse(cliente.isAtivo());

        assertNotNull(veiculoDAO.buscarPorId(203));

        assertFalse(veiculoDisponivel(203));

        assertThrows(
            SQLException.class,
            () -> novoAgendamento(203)
        );
    }

    @Test
    void deveRecuperarDisponibilidadeAposRestauracao()
            throws Exception {

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        assertFalse(veiculoDisponivel(203));

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.restaurarCliente(102)
        );

        Cliente restaurado = clienteDAO.buscarPorId(102);

        assertTrue(restaurado.isAtivo());
        assertFalse(restaurado.isExcluido());

        assertTrue(veiculoDisponivel(203));

        Agendamento agendamento = novoAgendamento(203);

        assertNotNull(
            agendamentoDAO.buscarPorId(
                agendamento.getIdAgendamento()
            )
        );
    }

    @Test
    void deveBloquearInativacaoAposCriacaoDeAgendamento()
            throws Exception {

        novoAgendamento(203);

        assertEquals(
            ResultadoStatusCliente.POSSUI_PENDENCIAS,
            clienteDAO.inativarCliente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.POSSUI_PENDENCIAS,
            veiculoDAO.inativarVeiculo(203)
        );

        assertTrue(clienteDAO.buscarPorId(102).isAtivo());
        assertTrue(veiculoDisponivel(203));

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(2, dashboard.clientesAtivos());
        assertEquals(3, dashboard.veiculosAtivos());
    }

    @Test
    void deveBloquearExclusaoAposCriacaoDeAgendamento()
            throws Exception {

        Agendamento agendamento = novoAgendamento(203);

        assertEquals(
            ResultadoStatusCliente.POSSUI_PENDENCIAS,
            clienteDAO.excluirLogicamente(102)
        );

        assertEquals(
            ResultadoStatusVeiculo.POSSUI_PENDENCIAS,
            veiculoDAO.excluirLogicamente(203)
        );

        assertFalse(clienteDAO.buscarPorId(102).isExcluido());
        assertFalse(veiculoDAO.buscarPorId(203).isExcluido());

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(
                agendamento.getIdAgendamento()
            ).getStatus()
        );
    }

    @Test
    void deveLiberarInativacaoAposCancelamentoSemPendencias()
            throws Exception {

        Agendamento agendamento = novoAgendamento(203);

        assertEquals(
            ResultadoStatusCliente.POSSUI_PENDENCIAS,
            clienteDAO.inativarCliente(102)
        );

        assertTrue(
            agendamentoDAO.cancelarDoCliente(
                agendamento.getIdAgendamento(),
                102
            )
        );

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
            "CANCELADO",
            agendamentoDAO.buscarPorId(
                agendamento.getIdAgendamento()
            ).getStatus()
        );

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(1, dashboard.clientesAtivos());
        assertEquals(2, dashboard.veiculosAtivos());
        assertEquals(1, dashboard.pagamentosPendentes());
    }

    @Test
    void devePreservarVinculosAposExclusaoERestauracao()
            throws Exception {

        Cliente cliente = novoCliente();

        int idCliente = cliente.getIdCliente();

        Veiculo veiculo = novoVeiculo(idCliente);

        int idVeiculo = veiculo.getIdVeiculo();

        Agendamento agendamento = novoAgendamento(idVeiculo);

        int idAgendamento = agendamento.getIdAgendamento();

        assertTrue(
            agendamentoDAO.cancelarDoCliente(
                idAgendamento,
                idCliente
            )
        );

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(idVeiculo)
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(idCliente)
        );

        assertTrue(
            clienteDAO.buscarPorId(idCliente).isExcluido()
        );

        assertTrue(
            veiculoDAO.buscarPorId(idVeiculo).isExcluido()
        );

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.restaurarCliente(idCliente)
        );

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.restaurarVeiculo(idVeiculo)
        );

        assertTrue(
            clienteDAO.buscarPorId(idCliente).isAtivo()
        );

        assertTrue(
            veiculoDAO.buscarPorId(idVeiculo).isAtivo()
        );

        assertEquals(
            idCliente,
            veiculoDAO.buscarPorId(idVeiculo).getIdCliente()
        );

        Agendamento historico = agendamentoDAO.buscarPorId(
            idAgendamento
        );

        assertNotNull(historico);
        assertEquals(idVeiculo, historico.getIdVeiculo());
        assertEquals("CANCELADO", historico.getStatus());

        assertTrue(
            agendamentoDAO.listarPorCliente(idCliente)
                .stream()
                .anyMatch(a ->
                    a.getIdAgendamento() == idAgendamento
                )
        );

        assertTrue(veiculoDisponivel(idVeiculo));

        Dashboard dashboard = dashboardDAO.carregar();

        assertEquals(3, dashboard.clientesAtivos());
        assertEquals(4, dashboard.veiculosAtivos());
    }
}
