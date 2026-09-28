package com.fastsplash.web.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.fastsplash.web.dao.ClienteDAO;
import com.fastsplash.web.model.Cliente;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cliente")
public class ClienteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ClienteDAO clienteDAO = new ClienteDAO();
    
    @Override
    protected void doGet(
    		
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

    	String acao = request.getParameter("acao");
    	
    	if ("editar".equals(acao)) {

    	    int idCliente = Integer.parseInt(
    	            request.getParameter("idCliente")
    	    );

    	    try {

    	        Cliente cliente =
    	                clienteDAO.buscarPorId(idCliente);

    	        request.setAttribute(
    	                "cliente",
    	                cliente
    	        );

    	        request.getRequestDispatcher(
    	                "/editar-cliente.jsp"
    	        ).forward(request, response);

    	    } catch (SQLException e) {

    	        throw new ServletException(
    	                "Erro ao buscar cliente.",
    	                e
    	        );
    	    }

    	    return;
    	}
        try {

            request.setAttribute(
                    "clientes",
                    clienteDAO.listarTodos()
            );

            request.getRequestDispatcher(
                    "/lista-clientes.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao listar clientes.",
                    e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String acao = request.getParameter("acao");


        // ATUALIZAR CLIENTE
        if ("atualizar".equals(acao)) {

            int idCliente = Integer.parseInt(
                    request.getParameter("idCliente")
            );

            String nome = request.getParameter("nome");
            String cpf = request.getParameter("cpf");
            String telefone = request.getParameter("telefone");
            String email = request.getParameter("email");

            try {

                Cliente cliente =
                        clienteDAO.buscarPorId(idCliente);

                if (cliente != null) {

                    cliente.setNome(nome);
                    cliente.setCpf(cpf);
                    cliente.setTelefone(telefone);
                    cliente.setEmail(email);

                    clienteDAO.atualizar(cliente);
                }

                response.sendRedirect(
                        request.getContextPath() + "/cliente"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao atualizar cliente.",
                        e
                );
            }

            return;
        }


        // EXCLUIR CLIENTE
        if ("excluir".equals(acao)) {

            int idCliente = Integer.parseInt(
                    request.getParameter("idCliente")
            );

            try {

                clienteDAO.excluir(idCliente);

                response.sendRedirect(
                        request.getContextPath() + "/cliente"
                );

            } catch (SQLException e) {

                throw new ServletException(
                        "Erro ao excluir cliente.",
                        e
                );
            }

            return;
        }


        // CADASTRAR CLIENTE
        String nome = request.getParameter("nome");
        String cpf = request.getParameter("cpf");
        String telefone = request.getParameter("telefone");
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");

        Cliente cliente = new Cliente();

        cliente.setNome(nome);
        cliente.setCpf(cpf);
        cliente.setTelefone(telefone);
        cliente.setEmail(email);

        // Temporário para nosso projeto acadêmico.
        // Depois vamos substituir por geração real de hash.
        cliente.setSenhaHash(
                "HASH_" + senha
        );

        try {

            clienteDAO.inserir(cliente);

            response.setContentType(
                    "text/html;charset=UTF-8"
            );

            response.getWriter().println(
                    "<h1>Cliente cadastrado com sucesso!</h1>"
            );

            response.getWriter().println(
                    "<p>ID gerado: "
                    + cliente.getIdCliente()
                    + "</p>"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Erro ao cadastrar cliente.",
                    e
            );
        }
    }
}
