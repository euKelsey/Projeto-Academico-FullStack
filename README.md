# Fast Splash — Projeto Acadêmico Full Stack

Sistema Full Stack desenvolvido como projeto acadêmico para simular o gerenciamento de um lava-rápido.

O projeto integra uma aplicação mobile em **Flutter/Dart**, um sistema Web e backend em **Java/JSP e Jakarta Servlets**, além de um banco de dados relacional **MySQL**.

## Funcionalidades

### Aplicativo Mobile

- Cadastro e autenticação de clientes
- Gerenciamento de veículos
- Consulta de serviços disponíveis
- Realização e cancelamento de agendamentos
- Acompanhamento de serviços
- Consulta de histórico e pagamentos simulados

### Sistema Web

- Gerenciamento de clientes e veículos
- Cadastro e gerenciamento de serviços
- Controle de agendamentos e atendimentos
- Gerenciamento de colaboradores
- Controle de pagamentos
- Acesso conforme o perfil do colaborador

## Tecnologias utilizadas

**Mobile:** Flutter e Dart

**Backend e Web:** Java, JSP, Jakarta Servlets, JDBC e Apache Tomcat

**Banco de dados:** MySQL e Aiven

**Infraestrutura:** Docker, Render, Git e GitHub

## Arquitetura

O aplicativo Flutter e o sistema Web utilizam o backend Java para processar as operações.

A comunicação com o banco de dados ocorre pelo backend, utilizando JDBC.

```text
Flutter / Navegador
        |
Backend Java / Servlets
        |
       JDBC
        |
    MySQL (Aiven)
```

## Banco de dados

O banco `lava_rapido` contém as tabelas responsáveis pelo gerenciamento das principais operações do sistema.

Os scripts de criação e dados iniciais estão disponíveis na pasta `database/`.

## Execução

### Aplicativo Flutter

```bash
flutter pub get
flutter run
```

A execução requer um backend acessível e o endereço da API configurado para o ambiente utilizado.

### Backend

O sistema Web utiliza Java e Apache Tomcat, com conexão ao MySQL por meio de variáveis de ambiente.

### Ambiente online

O backend e a aplicação Web possuem configuração de implantação no Render, utilizando o banco MySQL hospedado no Aiven.

Para executar o aplicativo com o backend online:

```bash
flutter run --dart-define=API_BASE_URL=https://fast-splash.onrender.com
```

## Conceitos trabalhados

- Desenvolvimento Full Stack
- Programação orientada a objetos
- APIs e arquitetura cliente-servidor
- Operações CRUD
- Banco de dados relacional
- Autenticação e controle de acesso
- Integração entre Web, Mobile e Backend
- Versionamento com Git e GitHub
- Deploy de aplicações

## Observações

O sistema utiliza dados fictícios e pagamentos simulados, sem integração com instituições financeiras.

**Finalidade:** projeto desenvolvido exclusivamente para fins acadêmicos, estudos e demonstrações.