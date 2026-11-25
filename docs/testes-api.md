# Fast Splash - Testes automatizados da API

## Objetivo

Validar os endpoints HTTP utilizados pelo aplicativo
mobile, garantindo a integridade das operacoes,
a autenticacao, o isolamento dos clientes e a
consistencia dos dados persistidos.

## Tecnologias

- Java 25 (alvo de compilacao)
- Maven Wrapper
- JUnit 5.13.4
- REST Assured 6.3.0
- Maven Failsafe 3.6.0
- Apache Tomcat 11
- MySQL 8.4
- Docker e Docker Compose

## Ambiente isolado

Os testes utilizam containers exclusivos e dados
ficticios, sem acesso ao ambiente de producao.

| Componente | Configuracao |
|---|---|
| Servidor HTTP | http://127.0.0.1:8081 |
| Container Web | fast-splash-web-test |
| Container MySQL | fast-splash-mysql-test |
| Porta MySQL local | 3308 |
| Banco | fast_splash_test |
| Usuario | fastsplash_test |
| Dados iniciais | database/seed_test.sql |
| Docker Compose | compose.test.yml |

As credenciais presentes no Compose sao exclusivas
do ambiente local de testes.

O banco de testes utiliza armazenamento temporario
e pode ser recriado durante as execucoes.

Nunca utilizar credenciais ou dados de producao.

## Execucao completa

A partir da raiz do repositorio, executar:

    bash scripts/test-api.sh

O script realiza:

1. Validacao da configuracao Docker.
2. Compilacao do codigo e dos testes.
3. Construcao da imagem Web de testes.
4. Preparacao do banco MySQL isolado.
5. Inicializacao do Tomcat.
6. Validacao das configuracoes do ambiente.
7. Verificacao da disponibilidade HTTP.
8. Execucao dos testes pelo Maven Failsafe.
9. Encerramento do servidor HTTP de testes.

## Execucao seletiva

Executar somente uma classe:

    bash scripts/test-api.sh -Dit.test=SegurancaApiIT

Executar somente os testes de pagamentos:

    bash scripts/test-api.sh -Dit.test=PagamentoApiIT

Executar somente os testes de agendamentos:

    bash scripts/test-api.sh -Dit.test=AgendamentoApiIT

## Perfis Maven

- Execucao padrao: testes unitarios.
- integration-tests: integracao MySQL e regras de negocio.
- api-tests: integracao HTTP com Tomcat isolado.

Os testes HTTP sao identificados pelo sufixo ApiIT
e excluidos do perfil integration-tests.

## Infraestrutura Java

AmbienteApiTeste.java:

- Valida as configuracoes do ambiente.
- Verifica a conexao com o banco autorizado.
- Verifica a disponibilidade do servidor HTTP.

BaseApiTeste.java:

- Configura as requisicoes REST Assured.
- Centraliza autenticacao e cookies de sessao.
- Centraliza validacoes de respostas HTTP.
- Restaura os dados ficticios antes e depois dos testes.

## Cobertura dos testes HTTP

| Classe | Testes |
|---|---:|
| InfraestruturaApiIT | 10 |
| CadastroClienteApiIT | 23 |
| AutenticacaoApiIT | 18 |
| MeuCadastroApiIT | 22 |
| VeiculoApiIT | 30 |
| ServicoApiIT | 14 |
| AgendamentoApiIT | 36 |
| PagamentoApiIT | 32 |
| SegurancaApiIT | 12 |
| Total | 197 |

## Regras verificadas

- Cadastro e autenticacao de clientes.
- Rejeicao de credenciais invalidas.
- Bloqueio de contas inativas e excluidas.
- Protecao dos dados de autenticacao.
- Consulta e atualizacao cadastral.
- Isolamento dos dados entre clientes.
- Cadastro, edicao e exclusao logica de veiculos.
- Disponibilidade e atualizacao dos servicos.
- Criacao e cancelamento de agendamentos.
- Preservacao dos precos contratados.
- Protecao contra manipulacao de valores.
- Prevencao de pagamentos duplicados.
- Pagamento obrigatorio antes do inicio da lavagem.
- Preservacao dos relacionamentos e historicos.
- Concorrencia em cadastros e operacoes financeiras.
- Verificacoes iniciais contra SQL Injection.
- Integridade das respostas JSON.

## Concorrencia

A classe SegurancaApiIT contem cinco cenarios
de concorrencia HTTP:

- Pagamentos simultaneos de registros existentes.
- Pagamentos simultaneos de novos agendamentos.
- Agendamentos simultaneos duplicados.
- Cadastros simultaneos com o mesmo CPF.
- Cadastros simultaneos com o mesmo e-mail.

A classe foi aprovada na suite inicial e em cinco
rodadas adicionais consecutivas.

Essas rodadas representaram 60 execucoes adicionais,
incluindo 25 execucoes de cenarios concorrentes.

As repeticoes nao aumentam a quantidade de testes
unicos do projeto e nao substituem testes de carga.

## Relatorios

Os relatorios HTTP sao gerados em:

    web/FastSplashWeb/target/failsafe-api-reports/

Os relatorios de integracao MySQL permanecem em:

    web/FastSplashWeb/target/failsafe-reports/

Os relatorios unitarios permanecem em:

    web/FastSplashWeb/target/surefire-reports/

## Regressao completa

Testes unitarios Java:

    bash web/FastSplashWeb/mvnw \
        -f web/FastSplashWeb/pom.xml test

Testes de integracao MySQL:

    bash scripts/test-java-integration.sh

Testes HTTP:

    bash scripts/test-api.sh

Analise e testes Flutter, na raiz do projeto:

    flutter analyze
    flutter test

Executar as suites que utilizam o banco isolado
sequencialmente, evitando restauracoes simultaneas.

## Resultado consolidado

Validacao realizada em 25/11/2026.

| Categoria | Aprovados |
|---|---:|
| Testes unitarios Java | 17 |
| Integracao MySQL | 419 |
| Integracao HTTP | 197 |
| Flutter | 28 |
| Total | 661 |

- Falhas: 0
- Erros: 0
- Testes ignorados nas suites Java: 0
- Problemas na analise estatica Flutter: 0

## Limitacoes e melhorias pendentes

A aprovacao dos testes representa a validacao dos
cenarios implementados, nao uma certificacao completa
de seguranca.

Pontos identificados para as proximas etapas:

- Validacao dos digitos verificadores do CPF.
- Validacao completa de e-mails e telefones.
- Politica de senhas e recuperacao de contas.
- Rotacao e revogacao segura das sessoes.
- Protecao contra enumeracao de contas.
- Limite de tentativas de autenticacao.
- Validacao do status do cliente na API de servicos.
- Protecao CSRF e tratamento centralizado de erros.
- Serializacao JSON robusta.
- Validacao das placas dos veiculos.
- Preservacao da propriedade historica dos veiculos.
- Validacao de datas e horarios de agendamento.
- Controle de capacidade operacional.
- Integracao entre cancelamentos e pagamentos.
- Correcao do campo pago na API de agendamentos.
- Revisao da consistencia transacional dos precos.
- Integracao futura com pagamentos reais.
- Testes da interface Web com Playwright.
- Ampliacao dos testes automatizados Flutter.
- Cobertura de codigo e integracao continua.

## Encerramento do ambiente

Para remover os containers exclusivos de testes:

    docker compose -f compose.test.yml --profile api down

A infraestrutura deve permanecer separada dos
ambientes de desenvolvimento e producao.

