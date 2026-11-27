# Fast Splash - Arquitetura do Backend

## 1. Objetivo

Reestruturar progressivamente o backend Java,
preservando as funcionalidades existentes,
a integridade dos dados e a compatibilidade
entre Web e Mobile.

## 2. Tecnologias preservadas

- Java
- Jakarta Servlets
- JSP
- Apache Tomcat
- MySQL
- JDBC
- Maven

## 3. Arquitetura pretendida

Fluxo principal:

    Web / Mobile
        |
    Filters / Security
        |
    Servlets / API
        |
    Services
        |
    DAOs
        |
    MySQL

A camada Services sera introduzida
progressivamente nas proximas etapas.

## 4. Limpeza estrutural

Foram removidas oito classes legadas:

- TesteAtualizarCliente
- TesteBuscarCliente
- TesteClienteDAO
- TesteExcluirCliente
- TesteListarClientes
- TesteVeiculoDAO
- TesteConexao
- TesteServlet

Os testes manuais foram substituidos pela
infraestrutura automatizada.

Os residuos de compilacao anteriores ao Maven
foram removidos e incluidos no gitignore.

## 5. Pool de conexoes

Biblioteca: HikariCP 7.0.2.

A classe Conexao preserva a assinatura:

    public static Connection conectar()
        throws SQLException

As conexoes passam a ser gerenciadas por um pool.

Os DAOs continuam utilizando try-with-resources.

O fechamento de uma conexao normalmente
devolve o recurso ao pool.

## 6. Configuracao centralizada

Classe:

    config/ConfiguracaoBanco.java

Variaveis de conexao preservadas:

- FASTSPLASH_DB_URL
- FASTSPLASH_DB_USER
- FASTSPLASH_DB_PASSWORD

Configuracoes adicionais opcionais:

| Variavel | Valor padrao |
|---|---:|
| FASTSPLASH_DB_POOL_MAX | 5 |
| FASTSPLASH_DB_POOL_MIN | 1 |
| FASTSPLASH_DB_POOL_CONNECTION_TIMEOUT | 10000 |
| FASTSPLASH_DB_POOL_VALIDATION_TIMEOUT | 5000 |
| FASTSPLASH_DB_POOL_IDLE_TIMEOUT | 60000 |
| FASTSPLASH_DB_POOL_MAX_LIFETIME | 600000 |

Os tempos sao definidos em milissegundos.

A configuracao valida os limites numericos,
a URL JDBC e a existencia da senha.

Nenhuma credencial real deve ser armazenada
no repositorio.

## 7. Ciclo de vida

Classe:

    config/CicloVidaBanco.java

O listener inicializa o pool durante
o carregamento da aplicacao pelo Tomcat.

O pool e encerrado quando a aplicacao
e descarregada.

Em caso de falha na inicializacao do banco,
a inicializacao da aplicacao e interrompida.

Os testes Java podem inicializar o pool
sem depender do Tomcat.

## 8. Logging

Dependencia:

    org.slf4j:slf4j-jdk14:2.0.17

Os registros do HikariCP sao integrados
ao sistema de logging nativo do Java.

## 9. Gerenciador de transacoes

Classe:

    db/Transacao.java

Responsabilidades:

- Obter uma conexao.
- Desativar o AutoCommit.
- Executar a operacao.
- Confirmar a transacao.
- Cancelar explicitamente quando solicitado.
- Executar rollback em caso de falha.
- Preservar a excecao original.
- Devolver a conexao ao pool.

O gerenciador trata SQLException,
RuntimeException e Error.

Falhas adicionais de rollback sao
registradas como excecoes suprimidas.

## 10. DAOs reestruturados

- AgendamentoDAO
- AtendimentoDAO
- ClienteDAO
- ColaboradorDAO
- PagamentoDAO
- VeiculoDAO

O gerenciamento explicito de transacoes
foi centralizado na classe Transacao.

As assinaturas publicas, consultas SQL
e regras existentes foram preservadas
durante esta etapa.

## 11. Novos testes automatizados

### PoolConexaoIT

12 testes abrangendo:

- Inicializacao.
- Inicializacao automatica.
- Encerramento.
- Reinicializacao.
- Reutilizacao de conexoes.
- Conexoes simultaneas.
- Restauracao de AutoCommit.
- Restauracao de ReadOnly.
- Limites de configuracao.
- Timeouts.
- Saturacao do pool.
- Liberacao apos timeout.

### TransacaoIT

8 testes abrangendo:

- Commit.
- Retorno da operacao.
- Cancelamento explicito.
- Rollback por SQLException.
- Rollback por RuntimeException.
- Rollback por Error.
- Atomicidade.
- Devolucao de conexoes apos falha.

## 12. Validacao Java

Data: 27/11/2026.

| Grupo | Testes aprovados |
|---|---:|
| Java unitarios | 17 |
| Integracao MySQL anterior | 419 |
| Pool de conexoes | 12 |
| Gerenciador de transacoes | 8 |
| Total | 456 |

Resultado: SUCESSO.

Duracao da execucao: 34 segundos.

## 13. Limitacoes e pontos futuros

- Ajustar o pool conforme a hospedagem.
- Validar o ciclo de vida no Tomcat.
- Testar falhas durante o proprio rollback.
- Aprimorar a configuracao de logging.
- Implementar a camada Services.
- Centralizar DTOs e validacoes.
- Padronizar excecoes.
- Aprimorar autenticacao e autorizacao.

A infraestrutura atual nao representa
a conclusao de toda a reestruturacao.

## 14. Politica de desenvolvimento

Preservar os testes existentes.

Adicionar testes para novas funcionalidades.

Executar testes seletivos durante
o desenvolvimento.

Executar regressao geral nos marcos
de consolidacao.

Manter o ambiente de producao isolado
das alteracoes da branch de desenvolvimento.

## 15. Regressao geral do Bloco A

Data: 27/11/2026.

| Suite | Testes aprovados |
|---|---:|
| Java unitarios e MySQL | 456 |
| API HTTP Java | 197 |
| Playwright Web | 534 |
| Flutter unitarios e widgets | 316 |
| Flutter HTTP real | 12 |
| Total | 1515 |

Duracao total: 00:11:14.

Resultado final: SUCESSO.

Todas as cinco suites foram aprovadas.

A inicializacao da aplicacao no Tomcat foi
validada pelas suites HTTP e Web.

Nenhuma alteracao funcional intencional
foi introduzida nas regras de negocio.

O Bloco A estabeleceu a fundacao necessaria
para a criacao dos componentes compartilhados
e da futura camada Services.
