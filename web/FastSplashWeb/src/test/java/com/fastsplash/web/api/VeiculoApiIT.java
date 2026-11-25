package com.fastsplash.web.api;

import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Veiculo;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class VeiculoApiIT extends BaseApiTeste {

    private final VeiculoDAO veiculoDAO =
        new VeiculoDAO();

    private static final String ROTA =
        "/api/veiculos";

    private static final String ROTA_EDITAR =
        "/api/veiculos/editar";

    private static final String ROTA_EXCLUIR =
        "/api/veiculos/excluir";

    private static final String PLACA =
        "TST1B01";

    private static final String MARCA =
        "FIAT";

    private static final String MODELO =
        "PULSE";

    private static final String COR =
        "BRANCO";

    private Map<String, String> dadosValidos() {

        Map<String, String> dados =
            new LinkedHashMap<>();

        dados.put("placa", PLACA);
        dados.put("marca", MARCA);
        dados.put("modelo", MODELO);
        dados.put("cor", COR);

        return dados;
    }

    private Map<String, String> dadosEdicao(
            int idVeiculo
    ) {

        var dados = dadosValidos();

        dados.put(
            "idVeiculo",
            String.valueOf(idVeiculo)
        );

        return dados;
    }

    private Response enviar(
            String sessao,
            String rota,
            Map<String, String> dados
    ) {

        return formularioAutenticado(sessao)

            .formParams(dados)

            .when()

            .post(rota);
    }

    private Response listar(String sessao) {

        return requisicaoAutenticada(sessao)

            .when()

            .get(ROTA);
    }

    private Response excluir(
            String sessao,
            int idVeiculo
    ) {

        return enviar(

            sessao,

            ROTA_EXCLUIR,

            Map.of(
                "idVeiculo",
                String.valueOf(idVeiculo)
            )
        );
    }

    private List<List<Object>> capturarRegistros(
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

    private List<List<Object>> capturarVeiculos()
            throws Exception {

        return capturarRegistros("""
            SELECT *
            FROM veiculo
            ORDER BY id_veiculo
            """);
    }

    private List<List<Object>> capturarHistorico()
            throws Exception {

        return capturarRegistros("""
            SELECT
                a.id_agendamento,
                a.id_veiculo,
                a.data,
                a.horario,
                a.status,
                a.arquivado_em,
                t.id_atendimento,
                t.status,
                t.data_inicio,
                t.data_fim,
                t.arquivado_em,
                p.id_pagamento,
                p.valor,
                p.status_pagamento,
                p.data_pagamento,
                p.forma_pagamento,
                p.arquivado_em,
                ags.id_servico,
                ags.valor_praticado
            FROM agendamento a
            LEFT JOIN atendimento t
                ON t.id_agendamento = a.id_agendamento
            LEFT JOIN pagamento p
                ON p.id_agendamento = a.id_agendamento
            LEFT JOIN agendamento_servico ags
                ON ags.id_agendamento = a.id_agendamento
            ORDER BY a.id_agendamento, ags.id_servico
            """);
    }

    private void verificarRejeicao(
            String sessao,
            String rota,
            Map<String, String> dados,
            int status,
            String mensagem
    ) throws Exception {

        var veiculosAnteriores =
            capturarVeiculos();

        var historicoAnterior =
            capturarHistorico();

        Response resposta =
            enviar(sessao, rota, dados);

        validarErro(resposta, status);

        resposta.then()

            .body(
                "mensagem",
                equalTo(mensagem)
            );

        assertEquals(
            veiculosAnteriores,
            capturarVeiculos()
        );

        assertEquals(
            historicoAnterior,
            capturarHistorico()
        );
    }

    private void validarDadosVeiculo(
            Response resposta,
            int idCliente,
            int idVeiculo
    ) {

        resposta.then()

            .body(
                "veiculo.idCliente",
                equalTo(idCliente)
            )

            .body(
                "veiculo.idVeiculo",
                equalTo(idVeiculo)
            )

            .body(
                "veiculo.placa",
                equalTo(PLACA)
            )

            .body(
                "veiculo.marca",
                equalTo(MARCA)
            )

            .body(
                "veiculo.modelo",
                equalTo(MODELO)
            )

            .body(
                "veiculo.cor",
                equalTo(COR)
            );
    }

    private Veiculo cadastrarComSucesso(
            String sessao,
            int idCliente,
            Map<String, String> dados
    ) throws Exception {

        int quantidadeAnterior =
            capturarVeiculos().size();

        Response resposta =
            enviar(sessao, ROTA, dados);

        validarSucesso(resposta, 201);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Veículo cadastrado com sucesso."
                )
            )

            .body(
                "veiculo.idVeiculo",
                greaterThan(0)
            );

        int idVeiculo = resposta.jsonPath()
            .getInt("veiculo.idVeiculo");

        validarDadosVeiculo(
            resposta,
            idCliente,
            idVeiculo
        );

        Veiculo veiculo =
            veiculoDAO.buscarPorId(idVeiculo);

        assertNotNull(veiculo);

        assertEquals(
            idCliente,
            veiculo.getIdCliente()
        );

        assertEquals(PLACA, veiculo.getPlaca());
        assertEquals(MARCA, veiculo.getMarca());
        assertEquals(MODELO, veiculo.getModelo());
        assertEquals(COR, veiculo.getCor());

        assertTrue(veiculo.isAtivo());
        assertFalse(veiculo.isExcluido());

        assertEquals(
            quantidadeAnterior + 1,
            capturarVeiculos().size()
        );

        return veiculo;
    }

    private void verificarCampoCadastro(
            String campo
    ) throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.remove(campo);

        verificarRejeicao(
            sessao,
            ROTA,
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    // =========================================
    // CONSULTA E ISOLAMENTO - 4 TESTES
    // =========================================

    @Test
    void deveListarVeiculosDoClienteAtivo() {

        String sessao =
            autenticarClienteAtivo();

        Response resposta =
            listar(sessao);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "veiculos.size()",
                equalTo(2)
            )

            .body(
                "veiculos.idVeiculo",
                containsInAnyOrder(201, 202)
            )

            .body(
                "veiculos.idCliente",
                everyItem(equalTo(101))
            );
    }

    @Test
    void deveListarSomenteVeiculosDoClienteLivre() {

        String sessao =
            autenticarClienteLivre();

        Response resposta =
            listar(sessao);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "veiculos.size()",
                equalTo(1)
            )

            .body(
                "veiculos[0].idVeiculo",
                equalTo(203)
            )

            .body(
                "veiculos[0].idCliente",
                equalTo(102)
            );
    }

    @Test
    void naoDeveListarVeiculoInativo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.inativarVeiculo(203)
        );

        listar(sessao)

            .then()

            .statusCode(200)

            .body(
                "sucesso",
                equalTo(true)
            )

            .body(
                "veiculos",
                empty()
            );

        assertNotNull(
            veiculoDAO.buscarPorId(203)
        );
    }

    @Test
    void naoDeveListarVeiculoExcluido()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertEquals(
            ResultadoStatusVeiculo.SUCESSO,
            veiculoDAO.excluirLogicamente(203)
        );

        listar(sessao)

            .then()

            .statusCode(200)

            .body(
                "sucesso",
                equalTo(true)
            )

            .body(
                "veiculos",
                empty()
            );

        assertTrue(
            veiculoDAO.buscarPorId(203)
                .isExcluido()
        );
    }

    // =========================================
    // CADASTRO - 8 TESTES
    // =========================================

    @Test
    void deveCadastrarVeiculoValido()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Veiculo veiculo =
            cadastrarComSucesso(
                sessao,
                102,
                dadosValidos()
            );

        listar(sessao)

            .then()

            .statusCode(200)

            .body(
                "veiculos.idVeiculo",
                hasItem(veiculo.getIdVeiculo())
            )

            .body(
                "veiculos.size()",
                equalTo(2)
            );
    }

    @Test
    void deveRejeitarCadastroSemPlaca()
            throws Exception {

        verificarCampoCadastro("placa");
    }

    @Test
    void deveRejeitarCadastroSemMarca()
            throws Exception {

        verificarCampoCadastro("marca");
    }

    @Test
    void deveRejeitarCadastroSemModelo()
            throws Exception {

        verificarCampoCadastro("modelo");
    }

    @Test
    void deveRejeitarCadastroSemCor()
            throws Exception {

        verificarCampoCadastro("cor");
    }

    @Test
    void deveNormalizarPlacaNoCadastro()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "placa",
            "  tst-1b01  "
        );

        cadastrarComSucesso(
            sessao,
            102,
            dados
        );
    }

    @Test
    void deveRejeitarPlacaDuplicada()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "placa",
            "tst-1a01"
        );

        verificarRejeicao(
            sessao,
            ROTA,
            dados,
            409,
            "Esta placa já está cadastrada."
        );
    }

    @Test
    void deveUtilizarProprietarioDaSessaoNoCadastro()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        var dados = dadosValidos();

        dados.put(
            "idCliente",
            "101"
        );

        Veiculo veiculo =
            cadastrarComSucesso(
                sessao,
                102,
                dados
            );

        String sessaoOutro =
            autenticarClienteAtivo();

        listar(sessaoOutro)

            .then()

            .statusCode(200)

            .body(
                "veiculos.idVeiculo",
                not(
                    hasItem(veiculo.getIdVeiculo())
                )
            );
    }

    // =========================================
    // EDICAO - 8 TESTES
    // =========================================

    @Test
    void deveEditarVeiculoDoProprioCliente()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Response resposta =
            enviar(
                sessao,
                ROTA_EDITAR,
                dadosEdicao(203)
            );

        validarSucesso(resposta, 200);

        validarDadosVeiculo(
            resposta,
            102,
            203
        );

        Veiculo veiculo =
            veiculoDAO.buscarPorId(203);

        assertEquals(102, veiculo.getIdCliente());
        assertEquals(PLACA, veiculo.getPlaca());
        assertEquals(MARCA, veiculo.getMarca());
        assertEquals(MODELO, veiculo.getModelo());
        assertEquals(COR, veiculo.getCor());

        assertTrue(veiculo.isAtivo());

        assertFalse(veiculo.isExcluido());
    }

    @Test
    void deveRejeitarEdicaoSemId()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dadosValidos(),
            400,
            "Veículo inválido."
        );
    }

    @Test
    void deveRejeitarIdInvalidoNaEdicao()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "idVeiculo",
            "abc"
        );

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dados,
            400,
            "Veículo inválido."
        );
    }

    @Test
    void deveRejeitarEdicaoDeVeiculoInexistente()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dadosEdicao(999999),
            404,
            "Veículo não encontrado."
        );
    }

    @Test
    void deveBloquearEdicaoDeVeiculoDeTerceiro()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dadosEdicao(201),
            404,
            "Veículo não encontrado."
        );
    }

    @Test
    void deveRejeitarEdicaoComCampoObrigatorioAusente()
            throws Exception {

        var dados = dadosEdicao(203);

        dados.remove("modelo");

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    @Test
    void deveRejeitarPlacaDuplicadaNaEdicao()
            throws Exception {

        var dados = dadosEdicao(203);

        dados.put(
            "placa",
            "TST1A01"
        );

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EDITAR,
            dados,
            409,
            "Esta placa já está cadastrada."
        );
    }

    @Test
    void devePreservarProprietarioEHistoricoNaEdicao()
            throws Exception {

        String sessao =
            autenticarClienteAtivo();

        var historicoAnterior =
            capturarHistorico();

        var dados = dadosEdicao(202);

        dados.put(
            "idCliente",
            "102"
        );

        Response resposta =
            enviar(
                sessao,
                ROTA_EDITAR,
                dados
            );

        validarSucesso(resposta, 200);

        validarDadosVeiculo(
            resposta,
            101,
            202
        );

        assertEquals(
            101,
            veiculoDAO.buscarPorId(202)
                .getIdCliente()
        );

        assertEquals(
            historicoAnterior,
            capturarHistorico()
        );

        listar(autenticarClienteLivre())

            .then()

            .statusCode(200)

            .body(
                "veiculos.idVeiculo",
                not(hasItem(202))
            );
    }

    // =========================================
    // EXCLUSAO LOGICA - 7 TESTES
    // =========================================

    @Test
    void deveExcluirLogicamenteVeiculoSemPendencias()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        int quantidadeAnterior =
            capturarVeiculos().size();

        Veiculo original =
            veiculoDAO.buscarPorId(203);

        Response resposta =
            excluir(sessao, 203);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "mensagem",
                equalTo(
                    "Veículo excluído com sucesso."
                )
            );

        Veiculo veiculo =
            veiculoDAO.buscarPorId(203);

        assertNotNull(veiculo);

        assertFalse(veiculo.isAtivo());

        assertTrue(veiculo.isExcluido());

        assertNotNull(
            veiculo.getExcluidoEm()
        );

        assertEquals(
            original.getPlaca(),
            veiculo.getPlaca()
        );

        assertEquals(
            original.getIdCliente(),
            veiculo.getIdCliente()
        );

        assertEquals(
            quantidadeAnterior,
            capturarVeiculos().size()
        );

        listar(sessao)

            .then()

            .statusCode(200)

            .body(
                "veiculos",
                empty()
            );
    }

    @Test
    void deveBloquearExclusaoComPendencias()
            throws Exception {

        verificarRejeicao(

            autenticarClienteAtivo(),

            ROTA_EXCLUIR,

            Map.of("idVeiculo", "201"),

            409,

            "Este veículo possui agendamentos "
                + "ou atendimentos pendentes."
        );
    }

    @Test
    void deveBloquearExclusaoDeVeiculoDeTerceiro()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EXCLUIR,
            Map.of("idVeiculo", "201"),
            404,
            "Veículo não encontrado."
        );
    }

    @Test
    void deveRejeitarExclusaoDeVeiculoInexistente()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EXCLUIR,
            Map.of("idVeiculo", "999999"),
            404,
            "Veículo não encontrado."
        );
    }

    @Test
    void deveRejeitarExclusaoComIdInvalido()
            throws Exception {

        verificarRejeicao(
            autenticarClienteLivre(),
            ROTA_EXCLUIR,
            Map.of("idVeiculo", "abc"),
            400,
            "Veículo inválido."
        );
    }

    @Test
    void deveRejeitarNovaExclusaoDoMesmoVeiculo()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        validarSucesso(
            excluir(sessao, 203),
            200
        );

        verificarRejeicao(
            sessao,
            ROTA_EXCLUIR,
            Map.of("idVeiculo", "203"),
            404,
            "Veículo não encontrado."
        );
    }

    @Test
    void deveBloquearEdicaoDeVeiculoExcluido()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        validarSucesso(
            excluir(sessao, 203),
            200
        );

        verificarRejeicao(
            sessao,
            ROTA_EDITAR,
            dadosEdicao(203),
            404,
            "Veículo não encontrado."
        );
    }

    // =========================================
    // CONTROLE DE ACESSO - 3 TESTES
    // =========================================

    @Test
    void deveBloquearCadastroSemAutenticacao()
            throws Exception {

        var anteriores =
            capturarVeiculos();

        Response resposta =
            requisicaoFormulario()

                .formParams(dadosValidos())

                .when()

                .post(ROTA);

        validarErro(resposta, 401);

        assertEquals(
            anteriores,
            capturarVeiculos()
        );
    }

    @Test
    void deveBloquearEdicaoSemAutenticacao()
            throws Exception {

        var anteriores =
            capturarVeiculos();

        Response resposta =
            requisicaoFormulario()

                .formParams(dadosEdicao(203))

                .when()

                .post(ROTA_EDITAR);

        validarErro(resposta, 401);

        assertEquals(
            anteriores,
            capturarVeiculos()
        );
    }

    @Test
    void deveBloquearExclusaoSemAutenticacao()
            throws Exception {

        var anteriores =
            capturarVeiculos();

        Response resposta =
            requisicaoFormulario()

                .formParam(
                    "idVeiculo",
                    "203"
                )

                .when()

                .post(ROTA_EXCLUIR);

        validarErro(resposta, 401);

        assertEquals(
            anteriores,
            capturarVeiculos()
        );
    }
}
