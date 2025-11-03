# DSpace 4 Solr Export Statistics

Este tutorial enseña cómo usar un script que permite exportar las estadísticas
de Solr de una instancia de DSpace 4 en un formato que las instancias de
versiones más recientes pueden importar.

## Motivación

DSpace 5 introdujo el script `solr-export-statistics`, que permite exportar
estadísticas para su importación en otras instancias. Como este script no
existe en DSpace 4, este script llena ese vacío.

## Cómo usar

1. Abra el archivo scripts/dspace4-solr-export-statistics.sh y edite las variables
al inicio del script para que correspondan a su instancia.

2. Después de definir las variables, ejecute el script:

```bash
bash ./scripts/dspace4-solr-export-statistics.sh
```

## Para qué sirve cada opción

- `EXPORT_DIR`: directorio donde se exportarán los archivos generados. Este
  directorio se creará si no existe.
- `INDEX_NAME`: nombre del índice; este nombre debe coincidir con el nombre del
  índice que se utilizará posteriormente en la importación mediante
  `solr-import-statistics`.
- `URL_BASE`: URL base de Solr; esta URL será utilizada por el script para
  descargar los archivos.
- `PAGINATION_ROWS`: cantidad de registros por archivo.

## Ejemplo de salida

Después de la ejecución, encontrará archivos CSV en el directorio definido por
`EXPORT_DIR`. Ejemplo de archivos generados:

```code
statistics_export_1.csv
statistics_export_2.csv
statistics_export_3.csv
```

Cada archivo contendrá los registros de estadísticas exportados desde Solr, que
pueden importarse directamente en otra instancia de DSpace usando
`solr-import-statistics`.

## Notas y avisos

- Verifique que Solr esté accesible en la URL definida en `URL_BASE` antes de
  ejecutar el script.
- Asegúrese de tener permisos de escritura en el directorio definido por
  `EXPORT_DIR`.
- La cantidad de registros por archivo corresponde a lo definido por
  `PAGINATION_ROWS`.
