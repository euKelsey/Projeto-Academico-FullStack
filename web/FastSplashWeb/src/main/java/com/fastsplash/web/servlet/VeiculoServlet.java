package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.model.Veiculo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/veiculo")
public class VeiculoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final VeiculoDAO veiculoDAO =
            new VeiculoDAO();

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


        // =====================================
        // ABRIR CADASTRO DE VEÍCULO
        // =====================================

        if ("novo".equals(acao)) {

            try {

                request.setAttribute(
                        "clientes",
                        clienteDAO.listarTodos()
                );

                request.getRequestDispatcher(
                        "/cadastro-veiculo.jsp"
                ).forward(
                        request,
                        response
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao carregar clientes.",
                        e
                );
            }

            return;
        }


        // =====================================
        // ABRIR EDIÇÃO DE VEÍCULO
        // =====================================

        if ("editar".equals(acao)) {

            int idVeiculo = Integer.parseInt(
                    request.getParameter(
                            "idVeiculo"
                    )
            );

            try {

                Veiculo veiculo =
                        veiculoDAO.buscarPorId(
                                idVeiculo
                        );

                if (veiculo == null) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Veículo não encontrado."
                    );

                    return;
                }

                request.setAttribute(
                        "veiculo",
                        veiculo
                );

                request.setAttribute(
                        "clientes",
                        clienteDAO.listarTodos()
                );

                request.getRequestDispatcher(
                        "/editar-veiculo.jsp"
                ).forward(
                        request,
                        response
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao buscar veículo.",
                        e
                );
            }

            return;
        }


        // =====================================
        // LISTAR VEÍCULOS
        // =====================================

        try {

            request.setAttribute(
                    "veiculos",
                    veiculoDAO.listarTodos()
            );

            request.getRequestDispatcher(
                    "/lista-veiculos.jsp"
            ).forward(
                    request,
                    response
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar veículos.",
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
        // ATUALIZAR VEÍCULO
        // =====================================

        if ("atualizar".equals(acao)) {

            int idVeiculo = Integer.parseInt(
                    request.getParameter(
                            "idVeiculo"
                    )
            );

            int idCliente = Integer.parseInt(
                    request.getParameter(
                            "idCliente"
                    )
            );

            String placa =
                    request.getParameter("placa");

            String marca =
                    request.getParameter("marca");

            String modelo =
                    request.getParameter("modelo");

            String cor =
                    request.getParameter("cor");

            try {

                Veiculo veiculo =
                        veiculoDAO.buscarPorId(
                                idVeiculo
                        );

                if (veiculo == null) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Veículo não encontrado."
                    );

                    return;
                }

                veiculo.setIdCliente(
                        idCliente
                );

                veiculo.setPlaca(
                        placa
                );

                veiculo.setMarca(
                        marca
                );

                veiculo.setModelo(
                        modelo
                );

                veiculo.setCor(
                        cor
                );

                veiculoDAO.atualizar(
                        veiculo
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/veiculo"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao atualizar veículo.",
                        e
                );
            }

            return;
        }


        // =====================================
        // EXCLUIR VEÍCULO
        // =====================================

        if ("excluir".equals(acao)) {

            int idVeiculo = Integer.parseInt(
                    request.getParameter(
                            "idVeiculo"
                    )
            );

            try {

                veiculoDAO.excluir(
                        idVeiculo
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/veiculo"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao excluir veículo.",
                        e
                );
            }

            return;
        }


        // =====================================
        // CADASTRAR VEÍCULO
        // =====================================

        int idCliente = Integer.parseInt(
                request.getParameter(
                        "idCliente"
                )
        );

        String placa =
                request.getParameter("placa");

        String marca =
                request.getParameter("marca");

        String modelo =
                request.getParameter("modelo");

        String cor =
                request.getParameter("cor");

        Veiculo veiculo =
                new Veiculo();

        veiculo.setIdCliente(
                idCliente
        );

        veiculo.setPlaca(
                placa
        );

        veiculo.setMarca(
                marca
        );

        veiculo.setModelo(
                modelo
        );

        veiculo.setCor(
                cor
        );

        try {

            veiculoDAO.inserir(
                    veiculo
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/veiculo"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar veículo.",
                    e
            );
        }
    }
}