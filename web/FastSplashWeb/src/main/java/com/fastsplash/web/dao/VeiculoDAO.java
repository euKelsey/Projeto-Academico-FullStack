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
                WHERE ativo = TRUE
                  AND excluido_em IS NULL
                  AND id_cliente IN (
                      SELECT id_cliente FROM cliente
                      WHERE ativo = TRUE AND excluido_em IS NULL
                  )
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
                  AND ativo = TRUE
                  AND excluido_em IS NULL
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
                  AND excluido_em IS NULL
                  AND ativo = TRUE
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



    // LISTAGEM POR STATUS
    public List<Veiculo> listarPorStatus(
            String status
    ) throws SQLException {

        String filtro = switch (
                status == null ? "ativos" : status
        ) {
            case "inativos" ->
                "ativo = FALSE AND excluido_em IS NULL";
            case "excluidos" ->
                "excluido_em IS NOT NULL";
            default ->
                "ativo = TRUE AND excluido_em IS NULL";
        };

        String sql = "SELECT * FROM veiculo WHERE "
                + filtro + " ORDER BY id_veiculo";

        List<Veiculo> veiculos = new ArrayList<>();

        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando =
                     conexao.prepareStatement(sql);
             ResultSet resultado = comando.executeQuery()) {

            while (resultado.next()) {
                veiculos.add(criarVeiculo(resultado));
            }
        }

        return veiculos;
    }

    // VERIFICAR PENDENCIAS
    private boolean possuiPendencias(
            Connection conexao,
            int idVeiculo
    ) throws SQLException {

        String sql = """
                SELECT EXISTS (
                    SELECT 1
                    FROM agendamento a
                    LEFT JOIN atendimento at
                        ON at.id_agendamento = a.id_agendamento
                    WHERE a.id_veiculo = ?
                      AND (
                          a.status = 'AGENDADO'
                          OR at.status IN (
                              'AGUARDANDO', 'EM_LAVAGEM'
                          )
                      )
                )
                """;

        try (PreparedStatement comando =
                conexao.prepareStatement(sql)) {

            comando.setInt(1, idVeiculo);

            try (ResultSet resultado =
                    comando.executeQuery()) {
                return resultado.next()
                        && resultado.getBoolean(1);
            }
        }
    }

    // CONTROLE TRANSACIONAL DE STATUS
    private ResultadoStatusVeiculo alterarStatus(
            int idVeiculo,
            String acao
    ) throws SQLException {

        try (Connection conexao = Conexao.conectar()) {

            conexao.setAutoCommit(false);

            try {

                Veiculo veiculo;

                String consulta = """
                        SELECT *
                        FROM veiculo
                        WHERE id_veiculo = ?
                        FOR UPDATE
                        """;

                try (PreparedStatement comando =
                        conexao.prepareStatement(consulta)) {

                    comando.setInt(1, idVeiculo);

                    try (ResultSet resultado =
                            comando.executeQuery()) {

                        if (!resultado.next()) {
                            conexao.rollback();
                            return ResultadoStatusVeiculo
                                    .VEICULO_NAO_ENCONTRADO;
                        }

                        veiculo = criarVeiculo(resultado);
                    }
                }

                if (veiculo.isExcluido()
                        && !"restaurar".equals(acao)) {
                    conexao.rollback();
                    return ResultadoStatusVeiculo.JA_EXCLUIDO;
                }

                if ("restaurar".equals(acao)
                        && !veiculo.isExcluido()) {
                    conexao.rollback();
                    return ResultadoStatusVeiculo.NAO_EXCLUIDO;
                }

                if ("inativar".equals(acao)
                        && !veiculo.isAtivo()) {
                    conexao.rollback();
                    return ResultadoStatusVeiculo.JA_INATIVO;
                }

                if ("reativar".equals(acao)
                        && veiculo.isAtivo()) {
                    conexao.rollback();
                    return ResultadoStatusVeiculo.JA_ATIVO;
                }

                boolean ativar =
                        "reativar".equals(acao)
                        || "restaurar".equals(acao);

                if (ativar) {

                    String sqlCliente = """
                            SELECT ativo, excluido_em
                            FROM cliente
                            WHERE id_cliente = ?
                            FOR UPDATE
                            """;

                    try (PreparedStatement comando =
                            conexao.prepareStatement(sqlCliente)) {

                        comando.setInt(
                                1, veiculo.getIdCliente());

                        try (ResultSet resultado =
                                comando.executeQuery()) {

                            if (!resultado.next()
                                    || !resultado.getBoolean("ativo")
                                    || resultado.getTimestamp(
                                            "excluido_em") != null) {

                                conexao.rollback();

                                return ResultadoStatusVeiculo
                                        .CLIENTE_INATIVO;
                            }
                        }
                    }

                } else if (
                        possuiPendencias(conexao, idVeiculo)) {

                    conexao.rollback();

                    return ResultadoStatusVeiculo
                            .POSSUI_PENDENCIAS;
                }

                String sql = switch (acao) {

                    case "inativar" -> """
                            UPDATE veiculo
                            SET ativo = FALSE
                            WHERE id_veiculo = ?
                            """;

                    case "excluir" -> """
                            UPDATE veiculo
                            SET ativo = FALSE,
                                excluido_em = CURRENT_TIMESTAMP
                            WHERE id_veiculo = ?
                            """;

                    case "reativar", "restaurar" -> """
                            UPDATE veiculo
                            SET ativo = TRUE,
                                excluido_em = NULL
                            WHERE id_veiculo = ?
                            """;

                    default ->
                        throw new SQLException("Acao invalida.");
                };

                try (PreparedStatement comando =
                        conexao.prepareStatement(sql)) {

                    comando.setInt(1, idVeiculo);
                    comando.executeUpdate();
                }

                conexao.commit();

                return ResultadoStatusVeiculo.SUCESSO;

            } catch (SQLException e) {

                conexao.rollback();
                throw e;
            }
        }
    }

    public ResultadoStatusVeiculo inativarVeiculo(
            int idVeiculo
    ) throws SQLException {
        return alterarStatus(idVeiculo, "inativar");
    }

    public ResultadoStatusVeiculo reativarVeiculo(
            int idVeiculo
    ) throws SQLException {
        return alterarStatus(idVeiculo, "reativar");
    }

    public ResultadoStatusVeiculo excluirLogicamente(
            int idVeiculo
    ) throws SQLException {
        return alterarStatus(idVeiculo, "excluir");
    }

    public ResultadoStatusVeiculo restaurarVeiculo(
            int idVeiculo
    ) throws SQLException {
        return alterarStatus(idVeiculo, "restaurar");
    }

    // Compatibilidade com chamadas existentes
    public void excluir(int idVeiculo)
            throws SQLException {

        ResultadoStatusVeiculo resultado =
                excluirLogicamente(idVeiculo);

        if (resultado != ResultadoStatusVeiculo.SUCESSO) {
            throw new SQLException(
                    "Nao foi possivel excluir: " + resultado
            );
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

        veiculo.setAtivo(
                resultado.getBoolean("ativo")
        );

        veiculo.setExcluidoEm(
                resultado.getObject(
                    "excluido_em",
                    java.time.LocalDateTime.class
                )
        );

        return veiculo;
    }
}