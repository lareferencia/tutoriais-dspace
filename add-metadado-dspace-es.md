
# Paso a paso: Cómo insertar metadatos en DSpace

Esta guía describe, paso a paso, cómo **crear un nuevo campo de metadatos en DSpace** utilizando la interfaz administrativa.

----------

## 1. Acceder a DSpace como administrador

1.  Abra DSpace en el navegador.
    
2.  Inicie sesión con una cuenta que tenga **perfil de administrador**.
    


----------

## 2. Acceder al menú de administración

1.  Después de iniciar sesión, localice la **barra lateral** de DSpace.
    
2.  Haga clic en él.
    

<img width="53" height="569" alt="barra lateral dspace" src="https://github.com/user-attachments/assets/467d5357-1501-4654-8602-b4d2064993a3" />

----------

## 3. Navegar hasta el área de metadatos

En el menú administrativo:

1.  Haga clic en **Registros**.
    
2.  Luego, haga clic en **Metadatos**.
    

Esto abrirá la página de gestión de esquemas y campos de metadatos.

<img width="274" height="559" alt="menu registros-metadatos" src="https://github.com/user-attachments/assets/b8b7b841-5a14-43bc-8080-63da68891fea" />

----------

## 4. Seleccionar el esquema de metadatos

1.  En la página de metadatos, localice la opción para **seleccionar el esquema**.
    
2.  Elija el esquema deseado.
    

Ejemplos:

-   `dublin core`
    
-   `local`
    
-   otro esquema personalizado
    

> ℹ️ El esquema **Dublin Core** (`dc`) es el más utilizado por defecto en DSpace.

<img width="1216" height="808" alt="esquemas metadatos" src="https://github.com/user-attachments/assets/a8ef341a-6363-4062-99b6-8e0fb243407f" />

----------

## 5. Crear un nuevo campo de metadatos

Después de seleccionar el esquema:

1.  Haga clic en el botón **Crear campo de metadatos**.
    
2.  Se mostrará un formulario para completar los datos del nuevo metadato.
    

<img width="1213" height="451" alt="crear campo de metadatos" src="https://github.com/user-attachments/assets/6f436b56-e6da-4469-bdca-81a72c29a7c6" />

----------

## 6. Completar los datos del metadato

En el formulario de creación, complete los siguientes campos:

### 🔹 Elemento *

-   Campo **obligatorio**.
    
-   Representa el nombre principal del metadato.
    

Ejemplo:

```
subject

```

----------

### 🔹 Calificador

-   Campo **opcional**.
    
-   Sirve para especializar el elemento.
    

Ejemplos:

```
cnpq
por
lattes

```

> ℹ️ Si se deja en blanco, el metadato será solamente `dc.element`.

----------

### 🔹 Nota de alcance

-   Campo **opcional**.
    
-   Se utiliza para describir la finalidad del metadato.
    
-   Ayuda a administradores y catalogadores a entender cómo debe usarse el campo.
    

Ejemplo:

```
Área del conocimiento según la clasificación del CNPq

```


----------

## 7. Guardar el metadato

1.  Después de completar los campos, haga clic en **Guardar**.
    
2.  El nuevo metadato pasará a formar parte del esquema seleccionado.
    



----------

## 8. Uso del metadato

Una vez creado:

-   El metadato puede utilizarse en:
    
    -   **Formularios de envío (submission forms)**
        
    -   **Configuraciones de búsqueda y facetas (Discovery/Solr)**
        
    -   **Visualización de ítems**
        

> ⚠️ Dependiendo del caso, puede ser necesario:

-   Limpiar la caché
    
-   Reindexar Solr
    
-   Ajustar el formulario de envío
    

----------

## 📌 Ejemplo final de metadato

```
Esquema: dc
Elemento: subject
Calificador: cnpq
Resultado: dc.subject.cnpq

```

----------

✅ ¡Listo! El metadato se creó correctamente y ya puede integrarse en las demás configuraciones de DSpace.
