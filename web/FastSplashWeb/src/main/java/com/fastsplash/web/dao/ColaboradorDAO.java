package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.db.Transacao;
import com.fastsplash.web.model.Colaborador;

public class ColaboradorDAO {


    // =========================================
    // CREATE
    // =========================================

    public void inserir(
            Colaborador colaborador
    ) throws SQLException {

        String sql = """
                INSERT INTO colaborador
                (
                    nome,
                    cargo,
                    nivel_acesso,
                    email,
                    senha_hash
                )
                VALUES (?, ?, ?, ?, ?)
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(
                            sql,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            comando.setString(
                    1,
                    colaborador.getNome()
            );

            comando.setString(
                    2,
                    colaborador.getCargo()
            );

            comando.setString(
                    3,
                    colaborador.getNivelAcesso()
            );


            // EMAIL PODE SER NULL
            if (colaborador.getEmail() == null) {

                comando.setNull(
                        4,
                        Types.VARCHAR
                );

            } else {

                comando.setString(
                        4,
                        colaborador.getEmail()
                );
            }


            // SENHA PODE SER NULL
            if (colaborador.getSenhaHash() == null) {

                comando.setNull(
                        5,
                        Types.VARCHAR
                );

            } else {

                comando.setString(
                        5,
                        colaborador.getSenhaHash()
                );
            }


            comando.executeUpdate();


            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {

                if (resultado.next()) {

                    colaborador.setIdColaborador(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }


    // =========================================
    // READ - LISTAR TODOS
    // =========================================

    public List<Colaborador> listarTodos()
            throws SQLException {

        String sql = """
                SELECT *
                FROM colaborador
                WHERE ativo = TRUE AND excluido_em IS NULL
                ORDER BY id_colaborador
                """;


        List<Colaborador> colaboradores =
                new ArrayList<>();


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql);

            ResultSet resultado =
                    comando.executeQuery()
        ) {

            while (resultado.next()) {

                colaboradores.add(
                        criarColaborador(
                                resultado
                        )
                );
            }
        }


        return colaboradores;
    }


    // =========================================
    // READ - BUSCAR POR ID
    // =========================================

    public Colaborador buscarPorId(
            int idColaborador
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM colaborador
                WHERE id_colaborador = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(
                    1,
                    idColaborador
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarColaborador(
                            resultado
                    );
                }
            }
        }


        return null;
    }


    // =========================================
    // UPDATE
    // =========================================


    public void atualizar(
            Colaborador colaborador,
            boolean alterarSenha
    ) throws SQLException {

        Transacao.executar((conexao, controle) -> {
            List<Colaborador> registros =
                    bloquearColaboradores(conexao);

            Colaborador atual = registros.stream()
                    .filter(c -> c.getIdColaborador()
                            == colaborador.getIdColaborador())
                    .findFirst()
                    .orElse(null);

            if (atual == null
                    || !atual.isAtivo()
                    || atual.isExcluido()) {

                throw new SQLException(
                        "Colaborador indisponivel para edicao.");
            }

            if ("ADMINISTRADOR".equals(atual.getNivelAcesso())
                    && !"ADMINISTRADOR".equals(
                            colaborador.getNivelAcesso())
                    && contarAdministradores(registros) <= 1) {

                throw new SQLException(
                        "Nao e permitido alterar o nivel do ultimo administrador.");
            }

            if (alterarSenha) {
                atualizarComSenha(conexao, colaborador);
            } else {
                atualizarSemSenha(conexao, colaborador);
            }

            return null;
        });
    }

    private void atualizarSemSenha(
            Connection conexao,
            Colaborador colaborador
    ) throws SQLException {

        String sql = """
                UPDATE colaborador
                SET
                    nome = ?,
                    cargo = ?,
                    nivel_acesso = ?,
                    email = ?
                WHERE id_colaborador = ?
                  AND ativo = TRUE
                  AND excluido_em IS NULL
                """;


        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    colaborador.getNome()
            );

            comando.setString(
                    2,
                    colaborador.getCargo()
            );

            comando.setString(
                    3,
                    colaborador.getNivelAcesso()
            );


            if (colaborador.getEmail() == null) {

                comando.setNull(
                        4,
                        Types.VARCHAR
                );

            } else {

                comando.setString(
                        4,
                        colaborador.getEmail()
                );
            }


            comando.setInt(
                    5,
                    colaborador.getIdColaborador()
            );


            comando.executeUpdate();
        }
    }


    private void atualizarComSenha(
            Connection conexao,
            Colaborador colaborador
    ) throws SQLException {

        String sql = """
                UPDATE colaborador
                SET
                    nome = ?,
                    cargo = ?,
                    nivel_acesso = ?,
                    email = ?,
                    senha_hash = ?
                WHERE id_colaborador = ?
                  AND ativo = TRUE
                  AND excluido_em IS NULL
                """;


        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    colaborador.getNome()
            );

            comando.setString(
                    2,
                    colaborador.getCargo()
            );

            comando.setString(
                    3,
                    colaborador.getNivelAcesso()
            );


            if (colaborador.getEmail() == null) {

                comando.setNull(
                        4,
                        Types.VARCHAR
                );

            } else {

                comando.setString(
                        4,
                        colaborador.getEmail()
                );
            }


            if (colaborador.getSenhaHash() == null) {

                comando.setNull(
                        5,
                        Types.VARCHAR
                );

            } else {

                comando.setString(
                        5,
                        colaborador.getSenhaHash()
                );
            }


            comando.setInt(
                    6,
                    colaborador.getIdColaborador()
            );


            comando.executeUpdate();
        }
    }


    // =========================================
    // DELETE
    // =========================================


    public List<Colaborador> listarPorStatus(
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

        String sql = "SELECT * FROM colaborador WHERE "
                + filtro + " ORDER BY id_colaborador";

        List<Colaborador> colaboradores = new ArrayList<>();

        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando =
                     conexao.prepareStatement(sql);
             ResultSet resultado = comando.executeQuery()) {

            while (resultado.next()) {
                colaboradores.add(criarColaborador(resultado));
            }
        }

        return colaboradores;
    }

    // Bloqueio compartilhado pelas operacoes administrativas
    private List<Colaborador> bloquearColaboradores(
            Connection conexao
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM colaborador FORCE INDEX (PRIMARY)
                ORDER BY id_colaborador
                FOR UPDATE
                """;

        List<Colaborador> colaboradores = new ArrayList<>();

        try (PreparedStatement comando =
                     conexao.prepareStatement(sql);
             ResultSet resultado = comando.executeQuery()) {

            while (resultado.next()) {
                colaboradores.add(criarColaborador(resultado));
            }
        }

        return colaboradores;
    }

    private long contarAdministradores(
            List<Colaborador> colaboradores
    ) {

        return colaboradores.stream()
                .filter(c -> c.isAtivo()
                        && !c.isExcluido()
                        && "ADMINISTRADOR".equals(
                                c.getNivelAcesso()))
                .count();
    }

    private boolean possuiPendencias(
            Connection conexao,
            int idColaborador
    ) throws SQLException {

        String sql = """
                SELECT EXISTS (
                    SELECT 1
                    FROM colaborador_atendimento ca
                    INNER JOIN atendimento a
                        ON a.id_atendimento = ca.id_atendimento
                    WHERE ca.id_colaborador = ?
                      AND a.status IN (
                          'AGUARDANDO', 'EM_LAVAGEM'
                      )
                )
                """;

        try (PreparedStatement comando =
                conexao.prepareStatement(sql)) {

            comando.setInt(1, idColaborador);

            try (ResultSet resultado =
                    comando.executeQuery()) {

                return resultado.next()
                        && resultado.getBoolean(1);
            }
        }
    }

    private ResultadoStatusColaborador alterarStatus(
            int idColaborador,
            int idUsuarioLogado,
            String acao
    ) throws SQLException {

        return Transacao.executar((conexao, controle) -> {
            List<Colaborador> registros =
                    bloquearColaboradores(conexao);

            Colaborador atual = registros.stream()
                    .filter(c -> c.getIdColaborador()
                            == idColaborador)
                    .findFirst()
                    .orElse(null);

            if (atual == null) {
                controle.cancelar();
                return ResultadoStatusColaborador
                        .COLABORADOR_NAO_ENCONTRADO;
            }

            boolean desativar =
                    "inativar".equals(acao)
                    || "excluir".equals(acao);

            if (desativar
                    && idColaborador == idUsuarioLogado) {

                controle.cancelar();

                return ResultadoStatusColaborador
                        .PROPRIO_USUARIO;
            }

            if (atual.isExcluido()
                    && !"restaurar".equals(acao)) {

                controle.cancelar();

                return ResultadoStatusColaborador
                        .JA_EXCLUIDO;
            }

            if ("restaurar".equals(acao)
                    && !atual.isExcluido()) {

                controle.cancelar();

                return ResultadoStatusColaborador
                        .NAO_EXCLUIDO;
            }

            if ("inativar".equals(acao)
                    && !atual.isAtivo()) {

                controle.cancelar();

                return ResultadoStatusColaborador
                        .JA_INATIVO;
            }

            if ("reativar".equals(acao)
                    && atual.isAtivo()) {

                controle.cancelar();

                return ResultadoStatusColaborador
                        .JA_ATIVO;
            }

            if (desativar) {

                if (atual.isAtivo()
                        && "ADMINISTRADOR".equals(
                                atual.getNivelAcesso())
                        && contarAdministradores(registros) <= 1) {

                    controle.cancelar();

                    return ResultadoStatusColaborador
                            .ULTIMO_ADMINISTRADOR;
                }

                if (possuiPendencias(
                        conexao, idColaborador)) {

                    controle.cancelar();

                    return ResultadoStatusColaborador
                            .POSSUI_PENDENCIAS;
                }
            }

            String sql = switch (acao) {

                case "inativar" -> """
                        UPDATE colaborador
                        SET ativo = FALSE
                        WHERE id_colaborador = ?
                        """;

                case "excluir" -> """
                        UPDATE colaborador
                        SET ativo = FALSE,
                            excluido_em = CURRENT_TIMESTAMP
                        WHERE id_colaborador = ?
                        """;

                case "reativar", "restaurar" -> """
                        UPDATE colaborador
                        SET ativo = TRUE,
                            excluido_em = NULL
                        WHERE id_colaborador = ?
                        """;

                default ->
                    throw new SQLException("Acao invalida.");
            };

            try (PreparedStatement comando =
                    conexao.prepareStatement(sql)) {

                comando.setInt(1, idColaborador);

                if (comando.executeUpdate() != 1) {
                    throw new SQLException(
                            "Nao foi possivel alterar o status.");
                }
            }


            return ResultadoStatusColaborador.SUCESSO;
        });
    }

    public ResultadoStatusColaborador inativarColaborador(
            int idColaborador,
            int idUsuarioLogado
    ) throws SQLException {

        return alterarStatus(
                idColaborador, idUsuarioLogado, "inativar");
    }

    public ResultadoStatusColaborador reativarColaborador(
            int idColaborador,
            int idUsuarioLogado
    ) throws SQLException {

        return alterarStatus(
                idColaborador, idUsuarioLogado, "reativar");
    }

    public ResultadoStatusColaborador excluirLogicamente(
            int idColaborador,
            int idUsuarioLogado
    ) throws SQLException {

        return alterarStatus(
                idColaborador, idUsuarioLogado, "excluir");
    }

    public ResultadoStatusColaborador restaurarColaborador(
            int idColaborador,
            int idUsuarioLogado
    ) throws SQLException {

        return alterarStatus(
                idColaborador, idUsuarioLogado, "restaurar");
    }

    public Colaborador buscarPorEmail(
            String email
    ) throws SQLException {

        String sql = """
                SELECT *
                FROM colaborador
                WHERE email = ?
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    email
            );


            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {

                    return criarColaborador(
                            resultado
                    );
                }
            }
        }


        return null;
    }

    public void atualizarSenhaHash(
            int idColaborador,
            String senhaHash
    ) throws SQLException {

        String sql = """
                UPDATE colaborador
                SET senha_hash = ?
                WHERE id_colaborador = ?
                  AND ativo = TRUE
                  AND excluido_em IS NULL
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(
                    1,
                    senhaHash
            );


            comando.setInt(
                    2,
                    idColaborador
            );


            comando.executeUpdate();
        }
    }

    // =========================================
    // MÉTODO AUXILIAR
    // =========================================

    private Colaborador criarColaborador(
            ResultSet resultado
    ) throws SQLException {

        Colaborador colaborador =
                new Colaborador();


        colaborador.setIdColaborador(
                resultado.getInt(
                        "id_colaborador"
                )
        );


        colaborador.setNome(
                resultado.getString(
                        "nome"
                )
        );


        colaborador.setCargo(
                resultado.getString(
                        "cargo"
                )
        );


        colaborador.setNivelAcesso(
                resultado.getString(
                        "nivel_acesso"
                )
        );


        colaborador.setEmail(
                resultado.getString(
                        "email"
                )
        );


        colaborador.setSenhaHash(
                resultado.getString(
                        "senha_hash"
                )
        );


        colaborador.setAtivo(
                resultado.getBoolean("ativo")
        );

        colaborador.setExcluidoEm(
                resultado.getObject(
                        "excluido_em",
                        java.time.LocalDateTime.class
                )
        );

        return colaborador;
    }
}
