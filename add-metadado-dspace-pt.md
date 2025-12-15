
# Passo a passo: Como inserir metadados no DSpace

Este guia descreve, passo a passo, como **criar um novo campo de metadado no DSpace** utilizando a interface administrativa.

----------

## 1. Acessar o DSpace como administrador

1.  Abra o DSpace no navegador.
    
2.  Faça login com uma conta que possua **perfil de administrador**.
    

----------

## 2. Acessar o menu de administração

1.  Após o login, localize a **barra lateral** do DSpace.
    
2.  Clique nela 
    

<img width="53" height="569" alt="barra lateral dspace" src="https://github.com/user-attachments/assets/467d5357-1501-4654-8602-b4d2064993a3" />


----------

## 3. Navegar até a área de metadados

No menu administrativo:

1.  Clique em **Registros**.
    
2.  Em seguida, clique em **Metadados**.
    

Isso abrirá a página de gerenciamento de esquemas e campos de metadados.

<img width="274" height="559" alt="Captura de tela de 2025-12-15 09-42-31" src="https://github.com/user-attachments/assets/b8b7b841-5a14-43bc-8080-63da68891fea" />


----------

## 4. Selecionar o esquema de metadados

1.  Na página de metadados, localize a opção para **selecionar o esquema**.
    
2.  Escolha o esquema desejado.
    
    Exemplo:
    
    -   `dublin core`
        
    -   `local`
        
    -   outro esquema personalizado
        

> ℹ️ O esquema **Dublin Core** (`dc`) é o mais utilizado por padrão no DSpace.

<img width="1216" height="808" alt="Captura de tela de 2025-12-15 09-43-13" src="https://github.com/user-attachments/assets/a8ef341a-6363-4062-99b6-8e0fb243407f" />


----------

## 5. Criar um novo campo de metadado

Após selecionar o esquema:

1.  Clique no botão **Criar campo de metadado**.
    
2.  Um formulário será exibido para preenchimento dos dados do novo metadado.
    

<img width="1213" height="451" alt="Captura de tela de 2025-12-15 09-43-42" src="https://github.com/user-attachments/assets/6f436b56-e6da-4469-bdca-81a72c29a7c6" />


----------

## 6. Preencher os dados do metadado

No formulário de criação, preencha os seguintes campos:

### 🔹 Elemento *

-   Campo **obrigatório**.
    
-   Representa o nome principal do metadado.
    

Exemplo:

```
subject

```

----------

### 🔹 Qualificador

-   Campo **opcional**.
    
-   Serve para especializar o elemento.
    

Exemplos:

```
cnpq
por
lattes

```

> ℹ️ Se deixado em branco, o metadado será apenas `dc.element`.

----------

### 🔹 Nota de Escopo

-   Campo **opcional**.
    
-   Usado para descrever a finalidade do metadado.
    
-   Ajuda administradores e catalogadores a entenderem como o campo deve ser usado.
    

Exemplo:

```
Área do conhecimento segundo a classificação do CNPq

```


----------

## 7. Salvar o metadado

1.  Após preencher os campos, clique em **Salvar**.
    
2.  O novo metadado passará a fazer parte do esquema selecionado.
    


----------

## 8. Uso do metadado

Após criado:

-   O metadado poderá ser utilizado:
    
    -   Em **formulários de submissão**
        
    -   Em **configurações de busca e facetas (Discovery/Solr)**
        
    -   Em **exibição de itens**
        

> ⚠️ Dependendo do caso, pode ser necessário:

-   Limpar cache
    
-   Reindexar o Solr
    
-   Ajustar o submission form
    

----------

## 📌 Exemplo final de metadado

```
Esquema: dc
Elemento: subject
Qualificador: cnpq
Resultado: dc.subject.cnpq

```

----------

✅ Pronto! O metadado foi criado com sucesso e já pode ser integrado às demais configurações do DSpace.
