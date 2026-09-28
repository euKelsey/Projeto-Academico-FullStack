package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Veiculo;

public class VeiculoDAO {

    // CREATE
    public void inserir(Veiculo veiculo) throws SQLException {

        String sql = """
                INSERT INTO veiculo
                (id_cliente, placa, marca, modelo, cor)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (
            Connection conexao = Conexao.conectar();

            PreparedStatement comando = conexao.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
            )
        ) {

            comando.setInt(1, veiculo.getIdCliente());
            comando.setString(2, veiculo.getPlaca());
            comando.setString(3, veiculo.getMarca());
            comando.setString(4, veiculo.getModelo());
            comando.setString(5, veiculo.getCor());

            comando.executeUpdate();

            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {

                if (resultado.next()) {

                    veiculo.setIdVeiculo(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }


    // READ - LISTAR TODOS
    public List<Veiculo> listarTodos() throws SQLException {

        String sql = """
                SELECT *
                FROM veiculo
                ORDER BY id_veiculo
                """;

        List<Veiculo> veiculos =
                new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql);
            ResultSet resultado =
                    comando.executeQuery()
        ) {

            while (resultado.next()) {

                Veiculo veiculo =
                        criarVeiculo(resultado);

                veiculos.add(veiculo);
            }
        }

        return veiculos;
    }


    // READ - BUSCAR PELO ID
    public Veiculo buscarPorId(
            int idVeiculo
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM veiculo
                WHERE id_veiculo = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idVeiculo
            );

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarVeiculo(
                            resultado
                    );
                }
            }
        }

        return null;
    }


    // READ - LISTAR VEÍCULOS DE UM CLIENTE
    public List<Veiculo> listarPorCliente(
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM veiculo
                WHERE id_cliente = ?
                ORDER BY id_veiculo
                """;

        List<Veiculo> veiculos =
                new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
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

                while (resultado.next()) {

                    Veiculo veiculo =
                            criarVeiculo(resultado);

                    veiculos.add(veiculo);
                }
            }
        }

        return veiculos;
    }


    // UPDATE
    public void atualizar(
            Veiculo veiculo
    ) throws SQLException {

        String sql = """
                UPDATE veiculo
                SET id_cliente = ?,
                    placa = ?,
                    marca = ?,
                    modelo = ?,
                    cor = ?
                WHERE id_veiculo = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    veiculo.getIdCliente()
            );

            comando.setString(
                    2,
                    veiculo.getPlaca()
            );

            comando.setString(
                    3,
                    veiculo.getMarca()
            );

            comando.setString(
                    4,
                    veiculo.getModelo()
            );

            comando.setString(
                    5,
                    veiculo.getCor()
            );

            comando.setInt(
                    6,
                    veiculo.getIdVeiculo()
            );

            comando.executeUpdate();
        }
    }


    // DELETE
    public void excluir(
            int idVeiculo
    ) throws SQLException {

        String sql = """
                DELETE FROM veiculo
                WHERE id_veiculo = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idVeiculo
            );

            comando.executeUpdate();
        }
    }


    // MÉTODO AUXILIAR
    private Veiculo criarVeiculo(
            ResultSet resultado
    ) throws SQLException {

        Veiculo veiculo =
                new Veiculo();

        veiculo.setIdVeiculo(
                resultado.getInt(
                        "id_veiculo"
                )
        );

        veiculo.setIdCliente(
                resultado.getInt(
                        "id_cliente"
                )
        );

        veiculo.setPlaca(
                resultado.getString(
                        "placa"
                )
        );

        veiculo.setMarca(
                resultado.getString(
                        "marca"
                )
        );

        veiculo.setModelo(
                resultado.getString(
                        "modelo"
                )
        );

        veiculo.setCor(
                resultado.getString(
                        "cor"
                )
        );

        return veiculo;
    }
}