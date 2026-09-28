package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/api/auth/login")
public class LoginClienteApiServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final ClienteDAO clienteDAO =
            new ClienteDAO();


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding(
                "UTF-8"
        );


        response.setContentType(
                "application/json;charset=UTF-8"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );


        String email =
                limpar(
                        request.getParameter(
                                "email"
                        )
                );


        String senha =
                limpar(
                        request.getParameter(
                                "senha"
                        )
                );


        if (email == null
                || senha == null) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Informe o e-mail e a senha."
            );

            return;
        }


        try {

            Cliente cliente =
                    clienteDAO.buscarPorEmail(
                            email
                    );


            if (cliente == null) {

                loginInvalido(
                        response
                );

                return;
            }


            boolean senhaCorreta =
                    SenhaUtil.verificarSenha(
                            senha,
                            cliente.getSenhaHash()
                    );


            if (!senhaCorreta) {

                loginInvalido(
                        response
                );

                return;
            }


            // =================================
            // MIGRAR HASH ANTIGO
            // =================================

            if (
                SenhaUtil.hashAntigo(
                        cliente.getSenhaHash()
                )
            ) {

                String novoHash =
                        SenhaUtil.gerarHash(
                                senha
                        );


                clienteDAO.atualizarSenhaHash(
                        cliente.getIdCliente(),
                        novoHash
                );


                cliente.setSenhaHash(
                        novoHash
                );
            }


            // =================================
            // CRIAR SESSÃO DO CLIENTE
            // =================================

            HttpSession sessao =
                    request.getSession(true);


            sessao.setAttribute(
                    "clienteLogado",
                    cliente
            );


            response.setStatus(
                    HttpServletResponse.SC_OK
            );


            response.getWriter().print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Login realizado com sucesso.",
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
                            escaparJson(
                                    cliente.getNome()
                            ),
                            escaparJson(
                                    cliente.getCpf()
                            ),
                            escaparJson(
                                    cliente.getTelefone()
                            ),
                            escaparJson(
                                    cliente.getEmail()
                            )
                    )
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao realizar login do cliente.",
                    e
            );
        }
    }


    private void loginInvalido(
            HttpServletResponse response
    ) throws IOException {

        responderErro(
                response,
                HttpServletResponse.SC_UNAUTHORIZED,
                "E-mail ou senha inválidos."
        );
    }


    private void responderErro(
            HttpServletResponse response,
            int status,
            String mensagem
    ) throws IOException {

        response.setStatus(
                status
        );


        response.getWriter().print(
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