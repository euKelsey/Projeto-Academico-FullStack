package com.fastsplash.web.api;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Atendimento;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class SegurancaApiIT extends BaseApiTeste {

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private static final String EMAIL_NOVO =
        "integracao@example.test";

    private static final String SENHA_NOVA =
        "IntegracaoFicticia@123";

    private Map<String, String> dadosCadastro() {

        Map<String, String> dados =
            new LinkedHashMap<>();

        dados.put(
            "nome",
            "CLIENTE INTEGRACAO TESTE"
        );

        dados.put("cpf", "98765410564");
        dados.put("telefone", "11900000105");
        dados.put("email", EMAIL_NOVO);
        dados.put("senha", SENHA_NOVA);
        dados.put("confirmarSenha", SENHA_NOVA);

        return dados;
    }

    private Response cadastrar(
            Map<String, String> dados
    ) {

        return requisicaoFormulario()

            .formParams(dados)

            .when()

            .post("/api/clientes");
    }

    private Response enviar(
            String sessao,
            String rota,
            Map<String, ?> dados
    ) {

        return formularioAutenticado(sessao)

            .formParams(dados)

            .when()

            .post(rota);
    }

    private Response consultar(
            String sessao,
            String rota
    ) {

        return requisicaoAutenticada(sessao)

            .when()

            .get(rota);
    }

    private int cadastrarVeiculo(
            String sessao
    ) {

        Response resposta = enviar(

            sessao,

            "/api/veiculos",

            Map.of(
                "placa", "TST1B09",
                "marca", "FIAT",
                "modelo", "PULSE",
                "cor", "BRANCO"
            )
        );

        validarSucesso(resposta, 201);

        return resposta.jsonPath()
            .getInt("veiculo.idVeiculo");
    }

    private Map<String, Object> dadosAgendamento(
            int idVeiculo
    ) {

        Map<String, Object> dados =
            new LinkedHashMap<>();

        dados.put(
            "idVeiculo",
            String.valueOf(idVeiculo)
        );

        dados.put(
            "data",
            LocalDate.now()
                .plusDays(7)
                .toString()
        );

        dados.put("horario", "10:30");

        dados.put(
            "idServico",
            List.of("301", "302")
        );

        return dados;
    }

    private int criarAgendamento(
            String sessao,
            int idVeiculo
    ) {

        Response resposta = enviar(

            sessao,

            "/api/agendamentos",

            dadosAgendamento(idVeiculo)
        );

        validarSucesso(resposta, 201);

        return resposta.jsonPath()
            .getInt("agendamento.idAgendamento");
    }

    private Response pagar(
            String sessao,
            int idAgendamento,
            String forma
    ) {

        return enviar(

            sessao,

            "/api/pagamentos/pagar",

            Map.of(
                "idAgendamento",
                String.valueOf(idAgendamento),

                "formaPagamento",
                forma
            )
        );
    }

    private List<List<Object>> consultarBanco(
            String sql
    ) throws Exception {

        List<List<Object>> registros =
            new ArrayList<>();

        try (
            Connection conexao =
                AmbienteTeste.conectar();

            var comando =
                conexao.createStatement();

            var resultado =
                comando.executeQuery(sql)
        ) {

            int colunas =
                resultado.getMetaData()
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

        return registros;
    }

    private long contar(String sql)
            throws Exception {

        return ((Number)

            consultarBanco(sql)
                .get(0)
                .get(0)

        ).longValue();
    }

    private Map<String, List<List<Object>>>
            capturarBanco() throws Exception {

        Map<String, List<List<Object>>> estado =
            new LinkedHashMap<>();

        Map<String, String> tabelas = Map.of(

            "cliente",
            "id_cliente",

            "veiculo",
            "id_veiculo",

            "servico",
            "id_servico",

            "colaborador",
            "id_colaborador",

            "agendamento",
            "id_agendamento",

            "atendimento",
            "id_atendimento",

            "pagamento",
            "id_pagamento",

            "agendamento_servico",
            "id_agendamento, id_servico",

            "colaborador_atendimento",
            "id_colaborador, id_atendimento"
        );

        for (var tabela : tabelas.entrySet()) {

            estado.put(

                tabela.getKey(),

                consultarBanco(
                    "SELECT * FROM "
                    + tabela.getKey()
                    + " ORDER BY "
                    + tabela.getValue()
                )
            );
        }

        return estado;
    }

    private void verificarPagamentoBanco(
            int idAgendamento,
            String valorEsperado,
            String formaEsperada
    ) throws Exception {

        var registros =
            consultarBanco("""
                SELECT
                    status_pagamento,
                    valor,
                    forma_pagamento,
                    data_pagamento
                FROM pagamento
                WHERE id_agendamento = %d
                """.formatted(idAgendamento));

        assertEquals(1, registros.size());

        var pagamento = registros.get(0);

        assertEquals(
            "PAGO",
            pagamento.get(0)
        );

        assertEquals(

            0,

            new BigDecimal(valorEsperado)
                .compareTo(
                    new BigDecimal(
                        pagamento.get(1).toString()
                    )
                )
        );

        assertEquals(
            formaEsperada,
            pagamento.get(2)
        );

        assertNotNull(
            pagamento.get(3)
        );
    }

    private List<Response> executarSimultaneamente(
            Callable<Response> primeira,
            Callable<Response> segunda
    ) throws Exception {

        var executor =
            Executors.newFixedThreadPool(2);

        CountDownLatch prontas =
            new CountDownLatch(2);

        CountDownLatch iniciar =
            new CountDownLatch(1);

        try {

            var tarefa1 = executor.submit(() -> {

                prontas.countDown();

                if (!iniciar.await(
                        10,
                        TimeUnit.SECONDS
                )) {

                    throw new IllegalStateException(
                        "Tempo excedido na sincronizacao."
                    );
                }

                return primeira.call();
            });

            var tarefa2 = executor.submit(() -> {

                prontas.countDown();

                if (!iniciar.await(
                        10,
                        TimeUnit.SECONDS
                )) {

                    throw new IllegalStateException(
                        "Tempo excedido na sincronizacao."
                    );
                }

                return segunda.call();
            });

            assertTrue(

                prontas.await(
                    10,
                    TimeUnit.SECONDS
                ),

                "As requisicoes nao ficaram prontas."
            );

            iniciar.countDown();

            Response resposta1 =
                tarefa1.get(
                    30,
                    TimeUnit.SECONDS
                );

            Response resposta2 =
                tarefa2.get(
                    30,
                    TimeUnit.SECONDS
                );

            return List.of(
                resposta1,
                resposta2
            );

        } finally {

            iniciar.countDown();

            executor.shutdown();

            if (!executor.awaitTermination(
                    30,
                    TimeUnit.SECONDS
            )) {

                executor.shutdownNow();

                assertTrue(
                    executor.awaitTermination(
                        15,
                        TimeUnit.SECONDS
                    )
                );
            }
        }
    }

    private Response verificarUnicoSucesso(
            List<Response> respostas,
            int statusSucesso,
            int statusRejeicao
    ) {

        var status = respostas.stream()

            .map(Response::statusCode)

            .sorted()

            .toList();

        assertEquals(

            List.of(
                statusSucesso,
                statusRejeicao
            ),

            status,

            () -> respostas.stream()
                .map(r ->
                    r.statusCode()
                    + ": "
                    + r.asString()
                )
                .toList()
                .toString()
        );

        Response sucesso = respostas.stream()

            .filter(r ->
                r.statusCode() == statusSucesso
            )

            .findFirst()

            .orElseThrow();

        Response rejeicao = respostas.stream()

            .filter(r ->
                r.statusCode() == statusRejeicao
            )

            .findFirst()

            .orElseThrow();

        validarSucesso(
            sucesso,
            statusSucesso
        );

        validarErro(
            rejeicao,
            statusRejeicao
        );

        return sucesso;
    }

    // =========================================
    // JORNADA COMPLETA
    // =========================================

    @Test
    void deveExecutarJornadaCompletaDoCliente()
            throws Exception {

        Response cadastro =
            cadastrar(dadosCadastro());

        validarSucesso(cadastro, 201);

        int idCliente = cadastro.jsonPath()
            .getInt("idCliente");

        String sessao = autenticarCliente(
            EMAIL_NOVO,
            SENHA_NOVA,
            idCliente
        );

        int idVeiculo =
            cadastrarVeiculo(sessao);

        int idAgendamento =
            criarAgendamento(
                sessao,
                idVeiculo
            );

        Atendimento atendimento =
            new Atendimento();

        atendimento.setIdAgendamento(
            idAgendamento
        );

        atendimentoDAO.inserir(atendimento);

        int idAtendimento =
            atendimento.getIdAtendimento();

        assertTrue(idAtendimento > 0);

        assertThrows(

            java.sql.SQLException.class,

            () ->
                atendimentoDAO.iniciarLavagem(
                    idAtendimento
                )
        );

        validarSucesso(

            pagar(
                sessao,
                idAgendamento,
                "PIX"
            ),

            200
        );

        verificarPagamentoBanco(
            idAgendamento,
            "130.00",
            "PIX"
        );

        atendimentoDAO.iniciarLavagem(
            idAtendimento
        );

        consultar(
            sessao,
            "/api/agendamentos"
        )

            .then()

            .statusCode(200)

            .body(
                "agendamentos[0].status",
                equalTo("Em andamento")
            );

        atendimentoDAO.finalizar(
            idAtendimento
        );

        assertEquals(

            "CONCLUIDO",

            agendamentoDAO.buscarPorId(
                idAgendamento
            ).getStatus()
        );

        consultar(
            sessao,
            "/api/agendamentos"
        )

            .then()

            .statusCode(200)

            .body(
                "agendamentos.size()",
                equalTo(1)
            )

            .body(
                "agendamentos[0].idAgendamento",
                equalTo(idAgendamento)
            )

            .body(
                "agendamentos[0].status",
                equalTo("Finalizado")
            );

        consultar(
            sessao,
            "/api/pagamentos"
        )

            .then()

            .statusCode(200)

            .body(
                "pagamentos.size()",
                equalTo(1)
            )

            .body(
                "pagamentos[0].statusPagamento",
                equalTo("PAGO")
            );

        verificarPagamentoBanco(
            idAgendamento,
            "130.00",
            "PIX"
        );
    }

    @Test
    void deveIsolarOperacoesEntreClientes()
            throws Exception {

        String sessaoA =
            autenticarClienteAtivo();

        String sessaoB =
            autenticarClienteLivre();

        int idAgendamento =
            criarAgendamento(
                sessaoB,
                203
            );

        var anterior =
            capturarBanco();

        validarErro(

            pagar(
                sessaoA,
                idAgendamento,
                "PIX"
            ),

            404
        );

        validarErro(

            enviar(

                sessaoA,

                "/api/agendamentos/cancelar",

                Map.of(
                    "idAgendamento",
                    String.valueOf(idAgendamento)
                )
            ),

            409
        );

        assertEquals(
            anterior,
            capturarBanco()
        );

        validarSucesso(

            pagar(
                sessaoB,
                idAgendamento,
                "PIX"
            ),

            200
        );

        consultar(
            sessaoA,
            "/api/pagamentos"
        )

            .then()

            .statusCode(200)

            .body(
                "pagamentos.idAgendamento",
                not(hasItem(idAgendamento))
            );

        consultar(
            sessaoB,
            "/api/pagamentos"
        )

            .then()

            .statusCode(200)

            .body(
                "pagamentos.idAgendamento",
                hasItem(idAgendamento)
            );

        verificarPagamentoBanco(
            idAgendamento,
            "130.00",
            "PIX"
        );
    }

    // =========================================
    // REVOGACAO DE ACESSO
    // =========================================

    private void verificarRevogacao(
            String sessao
    ) throws Exception {

        var anterior =
            capturarBanco();

        List<String> rotas = List.of(

            "/api/clientes/me",
            "/api/veiculos",
            "/api/agendamentos",
            "/api/pagamentos"
        );

        for (String rota : rotas) {

            Response resposta =
                consultar(sessao, rota);

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
        }

        Response tentativaCadastro = enviar(

            sessao,

            "/api/veiculos",

            Map.of(
                "placa", "TST1B09",
                "marca", "FIAT",
                "modelo", "PULSE",
                "cor", "BRANCO"
            )
        );

        tentativaCadastro.then()

            .statusCode(anyOf(
                is(401),
                is(403)
            ))

            .body(
                "sucesso",
                equalTo(false)
            );

        assertEquals(
            anterior,
            capturarBanco()
        );
    }

    @Test
    void deveRevogarAcessoAposInativacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(

            ResultadoStatusCliente.SUCESSO,

            clienteDAO.inativarCliente(102)
        );

        verificarRevogacao(sessao);
    }

    @Test
    void deveRevogarAcessoAposExclusaoLogica()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(

            ResultadoStatusCliente.SUCESSO,

            clienteDAO.excluirLogicamente(102)
        );

        verificarRevogacao(sessao);
    }

    // =========================================
    // CONCORRENCIA DE PAGAMENTOS
    // =========================================

    @Test
    void deveImpedirPagamentosSimultaneosExistentes()
            throws Exception {

        String sessaoA =
            autenticarClienteAtivo();

        String sessaoB =
            autenticarClienteAtivo();

        long quantidadeAnterior = contar(
            "SELECT COUNT(*) FROM pagamento"
        );

        var respostas =
            executarSimultaneamente(

                () -> pagar(
                    sessaoA,
                    501,
                    "PIX"
                ),

                () -> pagar(
                    sessaoB,
                    501,
                    "CREDITO"
                )
            );

        verificarUnicoSucesso(
            respostas,
            200,
            404
        );

        String formaVencedora =
            respostas.get(0).statusCode() == 200
                ? "PIX"
                : "CREDITO";

        verificarPagamentoBanco(
            501,
            "50.00",
            formaVencedora
        );

        assertEquals(

            quantidadeAnterior,

            contar(
                "SELECT COUNT(*) FROM pagamento"
            )
        );

        assertEquals(

            1L,

            contar("""
                SELECT COUNT(*)
                FROM pagamento
                WHERE id_pagamento = 701
                  AND id_agendamento = 501
                  AND status_pagamento = 'PAGO'
                """)
        );
    }

    @Test
    void deveImpedirPagamentosSimultaneosNovos()
            throws Exception {

        String sessaoA =
            autenticarClienteLivre();

        String sessaoB =
            autenticarClienteLivre();

        int idAgendamento =
            criarAgendamento(
                sessaoA,
                203
            );

        long quantidadeAnterior = contar(
            "SELECT COUNT(*) FROM pagamento"
        );

        var respostas =
            executarSimultaneamente(

                () -> pagar(
                    sessaoA,
                    idAgendamento,
                    "PIX"
                ),

                () -> pagar(
                    sessaoB,
                    idAgendamento,
                    "DEBITO"
                )
            );

        verificarUnicoSucesso(
            respostas,
            200,
            404
        );

        String formaVencedora =
            respostas.get(0).statusCode() == 200
                ? "PIX"
                : "DEBITO";

        verificarPagamentoBanco(
            idAgendamento,
            "130.00",
            formaVencedora
        );

        assertEquals(

            quantidadeAnterior + 1,

            contar(
                "SELECT COUNT(*) FROM pagamento"
            )
        );
    }

    // =========================================
    // CONCORRENCIA DE AGENDAMENTOS
    // =========================================

    @Test
    void deveImpedirAgendamentosSimultaneosDuplicados()
            throws Exception {

        String sessaoA =
            autenticarClienteLivre();

        String sessaoB =
            autenticarClienteLivre();

        var dados =
            dadosAgendamento(203);

        long quantidadeAnterior = contar(
            "SELECT COUNT(*) FROM agendamento"
        );

        long servicosAnteriores = contar(
            "SELECT COUNT(*) FROM agendamento_servico"
        );

        var respostas =
            executarSimultaneamente(

                () -> enviar(
                    sessaoA,
                    "/api/agendamentos",
                    dados
                ),

                () -> enviar(
                    sessaoB,
                    "/api/agendamentos",
                    dados
                )
            );

        Response sucesso =
            verificarUnicoSucesso(
                respostas,
                201,
                409
            );

        int id = sucesso.jsonPath()
            .getInt("agendamento.idAgendamento");

        assertNotNull(
            agendamentoDAO.buscarPorId(id)
        );

        assertEquals(

            quantidadeAnterior + 1,

            contar(
                "SELECT COUNT(*) FROM agendamento"
            )
        );

        assertEquals(

            servicosAnteriores + 2,

            contar(
                "SELECT COUNT(*) FROM agendamento_servico"
            )
        );

        assertEquals(

            2L,

            contar("""
                SELECT COUNT(*)
                FROM agendamento_servico
                WHERE id_agendamento = %d
                """.formatted(id))
        );
    }

    // =========================================
    // CONCORRENCIA DE CADASTROS
    // =========================================

    @Test
    void deveImpedirCadastrosSimultaneosComMesmoCpf()
            throws Exception {

        var dadosA =
            dadosCadastro();

        var dadosB =
            dadosCadastro();

        dadosB.put(
            "email",
            "integracao-b@example.test"
        );

        long quantidadeAnterior = contar(
            "SELECT COUNT(*) FROM cliente"
        );

        var respostas =
            executarSimultaneamente(

                () -> cadastrar(dadosA),

                () -> cadastrar(dadosB)
            );

        verificarUnicoSucesso(
            respostas,
            201,
            409
        );

        assertEquals(

            quantidadeAnterior + 1,

            contar(
                "SELECT COUNT(*) FROM cliente"
            )
        );

        assertEquals(

            1L,

            contar("""
                SELECT COUNT(*)
                FROM cliente
                WHERE cpf = '98765410564'
                """)
        );
    }

    @Test
    void deveImpedirCadastrosSimultaneosComMesmoEmail()
            throws Exception {

        var dadosA =
            dadosCadastro();

        var dadosB =
            dadosCadastro();

        dadosB.put(
            "cpf",
            "98765410645"
        );

        long quantidadeAnterior = contar(
            "SELECT COUNT(*) FROM cliente"
        );

        var respostas =
            executarSimultaneamente(

                () -> cadastrar(dadosA),

                () -> cadastrar(dadosB)
            );

        verificarUnicoSucesso(
            respostas,
            201,
            409
        );

        assertEquals(

            quantidadeAnterior + 1,

            contar(
                "SELECT COUNT(*) FROM cliente"
            )
        );

        assertEquals(

            1L,

            contar("""
                SELECT COUNT(*)
                FROM cliente
                WHERE email = 'integracao@example.test'
                """)
        );
    }

    // =========================================
    // PROTECAO CONTRA ENTRADAS MALICIOSAS
    // =========================================

    @Test
    void deveRejeitarSqlInjectionNoLogin()
            throws Exception {

        var anterior =
            capturarBanco();

        Response resposta = realizarLogin(

            "' OR '1'='1",

            "' OR '1'='1"
        );

        validarErro(resposta, 401);

        resposta.then()

            .body(
                "cliente",
                nullValue()
            );

        String sessao =
            resposta.getCookie(COOKIE_SESSAO);

        if (sessao != null && !sessao.isBlank()) {

            validarErro(

                consultar(
                    sessao,
                    "/api/clientes/me"
                ),

                401
            );
        }

        assertEquals(
            anterior,
            capturarBanco()
        );
    }

    @Test
    void deveRejeitarSqlInjectionNoIdDoVeiculo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var anterior =
            capturarBanco();

        Response resposta = enviar(

            sessao,

            "/api/veiculos/excluir",

            Map.of(
                "idVeiculo",
                "203 OR 1=1"
            )
        );

        validarErro(
            resposta,
            400
        );

        resposta.then()

            .body(
                "mensagem",
                equalTo("Veículo inválido.")
            );

        assertEquals(
            anterior,
            capturarBanco()
        );
    }

    @Test
    void devePreservarCaracteresEspeciaisNoJson()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        String nome =
            "CLIENTE \"TESTE\" \\ JOÃO";

        Response resposta = enviar(

            sessao,

            "/api/clientes/me",

            Map.of(
                "nome",
                nome,

                "telefone",
                "11900000102",

                "email",
                EMAIL_CLIENTE_LIVRE
            )
        );

        validarSucesso(
            resposta,
            200
        );

        resposta.then()

            .body(
                "cliente.nome",
                equalTo(nome)
            );

        assertEquals(

            nome,

            clienteDAO.buscarPorId(102)
                .getNome()
        );

        consultar(
            sessao,
            "/api/clientes/me"
        )

            .then()

            .statusCode(200)

            .body(
                "cliente.nome",
                equalTo(nome)
            );
    }
}
