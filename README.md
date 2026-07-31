# Mesa de Datos · Plan Estadístico Territorial de Ibagué

Aplicación web para diligenciar los cinco formularios del Plan Estadístico
Territorial (DANE — DIRPEN), articulada con los procesos misionales y el
Listado Maestro del SIGAMI de la Alcaldía de Ibagué.

## Publicar en GitHub Pages

1. Cree una cuenta en github.com, preferiblemente con el correo institucional.
2. Botón **New repository**. Nombre sugerido: `pet-ibague`. Marque **Public**
   (Pages es gratuito solo en repositorios públicos) y créelo.
3. En el repositorio vacío, **uploading an existing file**. Arrastre
   `index.html` y confirme con **Commit changes**.
4. Pestaña **Settings** → menú lateral **Pages**. En *Source* elija
   **Deploy from a branch**, rama `main`, carpeta `/ (root)`. Guarde.
5. Espere entre uno y dos minutos. La dirección queda así:
   `https://SUUSUARIO.github.io/pet-ibague/`

Para actualizar la aplicación más adelante, suba de nuevo `index.html` sobre
el existente: el sitio se refresca solo.

## Conectar la base de datos

1. Siga las instrucciones que están dentro de `backend-google-sheets.gs`.
2. Abra su sitio publicado, vaya a **Consolidado y exportación**, escoja
   destino `sheets`, pegue la URL `/exec` y la palabra clave, y guarde.
3. Oprima **Copiar enlace de la mesa**. Ese es el enlace que se le envía a los
   funcionarios: al abrirlo quedan conectados sin configurar nada.

## Qué es público y qué no

El repositorio es público, así que el código lo puede ver cualquiera. Los datos
diligenciados **no** están ahí: viven en la hoja de cálculo o en la base, que
tienen sus propios permisos.

El enlace de la mesa lleva la clave de escritura. Quien lo tenga puede enviar
registros, pero no leer los de los demás: el Apps Script solo escribe, nunca
devuelve información. Aun así, trátelo como un enlace interno y cambie la clave
en el script cuando termine cada jornada de talleres.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La aplicación completa. Es lo único que se publica. |
| `backend-google-sheets.gs` | Se pega en Apps Script; recibe y guarda los formularios. |
| `esquema-supabase.sql` | Alternativa en PostgreSQL, con vistas listas para Power BI. |

## Antes del primer taller

- Cargue el Listado Maestro en **Catálogo SIGAMI** (plantilla CSV descargable
  desde esa misma pantalla).
- Verifique que al elegir una dependencia aparezcan sus formatos aprobados.
- Haga una prueba completa: diligencie un F3, guárdelo y confirme que la fila
  llegó a la hoja de cálculo.
