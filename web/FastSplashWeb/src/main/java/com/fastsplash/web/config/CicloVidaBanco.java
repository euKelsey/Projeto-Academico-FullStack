package com.fastsplash.web.config;

import java.sql.SQLException;

import com.fastsplash.web.db.Conexao;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public final class CicloVidaBanco
        implements ServletContextListener {

    @Override
    public void contextInitialized(
            ServletContextEvent evento) {

        try {

            Conexao.inicializar();

            evento.getServletContext().log(
                    "Fast Splash: pool de conexoes inicializado.");

        } catch (SQLException e) {

            Conexao.encerrar();

            evento.getServletContext().log(
                    "Fast Splash: falha na inicializacao do banco.");

            throw new IllegalStateException(
                    "Nao foi possivel inicializar o banco.",
                    e);
        }
    }

    @Override
    public void contextDestroyed(
            ServletContextEvent evento) {

        Conexao.encerrar();

        evento.getServletContext().log(
                "Fast Splash: pool de conexoes encerrado.");
    }
}
