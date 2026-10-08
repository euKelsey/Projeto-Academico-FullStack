# Projeto-Academico-FullStack

Projeto acadêmico Full Stack desenvolvido para simular o funcionamento de um sistema de lava-rápido.

O repositório reúne uma solução completa com:

- aplicativo mobile;
- sistema Web;
- backend em Java;
- API com Servlets;
- banco de dados MySQL;
- autenticação e sessão;
- controle de acesso;
- cadastro de clientes e veículos;
- serviços e agendamentos;
- acompanhamento de atendimentos;
- pagamentos;
- histórico de serviços.

A aplicação mobile desenvolvida dentro do projeto utiliza o nome **Fast Splash**.

> Projeto desenvolvido exclusivamente para fins acadêmicos, estudos e testes locais.

---

## Visão geral

O projeto possui dois ambientes principais que utilizam o mesmo backend e o mesmo banco de dados.

### Aplicação mobile — Fast Splash

Desenvolvida com **Flutter e Dart**.

O cliente pode:

- criar uma conta;
- realizar login;
- consultar e atualizar seus dados;
- cadastrar veículos;
- editar veículos;
- excluir veículos;
- consultar os serviços disponíveis;
- realizar agendamentos;
- acompanhar o andamento do serviço;
- cancelar agendamentos permitidos;
- consultar o histórico de serviços;
- visualizar pagamentos pendentes;
- realizar pagamentos simulados;
- consultar pagamentos realizados;
- visualizar o próximo agendamento na tela inicial.

### Sistema Web

Desenvolvido com:

- Java;
- JSP;
- Jakarta Servlets;
- JDBC;
- Apache Tomcat.

O sistema Web é utilizado pelos colaboradores para gerenciamento de:

- clientes;
- veículos;
- serviços;
- agendamentos;
- atendimentos;
- colaboradores;
- pagamentos.

O sistema também possui controle de acesso de acordo com o nível do colaborador.

---

## Arquitetura

A comunicação principal do projeto segue o fluxo:

```text
Flutter
   ↓
API Java / Servlets
   ↓
DAO
   ↓
JDBC
   ↓
MySQL
```

O aplicativo Flutter **não acessa o banco de dados diretamente**.

Todas as operações passam pela API Java, responsável por autenticação, validações, regras de negócio e acesso ao MySQL.

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

### Ferramentas utilizadas no desenvolvimento

- Visual Studio Code
- Eclipse
- Android Studio
- Git
- GitHub

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

A criação deve respeitar a seguinte ordem:

```text
1. schema.sql
2. seed.sql
```

O arquivo `schema.sql` cria a estrutura do banco.

O arquivo `seed.sql` adiciona os dados iniciais utilizados para testes.

---

## Segurança da conexão com o banco

A senha do MySQL não é armazenada diretamente no código-fonte.

O backend utiliza a variável de ambiente:

```text
FASTSPLASH_DB_PASSWORD
```

Também podem ser configuradas:

```text
FASTSPLASH_DB_URL
FASTSPLASH_DB_USER
```

Valores padrão:

```text
FASTSPLASH_DB_URL=jdbc:mysql://localhost:3306/lava_rapido
FASTSPLASH_DB_USER=root
```

---

## Executando o sistema Web

### Requisitos

- Java instalado;
- Eclipse;
- Apache Tomcat 10;
- MySQL;
- banco `lava_rapido` configurado;
- variável de ambiente `FASTSPLASH_DB_PASSWORD`.

No Eclipse, importe o projeto localizado em:

```text
web/FastSplashWeb
```

Depois configure e inicie o Tomcat.

Acesse:

```text
http://localhost:8080/FastSplashWeb/
```

O sistema Web utiliza login de colaborador.

---

## Executando a aplicação Flutter

Antes da primeira execução:

```bash
flutter pub get
```

### Emulador Android

O endereço padrão utilizado pela aplicação é:

```text
http://10.0.2.2:8080/FastSplashWeb
```

Para executar:

```bash
flutter run
```

---

## Executando em celular físico

O celular e o computador precisam estar conectados à mesma rede local.

No Windows, descubra o IPv4 do computador:

```bash
ipconfig
```

Exemplo de IPv4:

```text
192.168.15.45
```

Execute o aplicativo informando o endereço da API:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.15.45:8080/FastSplashWeb
```

Para o funcionamento correto:

- o computador deve estar ligado;
- o MySQL deve estar em execução;
- o Tomcat deve estar iniciado;
- celular e computador devem estar na mesma rede;
- a porta utilizada pelo Tomcat deve estar acessível na rede local.

---

## Scripts de desenvolvimento no Windows

Para facilitar a execução do aplicativo durante o desenvolvimento, o projeto possui dois scripts `.bat` na raiz do repositório:

```text
iniciar_emulador.bat
iniciar_celular.bat
```

Esses arquivos automatizam comandos que normalmente precisariam ser executados manualmente no terminal.

### `iniciar_emulador.bat`

O script `iniciar_emulador.bat` é utilizado para iniciar um emulador Android e executar o projeto Flutter automaticamente.

No início do arquivo existe a variável:

```bat
set "EMULADOR=teste"
```

O valor deve corresponder ao nome de um emulador existente na máquina.

Os emuladores cadastrados podem ser consultados com:

```bash
flutter emulators
```

Caso o nome do emulador seja diferente em outro computador, basta alterar somente essa variável.

Exemplo:

```bat
set "EMULADOR=Pixel_7_API_35"
```

O script realiza, de forma automática:

```text
verifica se o emulador informado existe
        ↓
inicia o emulador
        ↓
localiza o ADB
        ↓
aguarda o dispositivo ficar disponível
        ↓
aguarda o Android terminar a inicialização
        ↓
executa flutter run
```

Também existe um limite de tempo para a inicialização. Se o emulador não ficar disponível ou o Android não concluir o boot dentro do período definido, o script apresenta uma mensagem de erro e tenta encerrar o emulador automaticamente.

O tempo máximo pode ser alterado pela variável:

```bat
set "TEMPO_MAXIMO=60"
```

Enquanto o `flutter run` estiver ativo, a janela do CMD aberta pelo script deve permanecer aberta.

Nessa janela podem ser utilizados os comandos do Flutter, por exemplo:

```text
r  → Hot Reload
R  → Hot Restart
q  → Encerrar flutter run
h  → Exibir ajuda
```

O terminal do Visual Studio Code continua disponível normalmente para comandos como Git, `flutter analyze` e outras tarefas de desenvolvimento.

---

### `iniciar_celular.bat`

O script `iniciar_celular.bat` é utilizado para executar a aplicação em um celular Android físico conectado ao computador.

Antes de utilizá-lo, é necessário configurar a variável:

```bat
set "IP_PC=SEU_IP_AQUI"
```

Exemplo:

```bat
set "IP_PC=192.168.0.25"
```

O IPv4 atual do computador pode ser consultado no Windows com:

```bash
ipconfig
```

O script:

```text
localiza o ADB
        ↓
verifica se existe um celular físico autorizado
        ↓
mostra o IP configurado para o backend
        ↓
executa flutter run com API_BASE_URL
```

O comando executado utiliza o endereço configurado em `IP_PC`:

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DO_PC:8080/FastSplashWeb
```

Para funcionar corretamente:

- o celular deve estar conectado por USB;
- a Depuração USB deve estar ativada;
- o computador deve estar autorizado no celular;
- o cabo USB deve permitir transferência de dados;
- o computador e o celular devem estar na mesma rede local para acesso ao backend;
- o Tomcat deve estar iniciado;
- o MySQL deve estar em execução.

Se o IPv4 do computador mudar, não é necessário alterar o código Flutter. Basta atualizar esta linha do script:

```bat
set "IP_PC=NOVO_IP"
```

---

### Por que existem dois scripts?

Os dois arquivos foram mantidos separados porque os fluxos são diferentes:

```text
iniciar_emulador.bat
→ inicia e aguarda um emulador Android
→ executa flutter run

iniciar_celular.bat
→ verifica um dispositivo físico conectado
→ configura o endereço do backend pelo IP do computador
→ executa flutter run
```

Essa separação mantém os scripts simples, facilita a manutenção e permite reutilizá-los em outros computadores alterando apenas as variáveis necessárias.

---

## Configuração do endereço da API

O Flutter utiliza uma variável de compilação para definir o endereço do backend.

Exemplo:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/FastSplashWeb',
);
```

Isso permite alternar entre emulador e dispositivo físico sem alterar manualmente o endereço no código.

```text
Emulador Android
→ http://10.0.2.2:8080/FastSplashWeb

Celular físico
→ http://IP_DO_COMPUTADOR:8080/FastSplashWeb
```

---

## Gerando APK Release

Para gerar um APK para testes em celular físico:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://IP_DO_PC:8080/FastSplashWeb
```

Exemplo:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.15.45:8080/FastSplashWeb
```

O APK é gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

O endereço informado em `API_BASE_URL` fica configurado naquele APK.

Se o IPv4 do computador mudar, será necessário gerar outro APK com o novo endereço.

---

## Permissões Android para testes locais

Para permitir acesso à rede, o projeto Android utiliza:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Como os testes locais utilizam HTTP, a tag `<application>` também possui:

```xml
android:usesCleartextTraffic="true"
```

Essas configurações são utilizadas para comunicação com o Tomcat dentro da rede local.

---

## Cadastro e autenticação

O cliente pode criar uma conta e realizar login pela aplicação mobile.

O backend é responsável por:

- validar as credenciais;
- criar a sessão HTTP;
- armazenar o cliente autenticado na sessão;
- proteger as operações que exigem autenticação.

O Flutter mantém o cookie de sessão recebido após o login e o reutiliza nas requisições seguintes.

Fluxo simplificado:

```text
Login no Flutter
      ↓
Servlet de autenticação
      ↓
HttpSession
      ↓
JSESSIONID
      ↓
Flutter reutiliza o cookie
      ↓
Requisições autenticadas
```

---

## Senhas

As senhas não são armazenadas em texto puro.

O backend utiliza:

```text
PBKDF2WithHmacSHA256
```

A implementação também mantém compatibilidade com dados antigos utilizados durante o desenvolvimento acadêmico.

---

## Veículos

O cliente pode:

- cadastrar;
- listar;
- editar;
- excluir veículos.

As operações são realizadas pela API e persistidas no banco de dados.

O backend também valida se o veículo pertence ao cliente autenticado antes de permitir alterações.

---

## Serviços

Os serviços disponíveis são carregados diretamente do MySQL.

Cada serviço pode possuir:

- nome;
- descrição;
- preço.

---

## Agendamentos

O cliente pode selecionar:

- veículo;
- um ou mais serviços;
- data;
- horário.

O agendamento é persistido no banco.

Os valores dos serviços são registrados no momento do agendamento por meio de `valor_praticado`, preservando o valor histórico da operação mesmo que o preço do serviço seja alterado posteriormente.

---

## Acompanhamento de serviço

No sistema Web, os atendimentos utilizam os status:

```text
AGUARDANDO
EM_LAVAGEM
FINALIZADO
```

Na aplicação mobile eles são apresentados de forma mais amigável:

```text
AGUARDANDO   → Agendado
EM_LAVAGEM  → Em andamento
FINALIZADO  → Finalizado
```

O início da lavagem depende do pagamento do agendamento.

Enquanto o pagamento estiver com status `PENDENTE`:

- o atendimento permanece `AGUARDANDO`;
- o sistema Web informa que o atendimento está aguardando pagamento;
- a ação **Iniciar** não é liberada na interface;
- o backend também bloqueia tentativas de iniciar a lavagem sem pagamento.

Após o pagamento passar para `PAGO`, a ação **Iniciar** é liberada e o atendimento pode mudar de `AGUARDANDO` para `EM_LAVAGEM`.

Fluxo simplificado:

```text
Agendamento
   ↓
Pagamento PENDENTE
   ↓
Atendimento AGUARDANDO
   ↓
Cliente realiza pagamento
   ↓
Pagamento PAGO
   ↓
Atendimento pode iniciar
   ↓
EM_LAVAGEM
   ↓
FINALIZADO
```

Quando o atendimento é finalizado pelo sistema Web, o agendamento passa para:

```text
CONCLUIDO
```

Depois disso, ele deixa de aparecer em **Acompanhar Serviço** e passa a ser exibido no **Histórico de Serviços**.

---

## Cancelamento de agendamento

O cliente pode cancelar um agendamento enquanto o backend considerar o cancelamento permitido.

A API verifica:

- se o agendamento pertence ao cliente autenticado;
- se ele ainda está com status permitido;
- se ainda não existe atendimento iniciado para aquele agendamento.

---

## Histórico de serviços

O histórico apresenta agendamentos:

```text
Finalizados
Cancelados
```

As informações exibidas podem incluir:

- veículo;
- serviços;
- data;
- horário;
- valor;
- status do serviço;
- status do pagamento;
- forma de pagamento;
- data do pagamento.

---

## Pagamentos

As formas de pagamento utilizadas no projeto são:

```text
PIX
DINHEIRO
CREDITO
DEBITO
```

Os status previstos no banco são:

```text
PENDENTE
PAGO
CANCELADO
```

O cliente pode visualizar:

- pagamentos pendentes;
- pagamentos realizados;
- valor;
- forma utilizada;
- data do pagamento.

O pagamento está integrado à regra de início do atendimento. Um atendimento só pode ser iniciado quando o pagamento relacionado ao agendamento estiver com status `PAGO`.

Essa regra é validada no backend, evitando que a lavagem seja iniciada mesmo por uma tentativa direta de chamada da ação enquanto o pagamento ainda estiver pendente.

Os pagamentos são **simulados** e utilizados exclusivamente para fins acadêmicos. Não existe integração com instituição financeira ou gateway de pagamento real.

---

## Tela inicial da aplicação

A tela inicial apresenta:

- nome do cliente autenticado;
- próximo agendamento;
- status do próximo serviço;
- atalhos para as principais funcionalidades.

A Home também possui atualização por gesto de puxar a tela para baixo.

---

## Controle de acesso no sistema Web

Os níveis de colaboradores utilizados são:

```text
ADMINISTRADOR
ATENDENTE
OPERACIONAL
```

O acesso às páginas do sistema Web é controlado pelo `AccessFilter`.

### ADMINISTRADOR

Possui acesso às funcionalidades administrativas disponíveis no sistema.

### ATENDENTE

Possui acesso às operações relacionadas ao atendimento dos clientes.

### OPERACIONAL

Na configuração atual do projeto, não possui acesso ao painel Web autenticado.

---

## API

Entre as rotas utilizadas pela aplicação mobile estão operações relacionadas a:

- autenticação;
- cadastro do cliente;
- dados do cliente autenticado;
- veículos;
- serviços;
- agendamentos;
- cancelamentos;
- pagamentos.

A API utiliza JSON nas respostas e sessão HTTP para autenticação do cliente.

---

## Git e GitHub

Para baixar alterações do repositório:

```bash
git pull origin main
```

Para enviar novas alterações:

```bash
git add .
git commit -m "Descrição da alteração"
git push origin main
```

---

## Arquivos que não devem ser versionados

Arquivos gerados automaticamente devem permanecer fora do Git.

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

## Validação do projeto

Durante o desenvolvimento foram utilizados comandos como:

```bash
flutter analyze
```

para análise do código Flutter,

```bash
git diff --check
```

para verificar problemas de formatação,

e:

```bash
git status
```

para revisar alterações antes dos commits.

---

## Executando em outro computador

O projeto pode ser clonado em outro computador ou notebook.

Exemplo:

```bash
git clone URL_DO_REPOSITORIO
```

Depois:

```bash
cd Projeto-Academico-FullStack
flutter pub get
```

Também será necessário preparar o ambiente local com:

- Flutter;
- Java;
- Eclipse;
- Apache Tomcat;
- MySQL;
- banco `lava_rapido`;
- variável `FASTSPLASH_DB_PASSWORD`.

Depois da configuração, o sistema Web, backend, banco e aplicativo podem ser executados localmente.

---

## Ambiente de execução

O projeto foi planejado para execução local durante estudos e apresentações acadêmicas.

### Emulador

```text
Flutter no emulador
       ↓
10.0.2.2:8080
       ↓
Tomcat no computador
       ↓
API Java
       ↓
MySQL
```

### Celular físico

```text
Celular
   ↓
Rede Wi-Fi local
   ↓
IPv4 do computador
   ↓
Tomcat
   ↓
API Java
   ↓
MySQL
```

Não é necessário publicar o projeto em um servidor externo para os objetivos atuais.

---

## Finalidade acadêmica

O projeto foi desenvolvido para estudo e aplicação prática de conceitos relacionados a:

- desenvolvimento mobile;
- desenvolvimento Web;
- desenvolvimento Full Stack;
- Flutter;
- Dart;
- Java;
- APIs;
- Servlets;
- JSP;
- JDBC;
- banco de dados relacional;
- MySQL;
- arquitetura cliente-servidor;
- autenticação;
- sessões HTTP;
- controle de acesso;
- integração entre sistemas;
- Git;
- GitHub.

---

## Aplicação Fast Splash

**Fast Splash** é apenas o nome utilizado pela aplicação mobile desenvolvida dentro deste projeto.

O nome do repositório é:

```text
Projeto-Academico-FullStack
```

O repositório representa o conjunto completo da solução acadêmica, incluindo aplicativo mobile, sistema Web, backend Java e banco de dados.

---

## Observação final

Este sistema não representa um serviço comercial real.

Clientes, pagamentos, credenciais de teste e demais dados utilizados durante o desenvolvimento possuem finalidade exclusivamente acadêmica e de testes.