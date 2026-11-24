package com.fastsplash.web.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.time.LocalDate;
import java.time.YearMonth;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Dashboard;

public class DashboardDAO {

    public Dashboard carregar() throws SQLException {

        try (Connection conexao = Conexao.conectar()) {

            LocalDate hoje;

            try (
                PreparedStatement comando =
                    conexao.prepareStatement("SELECT CURDATE()");
                ResultSet resultado = comando.executeQuery()
            ) {
                resultado.next();
                hoje = resultado.getDate(1).toLocalDate();
            }

            long clientesAtivos = contar(conexao, """
                SELECT COUNT(*)
                FROM cliente
                WHERE ativo = TRUE
                  AND excluido_em IS NULL
                """);

            long veiculosAtivos = contar(conexao, """
                SELECT COUNT(*)
                FROM veiculo v
                INNER JOIN cliente c
                    ON c.id_cliente = v.id_cliente
                WHERE v.ativo = TRUE
                  AND v.excluido_em IS NULL
                  AND c.ativo = TRUE
                  AND c.excluido_em IS NULL
                """);

            long servicosAtivos = contar(conexao, """
                SELECT COUNT(*)
                FROM servico
                WHERE ativo = TRUE
                  AND excluido_em IS NULL
                """);

            long colaboradoresAtivos = contar(conexao, """
                SELECT COUNT(*)
                FROM colaborador
                WHERE ativo = TRUE
                  AND excluido_em IS NULL
                """);

            long agendamentosHoje = contar(conexao, """
                SELECT COUNT(*)
                FROM agendamento
                WHERE data = CURDATE()
                  AND status <> 'CANCELADO'
                """);

            long aguardando = contar(conexao, """
                SELECT COUNT(*)
                FROM atendimento
                WHERE status = 'AGUARDANDO'
                  AND arquivado_em IS NULL
                """);

            long emLavagem = contar(conexao, """
                SELECT COUNT(*)
                FROM atendimento
                WHERE status = 'EM_LAVAGEM'
                  AND arquivado_em IS NULL
                """);

            long finalizados = contar(conexao, """
                SELECT COUNT(*)
                FROM atendimento
                WHERE status = 'FINALIZADO'
                """);

            String sqlPendentes = """
                SELECT
                    COUNT(*) AS quantidade,
                    COALESCE(SUM(
                        COALESCE(
                            p.valor,
                            servicos.valor_total,
                            0
                        )
                    ), 0) AS total

                FROM agendamento a

                LEFT JOIN pagamento p
                    ON p.id_agendamento = a.id_agendamento

                LEFT JOIN (
                    SELECT
                        id_agendamento,
                        SUM(valor_praticado) AS valor_total
                    FROM agendamento_servico
                    GROUP BY id_agendamento
                ) servicos
                    ON servicos.id_agendamento =
                       a.id_agendamento

                WHERE a.status <> 'CANCELADO'
                  AND a.arquivado_em IS NULL
                  AND p.arquivado_em IS NULL
                  AND COALESCE(
                      p.status_pagamento,
                      'PENDENTE'
                  ) = 'PENDENTE'
                """;

            long pagamentosPendentes;
            BigDecimal valoresAReceber;

            try (
                PreparedStatement comando =
                    conexao.prepareStatement(sqlPendentes);
                ResultSet resultado = comando.executeQuery()
            ) {
                resultado.next();

                pagamentosPendentes =
                    resultado.getLong("quantidade");

                valoresAReceber =
                    resultado.getBigDecimal("total");
            }

            List<Dashboard.FaturamentoMes> historico =
                carregarFaturamento(conexao, hoje);

            BigDecimal faturamentoMensal =
                historico.get(historico.size() - 1).valor();

            return new Dashboard(
                clientesAtivos,
                veiculosAtivos,
                servicosAtivos,
                colaboradoresAtivos,
                agendamentosHoje,
                aguardando,
                emLavagem,
                finalizados,
                pagamentosPendentes,
                faturamentoMensal,
                valoresAReceber,
                historico,
                carregarProximosAgendamentos(conexao)
            );
        }
    }

    private long contar(
            Connection conexao,
            String sql
    ) throws SQLException {

        try (
            PreparedStatement comando =
                conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery()
        ) {
            return resultado.next()
                ? resultado.getLong(1)
                : 0;
        }
    }

    private List<Dashboard.FaturamentoMes> carregarFaturamento(
            Connection conexao,
            LocalDate hoje
    ) throws SQLException {

        YearMonth atual = YearMonth.from(hoje);
        YearMonth inicial = atual.minusMonths(5);

        Map<YearMonth, BigDecimal> meses =
            new LinkedHashMap<>();

        for (int i = 0; i < 6; i++) {

            meses.put(
                inicial.plusMonths(i),
                BigDecimal.ZERO
            );
        }

        String sql = """
            SELECT
                YEAR(data_pagamento) AS ano,
                MONTH(data_pagamento) AS mes,
                SUM(valor) AS total

            FROM pagamento

            WHERE status_pagamento = 'PAGO'
              AND data_pagamento >= ?
              AND data_pagamento < ?

            GROUP BY
                YEAR(data_pagamento),
                MONTH(data_pagamento)

            ORDER BY ano, mes
            """;

        try (
            PreparedStatement comando =
                conexao.prepareStatement(sql)
        ) {

            comando.setDate(
                1,
                java.sql.Date.valueOf(inicial.atDay(1))
            );

            comando.setDate(
                2,
                java.sql.Date.valueOf(
                    atual.plusMonths(1).atDay(1)
                )
            );

            try (ResultSet resultado = comando.executeQuery()) {

                while (resultado.next()) {

                    YearMonth mes = YearMonth.of(
                        resultado.getInt("ano"),
                        resultado.getInt("mes")
                    );

                    meses.put(
                        mes,
                        resultado.getBigDecimal("total")
                    );
                }
            }
        }

        List<Dashboard.FaturamentoMes> historico =
            new ArrayList<>();

        meses.forEach((mes, valor) ->
            historico.add(
                new Dashboard.FaturamentoMes(mes, valor)
            )
        );

        return List.copyOf(historico);
    }

    private List<Dashboard.ProximoAgendamento>
            carregarProximosAgendamentos(
                Connection conexao
            ) throws SQLException {

        String sql = """
            SELECT
                a.id_agendamento,
                a.data,
                a.horario,
                c.nome AS cliente,

                CONCAT(
                    v.marca, ' ', v.modelo,
                    ' - ', v.placa
                ) AS veiculo,

                COALESCE(
                    GROUP_CONCAT(
                        s.nome
                        ORDER BY s.nome
                        SEPARATOR ', '
                    ),
                    'Sem serviços'
                ) AS servicos

            FROM agendamento a

            INNER JOIN veiculo v
                ON v.id_veiculo = a.id_veiculo

            INNER JOIN cliente c
                ON c.id_cliente = v.id_cliente

            LEFT JOIN agendamento_servico ags
                ON ags.id_agendamento = a.id_agendamento

            LEFT JOIN servico s
                ON s.id_servico = ags.id_servico

            WHERE a.status = 'AGENDADO'
              AND a.arquivado_em IS NULL
              AND (
                  a.data > CURDATE()
                  OR (
                      a.data = CURDATE()
                      AND a.horario >= CURTIME()
                  )
              )

            GROUP BY
                a.id_agendamento,
                a.data,
                a.horario,
                c.nome,
                v.marca,
                v.modelo,
                v.placa

            ORDER BY
                a.data,
                a.horario,
                a.id_agendamento

            LIMIT 5
            """;

        List<Dashboard.ProximoAgendamento> agendamentos =
            new ArrayList<>();

        try (
            PreparedStatement comando =
                conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery()
        ) {

            while (resultado.next()) {

                agendamentos.add(
                    new Dashboard.ProximoAgendamento(
                        resultado.getInt("id_agendamento"),
                        resultado.getString("cliente"),
                        resultado.getString("veiculo"),
                        resultado.getDate("data").toLocalDate(),
                        resultado.getTime("horario").toLocalTime(),
                        resultado.getString("servicos")
                    )
                );
            }
        }

        return List.copyOf(agendamentos);
    }
}
