package com.fastsplash.web.api;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import com.fastsplash.web.dao.AgendamentoDAO;
import com.fastsplash.web.dao.ServicoDAO;
import com.fastsplash.web.dao.VeiculoDAO;
import com.fastsplash.web.model.Agendamento;
import com.fastsplash.web.model.AgendamentoCliente;
import com.fastsplash.web.model.Cliente;
import com.fastsplash.web.model.Servico;
import com.fastsplash.web.model.Veiculo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(
    urlPatterns = {
        "/api/agendamentos",
        "/api/agendamentos/cancelar"
    }
)
public class AgendamentoApiServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AgendamentoDAO agendamentoDAO =
            new AgendamentoDAO();

    private final VeiculoDAO veiculoDAO =
            new VeiculoDAO();

    private final ServicoDAO servicoDAO =
            new ServicoDAO();


    // =========================================
    // GET - AGENDAMENTOS DO CLIENTE
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

            List<AgendamentoCliente> lista =
                    agendamentoDAO
                        .listarPorCliente(
                            cliente.getIdCliente()
                        );


            StringBuilder json =
                    new StringBuilder();


            json.append("""
                    {
                        "sucesso": true,
                        "agendamentos": [
                    """);


            for (
                int i = 0;
                i < lista.size();
                i++
            ) {

                json.append(
                    agendamentoParaJson(
                        lista.get(i)
                    )
                );


                if (i < lista.size() - 1) {
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
                    "Erro ao carregar agendamentos.",
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
            "/api/agendamentos/cancelar"
                .equals(caminho)
        ) {

            cancelar(
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


        String dataTexto =
                request.getParameter(
                        "data"
                );


        String horarioTexto =
                request.getParameter(
                        "horario"
                );


        String[] idsServicosTexto =
                request.getParameterValues(
                        "idServico"
                );


        if (
            dataTexto == null ||
            horarioTexto == null ||
            idsServicosTexto == null ||
            idsServicosTexto.length == 0
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Preencha todos os campos."
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


            LocalDate data =
                    LocalDate.parse(
                            dataTexto
                    );


            LocalTime horario =
                    LocalTime.parse(
                            horarioTexto
                    );


            List<Integer> idsServicos =
                    new ArrayList<>();


            double valorTotal = 0;


            for (
                String idTexto :
                idsServicosTexto
            ) {

                int idServico =
                        Integer.parseInt(
                                idTexto
                        );


                Servico servico =
                        servicoDAO.buscarPorId(
                                idServico
                        );


                if (servico == null) {

                    responderErro(
                            response,
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Serviço inválido."
                    );

                    return;
                }


                idsServicos.add(
                        idServico
                );


                valorTotal +=
                        servico.getPreco();
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

            agendamento.setStatus(
                    "AGENDADO"
            );

            agendamento.setIdsServicos(
                    idsServicos
            );


            agendamentoDAO.inserir(
                    agendamento
            );


            response.setStatus(
                    HttpServletResponse.SC_CREATED
            );


            response
                .getWriter()
                .print(
                    String.format(
                        Locale.US,
                        """
                        {
                            "sucesso": true,
                            "mensagem": "Agendamento confirmado com sucesso.",
                            "agendamento": {
                                "idAgendamento": %d,
                                "idVeiculo": %d,
                                "data": "%s",
                                "horario": "%s",
                                "status": "AGENDADO",
                                "valorTotal": %.2f
                            }
                        }
                        """,
                        agendamento
                            .getIdAgendamento(),
                        idVeiculo,
                        data,
                        horario,
                        valorTotal
                    )
                );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "Este veículo já possui um agendamento neste dia e horário."
            );


        } catch (
            NumberFormatException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Serviço inválido."
            );


        } catch (
            java.time.format
                .DateTimeParseException e
        ) {

            responderErro(
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Data ou horário inválido."
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao realizar agendamento.",
                    e
            );
        }
    }


    // =========================================
    // CANCELAR
    // =========================================

    private void cancelar(
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
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Agendamento inválido."
            );

            return;
        }


        try {

            boolean cancelado =
                    agendamentoDAO
                        .cancelarDoCliente(
                            idAgendamento,
                            cliente
                                .getIdCliente()
                        );


            if (!cancelado) {

                responderErro(
                        response,
                        HttpServletResponse.SC_CONFLICT,
                        "Este agendamento não pode mais ser cancelado."
                );

                return;
            }


            response
                .getWriter()
                .print(
                    """
                    {
                        "sucesso": true,
                        "mensagem": "Agendamento cancelado com sucesso."
                    }
                    """
                );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cancelar agendamento.",
                    e
            );
        }
    }


    // =========================================
    // JSON
    // =========================================

    private String agendamentoParaJson(
            AgendamentoCliente item
    ) {

        String status =
                statusParaFlutter(
                        item
                );


        StringBuilder servicos =
                new StringBuilder();


        servicos.append("[");


        for (
            int i = 0;
            i < item.getServicos().size();
            i++
        ) {

            Servico servico =
                    item.getServicos()
                        .get(i);


            servicos.append(
                String.format(
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
                )
            );


            if (
                i <
                item.getServicos().size() - 1
            ) {

                servicos.append(",");
            }
        }


        servicos.append("]");


        DateTimeFormatter horarioFormatado =
                DateTimeFormatter
                    .ofPattern(
                        "HH:mm"
                    );


        return String.format(
            Locale.US,
            """
            {
                "idAgendamento": %d,

                "veiculo": {
                    "idVeiculo": %d,
                    "marca": "%s",
                    "modelo": "%s",
                    "placa": "%s",
                    "cor": "%s"
                },

                "servicos": %s,

                "data": "%s",
                "horario": "%s",
                "status": "%s",
                "valorTotal": %.2f,
                "pago": false
            }
            """,
            item.getIdAgendamento(),
            item.getIdVeiculo(),
            escaparJson(item.getMarca()),
            escaparJson(item.getModelo()),
            escaparJson(item.getPlaca()),
            escaparJson(item.getCor()),
            servicos.toString(),
            item.getData(),
            item.getHorario()
                .format(
                    horarioFormatado
                ),
            status,
            item.getValorTotal()
        );
    }


    private String statusParaFlutter(
            AgendamentoCliente item
    ) {

        if (
            "CANCELADO".equals(
                item.getStatusAgendamento()
            )
        ) {
            return "Cancelado";
        }


        if (
            "FINALIZADO".equals(
                item.getStatusAtendimento()
            )
            ||
            "CONCLUIDO".equals(
                item.getStatusAgendamento()
            )
        ) {
            return "Finalizado";
        }


        if (
            "EM_LAVAGEM".equals(
                item.getStatusAtendimento()
            )
        ) {
            return "Em andamento";
        }


        return "Agendado";
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


    private void responderErro(
            HttpServletResponse response,
            int status,
            String mensagem
    ) throws IOException {

        response.setStatus(status);


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