package com.fastsplash.web.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class Agendamento {

    private int idAgendamento;
    private int idVeiculo;

    private LocalDate data;
    private LocalTime horario;

    private String status;

    private List<Integer> idsServicos =
            new ArrayList<>();

    // Campos usados para exibição
    private String veiculoDescricao;
    private String servicosDescricao;
    private double valorTotal;


    public Agendamento() {
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


    public int getIdVeiculo() {
        return idVeiculo;
    }

    public void setIdVeiculo(
            int idVeiculo
    ) {

        this.idVeiculo =
                idVeiculo;
    }


    public LocalDate getData() {
        return data;
    }

    public void setData(
            LocalDate data
    ) {

        this.data = data;
    }


    public LocalTime getHorario() {
        return horario;
    }

    public void setHorario(
            LocalTime horario
    ) {

        this.horario = horario;
    }


    public String getStatus() {
        return status;
    }

    public void setStatus(
            String status
    ) {

        this.status = status;
    }


    public List<Integer> getIdsServicos() {
        return idsServicos;
    }

    public void setIdsServicos(
            List<Integer> idsServicos
    ) {

        this.idsServicos =
                idsServicos;
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


    public double getValorTotal() {
        return valorTotal;
    }

    public void setValorTotal(
            double valorTotal
    ) {

        this.valorTotal =
                valorTotal;
    }
}