package com.fastsplash.web.filter;

import java.io.IOException;

import com.fastsplash.web.model.Colaborador;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class AccessFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain
    ) throws IOException, ServletException {

        HttpServletRequest httpRequest =
                (HttpServletRequest) request;

        HttpServletResponse httpResponse =
                (HttpServletResponse) response;


        String contexto =
                httpRequest.getContextPath();

        String uri =
                httpRequest.getRequestURI();

        String caminho =
                uri.substring(
                        contexto.length()
                );


        // =========================================
        // ROTAS PÚBLICAS
        // =========================================

        if (rotaPublica(caminho)) {

            chain.doFilter(
                    request,
                    response
            );

            return;
        }


        // =========================================
        // VERIFICAR SESSÃO
        // =========================================

        HttpSession sessao =
                httpRequest.getSession(false);


        if (sessao == null) {

            httpResponse.sendRedirect(
                    contexto + "/login"
            );

            return;
        }


        Colaborador usuarioLogado =
                (Colaborador)
                    sessao.getAttribute(
                            "usuarioLogado"
                    );


        if (usuarioLogado == null) {

            httpResponse.sendRedirect(
                    contexto + "/login"
            );

            return;
        }


        String nivelAcesso =
                usuarioLogado.getNivelAcesso();


        // =========================================
        // OPERACIONAL NÃO DEVE ACESSAR O SISTEMA
        // =========================================

        if ("OPERACIONAL".equals(
                nivelAcesso
        )) {

            sessao.invalidate();

            httpResponse.sendRedirect(
                    contexto + "/login"
            );

            return;
        }


        // =========================================
        // ADMINISTRADOR
        // =========================================

        if ("ADMINISTRADOR".equals(
                nivelAcesso
        )) {

            chain.doFilter(
                    request,
                    response
            );

            return;
        }


        // =========================================
        // ATENDENTE
        // =========================================

        if ("ATENDENTE".equals(
                nivelAcesso
        )) {

            if (rotaPermitidaAtendente(
                    caminho
            )) {

                chain.doFilter(
                        request,
                        response
                );

                return;
            }


            httpResponse.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Você não possui permissão para acessar esta área."
            );

            return;
        }


        // =========================================
        // NÍVEL DESCONHECIDO
        // =========================================

        sessao.invalidate();

        httpResponse.sendRedirect(
                contexto + "/login"
        );
    }


    // =========================================
    // ROTAS PÚBLICAS
    // =========================================
    private boolean rotaPublica(
                String caminho
    ) {

        return caminho.equals(
                "/"
           )
           ||
           caminho.equals(
                "/index.jsp"
           )
           ||
           caminho.equals(
                "/cadastro.jsp"
           )
           ||
           caminho.equals(
                "/login"
           )
           ||
           caminho.equals(
                "/login.jsp"
           )
           ||
           caminho.startsWith(
                "/api/"
           )
           ||
           caminho.startsWith(
                "/css/"
           )
           ||
           caminho.startsWith(
                "/js/"
           )
           ||
           caminho.startsWith(
                "/img/"
           )
           ||
           caminho.startsWith(
                "/favicon"
           );
    }
    
    


    // =========================================
    // ROTAS PERMITIDAS PARA ATENDENTE
    // =========================================

    private boolean rotaPermitidaAtendente(
            String caminho
    ) {

        return caminho.equals(
                    "/"
               )
               ||
               caminho.equals(
                    "/index.jsp"
               )
               ||
               caminho.equals(
                    "/dashboard.jsp"
               )
               ||
               caminho.equals(
                    "/logout"
               )
               ||
               caminho.startsWith(
                    "/cliente"
               )
               ||
               caminho.startsWith(
                    "/veiculo"
               )
               ||
               caminho.startsWith(
                    "/agendamento"
               )
               ||
               caminho.startsWith(
                    "/atendimento"
               )
               ||
               caminho.startsWith(
                    "/cadastro-cliente.jsp"
               )
               ||
               caminho.startsWith(
                    "/lista-clientes.jsp"
               )
               ||
               caminho.startsWith(
                    "/editar-cliente.jsp"
               )
               ||
               caminho.startsWith(
                    "/cadastro-veiculo.jsp"
               )
               ||
               caminho.startsWith(
                    "/lista-veiculos.jsp"
               )
               ||
               caminho.startsWith(
                    "/editar-veiculo.jsp"
               )
               ||
               caminho.startsWith(
                    "/cadastro-agendamento.jsp"
               )
               ||
               caminho.startsWith(
                    "/lista-agendamentos.jsp"
               )
               ||
               caminho.startsWith(
                    "/cadastro-atendimento.jsp"
               )
               ||
               caminho.startsWith(
                    "/lista-atendimentos.jsp"
               )
               ||
               caminho.startsWith(
                    "/detalhes-atendimento.jsp"
               );
    }
}
