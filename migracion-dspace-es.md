# Tutorial de Migración de DSpace 5/6 a DSpace 8 o 9

Este tutorial describe, de manera detallada y ordenada, el paso a paso del proceso de migración de una instalación antigua de DSpace (versiones 5 o 6) a las versiones más recientes (8 o 9). El objetivo es garantizar que todos los datos, configuraciones y estadísticas se preserven, además de orientar en la preparación del entorno y en la instalación del backend (Java) y frontend (Angular).

> 💡 **Convención utilizada en este tutorial**
> Para facilitar la lectura y evitar ambigüedades, las rutas y directorios se representarán según la convención siguiente:
>
> * **`[dspace-antiguo]`** → Directorio de instalación del **DSpace antiguo**
> * **`[dspace]`** → Directorio de instalación del **nuevo DSpace**
> * **`[dspace-source]`** → Directorio que contiene el **código fuente** del nuevo DSpace

## 📦 1. Preparación del Entorno

Instale los siguientes softwares en el nuevo servidor:

* JDK 17
* Maven 3.8.x
* Ant 1.10+
* PostgreSQL 12.x o superior (con la extensión pgcrypto)
* Solr

  * DSpace 8 → [Solr 8.x](https://solr.apache.org/guide/8_11/installing-solr.html)
  * DSpace 9 → [Solr 9.x](https://solr.apache.org/guide/solr/latest/deployment-guide/installing-solr.html)
* [Node.js v22.x](https://nodejs.org/en/download)
* [Yarn](https://www.npmjs.com/package/yarn) (DSpace 8)
* [PM2](https://www.npmjs.com/package/pm2)

## 💾 2. Respaldo de los Datos Existentes

> Haga un respaldo completo de la instalación antigua de DSpace **antes de iniciar la migración.**

### 2.1 Haga un dump de la base de datos PostgreSQL

Realice un dump completo (respaldo) de la base de datos PostgreSQL actual para garantizar la preservación de los datos durante la migración y posterior importación en la nueva versión.

```
pg_dump -U [db_username] -h [host] -p 5432 [db_name] > dump.sql
```

### 2.2 Exporte las estadísticas de Solr

Para garantizar que las estadísticas de SOLR se preserven y puedan ser utilizadas en la nueva instalación, es necesario exportarlas del sistema antiguo. Estos datos incluyen información importante de autoridad (`authority`) y estadísticas de uso (`statistics`), que ayudan en el mantenimiento y análisis de la base.

Ejecute los siguientes comandos en el directorio de instalación del DSpace antiguo:

```
[dspace-antiguo]/bin/dspace solr-export-statistics -i authority
[dspace-antiguo]/bin/dspace solr-export-statistics -i statistics
```

La ejecución de estos comandos generará, dentro del directorio `[dspace-antiguo]`, una carpeta llamada `solr-export` que contiene los archivos CSV exportados con las estadísticas de Solr.

### 2.3 Haga una copia del directorio `assetstore`

El directorio **assetstore** se encuentra en la instalación del DSpace y contiene todos los archivos almacenados en el sistema, incluidos subdirectorios y sus contenidos. Para garantizar que ningún dato se pierda durante la migración, es fundamental copiar todo el contenido de esta carpeta. Puede optar por comprimirla (zip) para facilitar la transferencia o copiar directamente el directorio completo a un lugar seguro.

Ejemplo de comando para copiar:

```
cp -r [dspace-antiguo]/assetstore /ruta/de/respaldo/
```

## 🗃️ 3. Preparación de la Base de Datos

### 3.1 Cree una base de datos y un usuario para DSpace

Primero, acceda al terminal de PostgreSQL con el usuario administrador:

```
sudo -u postgres psql
```

En el prompt de PostgreSQL, ejecute los siguientes comandos. Las líneas que comienzan con `--` son comentarios explicativos y no deben ser digitadas. Se recomienda reemplazar `#mysafepassword#` por una contraseña segura de su elección.

```sql
-- Crea un nuevo usuario llamado "dspace" con la contraseña definida.
CREATE USER dspace WITH PASSWORD '#mysafepassword#';
-- Crea una nueva base de datos llamada "dspace" y asigna al usuario "dspace" como propietario.
CREATE DATABASE dspace OWNER dspace;
-- Concede todos los privilegios en la base de datos "dspace" al usuario "dspace".
GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;
-- Conéctese a la base de datos "dspace" para ejecutar comandos dentro de ella.
\c dspace
-- Activa la extensión "pgcrypto", que proporciona funciones criptográficas necesarias para DSpace.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Verifica que la extensión "pgcrypto" está instalada en la base de datos.
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
-- Salir del terminal de PostgreSQL.
exit
```

### 3.2 Importe el dump de la base de datos

Para restaurar los datos de la base antigua en la nueva instalación, importe el archivo de respaldo (`dump.sql`) generado previamente. Este comando ejecuta el archivo SQL y recrea todas las tablas, datos y estructuras en la base de datos `dspace`.

Ejecute el siguiente comando, reemplazando `<ruta-absoluta>/dump.sql` por la ruta real de su archivo de respaldo:

```
psql -U dspace -d dspace -f "<ruta-absoluta>/dump.sql"
```

* `-U dspace`: especifica el usuario de la base de datos que realizará la importación.
* `-d dspace`: indica la base de datos de destino donde se restaurarán los datos.
* `-f "<ruta-absoluta>/dump.sql"`: apunta al archivo SQL que contiene el respaldo a restaurar.

## ⚙️ 4. Instalación del Backend (Servidor)

### 4.1 Descargue el código fuente de la versión deseada

Acceda al [repositorio oficial de DSpace en GitHub](https://github.com/DSpace/DSpace/tags), localice la etiqueta de la versión que desea instalar (por ejemplo, `dspace-9.0`) y descargue el archivo `.zip` o `.tar.gz`. Luego, extraiga el contenido en un directorio de trabajo, que llamaremos **`dspace-source`**.

### 4.2 Cree el directorio de instalación

Cree el directorio donde se instalará DSpace y conceda permisos al usuario que lo ejecutará:

```
mkdir [dspace]
chown [usuario-ejecucion] [dspace]
```

* `[dspace]` será el directorio final de instalación.
* `[usuario-ejecucion]` debe reemplazarse por el usuario del sistema que ejecutará DSpace.

### 4.3 Configure las variables de entorno del DSpace Servidor

El archivo `local.cfg` define parámetros esenciales de configuración. Navegue al directorio `[dspace-source]/dspace/config`, copie `local.cfg.EXAMPLE` a `local.cfg` y edite, como mínimo, las siguientes variables:

```
dspace.dir=/dspace                              
dspace.server.url=https://[host]/server     
dspace.ui.url=https://[host]                
solr.server=http://localhost:8983/solr           
db.url=jdbc:postgresql://localhost:5432/dspace   
db.username=dspace                               
db.password=#mysafepassword#
```

⚠️ Reemplace los valores de ejemplo por los reales de su entorno.

### 4.4 Compile DSpace

Compile el código fuente para generar los archivos necesarios a la instalación:

```
cd [dspace-source]
mvn package
```

Esto descargará dependencias, compilará el código y creará los paquetes en `dspace/target/dspace-installer`.

### 4.5 Instale DSpace Servidor

Después de compilar, ejecute el instalador para crear la estructura de directorios y copiar los archivos al directorio de instalación `[dspace]`:

```
cd [dspace-source]/dspace/target/dspace-installer
ant fresh_install
```

El parámetro `fresh_install` asegura que la instalación se haga desde cero, sin usar datos o configuraciones de instalaciones anteriores.

## 📁 5. Migración de Datos

### 5.1 Copie el directorio `assetstore` antiguo al nuevo directorio de instalación

```
cp -r [backup-assetstore-antiguo] [dspace]/
```

### 5.2 Ejecute la migración de la base de datos a la nueva versión

```
# Desde DSpace 6.x o anterior
[dspace]/bin/dspace database migrate ignored

# Desde DSpace 7.x o superior
[dspace]/bin/dspace database migrate
```

### 5.3 Copie los cores de Solr

```
cp -R [dspace]/solr/* [solr]/server/solr/configsets
```

### 5.4 Reinicie Solr

```
[solr]/bin/solr stop
[solr]/bin/solr start -Dsolr.config.lib.enabled=true
```

### 5.5 Importe las estadísticas de Solr

Para importar as estatísticas exportadas do Solr para a nova instalação do DSpace, execute os seguintes comandos:

```
[dspace]/bin/dspace solr-import-statistics -i authority -d [/path/solr-export]
[dspace]/bin/dspace solr-import-statistics -i statistics -d [/path/solr-export]
```
O parâmetro -d é opcional e serve para indicar o caminho onde estão localizados os arquivos CSV exportados.
Se não for informado, o diretório padrão utilizado será [dspace]/solr-export.

### 5.6 Reindexe todo el contenido

```
[dspace]/bin/dspace index-discovery -b
[dspace]/bin/dspace oai import
```

### 5.7 Inicie la aplicación backend

```
java -jar /dspace/webapps/server-boot.jar
```

Acceda a `http://[host]:8080/server` para verificar la API REST.

## 🌐 6. Instalación del Frontend (Angular)

### 6.1 Descargue el código fuente

Acceda al [repositorio dspace-angular](https://github.com/DSpace/dspace-angular/tags), seleccione la versión deseada y descargue el código.

### 6.2 Instalación de dependencias y compilación

```
cd [dspace-angular]
# DSpace 8
yarn install
yarn run build:prod
# DSpace 9
npm install
npm run build:prod
```

### 6.3 Configure las variables de entorno del frontend

```
cp config/config.example.yml config/config.prod.yml
```

Edite según su entorno:

```
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
```

### 6.4 Inicie la aplicación manualmente

```
# DSpace 8
yarn start
# DSpace 9
npm start
```

Acceda a `http://[host]:4000` para verificar la interfaz web.

## 🔐 7. Crear cuenta de administrador

```
/dspace/bin/dspace create-administrator
```

Ingrese correo electrónico, nombre completo y contraseña.

## ⚠️ Formularios de envío

A partir de DSpace 7, los archivos de configuración de envío han cambiado. La migración debe realizarse manualmente.

## 📚 Referencias

* 📘 [Migrating DSpace to a new server](https://wiki.lyrasis.org/display/DSDOC8x/Migrating+DSpace+to+a+new+server)
* 🛠️ [Installing DSpace](https://wiki.lyrasis.org/display/DSDOC8x/Installing+DSpace)
* 🔁 [Upgrading DSpace](https://wiki.lyrasis.org/display/DSDOC8x/Upgrading+DSpace)
* 📊 [SOLR Statistics Maintenance](https://wiki.lyrasis.org/display/DSDOC8x/SOLR+Statistics+Maintenance)
* ⚙️ [User Interface Configuration](https://wiki.lyrasis.org/display/DSDOC9x/User+Interface+Configuration)
* 🎨 [User Interface Customization (Angular)](https://wiki.lyrasis.org/display/DSDOC9x/User+Interface+Customization)
