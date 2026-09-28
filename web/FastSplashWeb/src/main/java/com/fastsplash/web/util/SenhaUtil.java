package com.fastsplash.web.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class SenhaUtil {

    private static final int ITERACOES = 120000;

    private static final int TAMANHO_HASH = 256;

    private static final int TAMANHO_SALT = 16;


    private SenhaUtil() {
    }


    public static String gerarHash(
            String senha
    ) {

        try {

            SecureRandom random =
                    new SecureRandom();


            byte[] salt =
                    new byte[TAMANHO_SALT];


            random.nextBytes(
                    salt
            );


            byte[] hash =
                    gerarBytesHash(
                            senha,
                            salt,
                            ITERACOES
                    );


            return "pbkdf2"
                    + "$"
                    + ITERACOES
                    + "$"
                    + Base64.getEncoder()
                            .encodeToString(salt)
                    + "$"
                    + Base64.getEncoder()
                            .encodeToString(hash);


        } catch (Exception e) {

            throw new RuntimeException(
                    "Erro ao gerar hash da senha.",
                    e
            );
        }
    }


    public static boolean verificarSenha(
            String senha,
            String senhaArmazenada
    ) {

        if (senha == null
                || senhaArmazenada == null) {

            return false;
        }


        /*
         * Compatibilidade temporária com as senhas
         * antigas que cadastramos usando HASH_.
         *
         * Quando todas forem alteradas para PBKDF2,
         * poderemos remover esta parte.
         */

        if (
            senhaArmazenada.startsWith(
                    "HASH_"
            )
        ) {

            return senhaArmazenada.equals(
                    "HASH_" + senha
            );
        }


        if (
            !senhaArmazenada.startsWith(
                    "pbkdf2$"
            )
        ) {

            return false;
        }


        try {

            String[] partes =
                    senhaArmazenada.split(
                            "\\$"
                    );


            if (partes.length != 4) {

                return false;
            }


            int iteracoes =
                    Integer.parseInt(
                            partes[1]
                    );


            byte[] salt =
                    Base64.getDecoder()
                            .decode(
                                    partes[2]
                            );


            byte[] hashEsperado =
                    Base64.getDecoder()
                            .decode(
                                    partes[3]
                            );


            byte[] hashInformado =
                    gerarBytesHash(
                            senha,
                            salt,
                            iteracoes
                    );


            return MessageDigest.isEqual(
                    hashEsperado,
                    hashInformado
            );


        } catch (Exception e) {

            return false;
        }
    }


    public static boolean hashAntigo(
            String senhaHash
    ) {

        return senhaHash != null
                && senhaHash.startsWith(
                        "HASH_"
                );
    }


    private static byte[] gerarBytesHash(
            String senha,
            byte[] salt,
            int iteracoes
    ) throws Exception {

        KeySpec especificacao =
                new PBEKeySpec(
                        senha.toCharArray(),
                        salt,
                        iteracoes,
                        TAMANHO_HASH
                );


        SecretKeyFactory fabrica =
                SecretKeyFactory.getInstance(
                        "PBKDF2WithHmacSHA256"
                );


        return fabrica
                .generateSecret(
                        especificacao
                )
                .getEncoded();
    }
}