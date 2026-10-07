package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.model.Agendamento;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/agendamento")
public class AgendamentoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final AgendamentoDAO agendamentoDAO =
            new AgendamentoDAO();

    private final VeiculoDAO veiculoDAO =
            new VeiculoDAO();

    private final ServicoDAO servicoDAO =
            new ServicoDAO();

    private final ClienteDAO clienteDAO =
            new ClienteDAO();


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


        // NOVO AGENDAMENTO
        if ("novo".equals(acao)) {

            carregarFormulario(
                    request,
                    response
            );

            return;
        }


        // LISTAR AGENDAMENTOS
        try {

            request.setAttribute(
                    "agendamentos",
                    agendamentoDAO.listarTodos()
            );

            request.getRequestDispatcher(
                    "/lista-agendamentos.jsp"
            ).forward(
                    request,
                    response
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar agendamentos.",
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
        // CANCELAR
        // =====================================

        if ("cancelar".equals(acao)) {

            int idAgendamento =
                    Integer.parseInt(
                            request.getParameter(
                                    "idAgendamento"
                            )
                    );

            try {

                agendamentoDAO.cancelar(
                        idAgendamento
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/agendamento"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao cancelar agendamento.",
                        e
                );
            }

            return;
        }


        // =====================================
        // CADASTRAR
        // =====================================

        String idVeiculoTexto =
                request.getParameter(
                        "idVeiculo"
                );

        String dataTexto =
                request.getParameter(
                        "data"
                );

        String horarioTexto =
                request.getParameter(
                        "horario"
                );


        if (
            idVeiculoTexto == null
            || idVeiculoTexto.isBlank()
            || dataTexto == null
            || dataTexto.isBlank()
            || horarioTexto == null
            || horarioTexto.isBlank()
        ) {

            request.setAttribute(
                    "erro",
                    "Preencha o veículo, a data e o horário."
            );

            carregarFormulario(
                    request,
                    response
            );

            return;
        }


        int idVeiculo =
                Integer.parseInt(
                        idVeiculoTexto
                );


        LocalDate data =
                LocalDate.parse(
                        dataTexto
                );


        LocalTime horario =
                LocalTime.parse(
                        horarioTexto
                );


        String[] servicosSelecionados =
                request.getParameterValues(
                        "servicos"
                );


        if (
            servicosSelecionados == null
            || servicosSelecionados.length == 0
        ) {

            request.setAttribute(
                    "erro",
                    "Selecione pelo menos um serviço."
            );

            carregarFormulario(
                    request,
                    response
            );

            return;
        }


        List<Integer> idsServicos =
                new ArrayList<>();


        for (
            String id :
            servicosSelecionados
        ) {

            idsServicos.add(
                    Integer.parseInt(id)
            );
        }


        Agendamento agendamento =
                new Agendamento();


        agendamento.setIdVeiculo(
                idVeiculo
        );

        agendamento.setData(
                data
        );

        agendamento.setHorario(
                horario
        );

        agendamento.setIdsServicos(
                idsServicos
        );


        try {

            agendamentoDAO.inserir(
                    agendamento
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/agendamento"
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            request.setAttribute(
                    "erro",
                    "Este veículo já possui um agendamento nesta data e horário."
            );


            carregarFormulario(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar agendamento.",
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
                    "clientes",
                    clienteDAO.listarTodos()
            );


            request.setAttribute(
                    "veiculos",
                    veiculoDAO.listarTodos()
            );


            request.setAttribute(
                    "servicos",
                    servicoDAO.listarTodos()
            );


            request.getRequestDispatcher(
                    "/cadastro-agendamento.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao carregar formulário de agendamento.",
                    e
            );
        }
    }
}