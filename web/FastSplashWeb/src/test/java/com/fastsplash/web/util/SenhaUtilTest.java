package com.fastsplash.web.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class SenhaUtilTest {

    private static final String SENHA_TESTE = "SenhaFicticia@123";

    @Test
    @DisplayName("Deve gerar um hash PBKDF2")
    void deveGerarHash() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertNotNull(hash);
        assertTrue(hash.startsWith("pbkdf2$"));
        assertNotEquals(SENHA_TESTE, hash);
    }

    @Test
    @DisplayName("Deve aceitar a senha correta")
    void deveAceitarSenhaCorreta() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertTrue(SenhaUtil.verificarSenha(SENHA_TESTE, hash));
    }

    @Test
    @DisplayName("Deve rejeitar uma senha incorreta")
    void deveRejeitarSenhaIncorreta() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertFalse(
            SenhaUtil.verificarSenha("SenhaIncorreta@123", hash)
        );
    }

    @Test
    @DisplayName("Deve gerar hashes diferentes para a mesma senha")
    void deveUtilizarSaltAleatorio() {
        String primeiroHash = SenhaUtil.gerarHash(SENHA_TESTE);
        String segundoHash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertNotEquals(primeiroHash, segundoHash);

        assertTrue(
            SenhaUtil.verificarSenha(SENHA_TESTE, primeiroHash)
        );

        assertTrue(
            SenhaUtil.verificarSenha(SENHA_TESTE, segundoHash)
        );
    }

    @Test
    @DisplayName("Deve rejeitar senha nula")
    void deveRejeitarSenhaNula() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertFalse(SenhaUtil.verificarSenha(null, hash));
    }

    @Test
    @DisplayName("Deve rejeitar hash nulo")
    void deveRejeitarHashNulo() {
        assertFalse(
            SenhaUtil.verificarSenha(SENHA_TESTE, null)
        );
    }

    @Test
    @DisplayName("Deve rejeitar hash vazio")
    void deveRejeitarHashVazio() {
        assertFalse(
            SenhaUtil.verificarSenha(SENHA_TESTE, "")
        );
    }

    @Test
    @DisplayName("Deve rejeitar formato de hash invalido")
    void deveRejeitarFormatoInvalido() {
        assertFalse(
            SenhaUtil.verificarSenha(SENHA_TESTE, "hash-invalido")
        );
    }

    @Test
    @DisplayName("Deve rejeitar hash PBKDF2 incompleto")
    void deveRejeitarHashIncompleto() {
        assertFalse(
            SenhaUtil.verificarSenha(SENHA_TESTE, "pbkdf2$120000")
        );
    }

    @Test
    @DisplayName("Deve rejeitar hash com Base64 invalido")
    void deveRejeitarBase64Invalido() {
        assertFalse(
            SenhaUtil.verificarSenha(
                SENHA_TESTE,
                "pbkdf2$120000$!!!$!!!"
            )
        );
    }

    @Test
    @DisplayName("Deve validar a estrutura do hash PBKDF2")
    void deveValidarEstruturaDoHash() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);
        String[] partes = hash.split("\\$");

        assertEquals(4, partes.length);
        assertEquals("pbkdf2", partes[0]);

        int iteracoes = Integer.parseInt(partes[1]);

        assertTrue(iteracoes >= 120000);

        byte[] salt = java.util.Base64.getDecoder()
            .decode(partes[2]);

        byte[] hashBytes = java.util.Base64.getDecoder()
            .decode(partes[3]);

        assertEquals(16, salt.length);
        assertEquals(32, hashBytes.length);
    }

    @Test
    @DisplayName("Deve diferenciar maiusculas e minusculas")
    void deveDiferenciarMaiusculasEMinusculas() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertFalse(
            SenhaUtil.verificarSenha("senhaficticia@123", hash)
        );
    }

    @Test
    @DisplayName("Deve aceitar caracteres especiais")
    void deveAceitarCaracteresEspeciais() {
        String senha = "Teste@#$%&*123!";
        String hash = SenhaUtil.gerarHash(senha);

        assertTrue(SenhaUtil.verificarSenha(senha, hash));
    }

    @Test
    @DisplayName("Deve aceitar caracteres Unicode")
    void deveAceitarUnicode() {
        String senha = "SenhaSegura@Ação123";
        String hash = SenhaUtil.gerarHash(senha);

        assertTrue(SenhaUtil.verificarSenha(senha, hash));
    }

    @Test
    @DisplayName("Deve rejeitar senha vazia contra hash valido")
    void deveRejeitarSenhaVazia() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        assertFalse(SenhaUtil.verificarSenha("", hash));
    }

    @Test
    @DisplayName("Deve rejeitar iteracoes invalidas")
    void deveRejeitarIteracoesInvalidas() {
        String hash = SenhaUtil.gerarHash(SENHA_TESTE);

        String hashInvalido = hash.replaceFirst(
            "pbkdf2[$][0-9]+[$]",
            java.util.regex.Matcher.quoteReplacement("pbkdf2$0$")
        );

        assertFalse(
            SenhaUtil.verificarSenha(SENHA_TESTE, hashInvalido)
        );
    }

    @Test
    @DisplayName("Deve identificar formato legado de senha")
    void deveIdentificarHashAntigo() {
        assertTrue(SenhaUtil.hashAntigo("HASH_Teste"));
        assertFalse(SenhaUtil.hashAntigo(null));
        assertFalse(
            SenhaUtil.hashAntigo(
                SenhaUtil.gerarHash(SENHA_TESTE)
            )
        );
    }
}
