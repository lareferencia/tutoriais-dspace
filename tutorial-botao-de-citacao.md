# Tutorial de Adicionar botão de citação

Este tutorial adiciona ao DSpace um botão para gerar citações bibliográficas
automaticamente nas páginas de item e de publicações:

<div align="center">
    <img alt="botao-de-citacao" src="https://github.com/user-attachments/assets/cca580ac-4d1d-40b9-a414-b3d99c0cbc4a" />
</div>

<div align="center">
    <img alt="botao-de-citacao-na-pagina" src="https://github.com/user-attachments/assets/11bced87-8c39-4672-9501-75ab978deda4" />
</div>

## Aplique o patch no backend

**Passo 1:** Entre no diretório do código-fonte do DSpace (backend) e execute:

> [!WARNING]
> Caso ocorram conflitos durante a aplicação do patch, é responsabilidade de
> quem está aplicando resolvê-los manualmente.

```bash
cd <dspace-source>
git apply -v <(curl -sL "https://patch-diff.githubusercontent.com/raw/DSpace/DSpace/pull/11451.patch")
```

**Passo 2:** Se o patch aplicou com sucesso, continue:

```bash
git add . && git commit -m "Adiciona endpoint de bibliografia"
```

> [!IMPORTANT]
> Se der conflito, após resolver, volte para o passo 1.

**Passo 3:** Após aplicar o patch, atualize a instalação e verifique se está funcionando normalmente:

```bash
cd <dspace-source>
mvn clean package
cd dspace/target/dspace-installer
ant update
```

## Aplique o patch no frontend

**Passo 1:** Entre no diretório do código-fonte do DSpace Angular (frontend) e execute:

> [!WARNING]
> Da mesma forma, se ocorrerem conflitos durante a aplicação do patch, eles
> devem ser resolvidos manualmente.

```bash
cd <dspace-angular-source>
git apply -v <(curl -sL "https://patch-diff.githubusercontent.com/raw/DSpace/dspace-angular/pull/4779.patch")
git add . && git commit -m "Adiciona botão de citação bibliográfica"
```

**Passo 2:** Após aplicar o patch, atualize e reinicie o frontend e verifique se está funcionando normalmente:

```bash
cd <dspace-angular-source>
npm run start
```

> [!IMPORTANT]
> Se der conflito, após resolver, volte para o passo 1.
