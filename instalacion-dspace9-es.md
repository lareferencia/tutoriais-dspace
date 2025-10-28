# Instalación de DSpace 9 desde cero

Este tutorial proporciona una guía paso a paso para instalar DSpace 9 desde cero de forma simplificada.
### 1. Configurando el entorno
- JDK 17
- Maven 3.8+
- Ant 1.10+
- PostgreSQL 12+
- [Solr 9.x](https://solr.apache.org/guide/solr/latest/deployment-guide/installing-solr.html)
- Node.js 22+
- PM2 (para la gestión del frontend Angular en producción)


---

### 2. Configurando la base de datos
Después de instalar PostgreSQL, cree la base de datos y el usuario para DSpace.

#### 2.1 Acceda a PostgreSQL como administrador:
```
sudo -u postgres psql
```

#### 2.2 Cree un usuario (sustituya 'dspace#pass' por una contraseña fuerte):

```
CREATE USER dspace WITH PASSWORD 'dspace#pass';
```

#### 2.3 Cree la base de datos DSpace y asigne la propiedad:

```
CREATE DATABASE dspace OWNER dspace;
```

#### 2.4 Conceda todos los privilegios al usuario:

```
GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;
```

#### 2.5 Active la extensión `pgcrypto`:

```
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

#### 2.6 Salga del prompt de PostgreSQL:

```
\q
```

---

### 3. Instalar el backend de DSpace (API REST)
Descargue la última versión del **backend de DSpace** del [sitio web oficial](https://dspace.org/download/) y descomprímala. Llamaremos a la carpeta extraída **[DSpace Source]**.

#### 3.1 Cree el directorio de instalación (utilizaremos /dspace):
```
cd /
mkdir dspace
chown [usuario-en-ejecucion] dspace
```

En esta parte utilizaremos las siguientes nomenclaturas:
> `[dspace]` → Directorio de instalación para DSpace (`/dspace`)
> `[DSpace Source]` → Carpeta que contiene el código fuente de DSpace

#### 3.2 Copie y edite el archivo de configuración
```
cp [DSpace Source]/dspace/config/local.cfg.EXAMPLE [DSpace Source]/dspace/config/local.cfg
```

Configuraciones mínimas:
```
dspace.dir=/dspace
dspace.server.url=http://[host]/server
dspace.ui.url=https://[host]
solr.server=http://localhost:8983/solr
db.url=jdbc:postgresql://localhost:5432/dspace
db.username=dspace
db.password=<DB Password>
```

Explicación

 - `dspace.dir`: Directorio de instalación de DSpace
 - `dspace.server.url`: URL pública del backend (API REST)
 - `dspace.ui.url`: URL pública del frontend Angular
 - `solr.server`: URL del servidor Solr
 - `db.url`: URL de conexión de la base de datos
 - `db.username` / `db.password`: Credenciales de la base de datos

#### 3.3 Construya el backend:
```
mvn package
```
#### 3.4 Instálelo usando Ant:
```
cd [DSpace Source]/dspace/target/dspace-installer
ant fresh_install
```
#### 3.5 Actualice el esquema de la base de datos:
```
[dspace]/bin/dspace database migrate
```
#### 3.6 Configure Solr:
```
cp -R [dspace]/solr/* [solr]/server/solr/configsets
```
#### 3.7 Reinicie Solr:
```
[solr]/bin/solr stop
[solr]/bin/solr start -Dsolr.config.lib.enabled=true
```
#### 3.8 Inicie el backend de DSpace:
```
java -jar /dspace/webapps/server-boot.jar
```
Acceda a la API en: http://[host]:8080/server

**Recomendación (producción):** Configure el `server.boot.jar` como un servicio de Linux (a través de `systemd` u otro servicio de gestión), y se ejecutará automáticamente y se reiniciará si falla.



### 4. Instalando el Frontend Angular
Descargue la última versión de la **UI de DSpace** del [sitio web oficial](https://dspace.org/download/) y descomprímala.

#### 4.1 Instale las dependencias:
```
npm install
```
#### 4.2 Copie y configure el archivo de configuración para producción:
```
cp config/config.example.yml config/config.prod.yml
```
Configuración de ejemplo:
```
ui:
    ssl: false
    host: [host-front]
    port: 4000
    nameSpace: /
rest:
  ssl: false
  host: [host-server]
  port: 8080
  nameSpace: /server
  ssrBaseUrl: http://localhost:8080/server
```
Esto conecta el frontend Angular con la API REST de DSpace.

#### 4.3 Inicie la UI manualmente:
```
npm start
```
#### 4.4 Para ejecutar Angular con PM2 (recomendado para producción), cree un archivo `dspace-ui.json`:
```
    {
	    "apps": [
		   {
			   "name": "dspace-ui",
			   "cwd" : "/full/path/[dspace-angular]",
			   "script": "dist/server/main.js",
			   "env": {
				   "NODE_ENV": "production"
				   }
			}
		]
	}
```
Inicie con:
```
pm2 start dspace-ui.json
```

### 5. Cree un Usuario Administrador
```
[dspace]/bin/dspace create-administrator
```
### Referencias
-  [Installing DSpace](https://wiki.lyrasis.org/display/DSDOC8x/Installing+DSpace)
