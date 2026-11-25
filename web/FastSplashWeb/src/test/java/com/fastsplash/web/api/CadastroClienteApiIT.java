package com.fastsplash.web.api;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.db.AmbienteTeste;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import io.restassured.response.Response;

import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.*;

class CadastroClienteApiIT extends BaseApiTeste {

    private final ClienteDAO clienteDAO =
        new ClienteDAO();

    private static final String NOME =
        "CLIENTE CADASTRO TESTE";

    private static final String CPF =
        "98765410564";

    private static final String TELEFONE =
        "11900000105";

    private static final String EMAIL =
        "cadastro@example.test";

    private static final String SENHA =
        "CadastroFicticio@123";

    private Map<String, String> dadosValidos() {

        Map<String, String> dados =
            new LinkedHashMap<>();

        dados.put("nome", NOME);
        dados.put("cpf", CPF);
        dados.put("telefone", TELEFONE);
        dados.put("email", EMAIL);
        dados.put("senha", SENHA);
        dados.put("confirmarSenha", SENHA);

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

    private long contarClientes() throws Exception {

        try (
            Connection conexao =
                AmbienteTeste.conectar();

            var comando =
                conexao.createStatement();

            var resultado =
                comando.executeQuery(
                    "SELECT COUNT(*) FROM cliente"
                )
        ) {

            assertTrue(resultado.next());

            return resultado.getLong(1);
        }
    }

    private Map<Integer, java.util.List<Object>>
            capturarClientes() throws Exception {

        Map<Integer, java.util.List<Object>> registros =
            new LinkedHashMap<>();

        for (Cliente cliente :
                clienteDAO.listarTodosParaHistorico()) {

            registros.put(
                cliente.getIdCliente(),

                java.util.Arrays.asList(
                    cliente.getNome(),
                    cliente.getCpf(),
                    cliente.getTelefone(),
                    cliente.getEmail(),
                    cliente.getSenhaHash(),
                    cliente.isAtivo(),
                    cliente.getExcluidoEm()
                )
            );
        }

        return registros;
    }

    private Cliente cadastrarComSucesso(
            Map<String, String> dados
    ) throws Exception {

        long quantidadeAnterior =
            contarClientes();

        Response resposta = cadastrar(dados);

        validarSucesso(resposta, 201);

        resposta.then()

            .body(
                "mensagem",
                equalTo("Cadastro realizado com sucesso.")
            )

            .body(
                "idCliente",
                greaterThan(0)
            )

            .body(
                "nome",
                not(isEmptyOrNullString())
            )

            .body(
                "email",
                not(isEmptyOrNullString())
            );

        int idCliente =
            resposta.jsonPath().getInt("idCliente");

        Cliente cliente =
            clienteDAO.buscarPorId(idCliente);

        assertNotNull(cliente);

        assertTrue(cliente.isAtivo());

        assertFalse(cliente.isExcluido());

        assertEquals(
            cliente.getNome(),
            resposta.jsonPath().getString("nome")
        );

        assertEquals(
            cliente.getEmail(),
            resposta.jsonPath().getString("email")
        );

        assertEquals(
            quantidadeAnterior + 1,
            contarClientes()
        );

        return cliente;
    }

    private void verificarRejeicao(
            Map<String, String> dados,
            int statusEsperado,
            String mensagemEsperada
    ) throws Exception {

        var registrosAnteriores =
            capturarClientes();

        long quantidadeAnterior =
            contarClientes();

        Response resposta = cadastrar(dados);

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
            quantidadeAnterior,
            contarClientes()
        );

        assertEquals(
            registrosAnteriores,
            capturarClientes(),
            "Cadastro rejeitado alterou registros existentes."
        );
    }

    private void verificarCampoObrigatorio(
            String campo
    ) throws Exception {

        Map<String, String> dados =
            dadosValidos();

        dados.remove(campo);

        verificarRejeicao(
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    @Test
    void deveCadastrarClienteValido()
            throws Exception {

        Cliente cliente =
            cadastrarComSucesso(dadosValidos());

        assertEquals(NOME, cliente.getNome());
        assertEquals(CPF, cliente.getCpf());
        assertEquals(TELEFONE, cliente.getTelefone());
        assertEquals(EMAIL, cliente.getEmail());

        assertTrue(cliente.isAtivo());

        assertNull(cliente.getExcluidoEm());
    }

    @Test
    void deveRejeitarCadastroSemNome()
            throws Exception {

        verificarCampoObrigatorio("nome");
    }

    @Test
    void deveRejeitarCadastroSemCpf()
            throws Exception {

        verificarCampoObrigatorio("cpf");
    }

    @Test
    void deveRejeitarCadastroSemTelefone()
            throws Exception {

        verificarCampoObrigatorio("telefone");
    }

    @Test
    void deveRejeitarCadastroSemEmail()
            throws Exception {

        verificarCampoObrigatorio("email");
    }

    @Test
    void deveRejeitarCadastroSemSenha()
            throws Exception {

        verificarCampoObrigatorio("senha");
    }

    @Test
    void deveRejeitarCadastroSemConfirmacaoDeSenha()
            throws Exception {

        verificarCampoObrigatorio("confirmarSenha");
    }

    @Test
    void deveRejeitarNomeEmBranco()
            throws Exception {

        var dados = dadosValidos();

        dados.put("nome", "   ");

        verificarRejeicao(
            dados,
            400,
            "Preencha todos os campos."
        );
    }

    @Test
    void deveRejeitarSenhasDiferentes()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "confirmarSenha",
            "OutraSenhaFicticia@123"
        );

        verificarRejeicao(
            dados,
            400,
            "As senhas não coincidem."
        );
    }

    @Test
    void deveRejeitarCpfComMenosDeOnzeDigitos()
            throws Exception {

        var dados = dadosValidos();

        dados.put("cpf", "1234567890");

        verificarRejeicao(
            dados,
            400,
            "O CPF deve possuir 11 dígitos."
        );
    }

    @Test
    void deveRejeitarCpfComMaisDeOnzeDigitos()
            throws Exception {

        var dados = dadosValidos();

        dados.put("cpf", "123456789012");

        verificarRejeicao(
            dados,
            400,
            "O CPF deve possuir 11 dígitos."
        );
    }

    @Test
    void deveRejeitarEmailSemArroba()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "email",
            "email-invalido.example.test"
        );

        verificarRejeicao(
            dados,
            400,
            "Informe um e-mail válido."
        );
    }

    @Test
    void deveRejeitarCpfDuplicado()
            throws Exception {

        var dados = dadosValidos();

        dados.put("cpf", "98765410130");

        verificarRejeicao(
            dados,
            409,
            "Já existe um cliente com este CPF ou e-mail."
        );

        assertNull(
            clienteDAO.buscarPorEmail(EMAIL)
        );
    }

    @Test
    void deveRejeitarEmailDuplicado()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "email",
            EMAIL_CLIENTE_ATIVO
        );

        verificarRejeicao(
            dados,
            409,
            "Já existe um cliente com este CPF ou e-mail."
        );
    }

    @Test
    void deveRejeitarCpfDeClienteInativo()
            throws Exception {

        var dados = dadosValidos();

        dados.put("cpf", "98765410300");

        verificarRejeicao(
            dados,
            409,
            "Já existe um cliente com este CPF ou e-mail."
        );
    }

    @Test
    void deveRejeitarEmailDeClienteExcluido()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "email",
            EMAIL_CLIENTE_EXCLUIDO
        );

        verificarRejeicao(
            dados,
            409,
            "Já existe um cliente com este CPF ou e-mail."
        );

        assertTrue(
            clienteDAO.buscarPorId(104).isExcluido()
        );
    }

    @Test
    void devePadronizarNomeEmMaiusculas()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "nome",
            "  Cliente João da Silva  "
        );

        Cliente cliente =
            cadastrarComSucesso(dados);

        assertEquals(
            "CLIENTE JOÃO DA SILVA",
            cliente.getNome()
        );
    }

    @Test
    void deveRemoverMascaraDoCpf()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "cpf",
            "987.654.105-64"
        );

        Cliente cliente =
            cadastrarComSucesso(dados);

        assertEquals(
            CPF,
            cliente.getCpf()
        );
    }

    @Test
    void deveRemoverMascaraDoTelefone()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "telefone",
            "(11) 90000-0105"
        );

        Cliente cliente =
            cadastrarComSucesso(dados);

        assertEquals(
            TELEFONE,
            cliente.getTelefone()
        );
    }

    @Test
    void deveRemoverEspacosExternosDoEmail()
            throws Exception {

        var dados = dadosValidos();

        dados.put(
            "email",
            "  " + EMAIL + "  "
        );

        Cliente cliente =
            cadastrarComSucesso(dados);

        assertEquals(
            EMAIL,
            cliente.getEmail()
        );

        assertNotNull(
            clienteDAO.buscarPorEmail(EMAIL)
        );
    }

    @Test
    void deveArmazenarSenhaUtilizandoPBKDF2()
            throws Exception {

        Cliente cliente =
            cadastrarComSucesso(dadosValidos());

        String hash =
            cliente.getSenhaHash();

        assertNotNull(hash);

        assertNotEquals(SENHA, hash);

        assertTrue(
            hash.startsWith("pbkdf2$")
        );

        assertFalse(
            SenhaUtil.hashAntigo(hash)
        );

        assertTrue(
            SenhaUtil.verificarSenha(
                SENHA,
                hash
            )
        );

        assertFalse(
            SenhaUtil.verificarSenha(
                "SenhaIncorreta@123",
                hash
            )
        );
    }

    @Test
    void naoDeveExporSenhaOuHashNaResposta()
            throws Exception {

        Response resposta =
            cadastrar(dadosValidos());

        validarSucesso(resposta, 201);

        int idCliente =
            resposta.jsonPath().getInt("idCliente");

        Cliente cliente =
            clienteDAO.buscarPorId(idCliente);

        assertNotNull(cliente);

        Map<String, Object> json =
            resposta.jsonPath().getMap("$");

        assertEquals(
            java.util.Set.of(
                "sucesso",
                "mensagem",
                "idCliente",
                "nome",
                "email"
            ),
            json.keySet()
        );

        assertFalse(
            resposta.asString().contains(SENHA)
        );

        assertFalse(
            resposta.asString().contains(
                cliente.getSenhaHash()
            )
        );
    }

    @Test
    void devePermitirLoginAposCadastro()
            throws Exception {

        Cliente cliente =
            cadastrarComSucesso(dadosValidos());

        String sessao = autenticarCliente(
            EMAIL,
            SENHA,
            cliente.getIdCliente()
        );

        requisicaoAutenticada(sessao)

            .when()

            .get("/api/clientes/me")

            .then()

            .log().ifValidationFails()

            .statusCode(200)

            .body(
                "sucesso",
                equalTo(true)
            )

            .body(
                "cliente.idCliente",
                equalTo(cliente.getIdCliente())
            )

            .body(
                "cliente.nome",
                equalTo(NOME)
            )

            .body(
                "cliente.cpf",
                equalTo(CPF)
            )

            .body(
                "cliente.telefone",
                equalTo(TELEFONE)
            )

            .body(
                "cliente.email",
                equalTo(EMAIL)
            );
    }
}
