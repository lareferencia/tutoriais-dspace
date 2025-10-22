
# Tutorial - Adicionando novos filtros à busca do DSpace

O DSpace permite estender e personalizar sua busca (Discovery) adicionando novos filtros. Esses filtros podem ser exibidos na barra lateral de busca, na página de filtros e até mesmo no menu **Navegar (Browse)** da barra de navegação.  
Este tutorial mostra, passo a passo, como configurar um novo filtro.  
## 1. Criar um *Filter Bean* em `discovery.xml`  
Abra o arquivo:  
`[dspace-source]/dspace/config/spring/api/discovery.xml`
Dentro dele, crie um novo *bean* de filtro.  
Por exemplo, para criar um filtro de **Orientador** (Advisor em inglês):  

```xml
<bean id="searchFilterAdvisor" class="org.dspace.discovery.configuration.DiscoverySearchFilterFacet">
    <!-- Nome do campo usado pelo índice de busca e pelas URLs -->
    <property name="indexFieldName" value="advisor"/>

    <!-- Campos de metadados mapeados para este filtro -->
    <property name="metadataFields">
        <list>
            <value>dc.contributor.advisor</value>
        </list>
    </property>

    <!-- Configuração do facet -->
    <property name="facetLimit" value="5"/>
    <property name="sortOrderSidebar" value="COUNT"/>
    <property name="sortOrderFilterPage" value="COUNT"/>
    <property name="isOpenByDefault" value="true"/>
    <property name="pageSize" value="10"/>
    <property name="exposeMinAndMaxValue" value="true"/>
</bean>
```
**Pontos principais:**  
- `indexFieldName`: Nome usado no índice Solr e na URL do filtro.  
- `metadataFields`: Campos de metadados do DSpace que esse filtro utilizará.  
- `facetLimit`, `pageSize` e `sortOrder*`: Controlam quantos resultados aparecem e como são ordenados.  
## 2. Registrar o Filtro na Configuração Padrão  
Ainda em `discovery.xml`, localize o *bean* **defaultConfiguration** e adicione seu novo filtro às propriedades dele.  
- Para incluir o filtro em **todos os filtros de busca**:  
```xml
<property name="searchFilters">
    <list>
        <!-- outros filtros -->
        <ref bean="searchFilterAdvisor"/>
    </list>
</property>
```
- Para também exibir o filtro na **barra lateral (sidebar facets)**:  
```xml
<property name="sidebarFacets">
    <list>
        <!-- outros filtros da barra lateral -->
        <ref bean="searchFilterAdvisor"/>
    </list>
</property>
```
## 3. Expor o Filtro na Barra de Navegação (Menu “Browse”)  
Se desejar que o filtro apareça na seção **Navegar (Browse)** da barra de navegação, edite o arquivo de configuração (`dspace.cfg` ou `local.cfg`, se preferir sobrescrever localmente) e adicione a seguinte linha:  
```ini
webui.browse.index.5 = advisor:metadata:dc.contributor.advisor:text
```
**Explicação:**  
- `advisor`: Deve corresponder ao `indexFieldName` definido no *bean*. Também será o nome usado na URL (ex.: `/browse?type=advisor`).  
- `metadata`: Indica que este é um índice baseado em metadados.  
- `dc.contributor.advisor`: Deve corresponder ao campo de metadados definido no filtro.  
- `text`: Tipo de campo usado para indexação.  

Você pode adicionar vários índices de navegação incrementando o número (`.1`, `.2`, `.5`, etc.).  
## 4. Recompilar e Reiniciar o DSpace  
Após modificar a configuração:  
4.1. Recompile o backend do DSpace. Dentro da pasta `[dspace-source]`, execute:  
```shell
mvn clean package
cd [dspace-source]/dspace/target/dspace-installer
ant update
```

4.2. Reinicie o Tomcat ou o contêiner do Spring Boot.  
### 5. Reindexar o Discovery  
Execute o seguinte comando para reconstruir o índice do Discovery:  
```shell
[dspace]/bin/dspace index-discovery -b
```
## Resultado  
A nova opção estará disponível no **menu Browse** da barra de navegação e/ou nos **filtros da barra lateral**, dependendo da sua configuração.  

**Referência:**  
[https://wiki.lyrasis.org/display/DSDOC9x/Discovery](https://wiki.lyrasis.org/display/DSDOC9x/Discovery)
