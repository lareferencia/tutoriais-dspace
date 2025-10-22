# Tutorial de Migração do DSpace 5/6 para DSpace 8 ou 9 

Este tutorial descreve, de forma detalhada e ordenada, o passo a passo do processo de migração de uma instalação antiga do DSpace (versões 5 ou 6) para as versões mais recentes (8 ou 9). O objetivo é garantir que todos os dados, configurações e estatísticas sejam preservados, além de orientar na preparação do ambiente e na instalação do backend (Java) e frontend (Angular).

> 💡 **Convenção utilizada neste tutorial**  
> Para facilitar a leitura e evitar ambiguidades, os caminhos e diretórios serão representados conforme a convenção abaixo:
> 
> - **`[dspace-antigo]`** → Diretório de instalação do **DSpace antigo**
> - **`[dspace]`** → Diretório de instalação do **novo DSpace**
> - **`[dspace-source]`** → Diretório contendo o **código-fonte** do novo DSpace

## 📦 1. Preparação do Ambiente

Instale os seguintes softwares no novo servidor:

- JDK 17
- Maven 3.8.x
- Ant 1.10+
- PostgreSQL 12.x ou superior (com a extensão pgcrypto)
- Solr
    - DSpace 8 → [Solr 8.x](https://solr.apache.org/guide/8_11/installing-solr.html)
    - DSpace 9 → [Solr 9.x](https://solr.apache.org/guide/solr/latest/deployment-guide/installing-solr.html)
- [Node.js v22.x](https://nodejs.org/en/download)
- [Yarn](https://www.npmjs.com/package/yarn) (DSpace 8)
- [PM2](https://www.npmjs.com/package/pm2)

## 💾 2. Backup dos Dados Existentes

> Faça backup completo da instalação antiga do DSpace **antes de iniciar a migração.**
### 2.1 Faça o dump da base de dados PostgreSQL
Faça um dump completo (backup) da base de dados PostgreSQL atual para garantir a preservação dos dados durante a migração e a posterior importação na nova versão.
```
pg_dump -U [db_username] -h [host] -p 5432 [db_name] > dump.sql
```
### 2.2 Exporte as estatísticas do Solr
Para garantir que as estatísticas do SOLR sejam preservadas e possam ser utilizadas na nova instalação, é necessário exportá-las do sistema antigo. Estes dados incluem informações importantes de autoridade (`authority`) e estatísticas de uso (`statistics`), que ajudam na manutenção e análise da base.
Para isso, execute os seguintes comandos no diretório de instalação do DSpace antigo:
```
[dspace-antigo]/bin/dspace solr-export-statistics -i authority[dspace-antigo]/bin/dspace solr-export-statistics -i statistics
```
A execução desses comandos acima irá gerar, dentro do diretório `[dspace-antigo]`, uma pasta chamada `solr-export` contendo os arquivos CSV exportados com as estatísticas do Solr.
### 2.3 Faça uma cópia do diretório `assetstore`
O diretório **assetstore** está localizado na instalação do DSpace e contém todos os arquivos armazenados no sistema, incluindo subdiretórios e seus conteúdos. Para garantir que nenhum dado seja perdido durante a migração, é fundamental copiar todo o conteúdo dessa pasta. Você pode optar por compactá-la (zip) para facilitar a transferência ou copiar diretamente o diretório completo para um local seguro.
Exemplo de comando para copiar:
```
cp -r [dspace-antigo]/assetstore /path/de/backup/
```
## 🗃️ 3. Preparação do Banco de Dados
### 3.1 Crie um banco de dados e usuário para o DSpace
Primeiro, acesse o terminal do PostgreSQL com o usuário administrador:
```
sudo -u postgres psql
```
No prompt do PostgreSQL, execute os comandos abaixo. As linhas que começam com `--` são comentários explicativos e não devem ser digitadas. Recomendamos substituir `#mysafepassword#` por uma senha forte e de sua preferência.
```sql
-- Cria um novo usuário chamado "dspace" com a senha definida.
CREATE USER dspace WITH PASSWORD '#mysafepassword#';
-- Cria um novo banco de dados chamado "dspace" e define o usuário "dspace" como proprietário.
CREATE DATABASE dspace OWNER dspace;
-- Concede todos os privilégios no banco de dados "dspace" ao usuário "dspace".
GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;
-- Conecta-se ao banco de dados "dspace" para executar comandos dentro dele.
\c dspace
-- Ativa a extensão "pgcrypto", que fornece funções criptográficas necessárias para o DSpace.
CREATE EXTENSION IF NOT EXISTS pgcrypto;-- Confirma que a extensão "pgcrypto" está instalada no banco de dados.
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
-- Sai do terminal do PostgreSQL.
exit
```

### 3.2 Importe o dump do banco de dados

Para restaurar os dados do banco antigo na nova instalação, você deve importar o arquivo de backup (`dump.sql`) que foi gerado anteriormente. Este comando executa o arquivo SQL e recria todas as tabelas, dados e estruturas no banco de dados `dspace`.

Execute o seguinte comando no terminal, substituindo `<caminho-absoluto>/dump.sql` pelo caminho real do seu arquivo de backup:

```
psql -U dspace -d dspace -f "<caminho-absoluto>/dump.sql"
```

- `-U dspace`: especifica o usuário do banco de dados que fará a importação.
- `-d dspace`: indica o banco de dados de destino onde os dados serão importados.
- `-f "<caminho-absoluto>/dump.sql"`: aponta para o arquivo SQL que contém o backup a ser restaurado.

## ⚙️ 4. Instalação do Backend (Servidor)

### 4.1 Baixe o código-fonte da versão desejada

Acesse o [repositório oficial do DSpace no GitHub](https://github.com/DSpace/DSpace/tags), localize a _tag_ da versão que deseja instalar (por exemplo, `dspace-9.0`) e baixe o arquivo `.zip` ou `.tar.gz`. Em seguida, extraia o conteúdo para um diretório de trabalho, que chamaremos de **`dspace-source`**.

### 4.2 Crie o diretório de instalação

Crie o diretório onde o DSpace será instalado e conceda permissão de acesso ao usuário que irá executá-lo:

```
mkdir [dspace]
chown [usuario-de-execução] [dspace]
```

- `[dspace]` será o diretório final da instalação.
- `[seu-usuario]` deve ser substituído pelo usuário do sistema que executará o DSpace.

### 4.3 Preencha as variáveis de ambiente do DSpace Servidor

O arquivo `local.cfg` define parâmetros essenciais de configuração. Navegue até o diretório [`dspace-source]/dspace/config`, faça uma cópia do arquivo `local.cfg.EXAMPLE` para `local.cfg` e edite-o configurando, no mínimo, as variáveis abaixo:

dspace.dir=/dspace                              
dspace.server.url=https://[host]/server     
dspace.ui.url=https://[host]                
solr.server=http://localhost:8983/solr           
db.url=jdbc:postgresql://localhost:5432/dspace   
db.username=dspace                               
db.password=#mysafepassword#                   `   `

⚠️ Importante: substitua os valores de exemplo acima pelos valores reais do seu ambiente.

- `dspace.dir`: Caminho no sistema onde o DSpace será instalado e executado (diretório base do sistema).
- `dspace.server.url`: URL pública da API REST do DSpace, usada por clientes como o frontend Angular.
- `dspace.ui.url`: URL onde os usuários acessam a interface web do DSpace (Angular).
- `solr.server`: Endereço do serviço Solr, responsável pelas buscas e indexação de conteúdo.
- `db.url`: URL de conexão com o banco PostgreSQL, incluindo host, porta e nome do banco de dados.
- `db.username`: Nome do usuário do PostgreSQL usado pelo DSpace.
- `db.password`: Senha correspondente ao usuário do banco de dados.

### 4.4 Compile o DSpace

Compile o código-fonte para gerar os arquivos necessários à instalação:

```
cd [dspace-source]mvn package
```

Esse comando irá baixar dependências, compilar o código e criar os pacotes na pasta `dspace/target/dspace-installer`.

### 4.5 Instalar o DSpace Servidor

Após a compilação, execute o instalador para criar a estrutura de diretórios e copiar os arquivos para o diretório de instalação `[dspace]`:

```
cd [dspace-source]/dspace/target/dspace-installer
ant fresh_install
```

O parâmetro `fresh_install` garante que a instalação seja feita do zero, sem aproveitar dados ou configurações de uma instalação anterior.

## 📁 5. Migração de Dados

### 5.1 Copie o diretório `assetstore` antigo para a nova pasta de instalação

O diretório **assetstore** armazena todos os arquivos carregados no DSpace (documentos, imagens, vídeos, etc.), organizados em subdiretórios internos. Para que o novo DSpace mantenha todos os itens já existentes, é necessário copiar o conteúdo do _assetstore_ do backup (feito na instalação antiga) para o diretório da nova instalação.

Execute o comando abaixo, substituindo `[backup-assetstore-antigo]` pelo caminho onde está o backup do _assetstore_:

```
cp -r [backup-assetstore-antigo] [dspace]/
```

ℹ️ **Observação:**

- Esse procedimento apenas transfere os arquivos físicos; os metadados e referências a eles são mantidos no banco de dados.
- Certifique-se de que as permissões e o proprietário dos arquivos no novo servidor permitam que o usuário que executa o DSpace possa acessá-los.

### 5.2 Execute a migração do banco de dados para a nova versão

Para atualizar a estrutura do banco de dados do DSpace antigo para a versão mais recente, é necessário executar o script de migração. Esse processo aplica todas as alterações necessárias no esquema e nos dados para garantir compatibilidade com a nova versão do sistema.

Execute o comando abaixo no diretório da nova instalação:

```
# Se estiver atualizando a partir do DSpace 6.x ou anterior
[dspace]/bin/dspace database migrate ignored
 
# Se estiver atualizando a partir do DSpace 7.x ou superior
[dspace]/bin/dspace database migrate
```

### 5.3 Copie os cores do Solr

O DSpace cria seis cores Solr vazios e pré-configurados. Para que o Solr os reconheça, copie-os de `[dspace]/solr` para o diretório onde o Solr procura suas configurações — que, na instalação padrão, é `[solr]/server/solr/configsets` — por exemplo:”

```
cp -R [dspace]/solr/* [solr]/server/solr/configsets
```

### 5.4 Reinicei o Solr

Reinicie o serviço do Solr para aplicar as configurações e garantir que os dados sejam carregados corretamente:

```
[solr]/bin/solr stop
[solr]/bin/solr start -Dsolr.config.lib.enabled=true
```

### 5.5 Importe as estatísticas do Solr

Para importar as estatísticas exportadas do Solr para a nova instalação do DSpace, execute os seguintes comandos:

```

```

O parâmetro `-d` é opcional e serve para indicar o caminho onde estão localizados os arquivos CSV exportados.  
Se não for informado, o diretório padrão utilizado será **`[dspace]/solr-export`**.

### 5.6 Reindexe todo o conteúdo para busca e navegação

Após a migração, é necessário recriar os índices de busca e navegação do DSpace para que todo o conteúdo esteja disponível corretamente nas funcionalidades de **search** e **navegação**.

Para reindexar manualmente, execute:

[`dspace]/bin/dspace index-discovery -b   `

ℹ️ **Observação:** O parâmetro `-b` realiza uma reindexação completa (_build_), recriando todos os índices do zero. Esse processo pode levar tempo, dependendo do volume de conteúdo.

Opcionalmente, se você utiliza **OAI-PMH**, também será necessário reindexar o conteúdo para esse endpoint:

```
[dspace]/bin/dspace oai import
```

### 5.7 Inicie a aplicação backend

Para iniciar o backend do DSpace manualmente, execute:

```
java -jar /dspace/webapps/server-boot.jar
```

Isso inicializará a API REST, permitindo que o frontend (Angular) e outras integrações se comuniquem com o sistema.

Acesse `http://[host]:8080/server` para verificar se a API está respondendo corretamente (porta `8080` é a padrão, mas pode ser alterada).

⚠️ **Recomendação:**  
Em ambientes de produção, é altamente recomendável configurar o `server-boot.jar` como um **serviço no Linux** (via `systemd` ou outro gerenciador de serviços) para garantir que o backend inicie automaticamente junto com o servidor e seja reiniciado em caso de falhas.

---

## 🌐 6. Instalação do Frontend (Angular)

Configuração da interface web do DSpace, baseada em Angular. Essencial para interação com o repositório via navegador.

### 6.1 Baixe o código-fonte da versão desejada

Acesse o repositório oficial [`dspace-angular`](https://github.com/DSpace/dspace-angular/tags) no GitHub, selecione a versão desejada (ex: `dspace-9.0`) e baixe o código-fonte em `.zip` ou `.tar.gz`. Extraia para um diretório de trabalho local.

### 6.2 Instalação das dependências e compilação do projeto

Entre na pasta do projeto:

cd [dspace-angular]`   `

Instale as dependências:

- DSpace 8:

```
yarn install
```

- DSpace 9:

`npm install`

Compile o projeto em modo de produção:

- DSpace 8:

```
yarn run build:prod
```

- DSpace 9:

```
npm run build:prod
```

> Isso gera os arquivos otimizados para execução em produção.

### 6.3 Preencha as variáveis de ambiente do frontend

Copie o arquivo de configuração de exemplo:

```
cp config/config.example.yml config/config.prod.yml
```

Edite os valores conforme o seu ambiente, por exemplo:

ui:  
  ssl: false           
  host: [host-front]      
  port: 4000           
  nameSpace: /  
  
rest:  
  ssl: true            
  host: [host-server]    
  port: 443            
  nameSpace: /server   
  ssrBaseUrl: http://localhost:8080/server  

Esta configuração conecta o frontend Angular ao backend REST do DSpace, em que.

- `ui:` (Variáveis do Frontend Angular do DSpace)
    - **ssl:** Define se o frontend será acessado via HTTPS (`true`) ou HTTP (`false`).
    - **host:** Endereço do servidor onde o frontend será executado (geralmente `localhost` em ambiente local).
    - **port:** Porta usada para acessar o frontend no navegador (ex: `4000`).
    - **nameSpace:** Caminho base da aplicação no navegador (geralmente `/`).
- `rest:` (Variáveis do Backend REST do DSpace)
    - **ssl:** Define se o backend REST está configurado com HTTPS (`true`) ou HTTP (`false`).
    - **host:** Domínio ou IP onde o backend REST do DSpace está rodando.
    - **port:** Porta usada para acessar o backend REST (normalmente `443` para HTTPS).
    - **nameSpace:** Caminho base do backend REST (ex: `/server`).
    - **ssrBaseUrl:** URL usada no servidor Angular para renderização do lado do servidor (SSR); melhora a performance quando frontend e backend estão no mesmo host. Ao definir o ssrBaseUrl, é obrigatório configurar também o dspace.server.ssr.url com o mesmo valor no local.cfg do backend.

### 6.4 Inicie a aplicação manualmente

- DSpace 8:

yarn start

- DSpace 9:

```
npm start
```

Isso inicia o servidor Angular localmente para testes ou uso manual.

Acesse `http://[host]:4000` para verificar se a interface web do DSpace está funcionando corretamente. Se tudo estiver certo, a página será carregada sem erros.

---

## 🔐 7. Criar conta de administrador

Para criar um usuário administrador do sistema, execute o seguinte comando no terminal:

```
/dspace/bin/dspace create-administrator
```

Você será solicitado a informar os seguintes dados:

- Endereço de e-mail do administrador (será o login)
- Nome completo
- Senha de acesso (com confirmação)

> ✅ Após a criação, você poderá usar esse usuário para acessar a interface administrativa do DSpace via web.
> 
## ⚠️ Formulários de submissão
A partir do **DSpace 7**, a configuração de submissão foi reformulada:
- O antigo arquivo `item-submission.xml` teve seu formato alterado.
- O arquivo `input-forms.xml` foi **substituído** por um novo: `submission-forms.xml`.

> ❗ **Este tutorial não abrange a migração dessas configurações.**  
> A migração dos formulários de submissão deve ser feita **manual e cuidadosamente**, adaptando os dados para o novo formato utilizado nas versões mais recentes do DSpace.

---

## 📚 Referências

Em caso de dúvidas durante o processo de migração, administração ou manutenção do DSpace, consulte a documentação oficial. Abaixo estão alguns links utilizados como base para a elaboração deste roteiro:

- 📘 [Migrating DSpace to a new server](https://wiki.lyrasis.org/display/DSDOC8x/Migrating+DSpace+to+a+new+server)
- 🛠️ [Installing DSpace](https://wiki.lyrasis.org/display/DSDOC8x/Installing+DSpace)
- 🔁 [Upgrading DSpace](https://wiki.lyrasis.org/display/DSDOC8x/Upgrading+DSpace)
- 📊 [SOLR Statistics Maintenance](https://wiki.lyrasis.org/display/DSDOC8x/SOLR+Statistics+Maintenance)
- ⚙️ [User Interface Configuration](https://wiki.lyrasis.org/display/DSDOC9x/User+Interface+Configuration)
- 🎨 [User Interface Customization (Angular)](https://wiki.lyrasis.org/display/DSDOC9x/User+Interface+Customization)
