package com.fastsplash.web.dao;

import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Cliente;

public class ClienteDAO {

    public void inserir(Cliente cliente) throws SQLException {

        String sql = """
                INSERT INTO cliente
                (nome, cpf, telefone, email, senha_hash)
                VALUES (?, ?, ?, ?, ?)
                """;
        

        try (
            Connection conexao = Conexao.conectar();

            PreparedStatement comando = conexao.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
            )
        ) {

            comando.setString(1, cliente.getNome());
            comando.setString(2, cliente.getCpf());
            comando.setString(3, cliente.getTelefone());
            comando.setString(4, cliente.getEmail());
            comando.setString(5, cliente.getSenhaHash());

            comando.executeUpdate();

            try (ResultSet resultado = comando.getGeneratedKeys()) {

                if (resultado.next()) {
                    cliente.setIdCliente(resultado.getInt(1));
                }
            }
        }
    }
    public List<Cliente> listarTodos() throws SQLException {

        String sql = "SELECT * FROM cliente";

        List<Cliente> clientes = new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando = conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery()
        ) {

            while (resultado.next()) {

                Cliente cliente = new Cliente();

                cliente.setIdCliente(
                        resultado.getInt("id_cliente")
                );

                cliente.setNome(
                        resultado.getString("nome")
                );

                cliente.setCpf(
                        resultado.getString("cpf")
                );

                cliente.setTelefone(
                        resultado.getString("telefone")
                );

                cliente.setEmail(
                        resultado.getString("email")
                );

                cliente.setSenhaHash(
                        resultado.getString("senha_hash")
                );

                clientes.add(cliente);
            }
        }

        return clientes;
    }
    public Cliente buscarPorId(int idCliente) throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando = conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (ResultSet resultado = comando.executeQuery()) {

                if (resultado.next()) {

                    Cliente cliente = new Cliente();

                    cliente.setIdCliente(
                            resultado.getInt("id_cliente")
                    );

                    cliente.setNome(
                            resultado.getString("nome")
                    );

                    cliente.setCpf(
                            resultado.getString("cpf")
                    );

                    cliente.setTelefone(
                            resultado.getString("telefone")
                    );

                    cliente.setEmail(
                            resultado.getString("email")
                    );

                    cliente.setSenhaHash(
                            resultado.getString("senha_hash")
                    );

                    return cliente;
                }
            }
        }

        return null;
    }
    public void atualizar(Cliente cliente) throws SQLException {

        String sql = """
                UPDATE cliente
                SET nome = ?,
                    cpf = ?,
                    telefone = ?,
                    email = ?,
                    senha_hash = ?
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando = conexao.prepareStatement(sql)
        ) {

            comando.setString(1, cliente.getNome());
            comando.setString(2, cliente.getCpf());
            comando.setString(3, cliente.getTelefone());
            comando.setString(4, cliente.getEmail());
            comando.setString(5, cliente.getSenhaHash());
            comando.setInt(6, cliente.getIdCliente());

            comando.executeUpdate();
        }
    }
    public void excluir(int idCliente) throws SQLException {

        String sql = """
                DELETE FROM cliente
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando = conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            comando.executeUpdate();
        }
    }
}