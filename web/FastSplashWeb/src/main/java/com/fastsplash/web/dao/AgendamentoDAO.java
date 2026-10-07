package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import com.fastsplash.web.model.AgendamentoCliente;
import com.fastsplash.web.model.Servico;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Agendamento;

public class AgendamentoDAO {


    // =========================================
    // CREATE
    // =========================================

    public void inserir(
            Agendamento agendamento
    ) throws SQLException {

        if (
            agendamento.getIdsServicos() == null
            || agendamento.getIdsServicos().isEmpty()
        ) {

            throw new SQLException(
                    "O agendamento deve possuir pelo menos um serviço."
            );
        }


        String sqlAgendamento = """
                INSERT INTO agendamento
                (id_veiculo, data, horario, status)
                VALUES (?, ?, ?, 'AGENDADO')
                """;


        String sqlBuscarPreco = """
                SELECT preco
                FROM servico
                WHERE id_servico = ?
                """;


        String sqlAgendamentoServico = """
                INSERT INTO agendamento_servico
                (
                    id_agendamento,
                    id_servico,
                    valor_praticado
                )
                VALUES (?, ?, ?)
                """;


        Connection conexao =
                Conexao.conectar();

        try {

            conexao.setAutoCommit(false);


            // =================================
            // CRIA O AGENDAMENTO
            // =================================

            try (
                PreparedStatement comandoAgendamento =
                        conexao.prepareStatement(
                                sqlAgendamento,
                                Statement.RETURN_GENERATED_KEYS
                        )
            ) {

                comandoAgendamento.setInt(
                        1,
                        agendamento.getIdVeiculo()
                );

                comandoAgendamento.setDate(
                        2,
                        Date.valueOf(
                                agendamento.getData()
                        )
                );

                comandoAgendamento.setTime(
                        3,
                        Time.valueOf(
                                agendamento.getHorario()
                        )
                );


                comandoAgendamento.executeUpdate();


                try (
                    ResultSet resultado =
                            comandoAgendamento
                                    .getGeneratedKeys()
                ) {

                    if (resultado.next()) {

                        agendamento.setIdAgendamento(
                                resultado.getInt(1)
                        );

                    } else {

                        throw new SQLException(
                                "Não foi possível obter o ID do agendamento."
                        );
                    }
                }
            }


            // =================================
            // LIGA OS SERVIÇOS AO AGENDAMENTO
            // =================================

            try (
                PreparedStatement buscarPreco =
                        conexao.prepareStatement(
                                sqlBuscarPreco
                        );

                PreparedStatement inserirServico =
                        conexao.prepareStatement(
                                sqlAgendamentoServico
                        )
            ) {

                for (
                    int idServico :
                    agendamento.getIdsServicos()
                ) {

                    buscarPreco.setInt(
                            1,
                            idServico
                    );


                    double valorPraticado;


                    try (
                        ResultSet resultado =
                                buscarPreco.executeQuery()
                    ) {

                        if (!resultado.next()) {

                            throw new SQLException(
                                    "Serviço "
                                    + idServico
                                    + " não encontrado."
                            );
                        }


                        valorPraticado =
                                resultado.getDouble(
                                        "preco"
                                );
                    }


                    inserirServico.setInt(
                            1,
                            agendamento.getIdAgendamento()
                    );

                    inserirServico.setInt(
                            2,
                            idServico
                    );

                    inserirServico.setDouble(
                            3,
                            valorPraticado
                    );


                    inserirServico.executeUpdate();
                }
            }


            conexao.commit();


        } catch (SQLException e) {

            conexao.rollback();

            throw e;


        } finally {

            conexao.close();
        }
    }


    // =========================================
    // READ - LISTAR TODOS
    // =========================================

    public List<Agendamento> listarTodos()
            throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    c.nome AS cliente,

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

                INNER JOIN cliente c
                    ON c.id_cliente =
                       v.id_cliente

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                GROUP BY
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    c.nome,
                    v.marca,
                    v.modelo,
                    v.placa

                ORDER BY
                    a.data DESC,
                    a.horario DESC
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

                agendamentos.add(
                        criarAgendamento(
                                resultado
                        )
                );
            }
        }


        return agendamentos;
    }


    // =========================================
    // READ - BUSCAR POR ID
    // =========================================

    public Agendamento buscarPorId(
            int idAgendamento
    ) throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    c.nome AS cliente,

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

                INNER JOIN cliente c
                    ON c.id_cliente =
                       v.id_cliente

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                WHERE a.id_agendamento = ?

                GROUP BY
                    a.id_agendamento,
                    a.id_veiculo,
                    a.data,
                    a.horario,
                    a.status,
                    c.nome,
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
                    idAgendamento
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarAgendamento(
                            resultado
                    );
                }
            }
        }


        return null;
    }


    // =========================================
    // CANCELAR
    // =========================================

    public void cancelar(
            int idAgendamento
    ) throws SQLException {

        String sql = """
                UPDATE agendamento
                SET status = 'CANCELADO'
                WHERE id_agendamento = ?
                  AND status = 'AGENDADO'
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idAgendamento
            );

            comando.executeUpdate();
        }
    }

 // =========================================
 // READ - AGENDAMENTOS DO CLIENTE
 // =========================================

 public List<AgendamentoCliente>
         listarPorCliente(
         int idCliente
 ) throws SQLException {

     String sql = """
             SELECT
                 a.id_agendamento,
                 a.id_veiculo,
                 a.data,
                 a.horario,
                 a.status AS status_agendamento,

                 v.marca,
                 v.modelo,
                 v.placa,
                 v.cor,

                 at.status AS status_atendimento,

                 s.id_servico,
                 s.nome AS nome_servico,
                 s.descricao,

                 ags.valor_praticado

             FROM agendamento a

             INNER JOIN veiculo v
                 ON v.id_veiculo =
                    a.id_veiculo

             LEFT JOIN atendimento at
                 ON at.id_agendamento =
                    a.id_agendamento

             LEFT JOIN agendamento_servico ags
                 ON ags.id_agendamento =
                    a.id_agendamento

             LEFT JOIN servico s
                 ON s.id_servico =
                    ags.id_servico

             WHERE v.id_cliente = ?

             ORDER BY
                 a.data DESC,
                 a.horario DESC,
                 a.id_agendamento DESC,
                 s.nome
             """;


     Map<Integer, AgendamentoCliente> mapa =
             new LinkedHashMap<>();


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

             while (resultado.next()) {

                 int idAgendamento =
                         resultado.getInt(
                                 "id_agendamento"
                         );


                 AgendamentoCliente item =
                         mapa.get(
                                 idAgendamento
                         );


                 if (item == null) {

                     item =
                             new AgendamentoCliente();


                     item.setIdAgendamento(
                             idAgendamento
                     );


                     item.setIdVeiculo(
                             resultado.getInt(
                                     "id_veiculo"
                             )
                     );


                     item.setData(
                             resultado
                                 .getDate("data")
                                 .toLocalDate()
                     );


                     item.setHorario(
                             resultado
                                 .getTime("horario")
                                 .toLocalTime()
                     );


                     item.setStatusAgendamento(
                             resultado.getString(
                                     "status_agendamento"
                             )
                     );


                     item.setStatusAtendimento(
                             resultado.getString(
                                     "status_atendimento"
                             )
                     );


                     item.setMarca(
                             resultado.getString(
                                     "marca"
                             )
                     );


                     item.setModelo(
                             resultado.getString(
                                     "modelo"
                             )
                     );


                     item.setPlaca(
                             resultado.getString(
                                     "placa"
                             )
                     );


                     item.setCor(
                             resultado.getString(
                                     "cor"
                             )
                     );


                     mapa.put(
                             idAgendamento,
                             item
                     );
                 }


                 int idServico =
                         resultado.getInt(
                                 "id_servico"
                         );


                 if (!resultado.wasNull()) {

                     Servico servico =
                             new Servico();


                     servico.setIdServico(
                             idServico
                     );


                     servico.setNome(
                             resultado.getString(
                                     "nome_servico"
                             )
                     );


                     servico.setDescricao(
                             resultado.getString(
                                     "descricao"
                             )
                     );


                     // Valor histórico do momento
                     // em que foi agendado.
                     servico.setPreco(
                             resultado.getDouble(
                                     "valor_praticado"
                             )
                     );


                     item.getServicos()
                         .add(
                             servico
                         );
                 }
             }
         }
     }


     return new ArrayList<>(
             mapa.values()
     );
 }

//=========================================
//CANCELAR PELO CLIENTE
//=========================================

public boolean cancelarDoCliente(
      int idAgendamento,
      int idCliente
) throws SQLException {

  String sql = """
          UPDATE agendamento a

          INNER JOIN veiculo v
              ON v.id_veiculo =
                 a.id_veiculo

          LEFT JOIN atendimento at
              ON at.id_agendamento =
                 a.id_agendamento

          SET a.status = 'CANCELADO'

          WHERE a.id_agendamento = ?
            AND v.id_cliente = ?
            AND a.status = 'AGENDADO'
            AND at.id_atendimento IS NULL
          """;


  try (
      Connection conexao =
              Conexao.conectar();

      PreparedStatement comando =
              conexao.prepareStatement(sql)
  ) {

      comando.setInt(
              1,
              idAgendamento
      );

      comando.setInt(
              2,
              idCliente
      );


      int linhas =
              comando.executeUpdate();


      return linhas > 0;
  }
}


    // =========================================
    // MÉTODO AUXILIAR
    // =========================================

    private Agendamento criarAgendamento(
            ResultSet resultado
    ) throws SQLException {

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


        agendamento.setClienteNome(
                resultado.getString(
                        "cliente"
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


        return agendamento;
    }
}
