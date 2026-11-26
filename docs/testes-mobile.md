# Fast Splash - Testes Automatizados Mobile

## 1. Objetivo

Estabelecer uma base automatizada de testes para o
aplicativo Flutter antes da reestruturacao do projeto,
preservando as funcionalidades existentes e permitindo
identificar regressoes durante o desenvolvimento.

## 2. Tecnologias utilizadas

- Flutter e Dart
- Flutter Test
- Widget Tests
- HTTP MockClient
- LCOV
- Python para leitura da cobertura
- Docker Compose
- Apache Tomcat 11
- MySQL 8.4
- Java 25 LTS no ambiente Docker

Todas as ferramentas utilizadas nesta etapa podem ser
executadas localmente sem custos adicionais.

## 3. Estrutura dos testes

test/
  data/
  formatters/
  models/
  screens/
  services/
  support/
  theme/

test-real/
  api_real_test.dart

scripts/
  test-mobile-real.sh

A pasta test contem os testes unitarios, de widgets
e de comunicacao HTTP simulada.

A pasta test-real contem os testes de comunicacao HTTP
com o backend real e isolado.

## 4. Distribuicao dos testes

| Grupo | Quantidade |
|---|---:|
| Modelos existentes | 28 |
| ApiService | 71 |
| Sessao do cliente | 7 |
| Formatadores | 31 |
| Tema | 10 |
| Autenticacao e perfil | 37 |
| Veiculos, servicos e agendamentos | 37 |
| Pagamentos, acompanhamento e historico | 29 |
| Navegacao, atualizacao e responsividade | 66 |
| Integracao HTTP real | 12 |
| Total | 328 |

Foram adicionados 300 testes Mobile durante esta etapa,
considerando os 28 testes de modelos preexistentes.

## 5. Execucao dos testes locais

Na raiz do repositorio:

    flutter test --reporter expanded

Resultado validado:

    +316: All tests passed!

Os testes desta suite nao dependem de um servidor
Tomcat em execucao nem de um banco de dados real.

## 6. Execucao da integracao HTTP real

Na raiz do repositorio:

    bash scripts/test-mobile-real.sh

Resultado validado:

    +12: All tests passed!

O script realiza:

1. Validacao das dependencias.
2. Build da imagem Docker do backend.
3. Recriacao do banco de testes.
4. Importacao do schema e do seed ficticio.
5. Inicializacao do Tomcat.
6. Validacao do isolamento.
7. Verificacao da disponibilidade HTTP.
8. Execucao dos testes Flutter reais.
9. Remocao dos containers e da rede temporaria.

## 7. Seguranca e isolamento

Projeto Docker:

    fast-splash-tests

Banco autorizado:

    fast_splash_test

Endereco HTTP autorizado:

    http://127.0.0.1:8081

URL JDBC interna autorizada:

    jdbc:mysql://mysql-test:3306/fast_splash_test

A variavel FASTSPLASH_DB_URL e validada antes da
execucao dos testes reais.

Os testes utilizam dados e credenciais ficticios.

Nenhum teste deve acessar o Render, o banco de producao
ou qualquer ambiente externo de dados reais.

As suites Java, API, Playwright e Mobile real nao devem
ser executadas simultaneamente quando compartilharem
o mesmo ambiente Docker de testes.

## 8. Cobertura de codigo

Comando:

    flutter test --coverage --reporter expanded

Relatorio:

    coverage/lcov.info

Resultado registrado:

| Indicador | Resultado |
|---|---:|
| Arquivos instrumentados | 17 |
| Linhas instrumentadas | 2250 |
| Linhas cobertas | 2223 |
| Linhas nao cobertas | 27 |
| Cobertura de linhas | 98.80% |

### Cobertura por arquivo

| Arquivo | Cobertura |
|---|---:|
| sessao_cliente.dart | 100.00% |
| main.dart | 80.00% |
| agendamento.dart | 100.00% |
| cliente.dart | 100.00% |
| pagamento.dart | 100.00% |
| servico.dart | 100.00% |
| veiculo.dart | 100.00% |
| agendamento_screen.dart | 99.74% |
| historico_servicos_screen.dart | 100.00% |
| home_screen.dart | 98.97% |
| login_screen.dart | 96.84% |
| meu_cadastro_screen.dart | 98.98% |
| pagamentos_screen.dart | 100.00% |
| status_servico_screen.dart | 98.50% |
| veiculos_screen.dart | 99.65% |
| api_service.dart | 93.68% |
| theme_controller.dart | 100.00% |

A cobertura corresponde as linhas instrumentadas no
relatorio LCOV, nao a totalidade dos arquivos Dart.

A tela de cadastro legado nao esta contemplada nesse
percentual.

Cobertura elevada nao comprova ausencia de defeitos,
nem equivale a cobertura integral de todos os caminhos
logicos do aplicativo.

## 9. Analise estatica

Comando:

    flutter analyze

Resultado validado:

    No issues found!

## 10. Responsividade

Foram verificadas oito telas nas seguintes dimensoes
logicas:

- 360 x 640
- 390 x 844
- 430 x 932
- 768 x 1024

Tambem foram verificados:

- Tema claro e escuro.
- Login em tela compacta.
- Navegacao entre telas.
- Atualizacao manual.
- Recuperacao apos falhas HTTP.

### Defeito identificado e corrigido

Arquivo:

    lib/screens/home_screen.dart

Problema:

Os cards de acesso rapido apresentavam overflow
vertical em telas de 360 e 390 pixels de largura.

Configuracao anterior:

    childAspectRatio: 1.02,

Configuracao corrigida:

    mainAxisExtent: 200,

A alteracao resolveu os tres testes reprovados
relacionados ao problema.

A regressao completa de 316 testes foi aprovada
apos a correcao.

## 11. Limitacoes e melhorias futuras

Os seguintes pontos devem ser avaliados durante
as proximas fases da reestruturacao:

- Remocao ou adequacao da tela de cadastro legado.
- Confirmacao de senha no cadastro legado.
- Persistencia segura de sessao.
- Revogacao de sessao no servidor.
- Tratamento centralizado de sessao expirada.
- Timeout das requisicoes HTTP.
- Tratamento padronizado de erros de comunicacao.
- Atualizacao automatica do acompanhamento.
- Prevencao de multiplas confirmacoes de pagamento.
- Estado do formulario de veiculos apos falhas.
- Preservacao das selecoes durante atualizacoes.
- Atualizacao imediata dos dados do perfil na Home.
- Tratamento de agendamentos ativos com datas passadas.
- Aperfeicoamento da responsividade e acessibilidade.
- Validacao em emulador e dispositivos Android reais.

Alguns desses pontos sao oportunidades de melhoria
ou riscos identificados por analise de codigo,
nao defeitos confirmados por testes reprovados.

A integracao HTTP real executa o ApiService do Flutter
no computador. Nao equivale a um teste completo do APK
em um dispositivo Android.

Os pagamentos permanecem simulados pelo sistema,
sem processamento financeiro real.

## 12. Resultado consolidado

| Suite | Testes aprovados |
|---|---:|
| Java | 633 |
| Playwright | 534 |
| Flutter unitarios e widgets | 316 |
| Flutter HTTP real | 12 |
| Total acumulado | 1495 |

Resultado registrado em 26/11/2026.

A infraestrutura Mobile foi validada para servir como
base de regressao durante as proximas fases do projeto.
