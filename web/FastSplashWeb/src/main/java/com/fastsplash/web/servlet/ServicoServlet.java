package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.model.Servico;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/servico")
public class ServicoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ServicoDAO servicoDAO =
            new ServicoDAO();


    // =========================================
    // GET
    // =========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String acao =
                request.getParameter("acao");


        // NOVO SERVIÇO
        if ("novo".equals(acao)) {

            request.getRequestDispatcher(
                    "/cadastro-servico.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }


        // EDITAR SERVIÇO
        if ("editar".equals(acao)) {

            int idServico = Integer.parseInt(
                    request.getParameter(
                            "idServico"
                    )
            );

            try {

                Servico servico =
                        servicoDAO.buscarPorId(
                                idServico
                        );

                if (servico == null) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Serviço não encontrado."
                    );

                    return;
                }

                request.setAttribute(
                        "servico",
                        servico
                );

                request.getRequestDispatcher(
                        "/editar-servico.jsp"
                ).forward(
                        request,
                        response
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao buscar serviço.",
                        e
                );
            }

            return;
        }


        // LISTAR SERVIÇOS
        try {

            request.setAttribute(
                    "servicos",
                    servicoDAO.listarTodos()
            );

            request.getRequestDispatcher(
                    "/lista-servicos.jsp"
            ).forward(
                    request,
                    response
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar serviços.",
                    e
            );
        }
    }


    // =========================================
    // POST
    // =========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String acao =
                request.getParameter("acao");


        // ATUALIZAR SERVIÇO
        if ("atualizar".equals(acao)) {

            int idServico = Integer.parseInt(
                    request.getParameter(
                            "idServico"
                    )
            );

            String nome =
                    request.getParameter("nome");

            String descricao =
                    request.getParameter(
                            "descricao"
                    );

            double preco = Double.parseDouble(
                    request.getParameter(
                            "preco"
                    )
            );

            try {

                Servico servico =
                        servicoDAO.buscarPorId(
                                idServico
                        );

                if (servico == null) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Serviço não encontrado."
                    );

                    return;
                }

                servico.setNome(
                        nome
                );

                servico.setDescricao(
                        descricao
                );

                servico.setPreco(
                        preco
                );

                servicoDAO.atualizar(
                        servico
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/servico"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao atualizar serviço.",
                        e
                );
            }

            return;
        }


        // EXCLUIR SERVIÇO
        if ("excluir".equals(acao)) {

            int idServico = Integer.parseInt(
                    request.getParameter(
                            "idServico"
                    )
            );

            try {

                servicoDAO.excluir(
                        idServico
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/servico"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao excluir serviço.",
                        e
                );
            }

            return;
        }


        // CADASTRAR SERVIÇO
        String nome =
                request.getParameter("nome");

        String descricao =
                request.getParameter(
                        "descricao"
                );

        double preco = Double.parseDouble(
                request.getParameter(
                        "preco"
                )
        );

        Servico servico =
                new Servico();

        servico.setNome(
                nome
        );

        servico.setDescricao(
                descricao
        );

        servico.setPreco(
                preco
        );

        try {

            servicoDAO.inserir(
                    servico
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/servico"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar serviço.",
                    e
            );
        }
    }
}