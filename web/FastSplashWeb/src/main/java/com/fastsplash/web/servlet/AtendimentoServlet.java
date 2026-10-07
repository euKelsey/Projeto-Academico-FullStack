package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.fastsplash.web.dao.AtendimentoDAO;
import com.fastsplash.web.model.Atendimento;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/atendimento")
public class AtendimentoServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final AtendimentoDAO atendimentoDAO =
            new AtendimentoDAO();


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


        // NOVO
        if ("novo".equals(acao)) {

            carregarFormulario(
                    request,
                    response
            );

            return;
        }


        // DETALHES
        if ("detalhes".equals(acao)) {

            int idAtendimento =
                    Integer.parseInt(
                            request.getParameter(
                                    "idAtendimento"
                            )
                    );


            try {

                Atendimento atendimento =
                        atendimentoDAO.buscarPorId(
                                idAtendimento
                        );


                if (atendimento == null) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Atendimento não encontrado."
                    );

                    return;
                }


                request.setAttribute(
                        "atendimento",
                        atendimento
                );


                request.getRequestDispatcher(
                        "/detalhes-atendimento.jsp"
                ).forward(
                        request,
                        response
                );


            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao buscar atendimento.",
                        e
                );
            }


            return;
        }


        // LISTAR
        try {

            request.setAttribute(
                    "atendimentos",
                    atendimentoDAO.listarTodos()
            );


            request.getRequestDispatcher(
                    "/lista-atendimentos.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar atendimentos.",
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


        // =====================================
        // INICIAR LAVAGEM
        // =====================================

        if ("iniciar".equals(acao)) {

            int idAtendimento =
                    Integer.parseInt(
                            request.getParameter(
                                    "idAtendimento"
                            )
                    );


            try {

                atendimentoDAO.iniciarLavagem(
                        idAtendimento
                );


                response.sendRedirect(
                        request.getContextPath()
                        + "/atendimento"
                );


            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao iniciar lavagem.",
                        e
                );
            }


            return;
        }


        // =====================================
        // FINALIZAR
        // =====================================

        if ("finalizar".equals(acao)) {

            int idAtendimento =
                    Integer.parseInt(
                            request.getParameter(
                                    "idAtendimento"
                            )
                    );


            try {

                atendimentoDAO.finalizar(
                        idAtendimento
                );


                response.sendRedirect(
                        request.getContextPath()
                        + "/atendimento"
                );


            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao finalizar atendimento.",
                        e
                );
            }


            return;
        }


        // =====================================
        // CRIAR ATENDIMENTO
        // =====================================

        String idAgendamentoTexto =
                request.getParameter(
                        "idAgendamento"
                );


        if (
            idAgendamentoTexto == null
            || idAgendamentoTexto.isBlank()
        ) {

            request.setAttribute(
                    "erro",
                    "Selecione um agendamento."
            );

            carregarFormulario(
                    request,
                    response
            );

            return;
        }


        int idAgendamento =
                Integer.parseInt(
                        idAgendamentoTexto
                );


        Atendimento atendimento =
                new Atendimento();


        atendimento.setIdAgendamento(
                idAgendamento
        );


        try {

            atendimentoDAO.inserir(
                    atendimento
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/atendimento"
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            request.setAttribute(
                    "erro",
                    "Este agendamento já possui um atendimento."
            );


            carregarFormulario(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao criar atendimento.",
                    e
            );
        }
    }


    // =========================================
    // CARREGAR FORMULÁRIO
    // =========================================

    private void carregarFormulario(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        try {

            request.setAttribute(
                    "agendamentos",
                    atendimentoDAO
                            .listarAgendamentosDisponiveis()
            );


            request.getRequestDispatcher(
                    "/cadastro-atendimento.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao carregar agendamentos.",
                    e
            );
        }
    }
}