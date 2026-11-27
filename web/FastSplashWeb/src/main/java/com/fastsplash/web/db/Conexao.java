package com.fastsplash.web.db;

import java.sql.Connection;
import java.sql.SQLException;

import com.fastsplash.web.config.ConfiguracaoBanco;
import com.zaxxer.hikari.HikariDataSource;

public final class Conexao {

    private static HikariDataSource pool;

    private Conexao() {
    }

    public static synchronized void inicializar()
            throws SQLException {

        if (pool != null && !pool.isClosed()) {
            return;
        }

        try {

            pool = new HikariDataSource(
                    ConfiguracaoBanco.criarConfiguracao());

        } catch (RuntimeException e) {

            throw new SQLException(
                    "Nao foi possivel inicializar "
                    + "o pool de conexoes.",
                    e);
        }
    }

    private static synchronized HikariDataSource obterPool()
            throws SQLException {

        inicializar();

        return pool;
    }

    public static Connection conectar()
            throws SQLException {

        return obterPool().getConnection();
    }

    public static synchronized boolean estaInicializado() {

        return pool != null && !pool.isClosed();
    }

    public static synchronized void encerrar() {

        if (pool != null) {

            try {
                pool.close();
            } finally {
                pool = null;
            }
        }
    }
}
