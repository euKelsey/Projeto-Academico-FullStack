package com.fastsplash.web.dao;

import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.db.BancoTeste;
import com.fastsplash.web.model.Colaborador;
import com.fastsplash.web.util.SenhaUtil;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static com.fastsplash.web.dao.ResultadoStatusColaborador.*;

class ColaboradorDAOIT {

    private final ColaboradorDAO dao = new ColaboradorDAO();

    private static final int ADMIN = 401;

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

    private Colaborador novoColaborador(String nivel) {

        Colaborador colaborador = new Colaborador();

        colaborador.setNome("Novo Colaborador Teste");
        colaborador.setCargo("Cargo Teste");
        colaborador.setNivelAcesso(nivel);

        if (!"OPERACIONAL".equals(nivel)) {
            colaborador.setEmail("novo.colaborador@example.test");

            colaborador.setSenhaHash(
                SenhaUtil.gerarHash("SenhaFicticia@123")
            );
        }

        return colaborador;
    }

    private long contarAdministradoresAtivos() throws Exception {

        return dao.listarTodos()
            .stream()
            .filter(c -> "ADMINISTRADOR".equals(c.getNivelAcesso()))
            .count();
    }

    @Test
    void deveCadastrarAdministrador() throws Exception {

        Colaborador colaborador = novoColaborador("ADMINISTRADOR");

        dao.inserir(colaborador);

        assertTrue(colaborador.getIdColaborador() > 0);

        Colaborador salvo = dao.buscarPorId(
            colaborador.getIdColaborador()
        );

        assertNotNull(salvo);
        assertEquals("ADMINISTRADOR", salvo.getNivelAcesso());
        assertEquals(colaborador.getNome(), salvo.getNome());
        assertEquals(colaborador.getCargo(), salvo.getCargo());
        assertEquals(colaborador.getEmail(), salvo.getEmail());
        assertTrue(salvo.isAtivo());
        assertFalse(salvo.isExcluido());
        assertEquals(2, contarAdministradoresAtivos());
    }

    @Test
    void deveCadastrarAtendente() throws Exception {

        Colaborador colaborador = novoColaborador("ATENDENTE");

        dao.inserir(colaborador);

        Colaborador salvo = dao.buscarPorId(
            colaborador.getIdColaborador()
        );

        assertNotNull(salvo);
        assertEquals("ATENDENTE", salvo.getNivelAcesso());
        assertNotNull(salvo.getEmail());
        assertNotNull(salvo.getSenhaHash());
        assertTrue(salvo.isAtivo());
    }

    @Test
    void deveCadastrarOperacionalSemCredenciais() throws Exception {

        Colaborador colaborador = novoColaborador("OPERACIONAL");

        dao.inserir(colaborador);

        Colaborador salvo = dao.buscarPorId(
            colaborador.getIdColaborador()
        );

        assertNotNull(salvo);
        assertEquals("OPERACIONAL", salvo.getNivelAcesso());
        assertNull(salvo.getEmail());
        assertNull(salvo.getSenhaHash());
        assertTrue(salvo.isAtivo());
    }

    @Test
    void deveBuscarColaboradorPorId() throws Exception {

        Colaborador colaborador = dao.buscarPorId(401);

        assertNotNull(colaborador);
        assertEquals(401, colaborador.getIdColaborador());
        assertEquals("ADMINISTRADOR", colaborador.getNivelAcesso());
    }

    @Test
    void deveBuscarColaboradorPorEmail() throws Exception {

        Colaborador colaborador = dao.buscarPorEmail(
            "admin@example.test"
        );

        assertNotNull(colaborador);
        assertEquals(401, colaborador.getIdColaborador());
    }

    @Test
    void deveRetornarNuloParaIdInexistente() throws Exception {
        assertNull(dao.buscarPorId(999999));
    }

    @Test
    void deveRetornarNuloParaEmailInexistente() throws Exception {

        assertNull(
            dao.buscarPorEmail("inexistente@example.test")
        );
    }

    @Test
    void deveListarSomenteColaboradoresAtivos() throws Exception {

        List<Integer> ids = dao.listarTodos()
            .stream()
            .map(Colaborador::getIdColaborador)
            .toList();

        assertEquals(List.of(401, 402, 403, 404), ids);
    }

    @Test
    void deveImpedirEmailDuplicado() throws Exception {

        Colaborador colaborador = novoColaborador("ATENDENTE");

        colaborador.setEmail("admin@example.test");

        SQLException erro = assertThrows(
            SQLException.class,
            () -> dao.inserir(colaborador)
        );

        assertEquals(1062, erro.getErrorCode());
        assertEquals(4, dao.listarTodos().size());
    }

    @Test
    void deveImpedirNivelDeAcessoInvalido() {

        Colaborador colaborador = novoColaborador("INVALIDO");

        assertThrows(
            SQLException.class,
            () -> dao.inserir(colaborador)
        );
    }

    @Test
    void deveAtualizarDadosSemAlterarSenha() throws Exception {

        Colaborador colaborador = dao.buscarPorId(402);

        String hashOriginal = colaborador.getSenhaHash();

        colaborador.setNome("Atendente Atualizado");
        colaborador.setCargo("Supervisor Teste");
        colaborador.setEmail("atualizado@example.test");
        colaborador.setSenhaHash(null);

        dao.atualizar(colaborador, false);

        Colaborador atualizado = dao.buscarPorId(402);

        assertEquals("Atendente Atualizado", atualizado.getNome());
        assertEquals("Supervisor Teste", atualizado.getCargo());
        assertEquals("atualizado@example.test", atualizado.getEmail());
        assertEquals(hashOriginal, atualizado.getSenhaHash());
    }

    @Test
    void deveAtualizarDadosComNovaSenha() throws Exception {

        Colaborador colaborador = dao.buscarPorId(402);

        String novaSenha = "NovaSenhaTeste@456";

        colaborador.setSenhaHash(
            SenhaUtil.gerarHash(novaSenha)
        );

        dao.atualizar(colaborador, true);

        Colaborador atualizado = dao.buscarPorId(402);

        assertTrue(
            SenhaUtil.verificarSenha(
                novaSenha,
                atualizado.getSenhaHash()
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                "SenhaFicticia@123",
                atualizado.getSenhaHash()
            )
        );
    }

    @Test
    void deveAtualizarSomenteHashDaSenha() throws Exception {

        String novoHash = SenhaUtil.gerarHash("NovaSenhaTeste@456");

        dao.atualizarSenhaHash(402, novoHash);

        assertEquals(
            novoHash,
            dao.buscarPorId(402).getSenhaHash()
        );
    }

    @Test
    void deveImpedirAtualizacaoDeColaboradorInativo() throws Exception {

        Colaborador colaborador = dao.buscarPorId(405);

        String nomeOriginal = colaborador.getNome();

        colaborador.setNome("Alteracao Indevida");

        assertThrows(
            SQLException.class,
            () -> dao.atualizar(colaborador, false)
        );

        assertEquals(nomeOriginal, dao.buscarPorId(405).getNome());
    }

    @Test
    void deveImpedirAtualizacaoDeColaboradorExcluido() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        Colaborador colaborador = dao.buscarPorId(404);

        colaborador.setNome("Alteracao Indevida");

        assertThrows(
            SQLException.class,
            () -> dao.atualizar(colaborador, false)
        );
    }

    @Test
    void deveImpedirAtualizacaoDeSenhaDeInativo() throws Exception {

        String hashOriginal = dao.buscarPorId(405).getSenhaHash();

        dao.atualizarSenhaHash(
            405,
            SenhaUtil.gerarHash("NovaSenhaTeste@456")
        );

        assertEquals(
            hashOriginal,
            dao.buscarPorId(405).getSenhaHash()
        );
    }

    @Test
    void deveReverterAtualizacaoComEmailDuplicado() throws Exception {

        Colaborador colaborador = dao.buscarPorId(402);

        String nomeOriginal = colaborador.getNome();
        String emailOriginal = colaborador.getEmail();

        colaborador.setNome("Nome Alterado");
        colaborador.setEmail("admin@example.test");

        assertThrows(
            SQLException.class,
            () -> dao.atualizar(colaborador, false)
        );

        Colaborador atualizado = dao.buscarPorId(402);

        assertEquals(nomeOriginal, atualizado.getNome());
        assertEquals(emailOriginal, atualizado.getEmail());
    }

    @Test
    void devePromoverAtendenteParaAdministrador() throws Exception {

        Colaborador colaborador = dao.buscarPorId(402);

        colaborador.setNivelAcesso("ADMINISTRADOR");

        dao.atualizar(colaborador, false);

        assertEquals(
            "ADMINISTRADOR",
            dao.buscarPorId(402).getNivelAcesso()
        );

        assertEquals(2, contarAdministradoresAtivos());
    }

    @Test
    void deveImpedirRebaixamentoDoUltimoAdministrador()
            throws Exception {

        Colaborador colaborador = dao.buscarPorId(401);

        colaborador.setNivelAcesso("ATENDENTE");

        assertThrows(
            SQLException.class,
            () -> dao.atualizar(colaborador, false)
        );

        assertEquals(
            "ADMINISTRADOR",
            dao.buscarPorId(401).getNivelAcesso()
        );

        assertEquals(1, contarAdministradoresAtivos());
    }

    @Test
    void devePermitirRebaixamentoComOutroAdministrador()
            throws Exception {

        Colaborador segundoAdmin = novoColaborador("ADMINISTRADOR");

        dao.inserir(segundoAdmin);

        Colaborador primeiroAdmin = dao.buscarPorId(401);

        primeiroAdmin.setNivelAcesso("ATENDENTE");

        dao.atualizar(primeiroAdmin, false);

        assertEquals(
            "ATENDENTE",
            dao.buscarPorId(401).getNivelAcesso()
        );

        assertEquals(1, contarAdministradoresAtivos());
    }

    @Test
    void deveImpedirInativacaoDoProprioUsuario() throws Exception {

        assertEquals(
            PROPRIO_USUARIO,
            dao.inativarColaborador(401, 401)
        );

        assertTrue(dao.buscarPorId(401).isAtivo());
    }

    @Test
    void deveImpedirExclusaoDoProprioUsuario() throws Exception {

        assertEquals(
            PROPRIO_USUARIO,
            dao.excluirLogicamente(401, 401)
        );

        assertFalse(dao.buscarPorId(401).isExcluido());
    }

    @Test
    void deveImpedirInativacaoDoUltimoAdministrador()
            throws Exception {

        assertEquals(
            ULTIMO_ADMINISTRADOR,
            dao.inativarColaborador(401, 402)
        );

        assertEquals(1, contarAdministradoresAtivos());
    }

    @Test
    void deveImpedirExclusaoDoUltimoAdministrador()
            throws Exception {

        assertEquals(
            ULTIMO_ADMINISTRADOR,
            dao.excluirLogicamente(401, 402)
        );

        assertTrue(dao.buscarPorId(401).isAtivo());
        assertFalse(dao.buscarPorId(401).isExcluido());
    }

    @Test
    void devePermitirInativacaoComOutroAdministrador()
            throws Exception {

        Colaborador segundoAdmin = novoColaborador("ADMINISTRADOR");

        dao.inserir(segundoAdmin);

        assertEquals(
            SUCESSO,
            dao.inativarColaborador(
                401,
                segundoAdmin.getIdColaborador()
            )
        );

        assertFalse(dao.buscarPorId(401).isAtivo());
        assertEquals(1, contarAdministradoresAtivos());
    }

    @Test
    void deveImpedirInativacaoComPendencias() throws Exception {

        assertEquals(
            POSSUI_PENDENCIAS,
            dao.inativarColaborador(403, ADMIN)
        );

        assertTrue(dao.buscarPorId(403).isAtivo());
    }

    @Test
    void deveImpedirExclusaoComPendencias() throws Exception {

        assertEquals(
            POSSUI_PENDENCIAS,
            dao.excluirLogicamente(403, ADMIN)
        );

        assertTrue(dao.buscarPorId(403).isAtivo());
        assertFalse(dao.buscarPorId(403).isExcluido());
    }

    @Test
    void deveInativarColaboradorSemPendencias() throws Exception {

        assertEquals(SUCESSO, dao.inativarColaborador(404, ADMIN));

        Colaborador colaborador = dao.buscarPorId(404);

        assertFalse(colaborador.isAtivo());
        assertFalse(colaborador.isExcluido());
    }

    @Test
    void deveIdentificarColaboradorJaInativo() throws Exception {

        assertEquals(
            JA_INATIVO,
            dao.inativarColaborador(405, ADMIN)
        );
    }

    @Test
    void deveReativarColaborador() throws Exception {

        assertEquals(SUCESSO, dao.reativarColaborador(405, ADMIN));
        assertTrue(dao.buscarPorId(405).isAtivo());
    }

    @Test
    void deveIdentificarColaboradorJaAtivo() throws Exception {

        assertEquals(
            JA_ATIVO,
            dao.reativarColaborador(404, ADMIN)
        );
    }

    @Test
    void deveExcluirColaboradorLogicamente() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        Colaborador colaborador = dao.buscarPorId(404);

        assertNotNull(colaborador);
        assertFalse(colaborador.isAtivo());
        assertTrue(colaborador.isExcluido());
        assertNotNull(colaborador.getExcluidoEm());
    }

    @Test
    void deveIdentificarColaboradorJaExcluido() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        assertEquals(
            JA_EXCLUIDO,
            dao.excluirLogicamente(404, ADMIN)
        );
    }

    @Test
    void deveImpedirReativacaoDiretaDeExcluido() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        assertEquals(
            JA_EXCLUIDO,
            dao.reativarColaborador(404, ADMIN)
        );
    }

    @Test
    void deveRestaurarColaboradorExcluido() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));
        assertEquals(SUCESSO, dao.restaurarColaborador(404, ADMIN));

        Colaborador colaborador = dao.buscarPorId(404);

        assertTrue(colaborador.isAtivo());
        assertFalse(colaborador.isExcluido());
        assertNull(colaborador.getExcluidoEm());
    }

    @Test
    void deveImpedirRestauracaoDeNaoExcluido() throws Exception {

        assertEquals(
            NAO_EXCLUIDO,
            dao.restaurarColaborador(404, ADMIN)
        );
    }

    @Test
    void deveIdentificarColaboradorInexistenteNasOperacoes()
            throws Exception {

        assertEquals(
            COLABORADOR_NAO_ENCONTRADO,
            dao.inativarColaborador(999999, ADMIN)
        );

        assertEquals(
            COLABORADOR_NAO_ENCONTRADO,
            dao.reativarColaborador(999999, ADMIN)
        );

        assertEquals(
            COLABORADOR_NAO_ENCONTRADO,
            dao.excluirLogicamente(999999, ADMIN)
        );

        assertEquals(
            COLABORADOR_NAO_ENCONTRADO,
            dao.restaurarColaborador(999999, ADMIN)
        );
    }

    @Test
    void deveFiltrarColaboradoresAtivos() throws Exception {

        List<Integer> ids = dao.listarPorStatus("ativos")
            .stream()
            .map(Colaborador::getIdColaborador)
            .toList();

        assertEquals(List.of(401, 402, 403, 404), ids);
    }

    @Test
    void deveFiltrarColaboradoresInativos() throws Exception {

        List<Colaborador> colaboradores =
            dao.listarPorStatus("inativos");

        assertEquals(1, colaboradores.size());
        assertEquals(405, colaboradores.get(0).getIdColaborador());
    }

    @Test
    void deveFiltrarColaboradoresExcluidos() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        List<Colaborador> colaboradores =
            dao.listarPorStatus("excluidos");

        assertEquals(1, colaboradores.size());
        assertEquals(404, colaboradores.get(0).getIdColaborador());
    }

    @Test
    void devePreservarHistoricoAposExclusao() throws Exception {

        assertEquals(SUCESSO, dao.excluirLogicamente(404, ADMIN));

        try (
            Connection conexao = AmbienteTeste.conectar();
            var comando = conexao.createStatement();
            var resultado = comando.executeQuery("""
                SELECT COUNT(*)
                FROM colaborador_atendimento ca
                JOIN atendimento a
                    ON a.id_atendimento = ca.id_atendimento
                JOIN colaborador c
                    ON c.id_colaborador = ca.id_colaborador
                WHERE c.id_colaborador = 404
                  AND c.excluido_em IS NOT NULL
                  AND a.status = 'FINALIZADO'
                """)
        ) {
            assertTrue(resultado.next());
            assertEquals(2, resultado.getInt(1));
        }
    }
}
