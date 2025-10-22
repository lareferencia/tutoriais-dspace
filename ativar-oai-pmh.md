
# ⚙️ Servidor OAI-PMH — Ativação e Manutenção no DSpace

A interface **OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting)** permite que outros sistemas coletem (**harvest**) registros de metadados do seu repositório DSpace.  

___

## 1. Ativação do Servidor OAI-PMH

O servidor **OAI-PMH do DSpace** é **habilitado por padrão**.  
No entanto, você pode ativá-lo ou desativá-lo manualmente no arquivo `local.cfg`, adicionando ou ajustando as seguintes configurações:

### Para habilitar adicione essa linha de código

    oai.enabled = true

###  Quando habilitado, o servidor OAI-PMH estará disponível neste caminho

    oai.path = oai
> Se você modificar essas configurações, será necessário o servidor.

Você pode testar se está funcionando acessando a url:

    [dspace.server.url]/[oai.path]/request?verb=Identify

 Exemplo: `http://localhost:8080/server/oai/request?verb=Identify`
 A resposta deve ser semelhante à do DSpace 7 Demo Server: [DSpace 7 Demo OAI](https://api7.dspace.org/server/oai/request?verb=Identify)

## 2. Manutenção do Servidor OAI-PMH
Após ativar o servidor, é necessário garantir que o **índice seja atualizado regularmente**. Atualmente, isso **não ocorre automaticamente** no DSpace. Para isso, utilize os comandos:

    [dspace.dir]/bin/dspace oai import 
    [dspace.dir]/bin/dspace index-discovery -b

### 2.1 Agendamento do índice via cron

Exemplo de cron para atualizar o índice do OAI-PMH diariamente à meia-noite:

#### Atualiza o índice OAI-PMH com o conteúdo mais recente todos os dias à meia-noite
##### OBS: NECESSÁRIO SOMENTE SE O OAI-PMH ESTIVER ATIVO

    0 0 * * * [dspace.dir]/bin/dspace oai import > /dev/null  
    0 0 * * * [dspace.dir]/bin/dspace index-discovery -b > /dev/null
> Isso garante que novos conteúdos fiquem disponíveis via OAI-PMH.
---
**Referência:** [DSpace Documentation - OAI](https://wiki.lyrasis.org/display/DSDOC10x/OAI)