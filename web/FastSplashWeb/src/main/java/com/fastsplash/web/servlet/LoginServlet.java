package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.ColaboradorDAO;
import com.fastsplash.web.model.Colaborador;
import com.fastsplash.web.util.SenhaUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final ColaboradorDAO colaboradorDAO =
            new ColaboradorDAO();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.getRequestDispatcher(
                "/login.jsp"
        ).forward(
                request,
                response
        );
    }


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding(
                "UTF-8"
        );


        String email =
                request.getParameter(
                        "email"
                );


        String senha =
                request.getParameter(
                        "senha"
                );


        if (email == null
                || email.isBlank()
                || senha == null
                || senha.isBlank()) {

            request.setAttribute(
                    "erro",
                    "Informe o e-mail e a senha."
            );


            request.getRequestDispatcher(
                    "/login.jsp"
            ).forward(
                    request,
                    response
            );


            return;
        }


        try {

            Colaborador colaborador =
                    colaboradorDAO.buscarPorEmail(
                            email.trim()
                    );


            if (colaborador == null) {

                loginInvalido(
                        request,
                        response
                );

                return;
            }


            // OPERACIONAL NÃO PODE ENTRAR NO SISTEMA

            if (
                "OPERACIONAL".equals(
                        colaborador.getNivelAcesso()
                )
            ) {

                request.setAttribute(
                        "erro",
                        "Este funcionário não possui acesso ao sistema."
                );


                request.getRequestDispatcher(
                        "/login.jsp"
                ).forward(
                        request,
                        response
                );


                return;
            }


            boolean senhaCorreta =
                    SenhaUtil.verificarSenha(
                            senha,
                            colaborador.getSenhaHash()
                    );


            if (!senhaCorreta) {

                loginInvalido(
                        request,
                        response
                );

                return;
            }


            /*
             * Se for uma senha antiga HASH_,
             * atualizamos automaticamente para PBKDF2.
             */

            if (
                SenhaUtil.hashAntigo(
                        colaborador.getSenhaHash()
                )
            ) {

                String novoHash =
                        SenhaUtil.gerarHash(
                                senha
                        );


                colaboradorDAO.atualizarSenhaHash(
                        colaborador.getIdColaborador(),
                        novoHash
                );


                colaborador.setSenhaHash(
                        novoHash
                );
            }


            HttpSession sessao =
                    request.getSession();


            sessao.setAttribute(
                    "usuarioLogado",
                    colaborador
            );


            sessao.setAttribute(
                    "nomeUsuario",
                    colaborador.getNome()
            );


            sessao.setAttribute(
                    "nivelAcesso",
                    colaborador.getNivelAcesso()
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/dashboard.jsp"
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao realizar login.",
                    e
            );
        }
    }


    private void loginInvalido(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setAttribute(
                "erro",
                "E-mail ou senha inválidos."
        );


        request.getRequestDispatcher(
                "/login.jsp"
        ).forward(
                request,
                response
        );
    }
}