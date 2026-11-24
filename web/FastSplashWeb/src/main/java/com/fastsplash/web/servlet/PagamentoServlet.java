package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.PagamentoDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/pagamento")
public class PagamentoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PagamentoDAO pagamentoDAO =
            new PagamentoDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        try {

            String filtro = normalizarFiltro(
                    request.getParameter("filtro"));

            request.setAttribute("filtro", filtro);

            request.setAttribute(
                    "pagamentos",
                    pagamentoDAO.listarPorStatus(filtro));

            request.getRequestDispatcher(
                    "/lista-pagamentos.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar pagamentos.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession sessao = request.getSession(false);

        if (sessao == null
                || !"ADMINISTRADOR".equals(
                        sessao.getAttribute("nivelAcesso"))) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Apenas administradores podem arquivar ou restaurar pagamentos.");

            return;
        }

        String acao = request.getParameter("acao");

        if (!"arquivar".equals(acao)
                && !"restaurar".equals(acao)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Operação inválida.");

            return;
        }

        int idPagamento;

        try {

            idPagamento = Integer.parseInt(
                    request.getParameter("idPagamento"));

            if (idPagamento <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID do pagamento inválido.");

            return;
        }

        String filtro = normalizarFiltro(
                request.getParameter("filtro"));

        try {

            boolean sucesso = "arquivar".equals(acao)
                    ? pagamentoDAO.arquivarPagamento(idPagamento)
                    : pagamentoDAO.restaurarPagamento(idPagamento);

            String mensagem = sucesso
                    ? "status=" + (
                        "arquivar".equals(acao)
                            ? "arquivado"
                            : "restaurado")
                    : "erro=operacaoInvalida";

            response.sendRedirect(
                    request.getContextPath()
                    + "/pagamento?filtro=" + filtro
                    + "&" + mensagem);

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao alterar arquivamento do pagamento.", e);
        }
    }

    private String normalizarFiltro(String filtro) {

        if ("pagos".equals(filtro)
                || "cancelados".equals(filtro)
                || "arquivados".equals(filtro)) {

            return filtro;
        }

        return "pendentes";
    }
}
