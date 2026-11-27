
package com.fastsplash.web.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.db.Conexao;
import com.fastsplash.web.db.Transacao;
import com.fastsplash.web.model.Cliente;

public class ClienteDAO {

    // =========================================
    // CREATE
    // =========================================

    public void inserir(Cliente cliente)
            throws SQLException {

        String sql = """
                INSERT INTO cliente
                (nome, cpf, telefone, email, senha_hash)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(
                            sql,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            comando.setString(1, cliente.getNome());
            comando.setString(2, cliente.getCpf());
            comando.setString(3, cliente.getTelefone());
            comando.setString(4, cliente.getEmail());
            comando.setString(5, cliente.getSenhaHash());

            comando.executeUpdate();

            try (
                ResultSet resultado =
                        comando.getGeneratedKeys()
            ) {
                if (resultado.next()) {
                    cliente.setIdCliente(
                            resultado.getInt(1)
                    );
                }
            }
        }
    }

    // =========================================
    // READ - LISTAR TODOS
    // =========================================

    public List<Cliente> listarTodos()
            throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE ativo = TRUE AND excluido_em IS NULL
                ORDER BY id_cliente
                """;

        List<Cliente> clientes = new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery()
        ) {

            while (resultado.next()) {
                clientes.add(criarCliente(resultado));
            }
        }

        return clientes;
    }

    // =========================================
    // READ - BUSCAR POR ID
    // =========================================

    public Cliente buscarPorId(int idCliente)
            throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {
                if (resultado.next()) {
                    return criarCliente(resultado);
                }
            }
        }

        return null;
    }

    // =========================================
    // READ - BUSCAR POR EMAIL
    // =========================================

    public Cliente buscarPorEmail(String email)
            throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                WHERE email = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(1, email);

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {
                if (resultado.next()) {
                    return criarCliente(resultado);
                }
            }
        }

        return null;
    }

    // =========================================
    // UPDATE
    // =========================================

    public void atualizar(Cliente cliente)
            throws SQLException {

        String sql = """
                UPDATE cliente
                SET nome = ?,
                    cpf = ?,
                    telefone = ?,
                    email = ?
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(1, cliente.getNome());
            comando.setString(2, cliente.getCpf());
            comando.setString(3, cliente.getTelefone());
            comando.setString(4, cliente.getEmail());
            comando.setInt(5, cliente.getIdCliente());

            comando.executeUpdate();
        }
    }

    // =========================================
    // UPDATE - SENHA
    // =========================================

    public void atualizarSenhaHash(
            int idCliente,
            String senhaHash
    ) throws SQLException {

        String sql = """
                UPDATE cliente
                SET senha_hash = ?
                WHERE id_cliente = ?
                """;

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setString(1, senhaHash);
            comando.setInt(2, idCliente);

            comando.executeUpdate();
        }
    }

    // =========================================
    // BLOQUEAR CLIENTE
    // =========================================

    public boolean bloquearCliente(
            Connection conexao,
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT id_cliente
                FROM cliente
                WHERE id_cliente = ?
                FOR UPDATE
                """;

        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {
                return resultado.next();
            }
        }
    }

    // =========================================
    // CONSULTAR STATUS
    // =========================================

    public boolean consultarStatus(
            Connection conexao,
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT ativo
                FROM cliente
                WHERE id_cliente = ?
                """;

        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {

                if (resultado.next()) {
                    return resultado.getBoolean("ativo");
                }

                throw new SQLException(
                        "Cliente não encontrado."
                );
            }
        }
    }

    // =========================================
    // VERIFICAR PENDÊNCIAS
    // =========================================

    public boolean possuiPendencias(
            Connection conexao,
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT EXISTS (
                    SELECT 1
                    FROM veiculo v
                    INNER JOIN agendamento a
                        ON a.id_veiculo = v.id_veiculo
                    LEFT JOIN atendimento at
                        ON at.id_agendamento = a.id_agendamento
                    WHERE v.id_cliente = ?
                      AND (
                          a.status = 'AGENDADO'
                          OR at.status IN (
                              'AGUARDANDO',
                              'EM_LAVAGEM'
                          )
                      )
                )
                """;

        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setInt(1, idCliente);

            try (
                ResultSet resultado =
                        comando.executeQuery()
            ) {
                if (resultado.next()) {
                    return resultado.getBoolean(1);
                }
            }
        }

        return false;
    }

    // =========================================
    // UPDATE - STATUS
    // =========================================

    public void atualizarStatus(
            Connection conexao,
            int idCliente,
            boolean ativo
    ) throws SQLException {

        String sql = """
                UPDATE cliente
                SET ativo = ?
                WHERE id_cliente = ? AND excluido_em IS NULL
                """;

        try (
            PreparedStatement comando =
                    conexao.prepareStatement(sql)
        ) {

            comando.setBoolean(1, ativo);
            comando.setInt(2, idCliente);

            int linhasAfetadas =
                    comando.executeUpdate();

            if (linhasAfetadas != 1) {
                throw new SQLException(
                        "Não foi possível atualizar "
                        + "o status do cliente."
                );
            }
        }
    }

    // =========================================
    // INATIVAR CLIENTE
    // =========================================

    public ResultadoStatusCliente inativarCliente(
            int idCliente
    ) throws SQLException {

        return Transacao.executar((conexao, controle) -> {
            if (!bloquearCliente(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente
                        .CLIENTE_NAO_ENCONTRADO;
            }

            if (estaExcluido(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.JA_EXCLUIDO;
            }

            if (!consultarStatus(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente
                        .JA_INATIVO;
            }

            if (possuiPendencias(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente
                        .POSSUI_PENDENCIAS;
            }

            atualizarStatus(
                    conexao,
                    idCliente,
                    false
            );


            return ResultadoStatusCliente.SUCESSO;
        });
    }

    // =========================================
    // REATIVAR CLIENTE
    // =========================================

    public ResultadoStatusCliente reativarCliente(
            int idCliente
    ) throws SQLException {

        return Transacao.executar((conexao, controle) -> {
            if (!bloquearCliente(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente
                        .CLIENTE_NAO_ENCONTRADO;
            }

            if (estaExcluido(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.JA_EXCLUIDO;
            }

            if (consultarStatus(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente
                        .JA_ATIVO;
            }

            atualizarStatus(
                    conexao,
                    idCliente,
                    true
            );


            return ResultadoStatusCliente.SUCESSO;
        });
    }

    // =========================================
    // DELETE
    // =========================================


    public boolean estaExcluido(
            Connection conexao,
            int idCliente
    ) throws SQLException {

        String sql = """
                SELECT excluido_em
                FROM cliente
                WHERE id_cliente = ?
                """;

        try (PreparedStatement comando =
                conexao.prepareStatement(sql)) {

            comando.setInt(1, idCliente);

            try (ResultSet resultado = comando.executeQuery()) {
                return resultado.next()
                        && resultado.getTimestamp("excluido_em") != null;
            }
        }
    }


    public ResultadoStatusCliente excluirLogicamente(
            int idCliente
    ) throws SQLException {

        return Transacao.executar((conexao, controle) -> {
            if (!bloquearCliente(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.CLIENTE_NAO_ENCONTRADO;
            }

            if (estaExcluido(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.JA_EXCLUIDO;
            }

            if (possuiPendencias(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.POSSUI_PENDENCIAS;
            }

            String sql = """
                    UPDATE cliente
                    SET ativo = FALSE,
                        excluido_em = CURRENT_TIMESTAMP
                    WHERE id_cliente = ?
                      AND excluido_em IS NULL
                    """;

            try (PreparedStatement comando =
                    conexao.prepareStatement(sql)) {
                comando.setInt(1, idCliente);
                comando.executeUpdate();
            }

            return ResultadoStatusCliente.SUCESSO;
        });
    }

    // Compatibilidade com chamadas existentes
    public void excluir(int idCliente) throws SQLException {

        ResultadoStatusCliente resultado =
                excluirLogicamente(idCliente);

        if (resultado != ResultadoStatusCliente.SUCESSO) {
            throw new SQLException(
                    "Nao foi possivel excluir: " + resultado
            );
        }
    }

    public ResultadoStatusCliente restaurarCliente(
            int idCliente
    ) throws SQLException {

        return Transacao.executar((conexao, controle) -> {
            if (!bloquearCliente(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.CLIENTE_NAO_ENCONTRADO;
            }

            if (!estaExcluido(conexao, idCliente)) {
                controle.cancelar();
                return ResultadoStatusCliente.NAO_EXCLUIDO;
            }

            String sql = """
                    UPDATE cliente
                    SET ativo = TRUE,
                        excluido_em = NULL
                    WHERE id_cliente = ?
                      AND excluido_em IS NOT NULL
                    """;

            try (PreparedStatement comando =
                    conexao.prepareStatement(sql)) {
                comando.setInt(1, idCliente);
                comando.executeUpdate();
            }

            return ResultadoStatusCliente.SUCESSO;
        });
    }

    public List<Cliente> listarPorStatus(
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

        String sql = "SELECT * FROM cliente WHERE "
                + filtro + " ORDER BY nome, id_cliente";

        List<Cliente> clientes = new ArrayList<>();

        try (Connection conexao = Conexao.conectar();
             PreparedStatement comando =
                     conexao.prepareStatement(sql);
             ResultSet resultado = comando.executeQuery()) {

            while (resultado.next()) {
                clientes.add(criarCliente(resultado));
            }
        }

        return clientes;
    }

    // =========================================
    // RESULTSET -> CLIENTE
    // =========================================

    private Cliente criarCliente(
            ResultSet resultado
    ) throws SQLException {

        Cliente cliente = new Cliente();

        cliente.setIdCliente(
                resultado.getInt("id_cliente")
        );

        cliente.setNome(
                resultado.getString("nome")
        );

        cliente.setCpf(
                resultado.getString("cpf")
        );

        cliente.setTelefone(
                resultado.getString("telefone")
        );

        cliente.setEmail(
                resultado.getString("email")
        );

        cliente.setSenhaHash(
                resultado.getString("senha_hash")
        );

        cliente.setAtivo(
                resultado.getBoolean("ativo")
        );

        cliente.setExcluidoEm(
                resultado.getObject(
                        "excluido_em",
                        java.time.LocalDateTime.class
                )
        );

        return cliente;
    }

    public List<Cliente> listarTodosParaHistorico()
            throws SQLException {

        String sql = """
                SELECT *
                FROM cliente
                ORDER BY nome, id_cliente
                """;

        List<Cliente> clientes = new ArrayList<>();

        try (
            Connection conexao = Conexao.conectar();
            PreparedStatement comando =
                    conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery()
        ) {

            while (resultado.next()) {
                clientes.add(criarCliente(resultado));
            }
        }

        return clientes;
    }
}
