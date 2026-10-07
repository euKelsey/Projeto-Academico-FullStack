package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.util.SenhaUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/clientes")
public class ClienteApiServlet extends HttpServlet {

        private static final long serialVersionUID = 1L;

        private final ClienteDAO clienteDAO = new ClienteDAO();

        @Override
        protected void doPost(
                        HttpServletRequest request,
                        HttpServletResponse response) throws ServletException, IOException {

                request.setCharacterEncoding("UTF-8");

                response.setContentType(
                                "application/json;charset=UTF-8");

                response.setCharacterEncoding("UTF-8");

                String nome = limpar(
                                request.getParameter("nome"));

                String telefone = limpar(
                                request.getParameter("telefone"));

                if (telefone != null) {

                        telefone = telefone.replaceAll(
                                        "\\D",
                                        "");
                }

                String email = limpar(
                                request.getParameter("email"));

                String cpf = limpar(
                                request.getParameter("cpf"));

                String senha = limpar(
                                request.getParameter("senha"));

                String confirmarSenha = limpar(
                                request.getParameter(
                                                "confirmarSenha"));

                // =====================================
                // CAMPOS OBRIGATÓRIOS
                // =====================================

                if (nome == null
                                || telefone == null
                                || email == null
                                || cpf == null
                                || senha == null
                                || confirmarSenha == null) {

                        responderErro(
                                        response,
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "Preencha todos os campos.");

                        return;
                }

                // =====================================
                // CONFIRMAÇÃO DE SENHA
                // =====================================

                if (!senha.equals(confirmarSenha)) {

                        responderErro(
                                        response,
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "As senhas não coincidem.");

                        return;
                }

                // =====================================
                // CPF
                // =====================================

                cpf = cpf.replaceAll(
                                "\\D",
                                "");

                if (cpf.length() != 11) {

                        responderErro(
                                        response,
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "O CPF deve possuir 11 dígitos.");

                        return;
                }

                // =====================================
                // E-MAIL
                // =====================================

                if (!email.contains("@")) {

                        responderErro(
                                        response,
                                        HttpServletResponse.SC_BAD_REQUEST,
                                        "Informe um e-mail válido.");

                        return;
                }

                // =====================================
                // CRIAR CLIENTE
                // =====================================

                Cliente cliente = new Cliente();

                cliente.setNome(
                                nome);

                cliente.setTelefone(
                                telefone);

                cliente.setEmail(
                                email);

                cliente.setCpf(
                                cpf);

                cliente.setSenhaHash(
                                SenhaUtil.gerarHash(
                                                senha));

                try {

                        clienteDAO.inserir(
                                        cliente);

                        response.setStatus(
                                        HttpServletResponse.SC_CREATED);

                        response.getWriter().print(
                                        """
                                                        {
                                                            "sucesso": true,
                                                            "mensagem": "Cadastro realizado com sucesso.",
                                                            "idCliente": %d,
                                                            "nome": "%s",
                                                            "email": "%s"
                                                        }
                                                        """.formatted(
                                                        cliente.getIdCliente(),
                                                        escaparJson(
                                                                        cliente.getNome()),
                                                        escaparJson(
                                                                        cliente.getEmail())));

                } catch (SQLIntegrityConstraintViolationException e) {

                        responderErro(
                                        response,
                                        HttpServletResponse.SC_CONFLICT,
                                        "Já existe um cliente com este CPF ou e-mail.");

                } catch (SQLException e) {

                        throw new ServletException(
                                        "Erro ao cadastrar cliente.",
                                        e);
                }
        }

        private String limpar(
                        String valor) {

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
                        String mensagem) throws IOException {

                response.setStatus(
                                status);

                response.getWriter().print(
                                """
                                                {
                                                    "sucesso": false,
                                                    "mensagem": "%s"
                                                }
                                                """.formatted(
                                                escaparJson(
                                                                mensagem)));
        }

        private String escaparJson(
                        String valor) {

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