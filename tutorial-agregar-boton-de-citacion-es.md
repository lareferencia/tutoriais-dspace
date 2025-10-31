# Tutorial para Agregar el Botón de Cita

Este tutorial agrega al DSpace un botón para generar citas
bibliográficas automáticamente en las páginas de ítems y publicaciones:

::: {align="center"}
    <img alt="boton-de-citacion" src="https://github.com/user-attachments/assets/cca580ac-4d1d-40b9-a414-b3d99c0cbc4a" />
:::

::: {align="center"}
    <img alt="boton-de-citacion-en-la-pagina" src="https://github.com/user-attachments/assets/11bced87-8c39-4672-9501-75ab978deda4" />
:::

## Aplicar el parche en el backend

**Paso 1:** Entra en el directorio del código fuente de DSpace (backend)
y ejecuta:

> \[!WARNING\] Si ocurren conflictos durante la aplicación del parche,
> es responsabilidad de quien lo aplica resolverlos manualmente.

``` bash
cd <dspace-source>
git apply -v <(curl -sL "https://patch-diff.githubusercontent.com/raw/DSpace/DSpace/pull/11451.patch")
```

**Paso 2:** Si el parche se aplica correctamente, continúa:

``` bash
git add . && git commit -m "Agrega endpoint de bibliografía"
```

> \[!IMPORTANT\] Si hay conflicto, después de resolverlo, vuelve al paso
> 1.

**Paso 3:** Después de aplicar el parche, actualiza la instalación y
verifica que funcione normalmente:

``` bash
cd <dspace-source>
mvn clean package
cd dspace/target/dspace-installer
ant update
```

## Aplicar el parche en el frontend

**Paso 1:** Entra en el directorio del código fuente de DSpace Angular
(frontend) y ejecuta:

> \[!WARNING\] De la misma manera, si ocurren conflictos durante la
> aplicación del parche, deben resolverse manualmente.

``` bash
cd <dspace-angular-source>
git apply -v <(curl -sL "https://patch-diff.githubusercontent.com/raw/DSpace/dspace-angular/pull/4779.patch")
git add . && git commit -m "Agrega botón de cita bibliográfica"
```

**Paso 3:** Si utilizas un tema personalizado y has sobrescrito los
componentes
`app/item-page/simple/item-types/untyped-item/untyped-item.component.ts`
y/o el archivo
`app/item-page/simple/item-types/publication/publication.component.ts`,
es necesario agregar el componente `BibliographyComponent` en los
imports de los archivos .ts:
`src/themes/<tu-tema>/app/item-page/simple/item-types/untyped-item/untyped-item.component.ts`
y/o
`src/themes/<tu-tema>/app/item-page/simple/item-types/publication/publication.component.ts`
y agregar el elemento
`<ds-item-bibliography [item]="object" class="my-2"></ds-item-bibliography>`
en los archivos .html:
`src/themes/<tu-tema>/app/item-page/simple/item-types/untyped-item/untyped-item.component.html`
y/o
`src/themes/<tu-tema>/app/item-page/simple/item-types/publication/publication.component.html`.
Debe insertarse como el último elemento dentro del
`<div class="col-xs-12 col-md-4">`. En caso de duda sobre la posición
correcta, revisa los archivos originales para ver su ubicación.

**Paso 2:** Después de aplicar el parche, actualiza y reinicia el
frontend y verifica que funcione correctamente:

``` bash
cd <dspace-angular-source>
npm run start
```

> \[!IMPORTANT\] Si hay conflicto, después de resolverlo, vuelve al paso
> 1.
