package com.fastsplash.web.db;

import java.sql.Connection;
import java.sql.SQLException;

public class TesteConexao {

    public static void main(String[] args) {

        try {

            Connection conexao = Conexao.conectar();

            System.out.println(
                    "Conexão com o banco realizada com sucesso!"
            );

            conexao.close();

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao conectar com o banco."
            );

            e.printStackTrace();
        }
    }
}