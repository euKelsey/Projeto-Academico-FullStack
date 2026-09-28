package com.fastsplash.web.model;

public class Colaborador {

    private int idColaborador;
    private String nome;
    private String cargo;
    private String nivelAcesso;
    private String email;
    private String senhaHash;


    public Colaborador() {
    }


    public int getIdColaborador() {
        return idColaborador;
    }


    public void setIdColaborador(
            int idColaborador
    ) {

        this.idColaborador =
                idColaborador;
    }


    public String getNome() {
        return nome;
    }


    public void setNome(
            String nome
    ) {

        this.nome =
                nome;
    }


    public String getCargo() {
        return cargo;
    }


    public void setCargo(
            String cargo
    ) {

        this.cargo =
                cargo;
    }


    public String getNivelAcesso() {
        return nivelAcesso;
    }


    public void setNivelAcesso(
            String nivelAcesso
    ) {

        this.nivelAcesso =
                nivelAcesso;
    }


    public String getEmail() {
        return email;
    }


    public void setEmail(
            String email
    ) {

        this.email =
                email;
    }


    public String getSenhaHash() {
        return senhaHash;
    }


    public void setSenhaHash(
            String senhaHash
    ) {

        this.senhaHash =
                senhaHash;
    }
}