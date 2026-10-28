package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;
import java.sql.SQLIntegrityConstraintViolationException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.ResultadoStatusCliente;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cliente")
public class ClienteServlet extends HttpServlet {

        private static final long serialVersionUID = 1L;

        private final ClienteDAO clienteDAO = new ClienteDAO();

        @Override
        protected void doGet(
                        HttpServletRequest request,
                        HttpServletResponse response) throws ServletException, IOException {

                String acao = request.getParameter(
                                "acao");

                // =========================================
                // PROTEGER ALTERAÇÕES DE STATUS
                // =========================================

                if ("inativar".equals(acao)
                                || "reativar".equals(acao)) {

                        if (!usuarioAdministrador(request)) {

                                response.sendError(
                                                HttpServletResponse.SC_FORBIDDEN,
                                                "Apenas administradores podem alterar "
                                                                + "o status dos clientes.");

                                return;
                        }
                }

                // =========================================
                // EDITAR
                // =========================================

                if ("editar".equals(acao)) {

                        int idCliente = Integer.parseInt(
                                        request.getParameter(
                                                        "idCliente"));

                        try {

                                Cliente cliente = clienteDAO.buscarPorId(
                                                idCliente);

                                request.setAttribute(
                                                "cliente",
                                                cliente);

                                request.getRequestDispatcher(
                                                "/editar-cliente.jsp").forward(
                                                                request,
                                                                response);

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao buscar cliente.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // LISTAR
                // =========================================

                try {

                        request.setAttribute(
                                        "clientes",
                                        clienteDAO.listarTodos());

                        request.getRequestDispatcher(
                                        "/lista-clientes.jsp").forward(
                                                        request,
                                                        response);

                } catch (SQLException e) {

                        throw new ServletException(
                                        "Erro ao listar clientes.",
                                        e);
                }
        }

        @Override
        protected void doPost(
                        HttpServletRequest request,
                        HttpServletResponse response) throws ServletException, IOException {

                request.setCharacterEncoding(
                                "UTF-8");

                String acao = request.getParameter(
                                "acao");

                // =========================================
                // INATIVAR CLIENTE
                // =========================================

                if ("inativar".equals(acao)) {

                        int idCliente;

                        try {
                                idCliente = Integer.parseInt(
                                                request.getParameter("idCliente"));

                                if (idCliente <= 0) {
                                        throw new NumberFormatException();
                                }

                        } catch (NumberFormatException e) {

                                response.sendError(
                                                HttpServletResponse.SC_BAD_REQUEST,
                                                "ID do cliente inválido.");

                                return;
                        }

                        // Conferir a permissão novamente no ponto da operação
                        if (!usuarioAdministrador(request)) {

                                response.sendError(
                                                HttpServletResponse.SC_FORBIDDEN,
                                                "Apenas administradores podem inativar clientes.");

                                return;
                        }

                        try {

                                ResultadoStatusCliente resultado = clienteDAO.inativarCliente(idCliente);

                                switch (resultado) {

                                        case SUCESSO:
                                                response.sendRedirect(
                                                                request.getContextPath()
                                                                                + "/cliente?status=inativado");
                                                break;

                                        case POSSUI_PENDENCIAS:
                                                response.sendRedirect(
                                                                request.getContextPath()
                                                                                + "/cliente?erro=pendencias");
                                                break;

                                        case JA_INATIVO:
                                                response.sendRedirect(
                                                                request.getContextPath()
                                                                                + "/cliente?erro=jaInativo");
                                                break;

                                        case CLIENTE_NAO_ENCONTRADO:
                                                response.sendError(
                                                                HttpServletResponse.SC_NOT_FOUND,
                                                                "Cliente não encontrado.");
                                                break;

                                        default:
                                                response.sendError(
                                                                HttpServletResponse.SC_CONFLICT,
                                                                "Não foi possível inativar o cliente.");
                                                break;
                                }

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao inativar cliente.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // REATIVAR CLIENTE
                // =========================================

                if ("reativar".equals(acao)) {

                        int idCliente;

                        try {

                                idCliente = Integer.parseInt(
                                                request.getParameter("idCliente"));

                                if (idCliente <= 0) {
                                        throw new NumberFormatException();
                                }

                        } catch (NumberFormatException e) {

                                response.sendError(
                                                HttpServletResponse.SC_BAD_REQUEST,
                                                "ID do cliente inválido.");

                                return;
                        }

                        // Verificar permissão administrativa
                        if (!usuarioAdministrador(request)) {

                                response.sendError(
                                                HttpServletResponse.SC_FORBIDDEN,
                                                "Apenas administradores podem reativar clientes.");

                                return;
                        }

                        try {

                                ResultadoStatusCliente resultado = clienteDAO.reativarCliente(idCliente);

                                switch (resultado) {

                                        case SUCESSO:
                                                response.sendRedirect(
                                                                request.getContextPath()
                                                                                + "/cliente?status=reativado");
                                                break;

                                        case JA_ATIVO:
                                                response.sendRedirect(
                                                                request.getContextPath()
                                                                                + "/cliente?erro=jaAtivo");
                                                break;

                                        case CLIENTE_NAO_ENCONTRADO:
                                                response.sendError(
                                                                HttpServletResponse.SC_NOT_FOUND,
                                                                "Cliente não encontrado.");
                                                break;

                                        default:
                                                response.sendError(
                                                                HttpServletResponse.SC_CONFLICT,
                                                                "Não foi possível reativar o cliente.");
                                                break;
                                }

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao reativar cliente.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // ATUALIZAR
                // =========================================

                if ("atualizar".equals(acao)) {

                        int idCliente = Integer.parseInt(
                                        request.getParameter(
                                                        "idCliente"));

                        String nome = padronizarTexto(
                                        request.getParameter(
                                                        "nome"));

                        String cpf = somenteNumeros(
                                        request.getParameter(
                                                        "cpf"));

                        String telefone = somenteNumeros(
                                        request.getParameter(
                                                        "telefone"));

                        String email = limpar(
                                        request.getParameter(
                                                        "email"));

                        try {

                                Cliente cliente = clienteDAO.buscarPorId(
                                                idCliente);

                                if (cliente != null) {

                                        cliente.setNome(nome);
                                        cliente.setCpf(cpf);
                                        cliente.setTelefone(
                                                        telefone);
                                        cliente.setEmail(email);

                                        clienteDAO.atualizar(
                                                        cliente);
                                }

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/cliente");

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao atualizar cliente.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // EXCLUIR
                // =========================================

                if ("excluir".equals(acao)) {

                        int idCliente = Integer.parseInt(
                                        request.getParameter(
                                                        "idCliente"));

                        try {

                                clienteDAO.excluir(
                                                idCliente);

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/cliente");

                        } catch (SQLIntegrityConstraintViolationException e) {

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/cliente?erro=clienteVinculado");

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao excluir cliente.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // CADASTRAR
                // =========================================

                String nome = padronizarTexto(
                                request.getParameter(
                                                "nome"));

                String cpf = somenteNumeros(
                                request.getParameter(
                                                "cpf"));

                String telefone = somenteNumeros(
                                request.getParameter(
                                                "telefone"));

                String email = limpar(
                                request.getParameter(
                                                "email"));

                String senha = limpar(
                                request.getParameter(
                                                "senha"));

                String confirmarSenha = limpar(
                                request.getParameter(
                                                "confirmarSenha"));

                if (nome == null
                                || cpf == null
                                || telefone == null
                                || email == null
                                || senha == null
                                || confirmarSenha == null) {

                        response.sendError(
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "Preencha todos os campos.");

                        return;
                }

                if (!senha.equals(
                                confirmarSenha)) {

                        response.sendError(
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "As senhas não coincidem.");

                        return;
                }

                Cliente cliente = new Cliente();

                cliente.setNome(nome);
                cliente.setCpf(cpf);
                cliente.setTelefone(
                                telefone);
                cliente.setEmail(email);

                cliente.setSenhaHash(
                                SenhaUtil.gerarHash(
                                                senha));

                try {

                        clienteDAO.inserir(
                                        cliente);

                        response.sendRedirect(
                                        request.getContextPath()
                                                        + "/cliente");

                } catch (SQLException e) {

                        throw new ServletException(
                                        "Erro ao cadastrar cliente.",
                                        e);
                }
        }

        private String limpar(
                        String valor) {

                if (valor == null) {
                        return null;
                }

                valor = valor.trim();

                if (valor.isEmpty()) {
                        return null;
                }

                return valor;
        }

        private String padronizarTexto(
                        String valor) {

                valor = limpar(
                                valor);

                if (valor == null) {
                        return null;
                }

                return valor.toUpperCase(
                                Locale.ROOT);
        }

        private String somenteNumeros(
                        String valor) {

                valor = limpar(
                                valor);

                if (valor == null) {
                        return null;
                }

                return valor.replaceAll(
                                "\\D",
                                "");
        }

        // =========================================
        // VERIFICAR PERMISSÃO ADMINISTRATIVA
        // =========================================

        private boolean usuarioAdministrador(
                        HttpServletRequest request) {

                HttpSession sessao = request.getSession(false);

                if (sessao == null) {
                        return false;
                }

                String nivelAcesso = (String) sessao.getAttribute(
                                "nivelAcesso");

                return "ADMINISTRADOR".equals(nivelAcesso);
        }
}
