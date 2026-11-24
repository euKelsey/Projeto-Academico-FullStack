package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.model.Servico;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/servico")
public class ServicoServlet extends HttpServlet {

        private static final long serialVersionUID = 1L;

        private final ServicoDAO servicoDAO = new ServicoDAO();

        // =========================================
        // GET
        // =========================================

        @Override
        protected void doGet(
                        HttpServletRequest request,
                        HttpServletResponse response)
                        throws ServletException, IOException {

                String acao = request.getParameter("acao");

                // NOVO SERVIÇO
                if ("novo".equals(acao)) {

                        request.getRequestDispatcher(
                                        "/cadastro-servico.jsp").forward(
                                                        request,
                                                        response);

                        return;
                }

                // EDITAR SERVIÇO
                if ("editar".equals(acao)) {

                        int idServico = Integer.parseInt(
                                        request.getParameter(
                                                        "idServico"));

                        try {

                                Servico servico =
                                                servicoDAO.buscarPorId(
                                                                idServico);

                                if (servico == null || !servico.isAtivo() || servico.isExcluido()) {

                                        response.sendError(
                                                        HttpServletResponse.SC_NOT_FOUND,
                                                        "Serviço não encontrado.");

                                        return;
                                }

                                request.setAttribute(
                                                "servico",
                                                servico);

                                request.getRequestDispatcher(
                                                "/editar-servico.jsp")
                                                .forward(
                                                                request,
                                                                response);

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao buscar serviço.",
                                                e);
                        }

                        return;
                }

                // LISTAR SERVIÇOS
                try {

                        String filtro = normalizarFiltro(
                                request.getParameter("filtro"));

                        if (!"ativos".equals(filtro)
                                && !usuarioAdministrador(request)) {

                                response.sendError(
                                        HttpServletResponse.SC_FORBIDDEN);
                                return;
                        }

                        List<Servico> servicos =
                                servicoDAO.listarPorStatus(filtro);

                        request.setAttribute("filtro", filtro);
                        request.setAttribute("servicos", servicos);

                        request.getRequestDispatcher(
                                        "/lista-servicos.jsp")
                                        .forward(
                                                        request,
                                                        response);

                } catch (SQLException e) {

                        throw new ServletException(
                                        "Erro ao listar serviços.",
                                        e);
                }
        }

        // =========================================
        // POST
        // =========================================

        @Override
        protected void doPost(
                        HttpServletRequest request,
                        HttpServletResponse response)
                        throws ServletException, IOException {

                request.setCharacterEncoding("UTF-8");

                String acao =
                                request.getParameter("acao");

                // =========================================
                // ATUALIZAR SERVIÇO
                // =========================================

                if ("atualizar".equals(acao)) {

                        int idServico =
                                        Integer.parseInt(
                                                        request.getParameter(
                                                                        "idServico"));

                        String nome =
                                        request.getParameter(
                                                        "nome");

                        String descricao =
                                        request.getParameter(
                                                        "descricao");

                        double preco =
                                        Double.parseDouble(
                                                        request.getParameter(
                                                                        "preco"));

                        try {

                                Servico servico =
                                                servicoDAO.buscarPorId(
                                                                idServico);

                                if (servico == null || !servico.isAtivo() || servico.isExcluido()) {

                                        response.sendError(
                                                        HttpServletResponse.SC_NOT_FOUND,
                                                        "Serviço não encontrado.");

                                        return;
                                }

                                servico.setNome(
                                                nome);

                                servico.setDescricao(
                                                descricao);

                                servico.setPreco(
                                                preco);

                                servicoDAO.atualizar(
                                                servico);

                                response.sendRedirect(
                                                request.getContextPath()
                                                                + "/servico");

                        } catch (SQLException e) {

                                throw new ServletException(
                                                "Erro ao atualizar serviço.",
                                                e);
                        }

                        return;
                }

                // =========================================
                // INATIVAR SERVIÇO
                // =========================================

                if ("inativar".equals(acao)
                                || "ativar".equals(acao)
                                || "reativar".equals(acao)
                                || "excluir".equals(acao)
                                || "restaurar".equals(acao)) {

                        processarStatus(request, response, acao);
                        return;
                }

                // =========================================
                // CADASTRAR SERVIÇO
                // =========================================

                String nome =
                                request.getParameter(
                                                "nome");

                String descricao =
                                request.getParameter(
                                                "descricao");

                double preco =
                                Double.parseDouble(
                                                request.getParameter(
                                                                "preco"));

                Servico servico =
                                new Servico();

                servico.setNome(
                                nome);

                servico.setDescricao(
                                descricao);

                servico.setPreco(
                                preco);

                servico.setAtivo(
                                true);

                try {

                        servicoDAO.inserir(
                                        servico);

                        response.sendRedirect(
                                        request.getContextPath()
                                                        + "/servico");

                } catch (SQLException e) {

                        throw new ServletException(
                                        "Erro ao cadastrar serviço.",
                                        e);
                }
        }

        private boolean usuarioAdministrador(
                HttpServletRequest request
        ) {

                HttpSession sessao = request.getSession(false);

                return sessao != null
                        && "ADMINISTRADOR".equals(
                                sessao.getAttribute("nivelAcesso"));
        }

        private String normalizarFiltro(String filtro) {

                if ("inativos".equals(filtro)
                        || "excluidos".equals(filtro)) {
                        return filtro;
                }

                return "ativos";
        }

        private void processarStatus(
                HttpServletRequest request,
                HttpServletResponse response,
                String acao
        ) throws ServletException, IOException {

                if (!usuarioAdministrador(request)) {

                        response.sendError(
                                HttpServletResponse.SC_FORBIDDEN,
                                "Apenas administradores podem alterar o status dos serviços.");
                        return;
                }

                int idServico;

                try {

                        idServico = Integer.parseInt(
                                request.getParameter("idServico"));

                        if (idServico <= 0) {
                                throw new NumberFormatException();
                        }

                } catch (NumberFormatException e) {

                        response.sendError(
                                HttpServletResponse.SC_BAD_REQUEST,
                                "ID do serviço inválido.");
                        return;
                }

                String filtro = normalizarFiltro(
                        request.getParameter("filtro"));

                try {

                        boolean sucesso = switch (acao) {

                                case "inativar" ->
                                    servicoDAO.inativarServico(idServico);

                                case "ativar", "reativar" ->
                                    servicoDAO.reativarServico(idServico);

                                case "excluir" ->
                                    servicoDAO.excluirLogicamente(idServico);

                                case "restaurar" ->
                                    servicoDAO.restaurarServico(idServico);

                                default ->
                                    false;
                        };

                        String mensagem;

                        if (sucesso) {

                                mensagem = "status=" + switch (acao) {

                                        case "inativar" -> "inativado";
                                        case "ativar", "reativar" -> "reativado";
                                        case "excluir" -> "excluido";
                                        case "restaurar" -> "restaurado";
                                        default -> "sucesso";
                                };

                        } else {

                                mensagem = "erro=operacaoInvalida";
                        }

                        response.sendRedirect(
                                request.getContextPath()
                                + "/servico?filtro=" + filtro
                                + "&" + mensagem);

                } catch (SQLException e) {

                        throw new ServletException(
                                "Erro ao alterar status do serviço.", e);
                }
        }

}