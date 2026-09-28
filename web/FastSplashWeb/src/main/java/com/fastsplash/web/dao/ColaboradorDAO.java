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


        if (alterarSenha) {

            atualizarComSenha(
                    colaborador
            );

        } else {

            atualizarSemSenha(
                    colaborador
            );
        }
    }


    private void atualizarSemSenha(
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
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

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
                """;


        try (
            Connection conexao =
                    Conexao.conectar();

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

    public void excluir(
            int idColaborador
    ) throws SQLException {

        String sql = """
                DELETE FROM colaborador
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


            comando.executeUpdate();
        }
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


        return colaborador;
    }
}