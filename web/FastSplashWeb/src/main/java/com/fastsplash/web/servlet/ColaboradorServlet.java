package com.fastsplash.web.servlet;

import com.fastsplash.web.util.SenhaUtil;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.fastsplash.web.dao.ColaboradorDAO;
import com.fastsplash.web.dao.ResultadoStatusColaborador;
import com.fastsplash.web.model.Colaborador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/colaborador")
public class ColaboradorServlet
        extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final ColaboradorDAO colaboradorDAO =
            new ColaboradorDAO();


    // =========================================
    // GET
    // =========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        if (!usuarioAdministrador(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Acesso restrito a administradores.");
            return;
        }



        String acao =
                request.getParameter("acao");


        // =====================================
        // NOVO
        // =====================================

        if ("novo".equals(acao)) {

            request.getRequestDispatcher(
                    "/cadastro-colaborador.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }


        // =====================================
        // EDITAR
        // =====================================

        if ("editar".equals(acao)) {

            String parametroId =
                    request.getParameter(
                            "idColaborador"
                    );


            if (parametroId == null
                    || parametroId.isBlank()) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "ID do colaborador não informado."
                );

                return;
            }


            try {

                int idColaborador =
                        Integer.parseInt(
                                parametroId
                        );


                Colaborador colaborador =
                        colaboradorDAO.buscarPorId(
                                idColaborador
                        );


                if (colaborador == null
                    || !colaborador.isAtivo()
                    || colaborador.isExcluido()) {

                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Colaborador não encontrado."
                    );

                    return;
                }


                request.setAttribute(
                        "colaborador",
                        colaborador
                );


                request.getRequestDispatcher(
                        "/editar-colaborador.jsp"
                ).forward(
                        request,
                        response
                );


            } catch (NumberFormatException e) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "ID do colaborador inválido."
                );


            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao buscar colaborador.",
                        e
                );
            }


            return;
        }


        // =====================================
        // LISTAR
        // =====================================

        try {

            request.setAttribute(
                    "colaboradores",
                    colaboradorDAO.listarPorStatus(
                            normalizarFiltro(
                                request.getParameter("filtro")))
            );


            request.getRequestDispatcher(
                    "/lista-colaboradores.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar colaboradores.",
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

        if (!usuarioAdministrador(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Acesso restrito a administradores.");
            return;
        }



        request.setCharacterEncoding("UTF-8");


        String acao =
                request.getParameter("acao");


        // =====================================
        // EXCLUIR
        // =====================================

        if ("inativar".equals(acao)
                || "reativar".equals(acao)
                || "excluir".equals(acao)
                || "restaurar".equals(acao)) {

            processarStatus(request, response, acao);
            return;
        }


        // =====================================
        // ATUALIZAR
        // =====================================

        if ("atualizar".equals(acao)) {

            atualizar(
                    request,
                    response
            );

            return;
        }


        // =====================================
        // CADASTRAR
        // =====================================

        cadastrar(
                request,
                response
        );
    }


    // =========================================
    // CADASTRAR
    // =========================================

    private void cadastrar(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String nome =
                limpar(
                        request.getParameter(
                                "nome"
                        )
                );


        String cargo =
                limpar(
                        request.getParameter(
                                "cargo"
                        )
                );


        String nivelAcesso =
                limpar(
                        request.getParameter(
                                "nivelAcesso"
                        )
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


        String erro =
                validarCadastro(
                        nome,
                        cargo,
                        nivelAcesso,
                        email,
                        senha
                );


        if (erro != null) {

            request.setAttribute(
                    "erro",
                    erro
            );


            request.getRequestDispatcher(
                    "/cadastro-colaborador.jsp"
            ).forward(
                    request,
                    response
            );


            return;
        }


        Colaborador colaborador =
                new Colaborador();


        colaborador.setNome(
                nome
        );


        colaborador.setCargo(
                cargo
        );


        colaborador.setNivelAcesso(
                nivelAcesso
        );


        colaborador.setEmail(
                email
        );


        if (senha != null) {

        	colaborador.setSenhaHash(
        	        SenhaUtil.gerarHash(
        	                senha
        	        )
        	);

        } else {

            colaborador.setSenhaHash(
                    null
            );
        }


        try {

            colaboradorDAO.inserir(
                    colaborador
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/colaborador"
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            request.setAttribute(
                    "erro",
                    "Já existe um colaborador com este e-mail."
            );


            request.getRequestDispatcher(
                    "/cadastro-colaborador.jsp"
            ).forward(
                    request,
                    response
            );


        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar colaborador.",
                    e
            );
        }
    }


    // =========================================
    // ATUALIZAR
    // =========================================

    private void atualizar(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String parametroId =
                request.getParameter(
                        "idColaborador"
                );


        if (parametroId == null
                || parametroId.isBlank()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID do colaborador não informado."
            );

            return;
        }


        try {

            int idColaborador =
                    Integer.parseInt(
                            parametroId
                    );


            Colaborador colaborador =
                    colaboradorDAO.buscarPorId(
                            idColaborador
                    );


            if (colaborador == null
                    || !colaborador.isAtivo()
                    || colaborador.isExcluido()) {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Colaborador não encontrado."
                );

                return;
            }


            String nome =
                    limpar(
                            request.getParameter(
                                    "nome"
                            )
                    );


            String cargo =
                    limpar(
                            request.getParameter(
                                    "cargo"
                            )
                    );


            String nivelAcesso =
                    limpar(
                            request.getParameter(
                                    "nivelAcesso"
                            )
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


            String erro =
                    validarEdicao(
                            nome,
                            cargo,
                            nivelAcesso,
                            email,
                            senha,
                            colaborador
                    );


            if (erro != null) {

                colaborador.setNome(
                        nome
                );

                colaborador.setCargo(
                        cargo
                );

                colaborador.setNivelAcesso(
                        nivelAcesso
                );

                colaborador.setEmail(
                        email
                );


                request.setAttribute(
                        "colaborador",
                        colaborador
                );


                request.setAttribute(
                        "erro",
                        erro
                );


                request.getRequestDispatcher(
                        "/editar-colaborador.jsp"
                ).forward(
                        request,
                        response
                );


                return;
            }


            colaborador.setNome(
                    nome
            );

            colaborador.setCargo(
                    cargo
            );

            colaborador.setNivelAcesso(
                    nivelAcesso
            );

            colaborador.setEmail(
                    email
            );


            boolean alterarSenha =
                    senha != null;


            if (alterarSenha) {

            	colaborador.setSenhaHash(
            	        SenhaUtil.gerarHash(
            	                senha
            	        )
            	);
            }


            colaboradorDAO.atualizar(
                    colaborador,
                    alterarSenha
            );


            response.sendRedirect(
                    request.getContextPath()
                    + "/colaborador"
            );


        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID do colaborador inválido."
            );


        } catch (
            SQLIntegrityConstraintViolationException e
        ) {

            throw new ServletException(
                    "Já existe outro colaborador com este e-mail.",
                    e
            );


        } catch (SQLException e) {

            if ("Nao e permitido alterar o nivel do ultimo administrador."
                    .equals(e.getMessage())) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/colaborador?erro=ultimoAdministrador");
                return;
            }

            if ("Colaborador indisponivel para edicao."
                    .equals(e.getMessage())) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/colaborador?erro=operacaoInvalida");
                return;
            }

            throw new ServletException(
                    "Erro ao atualizar colaborador.", e);
        }
    }


    // =========================================
    // EXCLUIR
    // =========================================


    private boolean usuarioAdministrador(
            HttpServletRequest request
    ) {

        HttpSession sessao = request.getSession(false);

        if (sessao == null) {
            return false;
        }

        Object usuario = sessao.getAttribute("usuarioLogado");

        return usuario instanceof Colaborador colaborador
                && "ADMINISTRADOR".equals(
                        colaborador.getNivelAcesso())
                && colaborador.isAtivo()
                && !colaborador.isExcluido();
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
                    HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Colaborador usuarioLogado =
                (Colaborador) request.getSession(false)
                        .getAttribute("usuarioLogado");

        int idUsuarioLogado =
                usuarioLogado.getIdColaborador();

        int idColaborador;

        try {

            idColaborador = Integer.parseInt(
                    request.getParameter("idColaborador"));

            if (idColaborador <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID do colaborador inválido.");
            return;
        }

        String filtro = normalizarFiltro(
                request.getParameter("filtro"));

        try {

            ResultadoStatusColaborador resultado =
                    switch (acao) {

                case "inativar" ->
                    colaboradorDAO.inativarColaborador(
                            idColaborador, idUsuarioLogado);

                case "reativar" ->
                    colaboradorDAO.reativarColaborador(
                            idColaborador, idUsuarioLogado);

                case "excluir" ->
                    colaboradorDAO.excluirLogicamente(
                            idColaborador, idUsuarioLogado);

                case "restaurar" ->
                    colaboradorDAO.restaurarColaborador(
                            idColaborador, idUsuarioLogado);

                default ->
                    throw new SQLException("Acao invalida.");
            };

            String mensagem;

            if (resultado == ResultadoStatusColaborador.SUCESSO) {

                mensagem = "status=" + switch (acao) {

                    case "inativar" -> "inativado";
                    case "reativar" -> "reativado";
                    case "excluir" -> "excluido";
                    case "restaurar" -> "restaurado";
                    default -> "sucesso";
                };

            } else {

                mensagem = "erro=" + switch (resultado) {

                    case ULTIMO_ADMINISTRADOR ->
                        "ultimoAdministrador";

                    case PROPRIO_USUARIO ->
                        "proprioUsuario";

                    case POSSUI_PENDENCIAS ->
                        "pendencias";

                    case COLABORADOR_NAO_ENCONTRADO ->
                        "naoEncontrado";

                    case JA_ATIVO ->
                        "jaAtivo";

                    case JA_INATIVO ->
                        "jaInativo";

                    case JA_EXCLUIDO ->
                        "jaExcluido";

                    case NAO_EXCLUIDO ->
                        "naoExcluido";

                    default ->
                        "operacaoInvalida";
                };
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/colaborador?filtro=" + filtro
                    + "&" + mensagem);

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao alterar status do colaborador.", e);
        }
    }

    private String validarCadastro(
            String nome,
            String cargo,
            String nivelAcesso,
            String email,
            String senha
    ) {

        if (nome == null) {

            return "Informe o nome.";
        }


        if (cargo == null) {

            return "Informe o cargo.";
        }


        if (!nivelValido(nivelAcesso)) {

            return "Nível de acesso inválido.";
        }


        if (possuiAcessoAoSistema(
                nivelAcesso
        )) {

            if (email == null) {

                return "E-mail é obrigatório para ADMINISTRADOR e ATENDENTE.";
            }


            if (senha == null) {

                return "Senha é obrigatória para ADMINISTRADOR e ATENDENTE.";
            }
        }


        return null;
    }


    // =========================================
    // VALIDAÇÃO DA EDIÇÃO
    // =========================================

    private String validarEdicao(
            String nome,
            String cargo,
            String nivelAcesso,
            String email,
            String novaSenha,
            Colaborador atual
    ) {

        if (nome == null) {

            return "Informe o nome.";
        }


        if (cargo == null) {

            return "Informe o cargo.";
        }


        if (!nivelValido(nivelAcesso)) {

            return "Nível de acesso inválido.";
        }


        if (possuiAcessoAoSistema(
                nivelAcesso
        )) {

            if (email == null) {

                return "E-mail é obrigatório para ADMINISTRADOR e ATENDENTE.";
            }


            boolean possuiSenhaAtual =
                    atual.getSenhaHash() != null
                    && !atual.getSenhaHash()
                            .isBlank();


            if (!possuiSenhaAtual
                    && novaSenha == null) {

                return "Informe uma senha para permitir acesso ao sistema.";
            }
        }


        return null;
    }


    // =========================================
    // NÍVEL COM LOGIN
    // =========================================

    private boolean possuiAcessoAoSistema(
            String nivelAcesso
    ) {

        return "ADMINISTRADOR".equals(
                    nivelAcesso
               )
               ||
               "ATENDENTE".equals(
                    nivelAcesso
               );
    }


    // =========================================
    // VALIDAR ENUM
    // =========================================

    private boolean nivelValido(
            String nivelAcesso
    ) {

        return "ADMINISTRADOR".equals(
                    nivelAcesso
               )
               ||
               "ATENDENTE".equals(
                    nivelAcesso
               )
               ||
               "OPERACIONAL".equals(
                    nivelAcesso
               );
    }


    // =========================================
    // CONVERTER VAZIO PARA NULL
    // =========================================

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
}
