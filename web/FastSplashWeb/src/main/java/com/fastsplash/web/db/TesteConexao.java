package com.fastsplash.web.db;

import java.sql.Connection;

public class TesteConexao {

    public static void main(String[] args) {

        try (
            Connection conexao =
                    Conexao.conectar()
        ) {

            System.out.println(
                    "Conexão com o MySQL realizada com sucesso!"
            );

        } catch (Exception e) {

            System.out.println(
                    "Erro ao conectar com o MySQL:"
            );

            e.printStackTrace();
        }
    }
}