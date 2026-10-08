package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Pagamento;

public class PagamentoDAO {


    // =========================================
    // LISTAR PAGAMENTOS DO CLIENTE
    // =========================================

    public List<Pagamento> listarPorCliente(
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT
                    a.id_agendamento,

                    COALESCE(
                        p.id_pagamento,
                        0
                    ) AS id_pagamento,

                    p.data_pagamento,

                    COALESCE(
                        p.valor,
                        SUM(ags.valor_praticado),
                        0
                    ) AS valor,

                    p.forma_pagamento,

                    COALESCE(
                        p.status_pagamento,
                        'PENDENTE'
                    ) AS status_pagamento,

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

                FROM agendamento a

                INNER JOIN veiculo v
                    ON v.id_veiculo =
                       a.id_veiculo

                LEFT JOIN pagamento p
                    ON p.id_agendamento =
                       a.id_agendamento

                LEFT JOIN agendamento_servico ags
                    ON ags.id_agendamento =
                       a.id_agendamento

                LEFT JOIN servico s
                    ON s.id_servico =
                       ags.id_servico

                WHERE v.id_cliente = ?
                  AND a.status <> 'CANCELADO'

                GROUP BY
                    a.id_agendamento,
                    p.id_pagamento,
                    p.data_pagamento,
                    p.valor,
                    p.forma_pagamento,
                    p.status_pagamento,
                    v.marca,
                    v.modelo,
                    v.placa

                ORDER BY
                    a.data DESC,
                    a.horario DESC
                """;


        List<Pagamento> pagamentos =
                new ArrayList<>();


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

                    Pagamento pagamento =
                            new Pagamento();


                    pagamento.setIdPagamento(
                            resultado.getInt(
                                    "id_pagamento"
                            )
                    );


                    pagamento.setIdAgendamento(
                            resultado.getInt(
                                    "id_agendamento"
                            )
                    );


                    Timestamp dataPagamento =
                            resultado.getTimestamp(
                                    "data_pagamento"
                            );


                    if (dataPagamento != null) {

                        pagamento.setDataPagamento(
                                dataPagamento
                                    .toLocalDateTime()
                        );
                    }


                    pagamento.setValor(
                            resultado.getDouble(
                                    "valor"
                            )
                    );


                    pagamento.setFormaPagamento(
                            resultado.getString(
                                    "forma_pagamento"
                            )
                    );


                    pagamento.setStatusPagamento(
                            resultado.getString(
                                    "status_pagamento"
                            )
                    );


                    pagamento.setVeiculoDescricao(
                            resultado.getString(
                                    "veiculo"
                            )
                    );


                    pagamento.setServicosDescricao(
                            resultado.getString(
                                    "servicos"
                            )
                    );


                    pagamentos.add(
                            pagamento
                    );
                }
            }
        }


        return pagamentos;
    }


    // =========================================
    // REALIZAR PAGAMENTO
    // =========================================

    public boolean realizarPagamento(
            int idAgendamento,
            int idCliente,
            String formaPagamento
    ) throws SQLException {

        String buscarValor = """
                SELECT
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

                WHERE a.id_agendamento = ?
                  AND v.id_cliente = ?
                  AND a.status <> 'CANCELADO'

                GROUP BY
                    a.id_agendamento
                """;


        String inserirPagamento = """
                INSERT INTO pagamento
                (
                    id_agendamento,
                    data_pagamento,
                    valor,
                    forma_pagamento,
                    status_pagamento
                )

                VALUES
                (
                    ?,
                    NOW(),
                    ?,
                    ?,
                    'PAGO'
                )

                ON DUPLICATE KEY UPDATE
                    data_pagamento = NOW(),
                    valor = VALUES(valor),
                    forma_pagamento =
                        VALUES(forma_pagamento),
                    status_pagamento = 'PAGO'
                """;


        Connection conexao =
                Conexao.conectar();


        try {

            conexao.setAutoCommit(false);


            double valorTotal;


            try (
                PreparedStatement comando =
                        conexao.prepareStatement(
                                buscarValor
                        )
            ) {

                comando.setInt(
                        1,
                        idAgendamento
                );

                comando.setInt(
                        2,
                        idCliente
                );


                try (
                    ResultSet resultado =
                            comando.executeQuery()
                ) {

                    if (!resultado.next()) {

                        conexao.rollback();

                        return false;
                    }


                    valorTotal =
                            resultado.getDouble(
                                    "valor_total"
                            );
                }
            }


            try (
                PreparedStatement comando =
                        conexao.prepareStatement(
                                inserirPagamento
                        )
            ) {

                comando.setInt(
                        1,
                        idAgendamento
                );

                comando.setDouble(
                        2,
                        valorTotal
                );

                comando.setString(
                        3,
                        formaPagamento
                );


                comando.executeUpdate();
            }


            conexao.commit();

            return true;


        } catch (SQLException e) {

            conexao.rollback();

            throw e;


        } finally {

            try {

                conexao.setAutoCommit(
                        true
                );

            } catch (SQLException e) {

                // A conexão será fechada.
            }


            conexao.close();
        }
    }

    // =========================================
    // LISTAR AGENDAMENTOS COM PAGAMENTO PAGO
    // =========================================

    public Set<Integer> listarAgendamentosPagos()
            throws SQLException {

        String sql = """
                SELECT id_agendamento
                FROM pagamento
                WHERE status_pagamento = 'PAGO'
                """;

        Set<Integer> agendamentosPagos =
                new HashSet<>();

        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql);

            ResultSet resultado =
                    comando.executeQuery()
        ) {

            while (resultado.next()) {

                agendamentosPagos.add(
                        resultado.getInt(
                                "id_agendamento"
                        )
                );
            }
        }

        return agendamentosPagos;
    }

}