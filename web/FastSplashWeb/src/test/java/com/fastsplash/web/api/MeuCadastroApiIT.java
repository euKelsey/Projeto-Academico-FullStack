package com.fastsplash.web.api;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class MeuCadastroApiIT extends BaseApiTeste {

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private static final String NOVO_NOME =
        "CLIENTE PERFIL ATUALIZADO";

    private static final String NOVO_TELEFONE =
        "11900000999";

    private static final String NOVO_EMAIL =
        "perfil-atualizado@example.test";

    private Map<String, String> dadosValidos() {

        Map<String, String> dados =
            new LinkedHashMap<>();

        dados.put("nome", NOVO_NOME);
        dados.put("telefone", NOVO_TELEFONE);
        dados.put("email", NOVO_EMAIL);

        return dados;
    }

    private Response atualizar(
            String sessao,
            Map<String, String> dados
    ) {

        return formularioAutenticado(sessao)

            .formParams(dados)

            .when()

            .post("/api/clientes/me");
    }

    private Response consultarPerfil(
            String sessao
    ) {

        return requisicaoAutenticada(sessao)

            .when()

            .get("/api/clientes/me");
    }

    private List<Object> capturarCliente(
            Cliente cliente
    ) {

        return Arrays.asList(
            cliente.getNome(),
            cliente.getCpf(),
            cliente.getTelefone(),
            cliente.getEmail(),
            cliente.getSenhaHash(),
            cliente.isAtivo(),
            cliente.getExcluidoEm()
        );
    }

    private Map<Integer, List<Object>>
            capturarTodosClientes() throws Exception {

        Map<Integer, List<Object>> registros =
            new LinkedHashMap<>();

        for (Cliente cliente :
                clienteDAO.listarTodosParaHistorico()) {

            registros.put(
                cliente.getIdCliente(),
                capturarCliente(cliente)
            );
        }

        return registros;
    }

    private List<List<Object>> consultarRegistros(
            String sql,
            int idCliente
    ) throws Exception {

        List<List<Object>> registros =
            new ArrayList<>();

        try (
            Connection conexao =
                AmbienteTeste.conectar();

            var comando =
                conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (var resultado =
                    comando.executeQuery()) {

                int colunas = resultado
                    .getMetaData()
                    .getColumnCount();

                while (resultado.next()) {

                    List<Object> linha =
                        new ArrayList<>();

                    for (int i = 1; i <= colunas; i++) {

                        linha.add(
                            resultado.getObject(i)
                        );
                    }

                    registros.add(linha);
                }
            }
        }

        return registros;
    }

    private Cliente atualizarComSucesso(
            String sessao,
            int idCliente
    ) throws Exception {

        var anteriores =
            capturarTodosClientes();

        Cliente original =
            clienteDAO.buscarPorId(idCliente);

        assertNotNull(original);

        Response resposta =
            atualizar(sessao, dadosValidos());

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Cadastro atualizado com sucesso."
                )
            )

            .body(
                "cliente.idCliente",
                equalTo(idCliente)
            )

            .body(
                "cliente.nome",
                equalTo(NOVO_NOME)
            )

            .body(
                "cliente.telefone",
                equalTo(NOVO_TELEFONE)
            )

            .body(
                "cliente.email",
                equalTo(NOVO_EMAIL)
            )

            .body(
                "cliente.cpf",
                equalTo(original.getCpf())
            );

        Cliente atual =
            clienteDAO.buscarPorId(idCliente);

        assertNotNull(atual);

        assertEquals(NOVO_NOME, atual.getNome());

        assertEquals(
            NOVO_TELEFONE,
            atual.getTelefone()
        );

        assertEquals(NOVO_EMAIL, atual.getEmail());

        assertEquals(
            original.getCpf(),
            atual.getCpf()
        );

        assertEquals(
            original.getSenhaHash(),
            atual.getSenhaHash()
        );

        assertEquals(
            original.isAtivo(),
            atual.isAtivo()
        );

        assertEquals(
            original.getExcluidoEm(),
            atual.getExcluidoEm()
        );

        assertTrue(atual.isAtivo());

        assertFalse(atual.isExcluido());

        anteriores.put(
            idCliente,
            capturarCliente(atual)
        );

        assertEquals(
            anteriores,
            capturarTodosClientes(),
            "A atualizacao alterou outros clientes."
        );

        return atual;
    }

    private void verificarAtualizacaoRejeitada(
            String sessao,
            Map<String, String> dados,
            int statusEsperado,
            String mensagemEsperada
    ) throws Exception {

        var anteriores =
            capturarTodosClientes();

        Response resposta =
            atualizar(sessao, dados);

        validarErro(
            resposta,
            statusEsperado
        );

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagemEsperada)
            );

        assertEquals(
            anteriores,
            capturarTodosClientes(),
            "Atualizacao rejeitada alterou o banco."
        );
    }

    private void verificarCampoObrigatorio(
            String campo
    ) throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.remove(campo);

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    // =========================================
    // CONSULTA E ATUALIZACAO CADASTRAL
    // =========================================

    @Test
    void deveConsultarDadosDoClienteAutenticado()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Cliente cliente =
            clienteDAO.buscarPorId(102);

        Response resposta =
            consultarPerfil(sessao);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.idCliente",
                equalTo(102)
            )

            .body(
                "cliente.nome",
                equalTo(cliente.getNome())
            )

            .body(
                "cliente.cpf",
                equalTo(cliente.getCpf())
            )

            .body(
                "cliente.telefone",
                equalTo(cliente.getTelefone())
            )

            .body(
                "cliente.email",
                equalTo(cliente.getEmail())
            );
    }

    @Test
    void deveAtualizarDadosCadastrais()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        atualizarComSucesso(
            sessao,
            102
        );
    }

    @Test
    void deveConsultarDadosAtualizadosNaMesmaSessao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        atualizarComSucesso(
            sessao,
            102
        );

        consultarPerfil(sessao)

            .then()

            .log().ifValidationFails()

            .statusCode(200)

            .body(
                "sucesso",
                equalTo(true)
            )

            .body(
                "cliente.idCliente",
                equalTo(102)
            )

            .body(
                "cliente.nome",
                equalTo(NOVO_NOME)
            )

            .body(
                "cliente.telefone",
                equalTo(NOVO_TELEFONE)
            )

            .body(
                "cliente.email",
                equalTo(NOVO_EMAIL)
            );
    }

    @Test
    void deveAutenticarComNovoEmailAposAtualizacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        atualizarComSucesso(
            sessao,
            102
        );

        validarErro(

            realizarLogin(
                EMAIL_CLIENTE_LIVRE,
                SENHA_TESTE
            ),

            401
        );

        String novaSessao =
            autenticarCliente(
                NOVO_EMAIL,
                SENHA_TESTE,
                102
            );

        consultarPerfil(novaSessao)

            .then()

            .statusCode(200)

            .body(
                "cliente.email",
                equalTo(NOVO_EMAIL)
            )

            .body(
                "cliente.idCliente",
                equalTo(102)
            );
    }

    // =========================================
    // AUTENTICACAO E CONTROLE DE ACESSO
    // =========================================

    @Test
    void deveBloquearAtualizacaoSemAutenticacao()
            throws Exception {

        var anteriores =
            capturarTodosClientes();

        Response resposta =
            requisicaoFormulario()

                .formParams(dadosValidos())

                .when()

                .post("/api/clientes/me");

        validarErro(resposta, 401);

        assertEquals(
            anteriores,
            capturarTodosClientes()
        );
    }

    @Test
    void deveBloquearAtualizacaoComSessaoInvalida()
            throws Exception {

        verificarAtualizacaoRejeitada(
            "SESSAO_INVALIDA_PERFIL_123",
            dadosValidos(),
            401,
            "Cliente não autenticado."
        );
    }

    @Test
    void deveBloquearAtualizacaoAposInativacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.inativarCliente(102)
        );

        var anteriores =
            capturarTodosClientes();

        Response resposta =
            atualizar(sessao, dadosValidos());

        resposta.then()

            .log().ifValidationFails()

            .statusCode(anyOf(
                is(401),
                is(403)
            ))

            .body(
                "sucesso",
                equalTo(false)
            );

        assertEquals(
            anteriores,
            capturarTodosClientes()
        );
    }

    @Test
    void deveBloquearAtualizacaoAposExclusao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusCliente.SUCESSO,
            clienteDAO.excluirLogicamente(102)
        );

        var anteriores =
            capturarTodosClientes();

        Response resposta =
            atualizar(sessao, dadosValidos());

        resposta.then()

            .log().ifValidationFails()

            .statusCode(anyOf(
                is(401),
                is(403)
            ))

            .body(
                "sucesso",
                equalTo(false)
            );

        assertEquals(
            anteriores,
            capturarTodosClientes()
        );
    }

    // =========================================
    // CAMPOS OBRIGATORIOS E VALIDACOES
    // =========================================

    @Test
    void deveRejeitarAtualizacaoSemNome()
            throws Exception {

        verificarCampoObrigatorio("nome");
    }

    @Test
    void deveRejeitarAtualizacaoSemTelefone()
            throws Exception {

        verificarCampoObrigatorio("telefone");
    }

    @Test
    void deveRejeitarAtualizacaoSemEmail()
            throws Exception {

        verificarCampoObrigatorio("email");
    }

    @Test
    void deveRejeitarNomeEmBranco()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put("nome", "   ");

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    @Test
    void deveRejeitarEmailSemArroba()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "email",
            "email-invalido.example.test"
        );

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            400,
            "Informe um e-mail válido."
        );
    }

    // =========================================
    // DUPLICIDADES
    // =========================================

    @Test
    void deveRejeitarEmailDeOutroClienteAtivo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "email",
            EMAIL_CLIENTE_ATIVO
        );

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            409,
            "Este e-mail já está sendo utilizado."
        );
    }

    @Test
    void deveRejeitarEmailDeClienteInativo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "email",
            EMAIL_CLIENTE_INATIVO
        );

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            409,
            "Este e-mail já está sendo utilizado."
        );
    }

    @Test
    void deveRejeitarEmailDeClienteExcluido()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "email",
            EMAIL_CLIENTE_EXCLUIDO
        );

        verificarAtualizacaoRejeitada(
            sessao,
            dados,
            409,
            "Este e-mail já está sendo utilizado."
        );
    }

    // =========================================
    // INTEGRIDADE E SEGURANCA CADASTRAL
    // =========================================

    @Test
    void naoDevePermitirAlteracaoDeOutroCliente()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var anteriores =
            capturarTodosClientes();

        var dados = dadosValidos();

        dados.put("idCliente", "101");

        Response resposta =
            atualizar(sessao, dados);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.idCliente",
                equalTo(102)
            );

        Cliente cliente102 =
            clienteDAO.buscarPorId(102);

        assertEquals(
            NOVO_NOME,
            cliente102.getNome()
        );

        assertEquals(
            NOVO_EMAIL,
            cliente102.getEmail()
        );

        anteriores.put(
            102,
            capturarCliente(cliente102)
        );

        assertEquals(
            anteriores,
            capturarTodosClientes()
        );

        String sessaoOutro =
            autenticarClienteAtivo();

        consultarPerfil(sessaoOutro)

            .then()

            .statusCode(200)

            .body(
                "cliente.idCliente",
                equalTo(101)
            )

            .body(
                "cliente.email",
                equalTo(EMAIL_CLIENTE_ATIVO)
            );
    }

    @Test
    void naoDevePermitirAlteracaoDeCpfPeloPerfil()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        String cpfOriginal =
            clienteDAO.buscarPorId(102)
                .getCpf();

        var dados = dadosValidos();

        dados.put(
            "cpf",
            "98765410564"
        );

        Response resposta =
            atualizar(sessao, dados);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "cliente.cpf",
                equalTo(cpfOriginal)
            );

        assertEquals(
            cpfOriginal,
            clienteDAO.buscarPorId(102)
                .getCpf()
        );
    }

    @Test
    void naoDevePermitirAlteracaoIndevidaDaSenha()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        String hashAnterior =
            clienteDAO.buscarPorId(102)
                .getSenhaHash();

        var dados = dadosValidos();

        String senhaIndevida =
            "SenhaIndevida@123";

        dados.put(
            "senha",
            senhaIndevida
        );

        dados.put(
            "confirmarSenha",
            senhaIndevida
        );

        Response resposta =
            atualizar(sessao, dados);

        validarSucesso(resposta, 200);

        String hashAtual =
            clienteDAO.buscarPorId(102)
                .getSenhaHash();

        assertEquals(
            hashAnterior,
            hashAtual
        );

        assertTrue(
            SenhaUtil.verificarSenha(
                SENHA_TESTE,
                hashAtual
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                senhaIndevida,
                hashAtual
            )
        );

        autenticarCliente(
            NOVO_EMAIL,
            SENHA_TESTE,
            102
        );

        validarErro(

            realizarLogin(
                NOVO_EMAIL,
                senhaIndevida
            ),

            401
        );
    }

    @Test
    void naoDeveExporSenhaOuHashNoPerfil()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        String hash =
            clienteDAO.buscarPorId(102)
                .getSenhaHash();

        Response consulta =
            consultarPerfil(sessao);

        Response atualizacao =
            atualizar(sessao, dadosValidos());

        for (Response resposta :
                List.of(consulta, atualizacao)) {

            validarSucesso(resposta, 200);

            Map<String, Object> cliente =
                resposta.jsonPath()
                    .getMap("cliente");

            assertEquals(
                Set.of(
                    "idCliente",
                    "nome",
                    "cpf",
                    "telefone",
                    "email"
                ),
                cliente.keySet()
            );

            assertFalse(
                resposta.asString()
                    .contains(SENHA_TESTE)
            );

            assertFalse(
                resposta.asString()
                    .contains(hash)
            );
        }
    }

    // =========================================
    // PRESERVACAO DOS RELACIONAMENTOS
    // =========================================

    @Test
    void devePreservarVeiculosVinculadosAoCliente()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        String sql = """
            SELECT *
            FROM veiculo
            WHERE id_cliente = ?
            ORDER BY id_veiculo
            """;

        var veiculosAnteriores =
            consultarRegistros(sql, 101);

        assertEquals(
            2,
            veiculosAnteriores.size()
        );

        atualizarComSucesso(
            sessao,
            101
        );

        assertEquals(
            veiculosAnteriores,
            consultarRegistros(sql, 101)
        );
    }

    @Test
    void devePreservarHistoricoOperacionalEFinanceiro()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        String sqlAgendamentos = """
            SELECT a.*
            FROM agendamento a
            INNER JOIN veiculo v
                ON v.id_veiculo = a.id_veiculo
            WHERE v.id_cliente = ?
            ORDER BY a.id_agendamento
            """;

        String sqlServicos = """
            SELECT ags.*
            FROM agendamento_servico ags
            INNER JOIN agendamento a
                ON a.id_agendamento = ags.id_agendamento
            INNER JOIN veiculo v
                ON v.id_veiculo = a.id_veiculo
            WHERE v.id_cliente = ?
            ORDER BY ags.id_agendamento, ags.id_servico
            """;

        String sqlAtendimentos = """
            SELECT t.*
            FROM atendimento t
            INNER JOIN agendamento a
                ON a.id_agendamento = t.id_agendamento
            INNER JOIN veiculo v
                ON v.id_veiculo = a.id_veiculo
            WHERE v.id_cliente = ?
            ORDER BY t.id_atendimento
            """;

        String sqlPagamentos = """
            SELECT p.*
            FROM pagamento p
            INNER JOIN agendamento a
                ON a.id_agendamento = p.id_agendamento
            INNER JOIN veiculo v
                ON v.id_veiculo = a.id_veiculo
            WHERE v.id_cliente = ?
            ORDER BY p.id_pagamento
            """;

        List<String> consultas = List.of(
            sqlAgendamentos,
            sqlServicos,
            sqlAtendimentos,
            sqlPagamentos
        );

        List<Integer> quantidadesEsperadas =
            List.of(5, 6, 4, 5);

        Map<String, List<List<Object>>> anteriores =
            new LinkedHashMap<>();

        for (int i = 0; i < consultas.size(); i++) {

            String sql = consultas.get(i);

            var registros =
                consultarRegistros(sql, 101);

            assertEquals(
                quantidadesEsperadas.get(i).intValue(),
                registros.size()
            );

            anteriores.put(
                sql,
                registros
            );
        }

        atualizarComSucesso(
            sessao,
            101
        );

        for (String sql : consultas) {

            assertEquals(
                anteriores.get(sql),
                consultarRegistros(sql, 101),
                "A atualizacao alterou o historico."
            );
        }
    }
}
