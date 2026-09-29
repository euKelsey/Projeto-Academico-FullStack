package com.fastsplash.web.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {

    private static final String URL =
            obterVariavel(
                    "FASTSPLASH_DB_URL",
                    "jdbc:mysql://localhost:3306/lava_rapido"
            );

    private static final String USUARIO =
            obterVariavel(
                    "FASTSPLASH_DB_USER",
                    "root"
            );

    private static final String SENHA =
            obterVariavel(
                    "FASTSPLASH_DB_PASSWORD",
                    null
            );


    static {
        try {
            Class.forName(
                    "com.mysql.cj.jdbc.Driver"
            );
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                    "Driver do MySQL não encontrado.",
                    e
            );
        }
    }


    public static Connection conectar()
            throws SQLException {

        if (SENHA == null
                || SENHA.isBlank()) {

            throw new SQLException(
                    "A variável de ambiente "
                    + "FASTSPLASH_DB_PASSWORD "
                    + "não foi configurada."
            );
        }

        return DriverManager.getConnection(
                URL,
                USUARIO,
                SENHA
        );
    }


    private static String obterVariavel(
            String nome,
            String valorPadrao
    ) {

        String valor =
                System.getenv(nome);

        if (valor == null
                || valor.isBlank()) {

            return valorPadrao;
        }

        return valor;
    }
}