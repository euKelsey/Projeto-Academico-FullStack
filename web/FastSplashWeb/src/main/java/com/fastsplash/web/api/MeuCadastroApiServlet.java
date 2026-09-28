package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.model.Cliente;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/api/clientes/me")
public class MeuCadastroApiServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ClienteDAO clienteDAO =
            new ClienteDAO();


    // =========================================
    // GET - BUSCAR DADOS DO CLIENTE LOGADO
    // =========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        prepararResposta(response);

        Cliente clienteSessao =
                obterClienteLogado(
                        request,
                        response
                );

        if (clienteSessao == null) {
            return;
        }


        try {

            Cliente cliente =
                    clienteDAO.buscarPorId(
                            clienteSessao.getIdCliente()
                    );


            if (cliente == null) {

                responderErro(
                        response,
                        HttpServletResponse.SC_NOT_FOUND,
                        "Cliente não encontrado."
                );

                return;
            }


            response.getWriter().print(
                    """
                    {
                        "sucesso": true,
                        "cliente": {
                            "idCliente": %d,
                            "nome": "%s",
                            "cpf": "%s",
                            "telefone": "%s",
                            "email": "%s"
                        }
                    }
                    """.formatted(
                            cliente.getIdCliente(),
                            escaparJson(cliente.getNome()),
                            escaparJson(cliente.getCpf()),
                            escaparJson(cliente.getTelefone()),
                            escaparJson(cliente.getEmail())
                    )
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao buscar cadastro do cliente.",
                    e
            );
        }
    }


    // =========================================
    // POST - ATUALIZAR DADOS
    // =========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        prepararResposta(response);


        Cliente clienteSessao =
                obterClienteLogado(
                        request,
                        response
                );

        if (clienteSessao == null) {
            return;
        }


        String nome =
                limpar(
                        request.getParameter("nome")
                );

        String telefone =
                limpar(
                        request.getParameter("telefone")
                );

        String email =
                limpar(
                        request.getParameter("email")
                );


        if (nome == null
                || telefone == null
                || email == null) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Preencha todos os campos."
            );

            return;
        }


        if (!email.contains("@")) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Informe um e-mail válido."
            );

            return;
        }


        try {

            Cliente cliente =
                    clienteDAO.buscarPorId(
                            clienteSessao.getIdCliente()
                    );


            if (cliente == null) {

                responderErro(
                        response,
                        HttpServletResponse.SC_NOT_FOUND,
                        "Cliente não encontrado."
                );

                return;
            }


            cliente.setNome(nome);
            cliente.setTelefone(telefone);
            cliente.setEmail(email);


            clienteDAO.atualizar(
                    cliente
            );


            // Atualiza também o objeto guardado na sessão.
            HttpSession sessao =
                    request.getSession(false);

            sessao.setAttribute(
                    "clienteLogado",
                    cliente
            );


            response.getWriter().print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Cadastro atualizado com sucesso.",
                        "cliente": {
                            "idCliente": %d,
                            "nome": "%s",
                            "cpf": "%s",
                            "telefone": "%s",
                            "email": "%s"
                        }
                    }
                    """.formatted(
                            cliente.getIdCliente(),
                            escaparJson(cliente.getNome()),
                            escaparJson(cliente.getCpf()),
                            escaparJson(cliente.getTelefone()),
                            escaparJson(cliente.getEmail())
                    )
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "Este e-mail já está sendo utilizado."
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao atualizar cadastro do cliente.",
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

        valor = valor.trim();

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

        response.setStatus(status);

        response.getWriter().print(
                """
                {
                    "sucesso": false,
                    "mensagem": "%s"
                }
                """.formatted(
                        escaparJson(mensagem)
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
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}