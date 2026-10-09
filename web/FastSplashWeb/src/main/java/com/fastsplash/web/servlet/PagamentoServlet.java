package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.PagamentoDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/pagamento")
public class PagamentoServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final PagamentoDAO pagamentoDAO =
            new PagamentoDAO();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        try {

            request.setAttribute(
                    "pagamentos",
                    pagamentoDAO.listarTodos()
            );


            request.getRequestDispatcher(
                    "/lista-pagamentos.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar pagamentos.",
                    e
            );
        }
    }
}