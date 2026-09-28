package com.fastsplash.web.dao;

import java.sql.SQLException;

import com.fastsplash.web.model.Cliente;

public class TesteClienteDAO {

    public static void main(String[] args) {

        Cliente cliente = new Cliente();

        cliente.setNome("Kelsey Luciano");
        cliente.setCpf("11122233344");
        cliente.setTelefone("11999999999");
        cliente.setEmail("Kelsey@teste.com");

        cliente.setSenhaHash("HASH_FICTICIO_PARA_TESTE");

        ClienteDAO clienteDAO = new ClienteDAO();

        try {

            clienteDAO.inserir(cliente);

            System.out.println("Cliente cadastrado com sucesso!");
            System.out.println(
                    "ID gerado: " + cliente.getIdCliente()
            );

        } catch (SQLException e) {

            System.out.println(
                    "Erro ao cadastrar cliente."
            );

            e.printStackTrace();
        }
    }
}