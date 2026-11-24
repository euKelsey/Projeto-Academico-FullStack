package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.model.Servico;

public class ServicoDAO {

        // CREATE
        public void inserir(Servico servico) throws SQLException {

                String sql = """
                                INSERT INTO servico
                                (nome, descricao, preco, ativo)
                                VALUES (?, ?, ?, ?)
                                """;

                try (
                                Connection conexao = Conexao.conectar();

                                PreparedStatement comando = conexao.prepareStatement(
                                                sql,
                                                Statement.RETURN_GENERATED_KEYS)) {

                        comando.setString(
                                        1,
                                        servico.getNome());

                        comando.setString(
                                        2,
                                        servico.getDescricao());

                        comando.setDouble(
                                        3,
                                        servico.getPreco());

                        comando.setBoolean(
                                        4,
                                        servico.isAtivo());

                        comando.executeUpdate();

                        try (
                                        ResultSet resultado = comando.getGeneratedKeys()) {

                                if (resultado.next()) {

                                        servico.setIdServico(
                                                        resultado.getInt(1));
                                }
                        }
                }
        }

        // READ - LISTAR TODOS
        public List<Servico> listarTodos() throws SQLException {

                String sql = """
                                SELECT *
                                FROM servico
                                ORDER BY id_servico
                                """;

                List<Servico> servicos = new ArrayList<>();

                try (
                                Connection conexao = Conexao.conectar();
                                PreparedStatement comando = conexao.prepareStatement(sql);
                                ResultSet resultado = comando.executeQuery()) {

                        while (resultado.next()) {

                                Servico servico = criarServico(resultado);

                                servicos.add(servico);
                        }
                }

                return servicos;
        }

        // READ - LISTAR ATIVOS
        public List<Servico> listarAtivos() throws SQLException {

                String sql = """
                                SELECT *
                                FROM servico
                                WHERE ativo = TRUE AND excluido_em IS NULL
                                ORDER BY id_servico
                                """;

                List<Servico> servicos = new ArrayList<>();

                try (
                                Connection conexao = Conexao.conectar();
                                PreparedStatement comando = conexao.prepareStatement(sql);
                                ResultSet resultado = comando.executeQuery()) {

                        while (resultado.next()) {

                                Servico servico = criarServico(resultado);

                                servicos.add(servico);
                        }
                }

                return servicos;
        }

        // READ - BUSCAR POR ID
        public Servico buscarPorId(
                        int idServico) throws SQLException {

                String sql = """
                                SELECT *
                                FROM servico
                                WHERE id_servico = ?
                                """;

                try (
                                Connection conexao = Conexao.conectar();
                                PreparedStatement comando = conexao.prepareStatement(sql)) {

                        comando.setInt(
                                        1,
                                        idServico);

                        try (
                                        ResultSet resultado = comando.executeQuery()) {

                                if (resultado.next()) {

                                        return criarServico(
                                                        resultado);
                                }
                        }
                }

                return null;
        }

        // UPDATE
        public void atualizar(
                        Servico servico) throws SQLException {

                String sql = """
                                UPDATE servico
                                SET nome = ?,
                                    descricao = ?,
                                    preco = ?
                                WHERE id_servico = ?
                                  AND ativo = TRUE
                                  AND excluido_em IS NULL
                                """;

                try (
                                Connection conexao = Conexao.conectar();
                                PreparedStatement comando = conexao.prepareStatement(sql)) {

                        comando.setString(
                                        1,
                                        servico.getNome());

                        comando.setString(
                                        2,
                                        servico.getDescricao());

                        comando.setDouble(
                                        3,
                                        servico.getPreco());

                        comando.setInt(
                                        4,
                                        servico.getIdServico());

                        comando.executeUpdate();
                }
        }

        // VERIFICA SE O SERVIÇO JÁ FOI UTILIZADO
        public boolean possuiAgendamentos(
                        int idServico) throws SQLException {

                String sql = """
                                SELECT 1
                                FROM agendamento_servico
                                WHERE id_servico = ?
                                LIMIT 1
                                """;

                try (
                                Connection conexao = Conexao.conectar();
                                PreparedStatement comando = conexao.prepareStatement(sql)) {

                        comando.setInt(
                                        1,
                                        idServico);

                        try (
                                        ResultSet resultado = comando.executeQuery()) {

                                return resultado.next();
                        }
                }
        }


        public List<Servico> listarPorStatus(
                String status
        ) throws SQLException {

                String filtro = switch (
                        status == null ? "ativos" : status
                ) {
                        case "inativos" ->
                            "ativo = FALSE AND excluido_em IS NULL";

                        case "excluidos" ->
                            "excluido_em IS NOT NULL";

                        default ->
                            "ativo = TRUE AND excluido_em IS NULL";
                };

                String sql = "SELECT * FROM servico WHERE "
                        + filtro + " ORDER BY id_servico";

                List<Servico> servicos = new ArrayList<>();

                try (Connection conexao = Conexao.conectar();
                     PreparedStatement comando =
                             conexao.prepareStatement(sql);
                     ResultSet resultado = comando.executeQuery()) {

                        while (resultado.next()) {
                                servicos.add(criarServico(resultado));
                        }
                }

                return servicos;
        }

        private boolean executarStatus(
                int idServico,
                String acao
        ) throws SQLException {

                String sql = switch (acao) {

                        case "inativar" -> """
                                UPDATE servico
                                SET ativo = FALSE
                                WHERE id_servico = ?
                                  AND ativo = TRUE
                                  AND excluido_em IS NULL
                                """;

                        case "reativar" -> """
                                UPDATE servico
                                SET ativo = TRUE
                                WHERE id_servico = ?
                                  AND ativo = FALSE
                                  AND excluido_em IS NULL
                                """;

                        case "excluir" -> """
                                UPDATE servico
                                SET ativo = FALSE,
                                    excluido_em = CURRENT_TIMESTAMP
                                WHERE id_servico = ?
                                  AND excluido_em IS NULL
                                """;

                        case "restaurar" -> """
                                UPDATE servico
                                SET ativo = TRUE,
                                    excluido_em = NULL
                                WHERE id_servico = ?
                                  AND excluido_em IS NOT NULL
                                """;

                        default ->
                            throw new SQLException("Acao invalida.");
                };

                try (Connection conexao = Conexao.conectar();
                     PreparedStatement comando =
                             conexao.prepareStatement(sql)) {

                        comando.setInt(1, idServico);

                        return comando.executeUpdate() == 1;
                }
        }

        public boolean inativarServico(
                int idServico
        ) throws SQLException {
                return executarStatus(idServico, "inativar");
        }

        public boolean reativarServico(
                int idServico
        ) throws SQLException {
                return executarStatus(idServico, "reativar");
        }

        public boolean excluirLogicamente(
                int idServico
        ) throws SQLException {
                return executarStatus(idServico, "excluir");
        }

        public boolean restaurarServico(
                int idServico
        ) throws SQLException {
                return executarStatus(idServico, "restaurar");
        }

        // Compatibilidade com chamadas existentes
        public void alterarStatus(
                int idServico,
                boolean ativo
        ) throws SQLException {

                boolean sucesso = ativo
                        ? reativarServico(idServico)
                        : inativarServico(idServico);

                if (!sucesso) {
                        throw new SQLException(
                                "Nao foi possivel alterar o status.");
                }
        }

        public void excluir(
                int idServico
        ) throws SQLException {

                if (!excluirLogicamente(idServico)) {
                        throw new SQLException(
                                "Nao foi possivel excluir o servico.");
                }
        }

        // MÉTODO AUXILIAR
        private Servico criarServico(
                        ResultSet resultado) throws SQLException {

                Servico servico = new Servico();

                servico.setIdServico(
                                resultado.getInt(
                                                "id_servico"));

                servico.setNome(
                                resultado.getString(
                                                "nome"));

                servico.setDescricao(
                                resultado.getString(
                                                "descricao"));

                servico.setPreco(
                                resultado.getDouble(
                                                "preco"));

                servico.setAtivo(
                                resultado.getBoolean(
                                                "ativo"));

                servico.setExcluidoEm(
                        resultado.getObject(
                                "excluido_em",
                                java.time.LocalDateTime.class
                        )
                );

                return servico;
        }
}