package com.fastsplash.web.model;

public class Servico {

    private int idServico;
    private String nome;
    private String descricao;
    private double preco;

    public Servico() {
    }

    public Servico(
            int idServico,
            String nome,
            String descricao,
            double preco
    ) {

        this.idServico = idServico;
        this.nome = nome;
        this.descricao = descricao;
        this.preco = preco;
    }

    public int getIdServico() {
        return idServico;
    }

    public void setIdServico(int idServico) {
        this.idServico = idServico;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public double getPreco() {
        return preco;
    }

    public void setPreco(double preco) {
        this.preco = preco;
    }
}