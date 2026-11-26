# Fast Splash - Testes automatizados Web

## Objetivo

Validar as funcionalidades da interface Web, a integridade
dos dados, as permissoes de acesso e a integracao entre
Web, API mobile e MySQL.

## Tecnologias

- Playwright
- TypeScript
- Chromium
- Node.js
- Docker Compose
- MySQL
- Apache Tomcat

## Ambiente isolado

URL autorizada:
http://127.0.0.1:8081

Banco:
fast_splash_test

Containers:
- fast-splash-web-test
- fast-splash-mysql-test

Os testes utilizam exclusivamente dados ficticios.
O banco de testes e restaurado automaticamente antes
e depois de cada teste funcional.

A execucao utiliza um worker para evitar interferencia
entre testes que compartilham o banco isolado.

## Executar todos os testes

Na raiz do repositorio:

    bash scripts/test-e2e.sh

## Executar um arquivo especifico

    bash scripts/test-e2e.sh autenticacao.spec.ts

## Executar testes por nome

    bash scripts/test-e2e.sh -g "nome do teste"

## Listar testes

    cd tests-e2e
    npm run test:list

## Consultar relatorio HTML

    cd tests-e2e
    npx playwright show-report

## Encerrar ambiente

Na raiz do repositorio:

    docker compose -f compose.test.yml --profile api down

## Cobertura validada

| Grupo | Testes aprovados |
|---|---:|
| Infraestrutura Playwright | 24 |
| Pagina inicial e navegacao | 24 |
| Autenticacao e permissoes | 41 |
| Dashboard | 30 |
| Menu lateral | 18 |
| Gerenciamento de clientes | 106 |
| Gerenciamento de cadastros | 106 |
| Gerenciamento operacional e financeiro | 94 |
| Validacao integrada | 91 |
| Total | 534 |

## Funcionalidades contempladas

- Pagina inicial e navegacao publica.
- Cadastro publico de clientes.
- Autenticacao administrativa.
- Controle de acesso por perfil.
- Dashboard e indicadores.
- Menu lateral.
- Gerenciamento de clientes.
- Gerenciamento de veiculos.
- Gerenciamento de servicos.
- Gerenciamento de colaboradores.
- Gerenciamento de agendamentos.
- Gerenciamento de atendimentos.
- Gerenciamento de pagamentos.
- Exclusao logica.
- Inativacao e reativacao.
- Arquivamento e restauracao.
- Preservacao de historico.
- Integridade dos relacionamentos.
- Preservacao dos valores contratados.
- Integracao Web, API mobile e MySQL.
- Revogacao de sessoes.
- Isolamento de dados entre clientes.
- Prevencao de pagamentos duplicados.
- Responsividade em diferentes resolucoes.

## Resultado da regressao

Data: 26/11/2026

- Playwright: 534 testes aprovados.
- Falhas: 0.
- Tempo de execucao: 9,5 minutos.

## Balanco acumulado

| Camada | Testes aprovados |
|---|---:|
| Java | 633 |
| Flutter | 28 |
| Playwright | 534 |
| Total | 1195 |

Os resultados Java e Flutter correspondem as validacoes
anteriores. A regressao desta etapa foi executada
exclusivamente na camada Playwright.

## Pendencias para reestruturacao

- Revisar protecao contra CSRF e XSS.
- Implementar limitacao de tentativas de login.
- Renovar identificadores de sessao na autenticacao.
- Corrigir revogacao de sessao na API de servicos.
- Fortalecer validacao de CPF, e-mail e senhas.
- Revisar cancelamento de agendamentos com vinculos.
- Revisar transferencia de veiculos com historico.
- Fortalecer validacao de datas e horarios.
- Melhorar tratamento de erros dos servlets.
- Implementar atribuicao de colaboradores.
- Aperfeicoar responsividade e identidade visual.
- Substituir gradualmente credenciais legadas.
- Corrigir inconsistencias conhecidas entre Web e API.

A aprovacao dos testes nao representa uma certificacao
completa de seguranca, acessibilidade ou ausencia de
vulnerabilidades.

As pendencias deverao receber testes de regressao
especificos durante a reestruturacao.

## Situacao

Etapa 1.8.9 - Implementacao e validacao concluidas.

Nenhuma alteracao funcional foi realizada no codigo
de producao durante esta etapa.
