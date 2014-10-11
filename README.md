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
createdb geoelectoral -O geoelectoral
psql -c "ALTER ROLE geoelectoral SUPERUSER"
psql -d geoelectoral -U geoelectoral -W < dumps/geoelectoral_0.3.sql
psql -c "ALTER ROLE geoelectoral NOSUPERUSER"
exit
```

# Elecciones 2014

Para añadir la base para las elecciones de 2014 (sin resultados):

```
sudo su postgres
psql -d geoelectoral -U geoelectoral -W < script/upgrade_0.3_hacia_0.4.sql
exit
```
