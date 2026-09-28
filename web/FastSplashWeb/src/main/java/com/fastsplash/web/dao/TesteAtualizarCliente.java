package com.fastsplash.web.dao;

import java.sql.SQLException;

import com.fastsplash.web.model.Cliente;

public class TesteAtualizarCliente {

    public static void main(String[] args) {

        ClienteDAO clienteDAO = new ClienteDAO();

        try {

            Cliente cliente =
                    clienteDAO.buscarPorId(4);

            if (cliente != null) {

                cliente.setTelefone("11988887777");
                cliente.setEmail("kelsey.atualizado@teste.com");

                clienteDAO.atualizar(cliente);

                System.out.println(
                        "Cliente atualizado com sucesso!"
                );

            } else {

                System.out.println(
                        "Cliente não encontrado."
                );
            }

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao atualizar cliente."
            );

            e.printStackTrace();
        }
    }
}