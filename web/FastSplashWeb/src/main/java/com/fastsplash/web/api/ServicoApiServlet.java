package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;

import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Servico;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/api/servicos")
public class ServicoApiServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ServicoDAO servicoDAO =
            new ServicoDAO();


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        prepararResposta(
                response
        );


        Cliente cliente =
                obterClienteLogado(
                        request,
                        response
                );


        if (cliente == null) {
            return;
        }


        try {

            List<Servico> servicos =
                    servicoDAO.listarTodos();


            StringBuilder json =
                    new StringBuilder();


            json.append("""
                    {
                        "sucesso": true,
                        "servicos": [
                    """);


            for (
                int i = 0;
                i < servicos.size();
                i++
            ) {

                Servico servico =
                        servicos.get(i);


                json.append(
                        servicoParaJson(
                                servico
                        )
                );


                if (
                    i < servicos.size() - 1
                ) {

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
                    "Erro ao listar serviços.",
                    e
            );
        }
    }


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


    private String servicoParaJson(
            Servico servico
    ) {

        return String.format(
                Locale.US,
                """
                {
                    "idServico": %d,
                    "nome": "%s",
                    "descricao": "%s",
                    "preco": %.2f
                }
                """,
                servico.getIdServico(),
                escaparJson(
                        servico.getNome()
                ),
                escaparJson(
                        servico.getDescricao()
                ),
                servico.getPreco()
        );
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
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}