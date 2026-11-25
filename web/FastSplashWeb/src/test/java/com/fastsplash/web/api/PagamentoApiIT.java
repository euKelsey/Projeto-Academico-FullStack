package com.fastsplash.web.api;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Servico;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.math.BigDecimal;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class PagamentoApiIT extends BaseApiTeste {

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private final ServicoDAO servicoDAO =
        new ServicoDAO();

    private final PagamentoDAO pagamentoDAO =
        new PagamentoDAO();

    private static final String ROTA =
        "/api/pagamentos";

    private static final String ROTA_PAGAR =
        "/api/pagamentos/pagar";

    private static final String ERRO_AGENDAMENTO =
        "Agendamento inválido.";

    private static final String ERRO_FORMA =
        "Forma de pagamento inválida.";

    private static final String ERRO_INDISPONIVEL =
        "Pagamento indisponível. Verifique se o "
        + "agendamento está disponível e se o "
        + "pagamento já foi realizado.";

    private Response listar(String sessao) {

        Response resposta =
            requisicaoAutenticada(sessao)

                .when()

                .get(ROTA);

        validarSucesso(resposta, 200);

        return resposta;
    }

    private Response enviarPagamento(
            String sessao,
            Map<String, String> dados
    ) {

        return formularioAutenticado(sessao)

            .formParams(dados)

            .when()

            .post(ROTA_PAGAR);
    }

    private Response pagar(
            String sessao,
            int idAgendamento,
            String forma
    ) {

        return enviarPagamento(

            sessao,

            Map.of(
                "idAgendamento",
                String.valueOf(idAgendamento),

                "formaPagamento",
                forma
            )
        );
    }

    private Map<String, Object> localizarPagamento(
            Response resposta,
            int idAgendamento
    ) {

        List<Map<String, Object>> registros =
            resposta.jsonPath()
                .getList("pagamentos");

        return registros.stream()

            .filter(p ->
                ((Number) p.get("idAgendamento"))
                    .intValue() == idAgendamento
            )

            .findFirst()

            .orElseThrow();
    }

    private List<List<Object>> consultarRegistros(
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

        return registros;
    }

    private List<List<Object>> capturarPagamentos()
            throws Exception {

        return consultarRegistros("""
            SELECT *
            FROM pagamento
            ORDER BY id_pagamento
            """);
    }

    private Map<String, List<List<Object>>>
            capturarEstado() throws Exception {

        Map<String, List<List<Object>>> estado =
            new LinkedHashMap<>();

        estado.put(
            "pagamento",
            capturarPagamentos()
        );

        estado.put(
            "agendamento",
            consultarRegistros("""
                SELECT *
                FROM agendamento
                ORDER BY id_agendamento
                """)
        );

        estado.put(
            "agendamento_servico",
            consultarRegistros("""
                SELECT *
                FROM agendamento_servico
                ORDER BY id_agendamento, id_servico
                """)
        );

        estado.put(
            "atendimento",
            consultarRegistros("""
                SELECT *
                FROM atendimento
                ORDER BY id_atendimento
                """)
        );

        return estado;
    }

    private Map<String, Object> consultarPagamentoBanco(
            int idAgendamento
    ) throws Exception {

        try (
            Connection conexao =
                AmbienteTeste.conectar();

            var comando =
                conexao.prepareStatement("""
                    SELECT *
                    FROM pagamento
                    WHERE id_agendamento = ?
                    """)
        ) {

            comando.setInt(
                1,
                idAgendamento
            );

            try (var resultado =
                    comando.executeQuery()) {

                if (!resultado.next()) {
                    return null;
                }

                Map<String, Object> dados =
                    new LinkedHashMap<>();

                var metadata =
                    resultado.getMetaData();

                for (
                    int i = 1;
                    i <= metadata.getColumnCount();
                    i++
                ) {

                    dados.put(
                        metadata.getColumnLabel(i),
                        resultado.getObject(i)
                    );
                }

                assertFalse(
                    resultado.next(),
                    "Existe mais de um pagamento."
                );

                return dados;
            }
        }
    }

    private void assertValor(
            String esperado,
            Object atual
    ) {

        assertInstanceOf(
            Number.class,
            atual
        );

        assertEquals(
            0,

            new BigDecimal(esperado)
                .compareTo(
                    new BigDecimal(atual.toString())
                )
        );
    }

    private int criarAgendamento(
            String sessao
    ) {

        Response resposta =
            formularioAutenticado(sessao)

                .formParam(
                    "idVeiculo",
                    "203"
                )

                .formParam(
                    "data",
                    LocalDate.now()
                        .plusDays(7)
                        .toString()
                )

                .formParam(
                    "horario",
                    "10:30"
                )

                .formParam(
                    "idServico",
                    "301"
                )

                .when()

                .post("/api/agendamentos");

        validarSucesso(
            resposta,
            201
        );

        return resposta.jsonPath()
            .getInt("agendamento.idAgendamento");
    }

    private void verificarPagamentoRejeitado(
            String sessao,
            Map<String, String> dados,
            int status,
            String mensagem
    ) throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            enviarPagamento(sessao, dados);

        validarErro(
            resposta,
            status
        );

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagem)
            );

        assertEquals(
            anterior,
            capturarEstado(),
            "Pagamento rejeitado alterou o banco."
        );
    }

    private void verificarIndisponibilidade(
            String sessao,
            int idAgendamento
    ) throws Exception {

        verificarPagamentoRejeitado(

            sessao,

            Map.of(
                "idAgendamento",
                String.valueOf(idAgendamento),

                "formaPagamento",
                "PIX"
            ),

            404,

            ERRO_INDISPONIVEL
        );
    }

    private Map<String, Object> pagarComSucesso(
            String sessao,
            int idAgendamento,
            String forma,
            String valorEsperado
    ) throws Exception {

        var anterior =
            capturarEstado();

        var pagamentoAnterior =
            consultarPagamentoBanco(idAgendamento);

        Response resposta =
            pagar(
                sessao,
                idAgendamento,
                forma
            );

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Pagamento realizado com sucesso."
                )
            );

        var pagamento =
            consultarPagamentoBanco(idAgendamento);

        assertNotNull(pagamento);

        assertEquals(
            "PAGO",
            pagamento.get("status_pagamento")
        );

        assertEquals(
            forma,
            pagamento.get("forma_pagamento")
        );

        assertNotNull(
            pagamento.get("data_pagamento")
        );

        assertNull(
            pagamento.get("arquivado_em")
        );

        assertValor(
            valorEsperado,
            pagamento.get("valor")
        );

        var atual =
            capturarEstado();

        int quantidadeEsperada =
            anterior.get("pagamento").size()
                + (pagamentoAnterior == null ? 1 : 0);

        assertEquals(
            quantidadeEsperada,
            atual.get("pagamento").size()
        );

        if (pagamentoAnterior != null) {

            assertEquals(
                pagamentoAnterior.get("id_pagamento"),
                pagamento.get("id_pagamento")
            );
        }

        assertEquals(
            anterior.get("agendamento"),
            atual.get("agendamento")
        );

        assertEquals(
            anterior.get("agendamento_servico"),
            atual.get("agendamento_servico")
        );

        assertEquals(
            anterior.get("atendimento"),
            atual.get("atendimento")
        );

        var item = localizarPagamento(
            listar(sessao),
            idAgendamento
        );

        assertEquals(
            "PAGO",
            item.get("statusPagamento")
        );

        assertEquals(
            forma,
            item.get("formaPagamento")
        );

        assertValor(
            valorEsperado,
            item.get("valor")
        );

        assertFalse(
            item.get("dataPagamento")
                .toString().isBlank()
        );

        return pagamento;
    }

    // =========================================
    // CONSULTA E ISOLAMENTO - 7 TESTES
    // =========================================

    @Test
    void deveListarPagamentosDoClienteAtivo() {

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "pagamentos.size()",
                equalTo(4)
            )

            .body(
                "pagamentos.idAgendamento",
                containsInAnyOrder(
                    501, 502, 503, 504
                )
            );
    }

    @Test
    void deveRetornarListaVaziaParaClienteLivre() {

        listar(autenticarClienteLivre())

            .then()

            .body(
                "pagamentos",
                empty()
            );
    }

    @Test
    void naoDeveListarPagamentosDeTerceiros()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id =
            criarAgendamento(sessao);

        pagarComSucesso(
            sessao,
            id,
            "PIX",
            "50.00"
        );

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "pagamentos.idAgendamento",
                not(hasItem(id))
            )

            .body(
                "pagamentos.idAgendamento",
                not(hasItem(506))
            );
    }

    @Test
    void naoDeveListarAgendamentoCancelado() {

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "pagamentos.idAgendamento",
                not(hasItem(505))
            );
    }

    @Test
    void deveRetornarDadosDoPagamentoPendente() {

        var pagamento = localizarPagamento(
            listar(autenticarClienteAtivo()),
            501
        );

        assertEquals(
            701,
            ((Number) pagamento.get("idPagamento"))
                .intValue()
        );

        assertEquals(
            "PENDENTE",
            pagamento.get("statusPagamento")
        );

        assertEquals(
            "",
            pagamento.get("formaPagamento")
        );

        assertEquals(
            "",
            pagamento.get("dataPagamento")
        );

        assertValor(
            "50.00",
            pagamento.get("valor")
        );
    }

    @Test
    void deveRetornarDadosDoPagamentoRealizado() {

        var pagamento = localizarPagamento(
            listar(autenticarClienteAtivo()),
            502
        );

        assertEquals(
            702,
            ((Number) pagamento.get("idPagamento"))
                .intValue()
        );

        assertEquals(
            "PAGO",
            pagamento.get("statusPagamento")
        );

        assertEquals(
            "PIX",
            pagamento.get("formaPagamento")
        );

        assertValor(
            "80.00",
            pagamento.get("valor")
        );

        assertDoesNotThrow(() ->

            LocalDateTime.parse(

                pagamento.get("dataPagamento")
                    .toString(),

                DateTimeFormatter.ofPattern(
                    "dd/MM/yyyy HH:mm"
                )
            )
        );
    }

    @Test
    void deveRetornarEstruturaJsonEsperada() {

        Response resposta =
            listar(autenticarClienteAtivo());

        Map<String, Object> json =
            resposta.jsonPath().getMap("$");

        assertEquals(

            Set.of(
                "sucesso",
                "pagamentos"
            ),

            json.keySet()
        );

        List<Map<String, Object>> pagamentos =
            resposta.jsonPath()
                .getList("pagamentos");

        assertFalse(pagamentos.isEmpty());

        for (var pagamento : pagamentos) {

            assertEquals(

                Set.of(
                    "idPagamento",
                    "idAgendamento",
                    "valor",
                    "formaPagamento",
                    "statusPagamento",
                    "dataPagamento",
                    "veiculo",
                    "servicos"
                ),

                pagamento.keySet()
            );

            assertInstanceOf(
                Number.class,
                pagamento.get("valor")
            );

            assertInstanceOf(
                String.class,
                pagamento.get("veiculo")
            );

            assertInstanceOf(
                String.class,
                pagamento.get("servicos")
            );
        }
    }

    // =========================================
    // FORMAS DE PAGAMENTO - 4 TESTES
    // =========================================

    @Test
    void deveRealizarPagamentoPix()
            throws Exception {

        pagarComSucesso(
            autenticarClienteAtivo(),
            501,
            "PIX",
            "50.00"
        );
    }

    @Test
    void deveRealizarPagamentoDinheiro()
            throws Exception {

        pagarComSucesso(
            autenticarClienteAtivo(),
            501,
            "DINHEIRO",
            "50.00"
        );
    }

    @Test
    void deveRealizarPagamentoCredito()
            throws Exception {

        pagarComSucesso(
            autenticarClienteAtivo(),
            501,
            "CREDITO",
            "50.00"
        );
    }

    @Test
    void deveRealizarPagamentoDebito()
            throws Exception {

        pagarComSucesso(
            autenticarClienteAtivo(),
            501,
            "DEBITO",
            "50.00"
        );
    }

    // =========================================
    // VALIDACOES DE ENTRADA - 5 TESTES
    // =========================================

    @Test
    void deveRejeitarPagamentoSemAgendamento()
            throws Exception {

        verificarPagamentoRejeitado(
            autenticarClienteAtivo(),
            Map.of("formaPagamento", "PIX"),
            400,
            ERRO_AGENDAMENTO
        );
    }

    @Test
    void deveRejeitarIdDeAgendamentoInvalido()
            throws Exception {

        verificarPagamentoRejeitado(

            autenticarClienteAtivo(),

            Map.of(
                "idAgendamento", "abc",
                "formaPagamento", "PIX"
            ),

            400,

            ERRO_AGENDAMENTO
        );
    }

    @Test
    void deveRejeitarPagamentoSemForma()
            throws Exception {

        verificarPagamentoRejeitado(
            autenticarClienteAtivo(),
            Map.of("idAgendamento", "501"),
            400,
            ERRO_FORMA
        );
    }

    @Test
    void deveRejeitarFormaDePagamentoInvalida()
            throws Exception {

        verificarPagamentoRejeitado(

            autenticarClienteAtivo(),

            Map.of(
                "idAgendamento", "501",
                "formaPagamento", "BOLETO"
            ),

            400,

            ERRO_FORMA
        );
    }

    @Test
    void deveRejeitarFormaDePagamentoEmBranco()
            throws Exception {

        verificarPagamentoRejeitado(

            autenticarClienteAtivo(),

            Map.of(
                "idAgendamento", "501",
                "formaPagamento", "   "
            ),

            400,

            ERRO_FORMA
        );
    }

    // =========================================
    // RESTRICOES DE PAGAMENTO - 6 TESTES
    // =========================================

    @Test
    void deveRejeitarPagamentoDeAgendamentoInexistente()
            throws Exception {

        verificarIndisponibilidade(
            autenticarClienteAtivo(),
            999999
        );
    }

    @Test
    void deveBloquearPagamentoDeTerceiro()
            throws Exception {

        verificarIndisponibilidade(
            autenticarClienteLivre(),
            501
        );
    }

    @Test
    void deveBloquearPagamentoDeAgendamentoCancelado()
            throws Exception {

        verificarIndisponibilidade(
            autenticarClienteAtivo(),
            505
        );
    }

    @Test
    void deveBloquearPagamentoJaRealizado()
            throws Exception {

        verificarIndisponibilidade(
            autenticarClienteAtivo(),
            502
        );
    }

    @Test
    void deveBloquearPagamentoArquivado()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        assertTrue(
            pagamentoDAO.arquivarPagamento(702)
        );

        verificarIndisponibilidade(
            sessao,
            502
        );
    }

    @Test
    void deveBloquearSegundaTentativaDePagamento()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        pagarComSucesso(
            sessao,
            501,
            "PIX",
            "50.00"
        );

        verificarPagamentoRejeitado(

            sessao,

            Map.of(
                "idAgendamento", "501",
                "formaPagamento", "CREDITO"
            ),

            404,

            ERRO_INDISPONIVEL
        );

        var pagamento =
            consultarPagamentoBanco(501);

        assertEquals(
            "PIX",
            pagamento.get("forma_pagamento")
        );

        assertValor(
            "50.00",
            pagamento.get("valor")
        );
    }

    // =========================================
    // INTEGRIDADE FINANCEIRA - 5 TESTES
    // =========================================

    @Test
    void deveAtualizarPagamentoPendenteExistente()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        var pagamento = pagarComSucesso(
            sessao,
            501,
            "PIX",
            "50.00"
        );

        assertEquals(
            701,
            ((Number) pagamento.get("id_pagamento"))
                .intValue()
        );

        assertEquals(
            6,
            capturarPagamentos().size()
        );
    }

    @Test
    void deveCriarPagamentoQuandoNaoExisteRegistro()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id =
            criarAgendamento(sessao);

        assertNull(
            consultarPagamentoBanco(id)
        );

        var pendente = localizarPagamento(
            listar(sessao),
            id
        );

        assertEquals(
            "PENDENTE",
            pendente.get("statusPagamento")
        );

        assertValor(
            "50.00",
            pendente.get("valor")
        );

        pagarComSucesso(
            sessao,
            id,
            "PIX",
            "50.00"
        );

        assertEquals(
            7,
            capturarPagamentos().size()
        );
    }

    @Test
    void deveIgnorarValorManipuladoNaRequisicao()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        Response resposta = enviarPagamento(

            sessao,

            Map.of(
                "idAgendamento", "501",
                "formaPagamento", "PIX",
                "valor", "0.01",
                "valorTotal", "0.01"
            )
        );

        validarSucesso(
            resposta,
            200
        );

        assertValor(
            "50.00",
            consultarPagamentoBanco(501)
                .get("valor")
        );
    }

    @Test
    void deveUtilizarPrecoHistoricoDoAgendamento()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id =
            criarAgendamento(sessao);

        Servico servico =
            servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        assertValor(
            "99.90",
            servicoDAO.buscarPorId(301)
                .getPreco()
        );

        pagarComSucesso(
            sessao,
            id,
            "PIX",
            "50.00"
        );
    }

    @Test
    void naoDeveAceitarProprietarioInformadoPeloCliente()
            throws Exception {

        verificarPagamentoRejeitado(

            autenticarClienteLivre(),

            Map.of(
                "idAgendamento", "501",
                "formaPagamento", "PIX",
                "idCliente", "101"
            ),

            404,

            ERRO_INDISPONIVEL
        );
    }

    // =========================================
    // INTEGRACAO OPERACIONAL - 2 TESTES
    // =========================================

    @Test
    void deveManterAtendimentoAguardandoAposPagamento()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        pagarComSucesso(
            sessao,
            501,
            "PIX",
            "50.00"
        );

        assertEquals(
            "AGUARDANDO",
            atendimentoDAO.buscarPorId(601)
                .getStatus()
        );

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(501)
                .getStatus()
        );
    }

    @Test
    void deveLiberarInicioDaLavagemAposPagamento()
            throws Exception {

        assertThrows(

            java.sql.SQLException.class,

            () ->
                atendimentoDAO.iniciarLavagem(601)
        );

        assertEquals(
            "AGUARDANDO",
            atendimentoDAO.buscarPorId(601)
                .getStatus()
        );

        pagarComSucesso(
            autenticarClienteAtivo(),
            501,
            "PIX",
            "50.00"
        );

        atendimentoDAO.iniciarLavagem(601);

        var atendimento =
            atendimentoDAO.buscarPorId(601);

        assertEquals(
            "EM_LAVAGEM",
            atendimento.getStatus()
        );

        assertNotNull(
            atendimento.getDataInicio()
        );

        assertEquals(
            "PAGO",
            consultarPagamentoBanco(501)
                .get("status_pagamento")
        );
    }

    // =========================================
    // CONTROLE DE ACESSO - 3 TESTES
    // =========================================

    @Test
    void deveBloquearPagamentoSemAutenticacao()
            throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            requisicaoFormulario()

                .formParam(
                    "idAgendamento",
                    "501"
                )

                .formParam(
                    "formaPagamento",
                    "PIX"
                )

                .when()

                .post(ROTA_PAGAR);

        validarErro(
            resposta,
            401
        );

        assertEquals(
            anterior,
            capturarEstado()
        );
    }

    @Test
    void deveBloquearPagamentoComSessaoInvalida()
            throws Exception {

        var anterior =
            capturarEstado();

        Response resposta = pagar(
            "SESSAO_INVALIDA_PAGAMENTO_123",
            501,
            "PIX"
        );

        validarErro(
            resposta,
            401
        );

        assertEquals(
            anterior,
            capturarEstado()
        );
    }

    @Test
    void deveRejeitarPostNaRotaDeListagem()
            throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            formularioAutenticado(
                autenticarClienteAtivo()
            )

                .formParam(
                    "idAgendamento",
                    "501"
                )

                .formParam(
                    "formaPagamento",
                    "PIX"
                )

                .when()

                .post(ROTA);

        validarErro(
            resposta,
            404
        );

        resposta.then()

            .body(
                "mensagem",
                equalTo("Rota não encontrada.")
            );

        assertEquals(
            anterior,
            capturarEstado()
        );
    }
}
