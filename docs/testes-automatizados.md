# Fast Splash - Infraestrutura Geral de Testes

## 1. Objetivo

Estabelecer uma base automatizada de regressao para
permitir a reestruturacao segura do Fast Splash.

A infraestrutura contempla o backend Java, banco de
dados MySQL, API HTTP, interface Web e aplicativo Flutter.

## 2. Tecnologias

- JUnit 5
- Maven Wrapper
- Maven Surefire e Failsafe
- REST Assured
- MySQL
- Docker Compose
- Apache Tomcat
- Playwright
- Flutter Test
- HTTP MockClient
- LCOV
- Python
- Bash

As ferramentas utilizadas podem ser executadas
localmente sem custos adicionais.

## 3. Executor central

Arquivo:

    scripts/test-all.sh

Executar todas as suites:

    bash scripts/test-all.sh

Ou:

    bash scripts/test-all.sh --all

## 4. Execucao seletiva

| Opcao | Suite | Referencia |
|---|---|---:|
| --java | Java unitarios e MySQL | 456 |
| --api | API HTTP Java | 197 |
| --web | Playwright Web | 534 |
| --mobile | Flutter completo | 328 |
| --mobile-local | Flutter unitarios e widgets | 316 |
| --mobile-real | Flutter HTTP real | 12 |
| --all | Todas as suites | 1515 |
| --list | Listagem de suites | - |
| --help | Ajuda | - |

Exemplo de execucao combinada:

    bash scripts/test-all.sh --java --mobile

As suites selecionadas sao executadas sequencialmente.

## 5. Scripts existentes

| Script | Responsabilidade |
|---|---|
| reset-test-db.sh | Preparacao do banco isolado |
| test-java-integration.sh | Integracao Java e MySQL |
| test-api.sh | Testes HTTP Java |
| test-e2e.sh | Testes Web Playwright |
| test-mobile-real.sh | Integracao HTTP Flutter |
| test-all.sh | Orquestracao geral |

O executor central reutiliza os scripts existentes,
sem duplicar suas regras de preparacao.

## 6. Dependencias

Conforme as suites selecionadas:

- Git Bash ou ambiente Bash compativel.
- Java compativel com o release 25 do Maven.
- Docker e Docker Compose.
- Python.
- Node.js e npm.
- Playwright e seus navegadores.
- Flutter e Dart.
- curl.

O Docker precisa estar em funcionamento para executar
as suites que dependem do backend isolado.

## 7. Isolamento e seguranca

Projeto Docker autorizado:

    fast-splash-tests

Banco de dados:

    fast_splash_test

Endereco MySQL local:

    127.0.0.1:3308

Endereco HTTP local:

    http://127.0.0.1:8081

URL JDBC interna:

    jdbc:mysql://mysql-test:3306/fast_splash_test

O ambiente utiliza dados e credenciais ficticios.

O banco de testes e recriado por meio do schema
gerado e do arquivo database/seed_test.sql.

Os testes nao devem acessar o ambiente de producao.

O executor valida a identidade dos containers
existentes antes de preparar o ambiente.

Ao finalizar, o executor encerra o projeto Docker
isolado, inclusive em caso de falhas tratadas.

## 8. Controle de execucao

O executor central possui:

- Validacao de dependencias.
- Selecao individual ou combinada de suites.
- Execucao sequencial.
- Bloqueio de execucoes centrais simultaneas.
- Interrupcao em caso de falha.
- Contagem automatica dos testes aprovados.
- Validacao das quantidades minimas de referencia.
- Registro de duracao por suite.
- Relatorio consolidado.
- Encerramento do ambiente Docker.

O bloqueio de simultaneidade protege as chamadas ao
executor central no mesmo repositorio.

Nao executar scripts individuais simultaneamente
com o executor central, pois compartilham recursos.

## 9. Contagem dos testes

Os perfis Maven executam novamente os testes
unitarios durante a fase verify.

Para evitar dupla contagem, os testes unitarios
Java sao contabilizados apenas na suite Java/MySQL.

A suite API contabiliza somente seus testes HTTP.

O executor utiliza os resumos das ferramentas
para identificar a quantidade de testes aprovados.

Quantidades inferiores aos valores de referencia
interrompem a execucao.

A verificacao de quantidade e uma protecao adicional,
mas nao garante a identidade de cada teste executado.

## 10. Distribuicao consolidada

### Java

| Grupo | Quantidade |
|---|---:|
| Testes unitarios | 17 |
| Validacao do ambiente MySQL | 4 |
| Validacao do seed | 13 |
| Integracao dos DAOs | 360 |
| Regras de negocio e concorrencia | 42 |
| API HTTP | 197 |
| Total Java | 633 |

### Web

| Grupo | Quantidade |
|---|---:|
| Playwright E2E | 534 |
| Total Web | 534 |

### Mobile

| Grupo | Quantidade |
|---|---:|
| Flutter unitarios e widgets | 316 |
| Flutter HTTP real | 12 |
| Total Mobile | 328 |

### Total geral

| Tecnologia | Quantidade |
|---|---:|
| Java | 633 |
| Playwright | 534 |
| Flutter | 328 |
| Total | 1495 |

## 11. Regressao geral oficial

Data: 26/11/2026.

Comando:

    bash scripts/test-all.sh

Resultado:

| Suite | Resultado | Testes | Duracao |
|---|---|---:|---|
| Java unitarios e MySQL | Aprovado | 436 | 00:00:48 |
| API HTTP Java | Aprovado | 197 | 00:00:53 |
| Playwright Web | Aprovado | 534 | 00:09:39 |
| Flutter unitarios e widgets | Aprovado | 316 | 00:00:11 |
| Flutter HTTP real | Aprovado | 12 | 00:00:25 |

Testes aprovados: 1495.

Suites aprovadas: 5 de 5.

Duracao total: 00:11:58.

Resultado final: SUCESSO.

O ambiente Docker foi encerrado ao final da execucao.

## 12. Relatorios locais

Diretorio:

    test-reports/

Cada execucao gera um diretorio individual contendo
os logs das suites selecionadas.

Exemplo:

    test-reports/
      data-hora-identificador/
        java.log
        api.log
        web.log
        mobile-local.log
        mobile-real.log

Os relatorios gerados sao ignorados pelo Git.

## 13. Cobertura Mobile

| Indicador | Resultado |
|---|---:|
| Arquivos instrumentados | 17 |
| Linhas instrumentadas | 2250 |
| Linhas cobertas | 2223 |
| Linhas nao cobertas | 27 |
| Cobertura instrumentada | 98.80% |

A cobertura registrada corresponde aos arquivos
instrumentados pelo LCOV.

A tela de cadastro Mobile legado nao esta incluida.

A analise estatica Flutter foi aprovada sem problemas.

## 14. Documentacao complementar

- docs/testes-api.md
- docs/testes-e2e.md
- docs/testes-mobile.md

As documentacoes especificas registram detalhes,
cenarios testados e limitacoes de cada tecnologia.

## 15. Limitacoes

A aprovacao da regressao nao significa que todos
os defeitos possiveis foram eliminados.

Os testes representam a base de comportamento
validada antes da reestruturacao.

Pontos para as proximas fases:

- Reestruturacao da arquitetura.
- Melhorias de seguranca e autenticacao.
- Tratamento centralizado de erros.
- Regras de negocio adicionais.
- Cobertura de codigo Java.
- Melhorias de acessibilidade.
- Validacao em dispositivos Android reais.
- Automacao de testes em CI/CD.

Os testes HTTP reais do Flutter nao substituem
a validacao completa do APK em dispositivos Android.

Nenhum pagamento real e processado pelos testes.

## 16. Politica de regressao futura

Durante a reestruturacao:

1. Implementar alteracoes em etapas controladas.
2. Executar os testes relacionados ao modulo alterado.
3. Adicionar testes para novas funcionalidades.
4. Investigar falhas antes de consolidar alteracoes.
5. Executar a regressao geral nos marcos do projeto.
6. Atualizar as referencias e documentacoes.
7. Nao publicar alteracoes sem validacao previa.

A infraestrutura geral de testes foi validada
em 26/11/2026 com 1495 testes aprovados.

## 17. Evolucao da infraestrutura - Bloco A

Data: 27/11/2026.

Melhorias implementadas:

- Remocao de oito classes legadas.
- Pool de conexoes HikariCP.
- Configuracao centralizada do banco.
- Gerenciamento do ciclo de vida do pool.
- Gerenciador centralizado de transacoes.
- Reestruturacao de seis DAOs.
- Logging SLF4J integrado ao Java.
- 12 novos testes do pool.
- 8 novos testes de transacoes.

### Distribuicao atualizada

| Grupo | Testes |
|---|---:|
| Java unitarios | 17 |
| Java integracao MySQL | 439 |
| API HTTP Java | 197 |
| Playwright Web | 534 |
| Flutter unitarios e widgets | 316 |
| Flutter HTTP real | 12 |
| Total | 1515 |

### Regressao geral

Comando:

    bash scripts/test-all.sh

| Suite | Testes | Resultado | Duracao |
|---|---:|---|---|
| Java unitarios e MySQL | 456 | Aprovado | 00:00:29 |
| API HTTP Java | 197 | Aprovado | 00:01:01 |
| Playwright Web | 534 | Aprovado | 00:09:04 |
| Flutter unitarios e widgets | 316 | Aprovado | 00:00:13 |
| Flutter HTTP real | 12 | Aprovado | 00:00:24 |

Total: 1515 testes aprovados.

Duracao total: 00:11:14.

Resultado final: SUCESSO.

A referencia anterior de 1495 testes permanece
registrada como historico da Fase 1.

A nova referencia oficial passa a ser 1515 testes.

Documentacao complementar:

    docs/arquitetura-backend.md
