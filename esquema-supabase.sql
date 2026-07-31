-- =====================================================================
-- Mesa de Datos · Plan Estadístico Territorial de Ibagué
-- Esquema para Supabase (PostgreSQL)
--
-- Úselo si quiere una base de datos de verdad en lugar de una hoja de
-- cálculo: consultas SQL, conexión directa desde Power BI y desde Python.
--
-- Instalación: cree un proyecto en supabase.com, abra el SQL Editor,
-- pegue todo esto y ejecute. Luego copie la URL del proyecto y la clave
-- "anon" en la pestaña Consolidado de la aplicación.
-- =====================================================================

create table if not exists respuestas (
  id            text primary key,          -- id que genera la aplicación
  formato       text not null,             -- F1, F3, A2, F2, SAT
  dependencia   text,
  proceso       text,
  titulo        text,
  actualizado   timestamptz default now(),
  datos         jsonb not null,            -- todas las preguntas del formato
  recibido      timestamptz default now()
);

create index if not exists idx_respuestas_formato     on respuestas (formato);
create index if not exists idx_respuestas_dependencia on respuestas (dependencia);
create index if not exists idx_respuestas_datos       on respuestas using gin (datos);

-- Catálogo del SIGAMI, para medir cobertura desde la base
create table if not exists formatos_sigami (
  codigo      text primary key,
  dependencia text,
  proceso     text,
  nombre      text,
  version     text,
  tipo        text
);

-- ---------------------------------------------------------------------
-- Seguridad
-- La aplicación escribe con la clave pública "anon". Se permite insertar
-- y actualizar, pero no leer ni borrar: quien consulta lo hace desde el
-- panel de Supabase o con la clave de servicio, nunca desde el navegador
-- de un funcionario.
-- ---------------------------------------------------------------------
alter table respuestas enable row level security;

create policy "la app puede insertar"   on respuestas for insert to anon with check (true);
create policy "la app puede actualizar" on respuestas for update to anon using (true) with check (true);

-- ---------------------------------------------------------------------
-- Vistas de trabajo
-- ---------------------------------------------------------------------

-- Avance por dependencia y formato: el tablero de la jornada
create or replace view v_avance as
select dependencia,
       formato,
       count(*)                                   as registros,
       max(actualizado)                           as ultimo_movimiento
from respuestas
group by dependencia, formato
order by dependencia, formato;

-- Cobertura del Listado Maestro: qué se caracterizó y qué falta
create or replace view v_cobertura_sigami as
select f.dependencia,
       f.codigo,
       f.nombre,
       f.tipo,
       (r.id is not null) as caracterizado,
       r.formato,
       r.actualizado
from formatos_sigami f
left join respuestas r
       on r.datos ->> 'SIGAMI · código Listado Maestro' like f.codigo || '%'
order by f.dependencia, f.codigo;

-- Inventario de registros administrativos, aplanado para Power BI
create or replace view v_registros_administrativos as
select id,
       dependencia,
       proceso,
       datos ->> 'B1 Nombre oficial del registro administrativo' as registro,
       datos ->> 'B2 Objetivo del registro administrativo'       as objetivo,
       datos ->> 'B8 Unidad de observación del registro'         as unidad_observacion,
       datos ->> 'B10 Variable llave o de identificación única'  as variable_llave,
       datos ->> 'B15 Frecuencia con que se recolectan los datos' as frecuencia,
       datos ->> 'B22 Cobertura geográfica del registro'         as cobertura,
       datos ->> 'B24 Desagregación por grupos'                  as desagregacion_grupos,
       datos ->> 'B25 ¿La entidad usa estos datos para generar información estadística?' as uso_estadistico,
       datos ->> 'B26 ¿Usuarios externos tienen acceso a los datos?' as acceso_externo,
       actualizado
from respuestas
where formato = 'F3';

-- Demandas priorizadas: el insumo del día 4
create or replace view v_demandas as
select id,
       dependencia,
       datos ->> '1 Indicador o requerimiento de información estadística' as requerimiento,
       datos ->> '11 Nivel de prioridad de la gestión de esta demanda'    as prioridad,
       datos ->> '9 Entidad que considera debe producir la información'   as entidad_productora,
       datos ->> '13 Desagregación geográfica requerida'                  as desagregacion,
       actualizado
from respuestas
where formato = 'F2';
