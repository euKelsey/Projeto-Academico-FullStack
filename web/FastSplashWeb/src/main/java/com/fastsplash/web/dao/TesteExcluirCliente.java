package com.fastsplash.web.dao;

import java.sql.SQLException;

public class TesteExcluirCliente {

    public static void main(String[] args) {

        ClienteDAO clienteDAO = new ClienteDAO();

        try {

            clienteDAO.excluir(4);

            System.out.println(
                    "Cliente excluído com sucesso!"
            );

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao excluir cliente."
            );

            e.printStackTrace();
        }
    }
}