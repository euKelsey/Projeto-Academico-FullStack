package com.fastsplash.web.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class Pagamento {

    private int idPagamento;
    private int idAgendamento;

    private LocalDateTime dataPagamento;

    private double valor;

    private String formaPagamento;
    private String statusPagamento;


    // Campos usados para exibição
    private String clienteNome;
    private String veiculoDescricao;
    private String servicosDescricao;

    private LocalDate dataAgendamento;
    private LocalTime horarioAgendamento;


    public int getIdPagamento() {
        return idPagamento;
    }

    public void setIdPagamento(
            int idPagamento
    ) {
        this.idPagamento = idPagamento;
    }


    public int getIdAgendamento() {
        return idAgendamento;
    }

    public void setIdAgendamento(
            int idAgendamento
    ) {
        this.idAgendamento = idAgendamento;
    }


    public LocalDateTime getDataPagamento() {
        return dataPagamento;
    }

    public void setDataPagamento(
            LocalDateTime dataPagamento
    ) {
        this.dataPagamento = dataPagamento;
    }


    public double getValor() {
        return valor;
    }

    public void setValor(
            double valor
    ) {
        this.valor = valor;
    }


    public String getFormaPagamento() {
        return formaPagamento;
    }

    public void setFormaPagamento(
            String formaPagamento
    ) {
        this.formaPagamento = formaPagamento;
    }


    public String getStatusPagamento() {
        return statusPagamento;
    }

    public void setStatusPagamento(
            String statusPagamento
    ) {
        this.statusPagamento = statusPagamento;
    }


    public String getClienteNome() {
        return clienteNome;
    }

    public void setClienteNome(
            String clienteNome
    ) {
        this.clienteNome = clienteNome;
    }


    public String getVeiculoDescricao() {
        return veiculoDescricao;
    }

    public void setVeiculoDescricao(
            String veiculoDescricao
    ) {
        this.veiculoDescricao = veiculoDescricao;
    }


    public String getServicosDescricao() {
        return servicosDescricao;
    }

    public void setServicosDescricao(
            String servicosDescricao
    ) {
        this.servicosDescricao = servicosDescricao;
    }


    public LocalDate getDataAgendamento() {
        return dataAgendamento;
    }

    public void setDataAgendamento(
            LocalDate dataAgendamento
    ) {
        this.dataAgendamento = dataAgendamento;
    }


    public LocalTime getHorarioAgendamento() {
        return horarioAgendamento;
    }

    public void setHorarioAgendamento(
            LocalTime horarioAgendamento
    ) {
        this.horarioAgendamento = horarioAgendamento;
    }
}