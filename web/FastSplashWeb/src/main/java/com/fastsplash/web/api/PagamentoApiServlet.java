package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

import com.fastsplash.web.dao.PagamentoDAO;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Pagamento;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
    urlPatterns = {
        "/api/pagamentos",
        "/api/pagamentos/pagar"
    }
)
public class PagamentoApiServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PagamentoDAO pagamentoDAO =
            new PagamentoDAO();


    // =========================================
    // GET
    // =========================================

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

            List<Pagamento> pagamentos =
                    pagamentoDAO.listarPorCliente(
                            cliente.getIdCliente()
                    );


            StringBuilder json =
                    new StringBuilder();


            json.append(
                    """
                    {
                        "sucesso": true,
                        "pagamentos": [
                    """
            );


            for (
                int i = 0;
                i < pagamentos.size();
                i++
            ) {

                json.append(
                        pagamentoParaJson(
                                pagamentos.get(i)
                        )
                );


                if (
                    i <
                    pagamentos.size() - 1
                ) {

                    json.append(",");
                }
            }


            json.append(
                    """
                        ]
                    }
                    """
            );


            response
                .getWriter()
                .print(
                    json.toString()
                );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao carregar pagamentos.",
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


        String caminho =
                request.getServletPath();


        if (
            "/api/pagamentos/pagar"
                .equals(caminho)
        ) {

            pagar(
                    request,
                    response,
                    cliente
            );

            return;
        }


        responderErro(
                response,
                HttpServletResponse
                    .SC_NOT_FOUND,
                "Rota não encontrada."
        );
    }


    // =========================================
    // PAGAR
    // =========================================

    private void pagar(
            HttpServletRequest request,
            HttpServletResponse response,
            Cliente cliente
    ) throws ServletException, IOException {

        int idAgendamento;


        try {

            idAgendamento =
                    Integer.parseInt(
                        request.getParameter(
                                "idAgendamento"
                        )
                    );

        } catch (
            NumberFormatException |
            NullPointerException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse
                        .SC_BAD_REQUEST,
                    "Agendamento inválido."
            );

            return;
        }


        String formaPagamento =
                request.getParameter(
                        "formaPagamento"
                );


        if (
            formaPagamento == null
            ||
            !formaPagamentoValida(
                    formaPagamento
            )
        ) {

            responderErro(
                    response,
                    HttpServletResponse
                        .SC_BAD_REQUEST,
                    "Forma de pagamento inválida."
            );

            return;
        }


        try {

            boolean realizado =
                    pagamentoDAO
                        .realizarPagamento(
                            idAgendamento,
                            cliente
                                .getIdCliente(),
                            formaPagamento
                        );


            if (!realizado) {

                responderErro(
                        response,
                        HttpServletResponse
                            .SC_NOT_FOUND,
                        "Agendamento não encontrado ou cancelado."
                );

                return;
            }


            response
                .getWriter()
                .print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Pagamento realizado com sucesso."
                    }
                    """
                );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao realizar pagamento.",
                    e
            );
        }
    }


    private boolean formaPagamentoValida(
            String forma
    ) {

        return
            "PIX".equals(forma)
            ||
            "DINHEIRO".equals(forma)
            ||
            "CREDITO".equals(forma)
            ||
            "DEBITO".equals(forma);
    }


    // =========================================
    // JSON
    // =========================================

    private String pagamentoParaJson(
            Pagamento pagamento
    ) {

        String dataPagamento = "";


        if (
            pagamento.getDataPagamento()
            != null
        ) {

            dataPagamento =
                    pagamento
                        .getDataPagamento()
                        .format(
                            DateTimeFormatter
                                .ofPattern(
                                    "dd/MM/yyyy HH:mm"
                                )
                        );
        }


        return String.format(
            Locale.US,
            """
            {
                "idPagamento": %d,
                "idAgendamento": %d,
                "valor": %.2f,
                "formaPagamento": "%s",
                "statusPagamento": "%s",
                "dataPagamento": "%s",
                "veiculo": "%s",
                "servicos": "%s"
            }
            """,
            pagamento.getIdPagamento(),
            pagamento.getIdAgendamento(),
            pagamento.getValor(),
            escaparJson(
                pagamento
                    .getFormaPagamento()
            ),
            escaparJson(
                pagamento
                    .getStatusPagamento()
            ),
            escaparJson(
                dataPagamento
            ),
            escaparJson(
                pagamento
                    .getVeiculoDescricao()
            ),
            escaparJson(
                pagamento
                    .getServicosDescricao()
            )
        );
    }


    // =========================================
    // SESSÃO
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
                    HttpServletResponse
                        .SC_UNAUTHORIZED,
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
                    HttpServletResponse
                        .SC_UNAUTHORIZED,
                    "Cliente não autenticado."
            );

            return null;
        }


        return cliente;
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