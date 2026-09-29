package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Veiculo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
    urlPatterns = {
        "/api/veiculos",
        "/api/veiculos/editar",
        "/api/veiculos/excluir"
    }
)
public class VeiculoApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final VeiculoDAO veiculoDAO =
            new VeiculoDAO();


    // =========================================
    // GET - LISTAR VEÍCULOS DO CLIENTE
    // =========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        prepararResposta(response);

        Cliente cliente =
                obterClienteLogado(
                        request,
                        response
                );

        if (cliente == null) {
            return;
        }

        try {

            List<Veiculo> veiculos =
                    veiculoDAO.listarPorCliente(
                            cliente.getIdCliente()
                    );

            StringBuilder json =
                    new StringBuilder();

            json.append("""
                    {
                        "sucesso": true,
                        "veiculos": [
                    """);

            for (int i = 0;
                 i < veiculos.size();
                 i++) {

                Veiculo veiculo =
                        veiculos.get(i);

                json.append(
                        veiculoParaJson(
                                veiculo
                        )
                );

                if (i <
                        veiculos.size() - 1) {

                    json.append(",");
                }
            }

            json.append("""
                        ]
                    }
                    """);

            response
                .getWriter()
                .print(
                    json.toString()
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

        request.setCharacterEncoding(
                "UTF-8"
        );

        prepararResposta(response);

        Cliente cliente =
                obterClienteLogado(
                        request,
                        response
                );

        if (cliente == null) {
            return;
        }

        String caminho =
                request.getServletPath();

        if (
            "/api/veiculos/editar"
                .equals(caminho)
        ) {

            editar(
                    request,
                    response,
                    cliente
            );

            return;
        }

        if (
            "/api/veiculos/excluir"
                .equals(caminho)
        ) {

            excluir(
                    request,
                    response,
                    cliente
            );

            return;
        }

        cadastrar(
                request,
                response,
                cliente
        );
    }


    // =========================================
    // CADASTRAR
    // =========================================

    private void cadastrar(
            HttpServletRequest request,
            HttpServletResponse response,
            Cliente cliente
    ) throws ServletException, IOException {

        String placa =
                limpar(
                    request.getParameter(
                            "placa"
                    )
                );

        String marca =
                limpar(
                    request.getParameter(
                            "marca"
                    )
                );

        String modelo =
                limpar(
                    request.getParameter(
                            "modelo"
                    )
                );

        String cor =
                limpar(
                    request.getParameter(
                            "cor"
                    )
                );

        if (
            placa == null ||
            marca == null ||
            modelo == null ||
            cor == null
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Preencha todos os campos."
            );

            return;
        }

        placa =
                placa
                    .replace("-", "")
                    .replace(" ", "")
                    .toUpperCase();

        Veiculo veiculo =
                new Veiculo();

        veiculo.setIdCliente(
                cliente.getIdCliente()
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

            response.setStatus(
                    HttpServletResponse.SC_CREATED
            );

            response
                .getWriter()
                .print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Veículo cadastrado com sucesso.",
                        "veiculo": %s
                    }
                    """.formatted(
                            veiculoParaJson(
                                    veiculo
                            )
                    )
                );

        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "Esta placa já está cadastrada."
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar veículo.",
                    e
            );
        }
    }


    // =========================================
    // EDITAR
    // =========================================

    private void editar(
            HttpServletRequest request,
            HttpServletResponse response,
            Cliente cliente
    ) throws ServletException, IOException {

        int idVeiculo;

        try {

            idVeiculo =
                    Integer.parseInt(
                        request.getParameter(
                                "idVeiculo"
                        )
                    );

        } catch (
            NumberFormatException |
            NullPointerException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Veículo inválido."
            );

            return;
        }

        String placa =
                limpar(
                    request.getParameter(
                            "placa"
                    )
                );

        String marca =
                limpar(
                    request.getParameter(
                            "marca"
                    )
                );

        String modelo =
                limpar(
                    request.getParameter(
                            "modelo"
                    )
                );

        String cor =
                limpar(
                    request.getParameter(
                            "cor"
                    )
                );

        if (
            placa == null ||
            marca == null ||
            modelo == null ||
            cor == null
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Preencha todos os campos."
            );

            return;
        }

        placa =
                placa
                    .replace("-", "")
                    .replace(" ", "")
                    .toUpperCase();

        try {

            Veiculo veiculo =
                    veiculoDAO.buscarPorId(
                            idVeiculo
                    );

            if (
                veiculo == null ||
                veiculo.getIdCliente()
                    != cliente.getIdCliente()
            ) {

                responderErro(
                        response,
                        HttpServletResponse.SC_NOT_FOUND,
                        "Veículo não encontrado."
                );

                return;
            }

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

            response
                .getWriter()
                .print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Veículo atualizado com sucesso.",
                        "veiculo": %s
                    }
                    """.formatted(
                            veiculoParaJson(
                                    veiculo
                            )
                    )
                );

        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "Esta placa já está cadastrada."
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao atualizar veículo.",
                    e
            );
        }
    }


    // =========================================
    // EXCLUIR
    // =========================================

    private void excluir(
            HttpServletRequest request,
            HttpServletResponse response,
            Cliente cliente
    ) throws ServletException, IOException {

        int idVeiculo;

        try {

            idVeiculo =
                    Integer.parseInt(
                        request.getParameter(
                                "idVeiculo"
                        )
                    );

        } catch (
            NumberFormatException |
            NullPointerException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Veículo inválido."
            );

            return;
        }

        try {

            Veiculo veiculo =
                    veiculoDAO.buscarPorId(
                            idVeiculo
                    );

            if (
                veiculo == null ||
                veiculo.getIdCliente()
                    != cliente.getIdCliente()
            ) {

                responderErro(
                        response,
                        HttpServletResponse.SC_NOT_FOUND,
                        "Veículo não encontrado."
                );

                return;
            }

            veiculoDAO.excluir(
                    idVeiculo
            );

            response
                .getWriter()
                .print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Veículo excluído com sucesso."
                    }
                    """
                );

        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "Não é possível excluir este veículo porque ele possui registros vinculados."
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao excluir veículo.",
                    e
            );
        }
    }


    // =========================================
    // CLIENTE LOGADO
    // =========================================

    private Cliente obterClienteLogado(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession sessao =
                request.getSession(false);

        if (sessao == null) {

            responderErro(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Cliente não autenticado."
            );

            return null;
        }

        Cliente cliente =
                (Cliente)
                    sessao.getAttribute(
                            "clienteLogado"
                    );

        if (cliente == null) {

            responderErro(
                    response,
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Cliente não autenticado."
            );

            return null;
        }

        return cliente;
    }


    // =========================================
    // VEÍCULO -> JSON
    // =========================================

    private String veiculoParaJson(
            Veiculo veiculo
    ) {

        return """
                {
                    "idVeiculo": %d,
                    "idCliente": %d,
                    "placa": "%s",
                    "marca": "%s",
                    "modelo": "%s",
                    "cor": "%s"
                }
                """.formatted(
                        veiculo.getIdVeiculo(),
                        veiculo.getIdCliente(),
                        escaparJson(
                                veiculo.getPlaca()
                        ),
                        escaparJson(
                                veiculo.getMarca()
                        ),
                        escaparJson(
                                veiculo.getModelo()
                        ),
                        escaparJson(
                                veiculo.getCor()
                        )
                );
    }


    // =========================================
    // AUXILIARES
    // =========================================

    private void prepararResposta(
            HttpServletResponse response
    ) {

        response.setContentType(
                "application/json;charset=UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );
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


    private void responderErro(
            HttpServletResponse response,
            int status,
            String mensagem
    ) throws IOException {

        response.setStatus(
                status
        );

        response
            .getWriter()
            .print(
                """
                {
                    "sucesso": false,
                    "mensagem": "%s"
                }
                """.formatted(
                        escaparJson(
                                mensagem
                        )
                )
            );
    }


    private String escaparJson(
            String valor
    ) {

        if (valor == null) {
            return "";
        }

        return valor
                .replace(
                    "\\",
                    "\\\\"
                )
                .replace(
                    "\"",
                    "\\\""
                )
                .replace(
                    "\n",
                    "\\n"
                )
                .replace(
                    "\r",
                    "\\r"
                );
    }
}