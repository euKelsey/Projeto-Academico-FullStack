package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Servico;

public class ServicoDAO {

    // CREATE
    public void inserir(Servico servico) throws SQLException {

        String sql = """
                INSERT INTO servico
                (nome, descricao, preco)
                VALUES (?, ?, ?)
                """;

        try (
            Connection conexao = Conexao.conectar();

            PreparedStatement comando = conexao.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
            )
        ) {

            comando.setString(
                    1,
                    servico.getNome()
            );

            comando.setString(
                    2,
                    servico.getDescricao()
            );

            comando.setDouble(
                    3,
                    servico.getPreco()
            );

            comando.executeUpdate();

            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {

                if (resultado.next()) {

                    servico.setIdServico(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }


    // READ - LISTAR TODOS
    public List<Servico> listarTodos() throws SQLException {

        String sql = """
                SELECT *
                FROM servico
                ORDER BY id_servico
                """;

        List<Servico> servicos =
                new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql);
            ResultSet resultado =
                    comando.executeQuery()
        ) {

            while (resultado.next()) {

                Servico servico =
                        criarServico(resultado);

                servicos.add(servico);
            }
        }

        return servicos;
    }


    // READ - BUSCAR POR ID
    public Servico buscarPorId(
            int idServico
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM servico
                WHERE id_servico = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idServico
            );

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarServico(
                            resultado
                    );
                }
            }
        }

        return null;
    }


    // UPDATE
    public void atualizar(
            Servico servico
    ) throws SQLException {

        String sql = """
                UPDATE servico
                SET nome = ?,
                    descricao = ?,
                    preco = ?
                WHERE id_servico = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    servico.getNome()
            );

            comando.setString(
                    2,
                    servico.getDescricao()
            );

            comando.setDouble(
                    3,
                    servico.getPreco()
            );

            comando.setInt(
                    4,
                    servico.getIdServico()
            );

            comando.executeUpdate();
        }
    }


    // DELETE
    public void excluir(
            int idServico
    ) throws SQLException {

        String sql = """
                DELETE FROM servico
                WHERE id_servico = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idServico
            );

            comando.executeUpdate();
        }
    }


    // MÉTODO AUXILIAR
    private Servico criarServico(
            ResultSet resultado
    ) throws SQLException {

        Servico servico =
                new Servico();

        servico.setIdServico(
                resultado.getInt(
                        "id_servico"
                )
        );

        servico.setNome(
                resultado.getString(
                        "nome"
                )
        );

        servico.setDescricao(
                resultado.getString(
                        "descricao"
                )
        );

        servico.setPreco(
                resultado.getDouble(
                        "preco"
                )
        );

        return servico;
    }
}