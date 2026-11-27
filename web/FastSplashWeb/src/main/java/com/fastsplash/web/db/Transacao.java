package com.fastsplash.web.db;

import java.sql.Connection;
import java.sql.SQLException;

/** Executa uma operacao em uma unica transacao JDBC. */
public final class Transacao {

    private Transacao() {
    }

    @FunctionalInterface
    public interface Operacao<T> {
        T executar(Connection conexao, Controle controle)
                throws SQLException;
    }

    public static final class Controle {
        private boolean cancelada;

        private Controle() {
        }

        public void cancelar() {
            cancelada = true;
        }
    }

    public static <T> T executar(Operacao<T> operacao)
            throws SQLException {

        try (Connection conexao = Conexao.conectar()) {
            conexao.setAutoCommit(false);
            Controle controle = new Controle();

            try {
                T resultado = operacao.executar(conexao, controle);

                if (controle.cancelada) {
                    conexao.rollback();
                } else {
                    conexao.commit();
                }

                return resultado;

            } catch (SQLException | RuntimeException | Error e) {
                try {
                    conexao.rollback();
                } catch (SQLException falhaRollback) {
                    e.addSuppressed(falhaRollback);
                }
                throw e;
            }
        }
    }
}
