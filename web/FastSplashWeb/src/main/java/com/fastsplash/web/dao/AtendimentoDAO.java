package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.Atendimento;

public class AtendimentoDAO {


    // =========================================
    // CREATE - CRIAR ATENDIMENTO
    // =========================================

    public void inserir(
            Atendimento atendimento
    ) throws SQLException {

        String sql = """
                INSERT INTO atendimento
                (id_agendamento)
                VALUES (?)
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

            comando.setInt(
                    1,
                    atendimento.getIdAgendamento()
            );


            comando.executeUpdate();


            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {

                if (resultado.next()) {

                    atendimento.setIdAtendimento(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }


    // =========================================
    // READ - LISTAR TODOS OS ATENDIMENTOS
    // =========================================

    public List<Atendimento> listarTodos()
            throws SQLException {

        String sql = """
                SELECT
                    at.id_atendimento,
                    at.id_agendamento,
                    at.status,
                    at.data_inicio,
                    at.data_fim,

                    CONCAT(
                        v.marca,
                        ' ',
                        v.modelo,
                        ' - ',
                        v.placa
                    ) AS veiculo,

                    GROUP_CONCAT(
                        s.nome
                        ORDER BY s.nome
                        SEPARATOR ', '
                    ) AS servicos

                FROM atendimento at

                INNER JOIN agendamento a
                    ON a.id_agendamento =
                       at.id_agendamento

                INNER JOIN veiculo v
                    ON v.id_veiculo =
                       a.id_veiculo

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                GROUP BY
                    at.id_atendimento,
                    at.id_agendamento,
                    at.status,
                    at.data_inicio,
                    at.data_fim,
                    v.marca,
                    v.modelo,
                    v.placa

                ORDER BY
                    at.id_atendimento DESC
                """;


        List<Atendimento> atendimentos =
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

                Atendimento atendimento =
                        criarAtendimento(
                                resultado
                        );

                atendimentos.add(
                        atendimento
                );
            }
        }


        return atendimentos;
    }


    // =========================================
    // READ - BUSCAR ATENDIMENTO POR ID
    // =========================================

    public Atendimento buscarPorId(
            int idAtendimento
    ) throws SQLException {

        String sql = """
                SELECT
                    at.id_atendimento,
                    at.id_agendamento,
                    at.status,
                    at.data_inicio,
                    at.data_fim,

                    CONCAT(
                        v.marca,
                        ' ',
                        v.modelo,
                        ' - ',
                        v.placa
                    ) AS veiculo,

                    GROUP_CONCAT(
                        s.nome
                        ORDER BY s.nome
                        SEPARATOR ', '
                    ) AS servicos

                FROM atendimento at

                INNER JOIN agendamento a
                    ON a.id_agendamento =
                       at.id_agendamento

                INNER JOIN veiculo v
                    ON v.id_veiculo =
                       a.id_veiculo

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                WHERE at.id_atendimento = ?

                GROUP BY
                    at.id_atendimento,
                    at.id_agendamento,
                    at.status,
                    at.data_inicio,
                    at.data_fim,
                    v.marca,
                    v.modelo,
                    v.placa
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idAtendimento
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarAtendimento(
                            resultado
                    );
                }
            }
        }


        return null;
    }


    // =========================================
    // LISTAR AGENDAMENTOS DISPONÍVEIS
    // =========================================

    public List<Agendamento>
            listarAgendamentosDisponiveis()
            throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,

                    CONCAT(
                        v.marca,
                        ' ',
                        v.modelo,
                        ' - ',
                        v.placa
                    ) AS veiculo,

                    GROUP_CONCAT(
                        s.nome
                        ORDER BY s.nome
                        SEPARATOR ', '
                    ) AS servicos,

                    COALESCE(
                        SUM(ags.valor_praticado),
                        0
                    ) AS valor_total

                FROM agendamento a

                INNER JOIN veiculo v
                    ON v.id_veiculo =
                       a.id_veiculo

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                LEFT JOIN atendimento at
                    ON at.id_agendamento =
                       a.id_agendamento

                WHERE
                    a.status = 'AGENDADO'
                    AND at.id_atendimento IS NULL

                GROUP BY
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    v.marca,
                    v.modelo,
                    v.placa

                ORDER BY
                    a.data,
                    a.horario
                """;


        List<Agendamento> agendamentos =
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

                Agendamento agendamento =
                        new Agendamento();


                agendamento.setIdAgendamento(
                        resultado.getInt(
                                "id_agendamento"
                        )
                );


                agendamento.setIdVeiculo(
                        resultado.getInt(
                                "id_veiculo"
                        )
                );


                agendamento.setData(
                        resultado.getDate(
                                "data"
                        ).toLocalDate()
                );


                agendamento.setHorario(
                        resultado.getTime(
                                "horario"
                        ).toLocalTime()
                );


                agendamento.setStatus(
                        resultado.getString(
                                "status"
                        )
                );


                agendamento.setVeiculoDescricao(
                        resultado.getString(
                                "veiculo"
                        )
                );


                agendamento.setServicosDescricao(
                        resultado.getString(
                                "servicos"
                        )
                );


                agendamento.setValorTotal(
                        resultado.getDouble(
                                "valor_total"
                        )
                );


                agendamentos.add(
                        agendamento
                );
            }
        }


        return agendamentos;
    }


    // =========================================
    // UPDATE - INICIAR LAVAGEM
    // =========================================

    public void iniciarLavagem(
            int idAtendimento
    ) throws SQLException {

        String sql = """
                UPDATE atendimento
                SET
                    status = 'EM_LAVAGEM',
                    data_inicio = NOW()
                WHERE id_atendimento = ?
                  AND status = 'AGUARDANDO'
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idAtendimento
            );


            int linhasAlteradas =
                    comando.executeUpdate();


            if (linhasAlteradas == 0) {

                throw new SQLException(
                        "O atendimento precisa estar AGUARDANDO para iniciar a lavagem."
                );
            }
        }
    }


    // =========================================
    // UPDATE - FINALIZAR ATENDIMENTO
    // =========================================

    public void finalizar(
            int idAtendimento
    ) throws SQLException {

        String sqlAtendimento = """
                UPDATE atendimento
                SET
                    status = 'FINALIZADO',
                    data_fim = NOW()
                WHERE id_atendimento = ?
                  AND status = 'EM_LAVAGEM'
                """;


        String sqlAgendamento = """
                UPDATE agendamento a

                INNER JOIN atendimento at
                    ON at.id_agendamento =
                       a.id_agendamento

                SET a.status = 'CONCLUIDO'

                WHERE at.id_atendimento = ?
                """;


        Connection conexao =
                Conexao.conectar();


        try {

            conexao.setAutoCommit(false);


            // =================================
            // FINALIZA O ATENDIMENTO
            // =================================

            try (
                PreparedStatement comandoAtendimento =
                        conexao.prepareStatement(
                                sqlAtendimento
                        )
            ) {

                comandoAtendimento.setInt(
                        1,
                        idAtendimento
                );


                int linhasAlteradas =
                        comandoAtendimento
                                .executeUpdate();


                if (linhasAlteradas == 0) {

                    throw new SQLException(
                            "O atendimento precisa estar EM_LAVAGEM antes de ser finalizado."
                    );
                }
            }


            // =================================
            // CONCLUI O AGENDAMENTO
            // =================================

            try (
                PreparedStatement comandoAgendamento =
                        conexao.prepareStatement(
                                sqlAgendamento
                        )
            ) {

                comandoAgendamento.setInt(
                        1,
                        idAtendimento
                );


                int linhasAlteradas =
                        comandoAgendamento
                                .executeUpdate();


                if (linhasAlteradas == 0) {

                    throw new SQLException(
                            "Agendamento relacionado ao atendimento não encontrado."
                    );
                }
            }


            conexao.commit();


        } catch (SQLException e) {

            conexao.rollback();

            throw e;


        } finally {

            try {

                conexao.setAutoCommit(true);

            } catch (SQLException e) {

                // A conexão será fechada logo abaixo.
            }


            conexao.close();
        }
    }


    // =========================================
    // MÉTODO AUXILIAR
    // RESULTSET -> OBJETO ATENDIMENTO
    // =========================================

    private Atendimento criarAtendimento(
            ResultSet resultado
    ) throws SQLException {

        Atendimento atendimento =
                new Atendimento();


        atendimento.setIdAtendimento(
                resultado.getInt(
                        "id_atendimento"
                )
        );


        atendimento.setIdAgendamento(
                resultado.getInt(
                        "id_agendamento"
                )
        );


        atendimento.setStatus(
                resultado.getString(
                        "status"
                )
        );


        Timestamp dataInicio =
                resultado.getTimestamp(
                        "data_inicio"
                );


        if (dataInicio != null) {

            atendimento.setDataInicio(
                    dataInicio
                            .toLocalDateTime()
            );
        }


        Timestamp dataFim =
                resultado.getTimestamp(
                        "data_fim"
                );


        if (dataFim != null) {

            atendimento.setDataFim(
                    dataFim
                            .toLocalDateTime()
            );
        }


        atendimento.setVeiculoDescricao(
                resultado.getString(
                        "veiculo"
                )
        );


        atendimento.setServicosDescricao(
                resultado.getString(
                        "servicos"
                )
        );


        return atendimento;
    }
}