# README

Este repositorio contiene la base de datos electorales del sitio http://geoelectoral.gob.bo.

La base de datos inicial (versión de 2013) es la siguiente: [dumps/geoelectoral_0.3.sql](dumps/geoelectoral_0.3.sql).

# Versiones de la base de datos

Ver el repositorio https://gitlab.geo.gob.bo/adsib/geoelectoral-datos-con-historia para más detalles sobre las diferentes versiones de la base de datos.  Este proyecto fue iniciado en los años 2010-2011 (ingreso y verificación de los datos, y desarrollo de un prototipo de sitio), y esta retomado para publicación en 2013.

* 0.1: los datos electorales fueron ingresados y verificados en este modelo de datos.
* 0.2: una versión de desarrollo en 2011.
* 0.3: basado sobre 0.2, pero retomado a partir en 2013, el modelo esta detallado en [MODELO_0.3.md](modelo_0.3/MODELO_0.3.md). Ver los scripts de migración desde 0.1. A modo de verificación, los datos son los mismos que el dump 0.2.

# Importar la base de datos (versión 0.3)

Primero instalar el servidor PostGreSQL con PostGIS

```
sudo aptitude install postgresql-9.1 postgresql-9.1-postgis postgis
sudo su postgres
dropdb geoelectoral
createuser -DlPRS geoelectoral
createdb geoelectoral -O geoelectoral
psql -c "ALTER ROLE geoelectoral SUPERUSER"
psql -d geoelectoral -h localhost -U geoelectoral -W < dumps/geoelectoral_0.3.sql
psql -c "ALTER ROLE geoelectoral NOSUPERUSER"
exit
```

# Elecciones 2014

## Elección sin resultados

Para añadir la base para las elecciones de 2014 (sin resultados):

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.3_hacia_0.4.sql
```

## Adición de los municipios de Chúa Cocani y Huatajata

Para añadir los municipios de Chúa Cocani y Huatajata:

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.4_hacia_0.5.sql
```

## Adición de las circunscripciones 2014

Para añadir las circunscripciones 2014:

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.5_hacia_0.6.sql
```

## Recalculo de las tablas de jerarquia

Para recalcular las tablas de jerarquia, lanzar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.6_hacia_0.7.sql
```

## Adición de un campo "observacion" en la tabla de resultados

Para añadir un campo "observacion" en la tabla de resultados, lanzar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.7_hacia_0.8.sql
```

## Incorporación de 3 circunscripciones 2014 que faltaban

Para incorporación de 3 circunscripciones 2014 que faltaban en la precedente importación, lanzar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.8_hacia_0.9.sql
```

## Función de incorporación de datos uninominales en circunscripciones:

Para añadir la función de incorporación de datos uninominales en circunscripciones:

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.9_hacia_0.10.sql
```

## Ingreso de resultados

Para los scripts se utiliza el paquete `poppler-utils` el cual es necesario instalar

```
sudo apt-get install poppler-utils
```

Para añadir los resultados plurinominales, lanzar

```
./scripts/parsing_oep_plurinominal.sh
psql -d geoelectoral -h localhost -U geoelectoral -W < /tmp/pluri.sql
```

Para añadir los resultados uninominales, lanzar

```
./scripts/parsing_oep_uninominal.sh
psql -d geoelectoral -h localhost -U geoelectoral -W < /tmp/uni.sql
```
## Datos municipios 2009

Para añadir los resultados del 2009 para municipios ejecutar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.10_hacia_0.11.sql

```

## Plurinominales de municipios 2002

Para añadir los resultados plurinominales de municipios del 2002 ejecutar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.11_hacia_0.12.sql
```

> _Nota:_

> Para obtener el archivo `scripts/upgrade_0.11_hacia_0.12.sql` se utiliza el script `scripts/import_municipios_2002_desde_shapefile.sh`. El script necesita ciertos requisitos descritos en el mismo archivo (revisar el script). El script se debe ejecutar desde la ubicación del archivo shapefile, generando al final el archivo `/tmp/muni2002.sql` el cual corresponde a `scripts/upgrade_0.11_hacia_0.12.sql`

## Geometrías de las circunscripciones 2014 actualizado

En fecha 13-05-2014 se definieron las circunscripciones para las elecciones de Octubre, para actualizar las geometrías ejecutar:

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.12_hacia_0.13.sql
```

## Tabla de versiones

Para hacer seguimiento a las versiones migradas se crea una tabla `versiones` con el nombre del archivo SQL migrado y la fecha.

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.13_hacia_0.14.sql
```

> _Nota:_

> * También se incluyen en la migración los nombres de archivos migrados con anterioridad al archivo SQL `upgrade_0.13_hacia_0.14.sql`.
> * La última fila de ésta tabla corresponde al último archivo SQL migrado.
> * A partir de ahora es necesario adicionar al final de cada archivo SQL `INSERT INTO versiones(descripcion) VALUES
('upgrade_X.X_hacia_X.X.sql')` con la versión correspondiente del upgrade.

## Actualización de datos al 100% elecciones generales 2014

Para el conteo oficial se debe ejecutar

```
psql -d geoelectoral -h localhost -U geoelectoral -W < scripts/upgrade_0.14_hacia_0.15.sql
```