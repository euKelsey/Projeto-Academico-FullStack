import '../models/cliente.dart';

class SessaoCliente {
  static Cliente? clienteLogado;

  static bool get estaLogado =>
      clienteLogado != null;

  static void iniciar(
    Cliente cliente,
  ) {
    clienteLogado = cliente;
  }

  static void encerrar() {
    clienteLogado = null;
  }
}