package com.fastsplash.web.api;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;
import com.fastsplash.web.model.Servico;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.time.LocalDate;
import java.time.LocalTime;
import java.math.BigDecimal;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class AgendamentoApiIT extends BaseApiTeste {

    private final AgendamentoDAO agendamentoDAO =
        new AgendamentoDAO();

    private final AtendimentoDAO atendimentoDAO =
        new AtendimentoDAO();

    private final ServicoDAO servicoDAO =
        new ServicoDAO();

    private final VeiculoDAO veiculoDAO =
        new VeiculoDAO();

    private static final String ROTA =
        "/api/agendamentos";

    private static final String ROTA_CANCELAR =
        "/api/agendamentos/cancelar";

    private static final String ERRO_CAMPOS =
        "Preencha todos os campos.";

    private static final String ERRO_VEICULO =
        "Veículo não encontrado.";

    private static final String ERRO_SERVICO =
        "Serviço inválido ou indisponível para agendamento.";

    private static final String ERRO_CANCELAMENTO =
        "Este agendamento não pode mais ser cancelado.";

    private LocalDate dataFutura() {

        return LocalDate.now().plusDays(7);
    }

    private Map<String, Object> dadosValidos() {

        Map<String, Object> dados =
            new LinkedHashMap<>();

        dados.put("idVeiculo", "203");
        dados.put("data", dataFutura().toString());
        dados.put("horario", "10:30");
        dados.put("idServico", "301");

        return dados;
    }

    private Response criar(
            String sessao,
            Map<String, Object> dados
    ) {

        return formularioAutenticado(sessao)

            .formParams(dados)

            .when()

            .post(ROTA);
    }

    private Response listar(String sessao) {

        Response resposta =
            requisicaoAutenticada(sessao)

                .when()

                .get(ROTA);

        validarSucesso(resposta, 200);

        return resposta;
    }

    private Response cancelar(
            String sessao,
            String id
    ) {

        return formularioAutenticado(sessao)

            .formParam("idAgendamento", id)

            .when()

            .post(ROTA_CANCELAR);
    }

    private Map<String, Object> localizarAgendamento(
            Response resposta,
            int idAgendamento
    ) {

        List<Map<String, Object>> registros =
            resposta.jsonPath()
                .getList("agendamentos");

        return registros.stream()

            .filter(a ->
                ((Number) a.get("idAgendamento"))
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

    private Map<String, List<List<Object>>>
            capturarEstado() throws Exception {

        Map<String, List<List<Object>>> estado =
            new LinkedHashMap<>();

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

        estado.put(
            "pagamento",
            consultarRegistros("""
                SELECT *
                FROM pagamento
                ORDER BY id_pagamento
                """)
        );

        return estado;
    }

    private List<List<Object>> servicosContratados(
            int idAgendamento
    ) throws Exception {

        return consultarRegistros("""
            SELECT id_servico, valor_praticado
            FROM agendamento_servico
            WHERE id_agendamento = %d
            ORDER BY id_servico
            """.formatted(idAgendamento));
    }

    private void assertValor(
            String esperado,
            Object atual
    ) {

        assertInstanceOf(Number.class, atual);

        assertEquals(
            0,
            new BigDecimal(esperado)
                .compareTo(
                    new BigDecimal(atual.toString())
                )
        );
    }

    private int criarComSucesso(
            String sessao,
            Map<String, Object> dados,
            String valorEsperado
    ) throws Exception {

        var estadoAnterior =
            capturarEstado();

        Response resposta =
            criar(sessao, dados);

        validarSucesso(resposta, 201);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Agendamento confirmado com sucesso."
                )
            )

            .body(
                "agendamento.idAgendamento",
                greaterThan(0)
            )

            .body(
                "agendamento.status",
                equalTo("AGENDADO")
            )

            .body(
                "agendamento.data",
                equalTo(dados.get("data"))
            )

            .body(
                "agendamento.horario",
                equalTo(dados.get("horario"))
            );

        int id = resposta.jsonPath()
            .getInt("agendamento.idAgendamento");

        assertValor(

            valorEsperado,

            resposta.jsonPath()
                .get("agendamento.valorTotal")
        );

        Agendamento agendamento =
            agendamentoDAO.buscarPorId(id);

        assertNotNull(agendamento);

        assertEquals(

            Integer.parseInt(
                dados.get("idVeiculo").toString()
            ),

            agendamento.getIdVeiculo()
        );

        assertEquals(
            LocalDate.parse(
                dados.get("data").toString()
            ),
            agendamento.getData()
        );

        assertEquals(
            LocalTime.parse(
                dados.get("horario").toString()
            ),
            agendamento.getHorario()
        );

        assertEquals(
            "AGENDADO",
            agendamento.getStatus()
        );

        assertFalse(agendamento.isArquivado());

        var estadoAtual =
            capturarEstado();

        assertEquals(

            estadoAnterior.get("agendamento").size() + 1,

            estadoAtual.get("agendamento").size()
        );

        assertEquals(
            estadoAnterior.get("atendimento"),
            estadoAtual.get("atendimento")
        );

        assertEquals(
            estadoAnterior.get("pagamento"),
            estadoAtual.get("pagamento")
        );

        return id;
    }

    private void verificarCriacaoRejeitada(
            String sessao,
            Map<String, Object> dados,
            int status,
            String mensagem
    ) throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            criar(sessao, dados);

        validarErro(resposta, status);

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagem)
            );

        assertEquals(
            anterior,
            capturarEstado(),
            "Agendamento rejeitado alterou o banco."
        );
    }

    private void verificarCancelamentoRejeitado(
            String sessao,
            String id,
            int status,
            String mensagem
    ) throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            cancelar(sessao, id);

        validarErro(resposta, status);

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagem)
            );

        assertEquals(
            anterior,
            capturarEstado()
        );
    }

    // =========================================
    // CONSULTA E ISOLAMENTO - 7 TESTES
    // =========================================

    @Test
    void deveListarAgendamentosDoClienteAtivo() {

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "agendamentos.size()",
                equalTo(5)
            )

            .body(
                "agendamentos.idAgendamento",
                containsInAnyOrder(
                    501, 502, 503, 504, 505
                )
            );
    }

    @Test
    void deveRetornarListaVaziaParaClienteSemAgendamentos() {

        listar(autenticarClienteLivre())

            .then()

            .body(
                "agendamentos",
                empty()
            );
    }

    @Test
    void naoDeveExporAgendamentosDeTerceiros() {

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "agendamentos.idAgendamento",
                not(hasItem(506))
            )

            .body(
                "agendamentos.veiculo.idVeiculo",
                everyItem(anyOf(
                    is(201),
                    is(202)
                ))
            );
    }

    @Test
    void deveRetornarStatusAgendado() {

        var item = localizarAgendamento(
            listar(autenticarClienteAtivo()),
            501
        );

        assertEquals(
            "Agendado",
            item.get("status")
        );
    }

    @Test
    void deveRetornarStatusEmAndamento() {

        var item = localizarAgendamento(
            listar(autenticarClienteAtivo()),
            503
        );

        assertEquals(
            "Em andamento",
            item.get("status")
        );
    }

    @Test
    void deveRetornarStatusFinalizado() {

        var item = localizarAgendamento(
            listar(autenticarClienteAtivo()),
            504
        );

        assertEquals(
            "Finalizado",
            item.get("status")
        );
    }

    @Test
    void deveRetornarStatusCancelado() {

        var item = localizarAgendamento(
            listar(autenticarClienteAtivo()),
            505
        );

        assertEquals(
            "Cancelado",
            item.get("status")
        );
    }

    // =========================================
    // CRIACAO DE AGENDAMENTOS - 5 TESTES
    // =========================================

    @Test
    void deveCriarAgendamentoComUmServico()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id = criarComSucesso(
            sessao,
            dadosValidos(),
            "50.00"
        );

        var servicos =
            servicosContratados(id);

        assertEquals(1, servicos.size());

        assertEquals(
            301,
            ((Number) servicos.get(0).get(0))
                .intValue()
        );

        assertValor(
            "50.00",
            servicos.get(0).get(1)
        );
    }

    @Test
    void deveCriarAgendamentoComDoisServicos()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "idServico",
            List.of("301", "302")
        );

        int id = criarComSucesso(
            autenticarClienteLivre(),
            dados,
            "130.00"
        );

        var servicos =
            servicosContratados(id);

        assertEquals(2, servicos.size());

        assertEquals(
            301,
            ((Number) servicos.get(0).get(0))
                .intValue()
        );

        assertEquals(
            302,
            ((Number) servicos.get(1).get(0))
                .intValue()
        );

        assertValor(
            "50.00",
            servicos.get(0).get(1)
        );

        assertValor(
            "80.00",
            servicos.get(1).get(1)
        );
    }

    @Test
    void deveListarAgendamentoRecemCriado()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id = criarComSucesso(
            sessao,
            dadosValidos(),
            "50.00"
        );

        var item = localizarAgendamento(
            listar(sessao),
            id
        );

        assertEquals(
            "Agendado",
            item.get("status")
        );

        assertEquals(
            dataFutura().toString(),
            item.get("data")
        );

        assertEquals(
            "10:30",
            item.get("horario")
        );

        assertValor(
            "50.00",
            item.get("valorTotal")
        );
    }

    @Test
    void deveIsolarNovoAgendamentoDoOutroCliente()
            throws Exception {

        int id = criarComSucesso(
            autenticarClienteLivre(),
            dadosValidos(),
            "50.00"
        );

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "agendamentos.idAgendamento",
                not(hasItem(id))
            );
    }

    @Test
    void deveIgnorarProprietarioInformadoNaRequisicao()
            throws Exception {

        var dados = dadosValidos();

        dados.put("idCliente", "101");

        int id = criarComSucesso(
            autenticarClienteLivre(),
            dados,
            "50.00"
        );

        assertEquals(
            203,
            agendamentoDAO.buscarPorId(id)
                .getIdVeiculo()
        );

        assertEquals(
            102,
            veiculoDAO.buscarPorId(203)
                .getIdCliente()
        );

        listar(autenticarClienteAtivo())

            .then()

            .body(
                "agendamentos.idAgendamento",
                not(hasItem(id))
            );
    }

    // =========================================
    // VALIDACOES DE ENTRADA - 12 TESTES
    // =========================================

    @Test
    void deveRejeitarCriacaoSemVeiculo()
            throws Exception {

        var dados = dadosValidos();

        dados.remove("idVeiculo");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            "Veículo inválido."
        );
    }

    @Test
    void deveRejeitarIdDeVeiculoInvalido()
            throws Exception {

        var dados = dadosValidos();

        dados.put("idVeiculo", "abc");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            "Veículo inválido."
        );
    }

    @Test
    void deveRejeitarVeiculoInexistente()
            throws Exception {

        var dados = dadosValidos();

        dados.put("idVeiculo", "999999");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            404,
            ERRO_VEICULO
        );
    }

    @Test
    void deveRejeitarVeiculoDeTerceiro()
            throws Exception {

        var dados = dadosValidos();

        dados.put("idVeiculo", "201");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            404,
            ERRO_VEICULO
        );
    }

    @Test
    void deveRejeitarVeiculoInativo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.inativarVeiculo(203)
        );

        verificarCriacaoRejeitada(
            sessao,
            dadosValidos(),
            404,
            ERRO_VEICULO
        );
    }

    @Test
    void deveRejeitarVeiculoExcluido()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(203)
        );

        verificarCriacaoRejeitada(
            sessao,
            dadosValidos(),
            404,
            ERRO_VEICULO
        );
    }

    @Test
    void deveRejeitarCriacaoSemData()
            throws Exception {

        var dados = dadosValidos();

        dados.remove("data");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            ERRO_CAMPOS
        );
    }

    @Test
    void deveRejeitarCriacaoSemHorario()
            throws Exception {

        var dados = dadosValidos();

        dados.remove("horario");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            ERRO_CAMPOS
        );
    }

    @Test
    void deveRejeitarCriacaoSemServicos()
            throws Exception {

        var dados = dadosValidos();

        dados.remove("idServico");

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            ERRO_CAMPOS
        );
    }

    @Test
    void deveRejeitarDataEHorarioInvalidos()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put("data", "data-invalida");

        verificarCriacaoRejeitada(
            sessao,
            dados,
            400,
            "Data ou horário inválido."
        );

        dados = dadosValidos();

        dados.put("horario", "25:70");

        verificarCriacaoRejeitada(
            sessao,
            dados,
            400,
            "Data ou horário inválido."
        );
    }

    @Test
    void deveRejeitarServicosInvalidosOuIndisponiveis()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        for (String idServico : List.of(
                "abc",
                "999999",
                "303",
                "304"
        )) {

            var dados = dadosValidos();

            dados.put(
                "idServico",
                idServico
            );

            verificarCriacaoRejeitada(
                sessao,
                dados,
                400,
                ERRO_SERVICO
            );
        }
    }

    @Test
    void deveRejeitarAgendamentoDuplicado()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        criarComSucesso(
            sessao,
            dados,
            "50.00"
        );

        verificarCriacaoRejeitada(
            sessao,
            dados,
            409,
            "Este veículo já possui um agendamento "
                + "neste dia e horário."
        );
    }

    // =========================================
    // INTEGRIDADE FINANCEIRA - 3 TESTES
    // =========================================

    @Test
    void deveUtilizarPrecoDoBancoENaoDaRequisicao()
            throws Exception {

        var dados = dadosValidos();

        dados.put("valorTotal", "0.01");
        dados.put("preco", "0.01");

        int id = criarComSucesso(
            autenticarClienteLivre(),
            dados,
            "50.00"
        );

        assertValor(
            "50.00",
            servicosContratados(id)
                .get(0).get(1)
        );
    }

    @Test
    void devePreservarPrecoHistoricoAposAlteracaoDoServico()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id = criarComSucesso(
            sessao,
            dadosValidos(),
            "50.00"
        );

        Servico servico =
            servicoDAO.buscarPorId(301);

        servico.setPreco(99.90);

        servicoDAO.atualizar(servico);

        var item = localizarAgendamento(
            listar(sessao),
            id
        );

        assertValor(
            "50.00",
            item.get("valorTotal")
        );

        assertValor(
            "50.00",
            servicosContratados(id)
                .get(0).get(1)
        );

        assertValor(
            "99.90",
            servicoDAO.buscarPorId(301)
                .getPreco()
        );

        var dadosNovo = dadosValidos();

        dadosNovo.put("horario", "11:30");

        criarComSucesso(
            sessao,
            dadosNovo,
            "99.90"
        );
    }

    @Test
    void devePreservarBancoQuandoUmDosServicosForInvalido()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "idServico",
            List.of("301", "303")
        );

        verificarCriacaoRejeitada(
            autenticarClienteLivre(),
            dados,
            400,
            ERRO_SERVICO
        );
    }

    // =========================================
    // CANCELAMENTOS - 7 TESTES
    // =========================================

    @Test
    void deveCancelarAgendamentoSemAtendimento()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int id = criarComSucesso(
            sessao,
            dadosValidos(),
            "50.00"
        );

        var anteriores =
            capturarEstado();

        Response resposta = cancelar(
            sessao,
            String.valueOf(id)
        );

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Agendamento cancelado com sucesso."
                )
            );

        assertEquals(
            "CANCELADO",
            agendamentoDAO.buscarPorId(id)
                .getStatus()
        );

        var atuais =
            capturarEstado();

        assertEquals(
            anteriores.get("agendamento").size(),
            atuais.get("agendamento").size()
        );

        assertEquals(
            anteriores.get("agendamento_servico"),
            atuais.get("agendamento_servico")
        );

        assertEquals(
            anteriores.get("atendimento"),
            atuais.get("atendimento")
        );

        assertEquals(
            anteriores.get("pagamento"),
            atuais.get("pagamento")
        );

        var item = localizarAgendamento(
            listar(sessao),
            id
        );

        assertEquals(
            "Cancelado",
            item.get("status")
        );
    }

    @Test
    void deveBloquearCancelamentoDeTerceiro()
            throws Exception {

        String sessaoProprietario =
            autenticarClienteLivre();

        int id = criarComSucesso(
            sessaoProprietario,
            dadosValidos(),
            "50.00"
        );

        verificarCancelamentoRejeitado(
            autenticarClienteAtivo(),
            String.valueOf(id),
            409,
            ERRO_CANCELAMENTO
        );

        assertEquals(
            "AGENDADO",
            agendamentoDAO.buscarPorId(id)
                .getStatus()
        );
    }

    @Test
    void deveBloquearCancelamentoComAtendimento()
            throws Exception {

        verificarCancelamentoRejeitado(
            autenticarClienteAtivo(),
            "501",
            409,
            ERRO_CANCELAMENTO
        );
    }

    @Test
    void deveBloquearCancelamentoDuranteLavagem()
            throws Exception {

        verificarCancelamentoRejeitado(
            autenticarClienteAtivo(),
            "503",
            409,
            ERRO_CANCELAMENTO
        );
    }

    @Test
    void deveBloquearCancelamentoDeAgendamentoConcluido()
            throws Exception {

        verificarCancelamentoRejeitado(
            autenticarClienteAtivo(),
            "504",
            409,
            ERRO_CANCELAMENTO
        );
    }

    @Test
    void deveBloquearNovoCancelamentoDeAgendamentoCancelado()
            throws Exception {

        verificarCancelamentoRejeitado(
            autenticarClienteAtivo(),
            "505",
            409,
            ERRO_CANCELAMENTO
        );
    }

    @Test
    void deveRejeitarCancelamentoComIdInvalidoOuInexistente()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        verificarCancelamentoRejeitado(
            sessao,
            "abc",
            400,
            "Agendamento inválido."
        );

        verificarCancelamentoRejeitado(
            sessao,
            "999999",
            409,
            ERRO_CANCELAMENTO
        );
    }

    // =========================================
    // CONTROLE DE ACESSO - 2 TESTES
    // =========================================

    @Test
    void deveBloquearCriacaoSemAutenticacao()
            throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            requisicaoFormulario()

                .formParams(dadosValidos())

                .when()

                .post(ROTA);

        validarErro(resposta, 401);

        assertEquals(
            anterior,
            capturarEstado()
        );
    }

    @Test
    void deveBloquearCancelamentoSemAutenticacao()
            throws Exception {

        var anterior =
            capturarEstado();

        Response resposta =
            requisicaoFormulario()

                .formParam("idAgendamento", "501")

                .when()

                .post(ROTA_CANCELAR);

        validarErro(resposta, 401);

        assertEquals(
            anterior,
            capturarEstado()
        );
    }
}
