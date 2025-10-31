# Tutorial - Agregar nuevos filtros a la búsqueda de DSpace

DSpace permite ampliar y personalizar su búsqueda (Discovery) agregando nuevos filtros.  
Estos filtros pueden mostrarse en la barra lateral de búsqueda, en la página de filtros e incluso en el menú **Navegar (Browse)** de la barra de navegación.  
Este tutorial muestra, paso a paso, cómo configurar un nuevo filtro.

## 1. Crear un *Filter Bean* en `discovery.xml`

Abra el archivo:  
`[dspace-source]/dspace/config/spring/api/discovery.xml`  
Dentro de él, cree un nuevo *bean* de filtro.  
Por ejemplo, para crear un filtro de **Director de tesis** (Advisor en inglés):

```xml
<bean id="searchFilterAdvisor" class="org.dspace.discovery.configuration.DiscoverySearchFilterFacet">
    <!-- Nombre del campo utilizado por el índice de búsqueda y las URL -->
    <property name="indexFieldName" value="advisor"/>

    <!-- Campos de metadatos mapeados para este filtro -->
    <property name="metadataFields">
        <list>
            <value>dc.contributor.advisor</value>
        </list>
    </property>

    <!-- Configuración del facet -->
    <property name="facetLimit" value="5"/>
    <property name="sortOrderSidebar" value="COUNT"/>
    <property name="sortOrderFilterPage" value="COUNT"/>
    <property name="isOpenByDefault" value="true"/>
    <property name="pageSize" value="10"/>
    <property name="exposeMinAndMaxValue" value="true"/>
</bean>
```

**Puntos principales:**  
- `indexFieldName`: Nombre usado en el índice Solr y en la URL del filtro.  
- `metadataFields`: Campos de metadatos de DSpace que utilizará este filtro.  
- `facetLimit`, `pageSize` y `sortOrder*`: Controlan cuántos resultados aparecen y cómo se ordenan.

## 2. Registrar el filtro en la configuración predeterminada

Todavía en `discovery.xml`, localice el *bean* **defaultConfiguration** y agregue su nuevo filtro a sus propiedades.

- Para incluir el filtro en **todos los filtros de búsqueda**:

```xml
<property name="searchFilters">
    <list>
        <!-- otros filtros -->
        <ref bean="searchFilterAdvisor"/>
    </list>
</property>
```

- Para también mostrar el filtro en la **barra lateral (sidebar facets)**:

```xml
<property name="sidebarFacets">
    <list>
        <!-- otros filtros de la barra lateral -->
        <ref bean="searchFilterAdvisor"/>
    </list>
</property>
```

## 3. Exponer el filtro en la barra de navegación (menú “Browse”)

Si desea que el filtro aparezca en la sección **Navegar (Browse)** de la barra de navegación, edite el archivo de configuración (`dspace.cfg` o `local.cfg`, si prefiere sobrescribir localmente) y agregue la siguiente línea:

```ini
webui.browse.index.5 = advisor:metadata:dc.contributor.advisor:text
```

**Explicación:**  
- `advisor`: Debe coincidir con el `indexFieldName` definido en el *bean*. También será el nombre usado en la URL (por ejemplo, `/browse?type=advisor`).  
- `metadata`: Indica que este es un índice basado en metadatos.  
- `dc.contributor.advisor`: Debe coincidir con el campo de metadatos definido en el filtro.  
- `text`: Tipo de campo utilizado para la indexación.  

Puede agregar varios índices de navegación incrementando el número (`.1`, `.2`, `.5`, etc.).

## 4. Recompilar y reiniciar DSpace

Después de modificar la configuración:

4.1. Recompile el backend de DSpace. Dentro de la carpeta `[dspace-source]`, ejecute:

```shell
mvn clean package
cd [dspace-source]/dspace/target/dspace-installer
ant update
```

4.2. Reinicie Tomcat o el contenedor de Spring Boot.

### 5. Reindexar Discovery

Ejecute el siguiente comando para reconstruir el índice de Discovery:

```shell
[dspace]/bin/dspace index-discovery -b
```

## Resultado

La nueva opción estará disponible en el **menú Browse** de la barra de navegación y/o en los **filtros de la barra lateral**, según su configuración.

**Referencia:**  
[https://wiki.lyrasis.org/display/DSDOC9x/Discovery](https://wiki.lyrasis.org/display/DSDOC9x/Discovery)
