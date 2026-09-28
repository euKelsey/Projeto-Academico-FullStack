package com.fastsplash.web.dao;

import java.sql.SQLException;
import java.util.List;

import com.fastsplash.web.model.Cliente;

public class TesteListarClientes {

    public static void main(String[] args) {

        ClienteDAO clienteDAO = new ClienteDAO();

        try {

            List<Cliente> clientes =
                    clienteDAO.listarTodos();

            for (Cliente cliente : clientes) {

                System.out.println(
                        cliente.getIdCliente()
                        + " - "
                        + cliente.getNome()
                        + " - "
                        + cliente.getEmail()
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao listar clientes."
            );

            e.printStackTrace();
        }
    }
}