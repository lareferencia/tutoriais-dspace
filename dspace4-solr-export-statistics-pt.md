# DSpace 4 Solr Export Statistics

Esse tutorial ensina a usar um script que permite exportar as estatísticas do
Solr de uma instância de DSpace 4 em um formato que instâncias de versões mais
recentes conseguem importar.

## Motivação

O DSpace 5 introduziu o script `solr-export-statistics`, que permite exportar
estatísticas para importação em outras instâncias. Como ele não existe no
DSpace 4, este script preenche essa lacuna.

## Como usar

1. Abra o arquivo scripts/dspace4-solr-export-statistics.sh e edite as
variáveis no início do script para que correspondam à sua instância.

2. Após definir as variáveis, execute o script:

```bash
bash ./scripts/dspace4-solr-export-statistics.sh
```

## Para quê serve cada opção?

- `EXPORT_DIR`: diretório onde os arquivos gerados serão exportados. Esse diretório será criado se não existir.
- `INDEX_NAME`: nome do índice, esse nome deve corresponder ao nome do índice
  que será futuramente usado na importação via `solr-import-statistics`.
- `URL_BASE`: URL base do Solr, essa URL será usada pelo script para baixar os
  arquivos.
- `PAGINATION_ROWS`: quantidade de registros por arquivo.

## Exemplo de saída

Após a execução, você encontrará arquivos CSV no diretório definido por
`EXPORT_DIR`. Exemplo de arquivos gerados:

```code
statistics_export_1.csv
statistics_export_2.csv
statistics_export_3.csv
```

Cada arquivo conterá os registros de estatísticas exportados do Solr, podendo
ser importados diretamente em outra instância do DSpace usando
`solr-import-statistics`.

## Notas e avisos

- Verifique se o Solr está acessível na URL definida em `URL_BASE` antes de
  executar o script.
- Certifique-se de que você possui permissões de escrita no diretório definido
  por `EXPORT_DIR`.
- A quantidade de registros por arquivo é equivalente ao que foi definido por
  `PAGINATION_ROWS`.
