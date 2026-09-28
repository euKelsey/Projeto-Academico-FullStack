package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Cliente;

public class ClienteDAO {


    // =========================================
    // CREATE
    // =========================================

    public void inserir(
            Cliente cliente
    ) throws SQLException {

        String sql = """
                INSERT INTO cliente
                (
                    nome,
                    cpf,
                    telefone,
                    email,
                    senha_hash
                )
                VALUES (?, ?, ?, ?, ?)
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(
                            sql,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            comando.setString(
                    1,
                    cliente.getNome()
            );

            comando.setString(
                    2,
                    cliente.getCpf()
            );

            comando.setString(
                    3,
                    cliente.getTelefone()
            );

            comando.setString(
                    4,
                    cliente.getEmail()
            );

            comando.setString(
                    5,
                    cliente.getSenhaHash()
            );


            comando.executeUpdate();


            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {

                if (resultado.next()) {

                    cliente.setIdCliente(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }


    // =========================================
    // READ - LISTAR TODOS
    // =========================================

    public List<Cliente> listarTodos()
            throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                ORDER BY id_cliente
                """;


        List<Cliente> clientes =
                new ArrayList<>();


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql);

            ResultSet resultado =
                    comando.executeQuery()
        ) {

            while (resultado.next()) {

                clientes.add(
                        criarCliente(resultado)
                );
            }
        }


        return clientes;
    }


    // =========================================
    // READ - BUSCAR POR ID
    // =========================================

    public Cliente buscarPorId(
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE id_cliente = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idCliente
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarCliente(
                            resultado
                    );
                }
            }
        }


        return null;
    }


    // =========================================
    // READ - BUSCAR POR EMAIL
    // =========================================

    public Cliente buscarPorEmail(
            String email
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE email = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    email
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarCliente(
                            resultado
                    );
                }
            }
        }


        return null;
    }


    // =========================================
    // UPDATE
    // =========================================

    public void atualizar(
            Cliente cliente
    ) throws SQLException {

        String sql = """
                UPDATE cliente
                SET
                    nome = ?,
                    cpf = ?,
                    telefone = ?,
                    email = ?
                WHERE id_cliente = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    cliente.getNome()
            );

            comando.setString(
                    2,
                    cliente.getCpf()
            );

            comando.setString(
                    3,
                    cliente.getTelefone()
            );

            comando.setString(
                    4,
                    cliente.getEmail()
            );

            comando.setInt(
                    5,
                    cliente.getIdCliente()
            );


            comando.executeUpdate();
        }
    }


    // =========================================
    // UPDATE - SENHA
    // =========================================

    public void atualizarSenhaHash(
            int idCliente,
            String senhaHash
    ) throws SQLException {

        String sql = """
                UPDATE cliente
                SET senha_hash = ?
                WHERE id_cliente = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    senhaHash
            );

            comando.setInt(
                    2,
                    idCliente
            );


            comando.executeUpdate();
        }
    }


    // =========================================
    // DELETE
    // =========================================

    public void excluir(
            int idCliente
    ) throws SQLException {

        String sql = """
                DELETE FROM cliente
                WHERE id_cliente = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idCliente
            );


            comando.executeUpdate();
        }
    }


    // =========================================
    // RESULTSET -> CLIENTE
    // =========================================

    private Cliente criarCliente(
            ResultSet resultado
    ) throws SQLException {

        Cliente cliente =
                new Cliente();


        cliente.setIdCliente(
                resultado.getInt(
                        "id_cliente"
                )
        );

        cliente.setNome(
                resultado.getString(
                        "nome"
                )
        );

        cliente.setCpf(
                resultado.getString(
                        "cpf"
                )
        );

        cliente.setTelefone(
                resultado.getString(
                        "telefone"
                )
        );

        cliente.setEmail(
                resultado.getString(
                        "email"
                )
        );

        cliente.setSenhaHash(
                resultado.getString(
                        "senha_hash"
                )
        );


        return cliente;
    }
}