package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.dao.ResultadoStatusVeiculo;
import com.fastsplash.web.model.Cliente;
import jakarta.servlet.http.HttpSession;
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


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String acao =
                request.getParameter(
                        "acao"
                );


        // =========================================
        // NOVO VEÍCULO
        // =========================================

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


        // =========================================
        // EDITAR VEÍCULO
        // =========================================

        if ("editar".equals(acao)) {

            int idVeiculo =
                    Integer.parseInt(
                            request.getParameter(
                                    "idVeiculo"
                            )
                    );

            try {

                Veiculo veiculo =
                        veiculoDAO.buscarPorId(
                                idVeiculo
                        );

                if (veiculo == null || !veiculo.isAtivo() || veiculo.isExcluido()) {

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


        // =========================================
        // LISTAR VEÍCULOS
        // =========================================

        try {

            String filtro = normalizarFiltro(
                    request.getParameter("filtro"));

            if (!"ativos".equals(filtro)
                    && !usuarioAdministrador(request)) {

                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            request.setAttribute("filtro", filtro);

            request.setAttribute(
                    "veiculos",
                    veiculoDAO.listarPorStatus(filtro)
            );

            /*
             * Também enviamos os clientes para a JSP.
             * Assim a tabela mostra o nome do proprietário,
             * e não somente o ID do cliente.
             */
            request.setAttribute(
                    "clientes",
                    clienteDAO.listarTodosParaHistorico()
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


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding(
                "UTF-8"
        );

        String acao =
                request.getParameter(
                        "acao"
                );


        // =========================================
        // ATUALIZAR VEÍCULO
        // =========================================

        if ("atualizar".equals(acao)) {

            int idVeiculo =
                    Integer.parseInt(
                            request.getParameter(
                                    "idVeiculo"
                            )
                    );

            int idCliente =
                    Integer.parseInt(
                            request.getParameter(
                                    "idCliente"
                            )
                    );

            String placa =
                    padronizarPlaca(
                            request.getParameter(
                                    "placa"
                            )
                    );

            String marca =
                    padronizarTexto(
                            request.getParameter(
                                    "marca"
                            )
                    );

            String modelo =
                    padronizarTexto(
                            request.getParameter(
                                    "modelo"
                            )
                    );

            String cor =
                    padronizarTexto(
                            request.getParameter(
                                    "cor"
                            )
                    );


            if (
                placa == null
                || marca == null
                || modelo == null
                || cor == null
            ) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Preencha todos os campos."
                );

                return;
            }


            if (!placaValida(placa)) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Informe uma placa brasileira válida com 7 caracteres."
                );

                return;
            }


            try {

                Veiculo veiculo =
                        veiculoDAO.buscarPorId(
                                idVeiculo
                        );

                if (veiculo == null || !veiculo.isAtivo() || veiculo.isExcluido()) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Veículo não encontrado."
                    );

                    return;
                }

                if (!clienteDisponivel(idCliente)) {
                    response.sendError(
                            HttpServletResponse.SC_CONFLICT,
                            "O proprietario precisa estar ativo.");
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


        // =========================================
        // EXCLUIR VEÍCULO
        // =========================================


        if ("inativar".equals(acao)
                || "reativar".equals(acao)
                || "excluir".equals(acao)
                || "restaurar".equals(acao)) {

            processarStatus(request, response, acao);
            return;
        }

        // =========================================
        // CADASTRAR VEÍCULO
        // =========================================

        String idClienteTexto =
                limpar(
                        request.getParameter(
                                "idCliente"
                        )
                );

        String placa =
                padronizarPlaca(
                        request.getParameter(
                                "placa"
                        )
                );

        String marca =
                padronizarTexto(
                        request.getParameter(
                                "marca"
                        )
                );

        String modelo =
                padronizarTexto(
                        request.getParameter(
                                "modelo"
                        )
                );

        String cor =
                padronizarTexto(
                        request.getParameter(
                                "cor"
                        )
                );


        if (
            idClienteTexto == null
            || placa == null
            || marca == null
            || modelo == null
            || cor == null
        ) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Preencha todos os campos."
            );

            return;
        }


        if (!placaValida(placa)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Informe uma placa brasileira válida com 7 caracteres."
            );

            return;
        }


        int idCliente =
                Integer.parseInt(
                        idClienteTexto
                );


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

            if (!clienteDisponivel(idCliente)) {
                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "O proprietario precisa estar ativo.");
                return;
            }

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



    private boolean clienteDisponivel(
            int idCliente
    ) throws SQLException {

        Cliente cliente = clienteDAO.buscarPorId(idCliente);

        return cliente != null
                && cliente.isAtivo()
                && !cliente.isExcluido();
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
                    "Apenas administradores podem alterar o status dos veiculos.");
            return;
        }

        int idVeiculo;

        try {

            idVeiculo = Integer.parseInt(
                    request.getParameter("idVeiculo"));

            if (idVeiculo <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID do veiculo invalido.");
            return;
        }

        String filtro = normalizarFiltro(
                request.getParameter("filtro"));

        try {

            ResultadoStatusVeiculo resultado = switch (acao) {

                case "inativar" ->
                    veiculoDAO.inativarVeiculo(idVeiculo);

                case "reativar" ->
                    veiculoDAO.reativarVeiculo(idVeiculo);

                case "excluir" ->
                    veiculoDAO.excluirLogicamente(idVeiculo);

                case "restaurar" ->
                    veiculoDAO.restaurarVeiculo(idVeiculo);

                default ->
                    throw new IllegalArgumentException("Acao invalida.");
            };

            String mensagem = switch (resultado) {

                case SUCESSO -> "status=" + switch (acao) {
                    case "inativar" -> "inativado";
                    case "reativar" -> "reativado";
                    case "excluir" -> "excluido";
                    case "restaurar" -> "restaurado";
                    default -> "sucesso";
                };

                case POSSUI_PENDENCIAS -> "erro=pendencias";
                case JA_ATIVO -> "erro=jaAtivo";
                case JA_INATIVO -> "erro=jaInativo";
                case JA_EXCLUIDO -> "erro=jaExcluido";
                case NAO_EXCLUIDO -> "erro=naoExcluido";
                case CLIENTE_INATIVO -> "erro=clienteInativo";
                case VEICULO_NAO_ENCONTRADO -> "erro=naoEncontrado";
            };

            response.sendRedirect(
                    request.getContextPath()
                    + "/veiculo?filtro=" + filtro
                    + "&" + mensagem);

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao alterar status do veiculo.", e);
        }
    }

    private String limpar(
            String valor
    ) {

        if (valor == null) {
            return null;
        }

        valor =
                valor.trim();

        if (valor.isEmpty()) {
            return null;
        }

        return valor;
    }


    private String padronizarTexto(
            String valor
    ) {

        valor =
                limpar(
                        valor
                );

        if (valor == null) {
            return null;
        }

        return valor.toUpperCase(
                Locale.ROOT
        );
    }


    private String padronizarPlaca(
            String placa
    ) {

        placa =
                limpar(
                        placa
                );

        if (placa == null) {
            return null;
        }

        return placa
                .replaceAll(
                        "[^A-Za-z0-9]",
                        ""
                )
                .toUpperCase(
                        Locale.ROOT
                );
    }


    private boolean placaValida(
            String placa
    ) {

        return placa.matches(
                "[A-Z]{3}[0-9]{4}"
        )
        ||
        placa.matches(
                "[A-Z]{3}[0-9][A-Z][0-9]{2}"
        );
    }
}
