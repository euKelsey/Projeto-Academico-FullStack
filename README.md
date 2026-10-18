# Projeto Acadêmico Full Stack — Fast Splash

Sistema Full Stack desenvolvido como projeto acadêmico para simular o funcionamento de um lava-rápido.

A solução integra uma aplicação mobile em **Flutter/Dart**, um sistema Web em **Java/JSP**, uma API baseada em **Jakarta Servlets** e um banco de dados **MySQL**. O projeto permite gerenciar clientes, veículos, serviços, agendamentos, atendimentos e pagamentos.

> Projeto desenvolvido exclusivamente para fins acadêmicos, estudos, testes e demonstrações.

---

## Funcionalidades

### Aplicação mobile — Fast Splash

O cliente pode:

- criar uma conta e realizar login;
- consultar e atualizar seus dados;
- cadastrar, editar e excluir veículos;
- consultar os serviços disponíveis;
- realizar e cancelar agendamentos permitidos;
- acompanhar o andamento do serviço;
- visualizar o próximo agendamento na tela inicial;
- consultar pagamentos pendentes e realizados;
- realizar pagamentos simulados;
- consultar o histórico de serviços.

### Sistema Web

O sistema Web é utilizado pelos colaboradores para gerenciamento de:

- clientes;
- veículos;
- serviços;
- agendamentos;
- atendimentos;
- colaboradores;
- pagamentos.

O acesso às funcionalidades é controlado de acordo com o nível do colaborador.

---

## Tecnologias utilizadas

### Mobile

- Flutter
- Dart
- package:http

### Backend e Web

- Java
- JSP
- Jakarta Servlets
- JDBC
- Apache Tomcat 10

### Banco de dados

- MySQL
- MySQL Workbench
- Aiven MySQL

### Infraestrutura e deploy

- Docker
- Render
- Aiven
- GitHub

### Ferramentas de desenvolvimento

- Visual Studio Code
- Eclipse
- Android Studio
- Git
- GitHub

---

## Arquitetura

O aplicativo Flutter não acessa o banco de dados diretamente. As operações passam pelo backend Java, responsável por autenticação, validações, regras de negócio e persistência.

### Ambiente online

```text
Aplicativo Flutter / Navegador
            ↓
        Render
            ↓
Apache Tomcat + Java
            ↓
    API / Servlets
            ↓
           DAO
            ↓
          JDBC
            ↓
      Aiven MySQL
```

### Ambiente local

```text
Flutter / Navegador
        ↓
Tomcat no computador
        ↓
API Java / Servlets
        ↓
DAO
        ↓
JDBC
        ↓
MySQL local
```

---

## Estrutura principal do projeto

```text
Projeto-Academico-FullStack/
│
├── android/
│
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   └── README.md
│
├── lib/
│   ├── data/
│   ├── models/
│   ├── screens/
│   └── services/
│
├── web/
│   └── FastSplashWeb/
│       ├── Dockerfile
│       └── src/
│           └── main/
│               ├── java/
│               └── webapp/
│
├── iniciar_emulador.bat
├── iniciar_celular.bat
├── pubspec.yaml
└── README.md
```

---

## Banco de dados

O banco utilizado pelo projeto é:

```text
lava_rapido
```

A criação do banco deve respeitar a seguinte ordem:

```text
1. schema.sql
2. seed.sql
```

- `schema.sql`: cria a estrutura do banco;
- `seed.sql`: adiciona dados iniciais para testes.

O projeto pode utilizar MySQL local durante o desenvolvimento ou Aiven MySQL no ambiente online.

---

## Configuração do backend

A conexão com o banco utiliza variáveis de ambiente.

```text
FASTSPLASH_DB_PASSWORD
FASTSPLASH_DB_URL
FASTSPLASH_DB_USER
```

Valores padrão utilizados no ambiente local:

```text
FASTSPLASH_DB_URL=jdbc:mysql://localhost:3306/lava_rapido
FASTSPLASH_DB_USER=root
```

Senhas e demais credenciais privadas não devem ser armazenadas no código-fonte nem versionadas no GitHub.

---

## Executando o sistema Web localmente

### Requisitos

- Java
- Eclipse
- Apache Tomcat 10
- MySQL
- banco `lava_rapido` configurado
- variável `FASTSPLASH_DB_PASSWORD`

No Eclipse, importe:

```text
web/FastSplashWeb
```

Configure o projeto no Tomcat e inicie o servidor.

Acesse:

```text
http://localhost:8080/FastSplashWeb/
```

---

## Executando a aplicação Flutter

Instale as dependências:

```bash
flutter pub get
```

### Emulador Android com backend local

O endereço padrão da API é:

```text
http://10.0.2.2:8080/FastSplashWeb
```

Execute:

```bash
flutter run
```

### Celular físico com backend local

O computador e o celular devem estar na mesma rede.

Descubra o IPv4 do computador:

```bash
ipconfig
```

Depois execute:

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DO_PC:8080/FastSplashWeb
```

### Backend online

```bash
flutter run --dart-define=API_BASE_URL=https://fast-splash.onrender.com
```

Nesse modo, o aplicativo utiliza o backend hospedado no Render e não depende do Tomcat ou MySQL local.

---

## Ambiente online

O sistema Web e o backend Java são publicados no **Render** utilizando Docker.

O banco MySQL online está hospedado no **Aiven**.

A aplicação Web é publicada como aplicação `ROOT` do Tomcat.

Acesso público:

```text
https://fast-splash.onrender.com
```

O ambiente online é destinado a testes, demonstrações acadêmicas e portfólio, não a uso comercial em produção.

---

## Configuração do endereço da API

O Flutter utiliza `API_BASE_URL` para alternar entre ambientes sem alterar manualmente o código.

Exemplo:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/FastSplashWeb',
);
```

Principais cenários:

```text
Emulador Android + backend local
→ http://10.0.2.2:8080/FastSplashWeb

Celular físico + backend local
→ http://IP_DO_COMPUTADOR:8080/FastSplashWeb

Backend online
→ https://fast-splash.onrender.com
```

---

## Scripts de desenvolvimento no Windows

O projeto possui dois scripts auxiliares:

```text
iniciar_emulador.bat
iniciar_celular.bat
```

- `iniciar_emulador.bat`: inicia um emulador Android e executa o Flutter;
- `iniciar_celular.bat`: executa o Flutter em um dispositivo físico utilizando o IP configurado para o backend local.

Esses scripts são opcionais e existem apenas para agilizar o ambiente de desenvolvimento.

---

## Gerando APK Release

### Utilizando o backend online

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://fast-splash.onrender.com
```

O APK é gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Utilizando backend local

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://IP_DO_PC:8080/FastSplashWeb
```

---

## Autenticação e segurança

O cliente pode criar uma conta e realizar login pela aplicação mobile.

O backend utiliza sessão HTTP para autenticação:

```text
Login
  ↓
Servlet de autenticação
  ↓
HttpSession
  ↓
JSESSIONID
  ↓
Requisições autenticadas
```

O Flutter mantém o cookie de sessão recebido após o login e o reutiliza nas requisições seguintes.

As senhas não são armazenadas em texto puro. O backend utiliza:

```text
PBKDF2WithHmacSHA256
```

---

## Fluxo principal do serviço

O cliente realiza um agendamento selecionando veículo, serviços, data e horário.

Os valores dos serviços são registrados no momento do agendamento por meio de `valor_praticado`, preservando o histórico mesmo que o preço seja alterado posteriormente.

Fluxo simplificado:

```text
Agendamento
   ↓
Pagamento PENDENTE
   ↓
Atendimento AGUARDANDO
   ↓
Pagamento PAGO
   ↓
Atendimento pode iniciar
   ↓
EM_LAVAGEM
   ↓
FINALIZADO
   ↓
Agendamento CONCLUIDO
```

O backend também impede o início do atendimento enquanto o pagamento relacionado estiver pendente.

---

## Pagamentos

As formas de pagamento previstas são:

```text
PIX
DINHEIRO
CREDITO
DEBITO
```

Status utilizados:

```text
PENDENTE
PAGO
CANCELADO
```

Os pagamentos são simulados e utilizados exclusivamente para fins acadêmicos. Não existe integração com instituição financeira ou gateway de pagamento real.

---

## Controle de acesso no sistema Web

Os níveis de colaboradores utilizados são:

```text
ADMINISTRADOR
ATENDENTE
OPERACIONAL
```

O acesso às páginas do sistema Web é controlado pelo `AccessFilter`.

- **ADMINISTRADOR:** acesso às funcionalidades administrativas;
- **ATENDENTE:** acesso às operações relacionadas ao atendimento dos clientes;
- **OPERACIONAL:** na configuração atual, não possui acesso ao painel Web autenticado.

---

## API

A aplicação mobile utiliza a API Java para operações relacionadas a:

- autenticação;
- cadastro e dados do cliente;
- veículos;
- serviços;
- agendamentos;
- cancelamentos;
- pagamentos.

As respostas utilizam JSON e a autenticação é mantida por sessão HTTP.

---

## Git e GitHub

Atualizar o repositório local:

```bash
git pull origin main
```

Enviar alterações:

```bash
git add .
git commit -m "Descrição da alteração"
git push origin main
```

O Render pode iniciar automaticamente um novo deploy após alterações enviadas para a branch configurada.

---

## Arquivos que não devem ser versionados

Exemplos:

```text
build/
.dart_tool/
web/FastSplashWeb/build/
```

Também não devem ser versionados:

- senhas;
- credenciais;
- arquivos contendo informações sensíveis;
- APKs gerados localmente.

---

## Validação

Durante o desenvolvimento foram utilizados comandos como:

```bash
flutter analyze
git diff --check
git status
```

A solução também foi testada em:

- navegador no computador;
- navegador no celular;
- emulador Android;
- APK Release em celular físico;
- banco Aiven MySQL;
- ambiente online independente do computador de desenvolvimento.

---

## Finalidade acadêmica

O projeto foi desenvolvido para aplicar, de forma prática, conceitos de:

- desenvolvimento mobile;
- desenvolvimento Web e Full Stack;
- Flutter e Dart;
- Java, JSP, Servlets e JDBC;
- APIs e arquitetura cliente-servidor;
- banco de dados relacional e MySQL;
- autenticação e sessões HTTP;
- controle de acesso;
- Docker e deploy em nuvem;
- Git e GitHub.

O repositório representa a solução completa do projeto. **Fast Splash** é o nome utilizado pela aplicação mobile.

---

## Observação

Este sistema não representa um serviço comercial real.

Clientes, pagamentos, credenciais de teste e demais dados utilizados durante o desenvolvimento possuem finalidade exclusivamente acadêmica, de testes e demonstração.
