package com.fastsplash.web.dao;

import java.sql.SQLException;
import java.util.List;

import com.fastsplash.web.model.Veiculo;

public class TesteVeiculoDAO {

    public static void main(String[] args) {

        VeiculoDAO veiculoDAO =
                new VeiculoDAO();

        try {

            // =====================================
            // LISTAR TODOS
            // =====================================

            System.out.println(
                    "===== TODOS OS VEÍCULOS ====="
            );

            List<Veiculo> veiculos =
                    veiculoDAO.listarTodos();

            for (Veiculo veiculo : veiculos) {

                exibirVeiculo(veiculo);
            }


            // =====================================
            // BUSCAR POR ID
            // =====================================

            System.out.println();
            System.out.println(
                    "===== BUSCAR POR ID ====="
            );

            Veiculo veiculo =
                    veiculoDAO.buscarPorId(7);

            if (veiculo != null) {

                exibirVeiculo(veiculo);

            } else {

                System.out.println(
                        "Veículo não encontrado."
                );
            }


            // =====================================
            // LISTAR POR CLIENTE
            // =====================================

            System.out.println();
            System.out.println(
                    "===== VEÍCULOS DO CLIENTE 1 ====="
            );

            List<Veiculo> veiculosCliente =
                    veiculoDAO.listarPorCliente(1);

            for (Veiculo v : veiculosCliente) {

                exibirVeiculo(v);
            }


        } catch (SQLException e) {

            System.out.println(
                    "Erro durante os testes."
            );

            e.printStackTrace();
        }
    }


    private static void exibirVeiculo(
            Veiculo veiculo
    ) {

        System.out.println(
                "ID: "
                + veiculo.getIdVeiculo()
                + " | Cliente: "
                + veiculo.getIdCliente()
                + " | "
                + veiculo.getMarca()
                + " "
                + veiculo.getModelo()
                + " | Placa: "
                + veiculo.getPlaca()
                + " | Cor: "
                + veiculo.getCor()
        );
    }
}