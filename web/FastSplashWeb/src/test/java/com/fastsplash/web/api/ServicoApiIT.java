package com.fastsplash.web.api;

import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.model.Servico;

import io.restassured.response.Response;
import io.restassured.config.JsonConfig;
import io.restassured.config.RestAssuredConfig;
import io.restassured.path.json.config.JsonPathConfig;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class ServicoApiIT extends BaseApiTeste {

    private final ServicoDAO servicoDAO =
        new ServicoDAO();

    private static final String ROTA =
        "/api/servicos";

    private Response listar(String sessao) {

        return requisicaoAutenticada(sessao)

            .when()

            .get(ROTA);
    }

    private Response listarComSucesso(
            String sessao
    ) {

        Response resposta = listar(sessao);

        validarSucesso(resposta, 200);

        resposta.then()

            .body(
                "servicos",
                notNullValue()
            );

        return resposta;
    }

    private List<Map<String, Object>> obterServicos(
            Response resposta
    ) {

        return resposta.jsonPath()

            .using(
                new JsonPathConfig()

                    .numberReturnType(
                        JsonPathConfig.NumberReturnType.BIG_DECIMAL
                    )
            )

            .getList("servicos");
    }

    private Map<String, Object> localizarServico(
            Response resposta,
            int idServico
    ) {

        return obterServicos(resposta)

            .stream()

            .filter(s ->
                ((Number) s.get("idServico"))
                    .intValue() == idServico
            )

            .findFirst()

            .orElseThrow();
    }

    private void assertPreco(
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

    private void verificarServico(
            Response resposta,
            Servico esperado
    ) {

        var atual = localizarServico(
            resposta,
            esperado.getIdServico()
        );

        assertEquals(
            esperado.getIdServico(),
            ((Number) atual.get("idServico"))
                .intValue()
        );

        assertEquals(
            esperado.getNome(),
            atual.get("nome")
        );

        assertEquals(
            esperado.getDescricao() == null
                ? ""
                : esperado.getDescricao(),

            atual.get("descricao")
        );

        assertPreco(
            BigDecimal.valueOf(
                esperado.getPreco()
            ).toPlainString(),

            atual.get("preco")
        );
    }

    // =========================================
    // LISTAGEM E CONSISTENCIA
    // =========================================

    @Test
    void deveListarServicosAtivos() {

        Response resposta =
            listarComSucesso(
                autenticarClienteAtivo()
            );

        resposta.then()

            .body(
                "servicos.size()",
                equalTo(2)
            )

            .body(
                "servicos.idServico",
                containsInAnyOrder(301, 302)
            );
    }

    @Test
    void naoDeveListarServicosInativos()
            throws Exception {

        Servico servico =
            servicoDAO.buscarPorId(303);

        assertNotNull(servico);
        assertFalse(servico.isAtivo());
        assertFalse(servico.isExcluido());

        listarComSucesso(
            autenticarClienteLivre()
        )

            .then()

            .body(
                "servicos.idServico",
                not(hasItem(303))
            );
    }

    @Test
    void naoDeveListarServicosExcluidos()
            throws Exception {

        Servico servico =
            servicoDAO.buscarPorId(304);

        assertNotNull(servico);
        assertTrue(servico.isExcluido());

        listarComSucesso(
            autenticarClienteLivre()
        )

            .then()

            .body(
                "servicos.idServico",
                not(hasItem(304))
            );
    }

    @Test
    void deveRetornarDadosConsistentesComBanco()
            throws Exception {

        List<Servico> esperados =
            servicoDAO.listarAtivos();

        Response resposta =
            listarComSucesso(
                autenticarClienteLivre()
            );

        assertEquals(
            esperados.size(),
            obterServicos(resposta).size()
        );

        for (Servico servico : esperados) {

            verificarServico(
                resposta,
                servico
            );
        }

        assertPreco(
            "50.00",
            localizarServico(resposta, 301)
                .get("preco")
        );

        assertPreco(
            "80.00",
            localizarServico(resposta, 302)
                .get("preco")
        );
    }

    @Test
    void deveRetornarEstruturaJsonEsperada() {

        Response resposta =
            listarComSucesso(
                autenticarClienteAtivo()
            );

        Map<String, Object> json =
            resposta.jsonPath().getMap("$");

        assertEquals(

            Set.of(
                "sucesso",
                "servicos"
            ),

            json.keySet()
        );

        var servicos =
            obterServicos(resposta);

        assertFalse(servicos.isEmpty());

        for (var servico : servicos) {

            assertEquals(

                Set.of(
                    "idServico",
                    "nome",
                    "descricao",
                    "preco"
                ),

                servico.keySet()
            );

            assertInstanceOf(
                Number.class,
                servico.get("idServico")
            );

            assertInstanceOf(
                String.class,
                servico.get("nome")
            );

            assertInstanceOf(
                String.class,
                servico.get("descricao")
            );

            assertInstanceOf(
                Number.class,
                servico.get("preco")
            );

            assertFalse(
                servico.get("nome")
                    .toString().isBlank()
            );

            assertTrue(

                new BigDecimal(
                    servico.get("preco").toString()
                ).signum() >= 0
            );
        }
    }

    // =========================================
    // ATUALIZACOES DO CATALOGO
    // =========================================

    @Test
    void deveRefletirAlteracaoDePreco()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Response anterior =
            listarComSucesso(sessao);

        assertPreco(
            "50.00",
            localizarServico(anterior, 301)
                .get("preco")
        );

        Servico servico =
            servicoDAO.buscarPorId(301);

        servico.setPreco(79.90);

        servicoDAO.atualizar(servico);

        Response atual =
            listarComSucesso(sessao);

        assertPreco(
            "79.90",
            localizarServico(atual, 301)
                .get("preco")
        );

        assertPreco(
            "80.00",
            localizarServico(atual, 302)
                .get("preco")
        );

        verificarServico(
            atual,
            servicoDAO.buscarPorId(301)
        );
    }

    @Test
    void deveRefletirAlteracaoDeNomeEDescricao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Servico servico =
            servicoDAO.buscarPorId(301);

        String novoNome =
            "Lavagem Especial Teste";

        String novaDescricao =
            "Lavagem externa com proteção e acabamento.";

        servico.setNome(novoNome);
        servico.setDescricao(novaDescricao);

        servicoDAO.atualizar(servico);

        var atual = localizarServico(
            listarComSucesso(sessao),
            301
        );

        assertEquals(
            novoNome,
            atual.get("nome")
        );

        assertEquals(
            novaDescricao,
            atual.get("descricao")
        );

        assertPreco(
            "50.00",
            atual.get("preco")
        );
    }

    @Test
    void deveListarServicoRecemCadastrado()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        Servico servico = new Servico();

        servico.setNome(
            "Higienização Especial Teste"
        );

        servico.setDescricao(
            "Limpeza interna de teste."
        );

        servico.setPreco(129.99);
        servico.setAtivo(true);

        servicoDAO.inserir(servico);

        Response resposta =
            listarComSucesso(sessao);

        resposta.then()

            .body(
                "servicos.size()",
                equalTo(3)
            )

            .body(
                "servicos.idServico",
                hasItem(servico.getIdServico())
            );

        verificarServico(
            resposta,
            servico
        );
    }

    @Test
    void deveRemoverServicoDaListaAposInativacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        listarComSucesso(sessao)

            .then()

            .body(
                "servicos.idServico",
                hasItem(301)
            );

        assertTrue(
            servicoDAO.inativarServico(301)
        );

        listarComSucesso(sessao)

            .then()

            .body(
                "servicos.idServico",
                contains(302)
            );

        Servico servico =
            servicoDAO.buscarPorId(301);

        assertNotNull(servico);
        assertFalse(servico.isAtivo());
        assertFalse(servico.isExcluido());
    }

    @Test
    void deveListarServicoAposReativacao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertTrue(
            servicoDAO.reativarServico(303)
        );

        Response resposta =
            listarComSucesso(sessao);

        resposta.then()

            .body(
                "servicos.size()",
                equalTo(3)
            )

            .body(
                "servicos.idServico",
                containsInAnyOrder(301, 302, 303)
            );

        assertPreco(
            "40.00",
            localizarServico(resposta, 303)
                .get("preco")
        );

        verificarServico(
            resposta,
            servicoDAO.buscarPorId(303)
        );
    }

    @Test
    void deveRefletirExclusaoERestauracao()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertTrue(
            servicoDAO.excluirLogicamente(301)
        );

        listarComSucesso(sessao)

            .then()

            .body(
                "servicos.idServico",
                contains(302)
            );

        assertTrue(
            servicoDAO.buscarPorId(301)
                .isExcluido()
        );

        assertTrue(
            servicoDAO.restaurarServico(301)
        );

        Response resposta =
            listarComSucesso(sessao);

        resposta.then()

            .body(
                "servicos.idServico",
                containsInAnyOrder(301, 302)
            );

        assertPreco(
            "50.00",
            localizarServico(resposta, 301)
                .get("preco")
        );

        assertTrue(
            servicoDAO.buscarPorId(301)
                .isAtivo()
        );

        assertFalse(
            servicoDAO.buscarPorId(301)
                .isExcluido()
        );
    }

    @Test
    void deveRetornarListaVaziaSemServicosAtivos()
            throws Exception {

        String sessao =
            autenticarClienteLivre();

        assertTrue(
            servicoDAO.inativarServico(301)
        );

        assertTrue(
            servicoDAO.inativarServico(302)
        );

        assertTrue(
            servicoDAO.listarAtivos().isEmpty()
        );

        listarComSucesso(sessao)

            .then()

            .body(
                "servicos",
                empty()
            );
    }

    // =========================================
    // AUTENTICACAO E CATALOGO COMPARTILHADO
    // =========================================

    @Test
    void deveExibirMesmoCatalogoParaClientesDiferentes() {

        String sessaoAtivo =
            autenticarClienteAtivo();

        String sessaoLivre =
            autenticarClienteLivre();

        assertNotEquals(
            sessaoAtivo,
            sessaoLivre
        );

        var catalogoAtivo =
            obterServicos(
                listarComSucesso(sessaoAtivo)
            );

        var catalogoLivre =
            obterServicos(
                listarComSucesso(sessaoLivre)
            );

        assertFalse(catalogoAtivo.isEmpty());

        assertEquals(
            catalogoAtivo.size(),
            catalogoLivre.size()
        );

        assertEquals(
            Set.copyOf(catalogoAtivo),
            Set.copyOf(catalogoLivre)
        );
    }

    @Test
    void deveBloquearConsultaComSessaoInvalida() {

        Response resposta =
            listar(
                "SESSAO_INVALIDA_SERVICOS_123"
            );

        validarErro(resposta, 401);

        resposta.then()

            .body(
                "servicos",
                nullValue()
            );
    }
}
