package com.fastsplash.web.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.List;

public record Dashboard(

        long clientesAtivos,
        long veiculosAtivos,
        long servicosAtivos,
        long colaboradoresAtivos,

        long agendamentosHoje,
        long atendimentosAguardando,
        long atendimentosEmLavagem,
        long atendimentosFinalizados,

        long pagamentosPendentes,

        BigDecimal faturamentoMensal,
        BigDecimal valoresAReceber,

        List<FaturamentoMes> faturamentoHistorico,
        List<ProximoAgendamento> proximosAgendamentos

) {

    public record FaturamentoMes(
            YearMonth mes,
            BigDecimal valor
    ) {}

    public record ProximoAgendamento(
            int idAgendamento,
            String cliente,
            String veiculo,
            LocalDate data,
            LocalTime horario,
            String servicos
    ) {}
}
