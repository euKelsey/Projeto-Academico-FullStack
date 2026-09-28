package com.fastsplash.web.dao;

import java.sql.SQLException;

import com.fastsplash.web.model.Cliente;

public class TesteBuscarCliente {

    public static void main(String[] args) {

        ClienteDAO clienteDAO = new ClienteDAO();

        try {

            Cliente cliente =
                    clienteDAO.buscarPorId(4);

            if (cliente != null) {

                System.out.println(
                        "Cliente encontrado:"
                );

                System.out.println(
                        "ID: " + cliente.getIdCliente()
                );

                System.out.println(
                        "Nome: " + cliente.getNome()
                );

                System.out.println(
                        "E-mail: " + cliente.getEmail()
                );

            } else {

                System.out.println(
                        "Cliente não encontrado."
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao buscar cliente."
            );

            e.printStackTrace();
        }
    }
}