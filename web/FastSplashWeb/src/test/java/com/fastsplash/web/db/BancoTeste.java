package com.fastsplash.web.db;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.Statement;

public final class BancoTeste {

    private BancoTeste() {
    }

    public static synchronized void restaurarSeed() throws Exception {

        AmbienteTeste.validarAmbiente();

        Path seed = Path.of(
            "../../database/seed_test.sql"
        ).toAbsolutePath().normalize();

        if (!Files.isRegularFile(seed)) {
            throw new IllegalStateException(
                "Seed de testes nao encontrado: " + seed
            );
        }

        String sql = Files.readString(seed);

        sql = sql.replaceAll("(?m)^\\s*--.*$", "");

        try (
            Connection conexao = AmbienteTeste.conectar();
            Statement comando = conexao.createStatement()
        ) {
            conexao.setAutoCommit(false);

            try {
                comando.executeUpdate("DELETE FROM colaborador_atendimento");
                comando.executeUpdate("DELETE FROM pagamento");
                comando.executeUpdate("DELETE FROM atendimento");
                comando.executeUpdate("DELETE FROM agendamento_servico");
                comando.executeUpdate("DELETE FROM agendamento");
                comando.executeUpdate("DELETE FROM veiculo");
                comando.executeUpdate("DELETE FROM servico");
                comando.executeUpdate("DELETE FROM colaborador");
                comando.executeUpdate("DELETE FROM cliente");

                for (String trecho : sql.split(";")) {

                    String instrucao = trecho.strip();

                    if (instrucao.isEmpty()
                            || instrucao.equalsIgnoreCase("USE fast_splash_test")
                            || instrucao.equalsIgnoreCase("START TRANSACTION")
                            || instrucao.equalsIgnoreCase("COMMIT")) {
                        continue;
                    }

                    comando.execute(instrucao);
                }

                conexao.commit();

            } catch (Exception e) {
                conexao.rollback();
                throw e;
            }
        }
    }
}
