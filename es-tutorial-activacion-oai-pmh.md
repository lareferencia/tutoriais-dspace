
# ⚙️ Servidor OAI-PMH — Activación y Mantenimiento en DSpace

La interfaz OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting) permite que otros sistemas recolecten (harvest) registros de metadatos de su repositorio DSpace.
___

## 1. Activación del Servidor OAI-PMH

El servidor OAI-PMH de DSpace está habilitado por defecto.

Sin embargo, puede activarlo o desactivarlo manualmente en el archivo local.cfg, agregando o ajustando las siguientes configuraciones:

### Para habilitarlo, agregue esta línea de código

    oai.enabled = true

###  Cuando está habilitado, el servidor OAI-PMH estará disponible en esta ruta

    oai.path = oai
> Se você modificar essas configurações, será necessário o servidor.

Puede comprobar si está funcionando accediendo a la siguiente URL:

    [dspace.server.url]/[oai.path]/request?verb=Identify

 Ejemplo: `http://localhost:8080/server/oai/request?verb=Identify`
 La respuesta debe ser similar a la del servidor de demostración de DSpace: https://demo.dspace.org/server/oai/request?verb=Identify

## 2. Mantenimiento del Servidor OAI-PMH
Después de activar el servidor, es necesario asegurarse de que el índice se actualice regularmente. Actualmente, esto no ocurre automáticamente en DSpace.
Para hacerlo, utilice los siguientes comandos:

    [dspace.dir]/bin/dspace oai import 
    [dspace.dir]/bin/dspace index-discovery -b

### 2.1 Programación del índice mediante cron

Ejemplo de configuración cron para actualizar el índice del OAI-PMH diariamente a medianoche:

Actualiza el índice OAI-PMH con el contenido más reciente todos los días a medianoche.

**NOTA: NECESARIO SOLO SI EL OAI-PMH ESTÁ ACTIVO**

    0 0 * * * [dspace.dir]/bin/dspace oai import > /dev/null  
    0 0 * * * [dspace.dir]/bin/dspace index-discovery -b > /dev/null
    
> Esto garantiza que los nuevos contenidos estén disponibles a través del servicio OAI-PMH.
---
**Referencia:** [DSpace Documentation - OAI](https://wiki.lyrasis.org/display/DSDOC10x/OAI)
