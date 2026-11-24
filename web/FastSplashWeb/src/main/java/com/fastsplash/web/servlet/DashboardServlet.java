package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.DashboardDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DashboardDAO dashboardDAO =
        new DashboardDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession sessao = request.getSession(false);

        if (sessao == null
                || sessao.getAttribute("usuarioLogado") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login"
            );

            return;
        }

        Object nivel =
            sessao.getAttribute("nivelAcesso");

        if (!"ADMINISTRADOR".equals(nivel)
                && !"ATENDENTE".equals(nivel)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN
            );

            return;
        }

        response.setHeader(
            "Cache-Control",
            "no-store"
        );

        try {

            request.setAttribute(
                "dashboard",
                dashboardDAO.carregar()
            );

            request.getRequestDispatcher(
                "/dashboard.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                "Erro ao carregar os indicadores do Dashboard.",
                e
            );
        }
    }
}
