package com.fastsplash.web.model;

import java.time.LocalDateTime;

public class Atendimento {

    private int idAtendimento;
    private int idAgendamento;

    private String status;

    private LocalDateTime dataInicio;
    private LocalDateTime dataFim;

    // Campos auxiliares para exibição
    private String clienteNome;
    private String veiculoDescricao;
    private String servicosDescricao;


    public Atendimento() {
    }


    public int getIdAtendimento() {
        return idAtendimento;
    }


    public void setIdAtendimento(
            int idAtendimento
    ) {

        this.idAtendimento =
                idAtendimento;
    }


    public int getIdAgendamento() {
        return idAgendamento;
    }


    public void setIdAgendamento(
            int idAgendamento
    ) {

        this.idAgendamento =
                idAgendamento;
    }


    public String getStatus() {
        return status;
    }


    public void setStatus(
            String status
    ) {

        this.status =
                status;
    }


    public LocalDateTime getDataInicio() {
        return dataInicio;
    }


    public void setDataInicio(
            LocalDateTime dataInicio
    ) {

        this.dataInicio =
                dataInicio;
    }


    public LocalDateTime getDataFim() {
        return dataFim;
    }


    public void setDataFim(
            LocalDateTime dataFim
    ) {

        this.dataFim =
                dataFim;
    }


    public String getClienteNome() {
        return clienteNome;
    }


    public void setClienteNome(
            String clienteNome
    ) {

        this.clienteNome =
                clienteNome;
    }


    public String getVeiculoDescricao() {
        return veiculoDescricao;
    }


    public void setVeiculoDescricao(
            String veiculoDescricao
    ) {

        this.veiculoDescricao =
                veiculoDescricao;
    }


    public String getServicosDescricao() {
        return servicosDescricao;
    }


    public void setServicosDescricao(
            String servicosDescricao
    ) {

        this.servicosDescricao =
                servicosDescricao;
    }
}