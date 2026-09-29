package com.fastsplash.web.model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class AgendamentoCliente {

    private int idAgendamento;
    private int idVeiculo;

    private LocalDate data;
    private LocalTime horario;

    private String statusAgendamento;
    private String statusAtendimento;

    private String marca;
    private String modelo;
    private String placa;
    private String cor;

    private List<Servico> servicos =
            new ArrayList<>();


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


    public String getStatusAgendamento() {
        return statusAgendamento;
    }

    public void setStatusAgendamento(
            String statusAgendamento
    ) {
        this.statusAgendamento =
                statusAgendamento;
    }


    public String getStatusAtendimento() {
        return statusAtendimento;
    }

    public void setStatusAtendimento(
            String statusAtendimento
    ) {
        this.statusAtendimento =
                statusAtendimento;
    }


    public String getMarca() {
        return marca;
    }

    public void setMarca(
            String marca
    ) {
        this.marca = marca;
    }


    public String getModelo() {
        return modelo;
    }

    public void setModelo(
            String modelo
    ) {
        this.modelo = modelo;
    }


    public String getPlaca() {
        return placa;
    }

    public void setPlaca(
            String placa
    ) {
        this.placa = placa;
    }


    public String getCor() {
        return cor;
    }

    public void setCor(
            String cor
    ) {
        this.cor = cor;
    }


    public List<Servico> getServicos() {
        return servicos;
    }

    public void setServicos(
            List<Servico> servicos
    ) {
        this.servicos = servicos;
    }


    public double getValorTotal() {

        double total = 0;

        for (Servico servico : servicos) {
            total += servico.getPreco();
        }

        return total;
    }
}