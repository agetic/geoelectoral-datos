#!/bin/bash

# El scrip requiere de una base de datos temporal en éste caso "muni2002"
# con soporte para postgis, también requiere del nombre de base de datos de
# Geoelectoral en éste caso es "geoelectoral".

PGUSER=postgres              # Usuario de la base de datos
PGPASSWORD=postgres          # Password del usuario de base de datos
BASE_DATOS=muni2002          # Base de datos temporal con soporte para PostGIS
BD_GEOELECTORAL=geoelectoral # Base de datos de GeoElectoral

SHAPEFILE=bolivia_SimplifyPolygon.shp # Archivo shapefile
TABLA_ORIGEN=bolivia_simplifypolygon  # Tabla origen del archivo shapefile
TABLA=muni2002                        # Nombre de tabla temporal

# Exportación del Shapefile a PostGIS
shp2pgsql -s 4326 -I -W LATIN1 $SHAPEFILE > /tmp/$TABLA.sql

# Eliminando la tabla existente
psql -U $PGUSER -d $BASE_DATOS -c "DROP TABLE IF EXISTS $TABLA; DROP TABLE IF EXISTS $TABLA_ORIGEN;"
psql -U $PGUSER -d $BASE_DATOS -f /tmp/$TABLA.sql
psql -U $PGUSER -d $BASE_DATOS -c "ALTER TABLE $TABLA_ORIGEN RENAME TO $TABLA;"
psql -U $PGUSER -d $BASE_DATOS -c "ALTER TABLE $TABLA DROP COLUMN geom;"
pg_dump -U $PGUSER $BASE_DATOS -t $TABLA > /tmp/$TABLA.sql

# Eliminar la tabla de la base de datos temporal
psql -U $PGUSER -d $BASE_DATOS -c "DROP TABLE IF EXISTS $TABLA;"

# Cargar la tabla en geoelectoral
psql -U $PGUSER -d $BD_GEOELECTORAL -c "DROP TABLE IF EXISTS $TABLA;"
psql -U $PGUSER -d $BD_GEOELECTORAL -f /tmp/$TABLA.sql

rm /tmp/$TABLA.sql

# Creación del encabezado para el archivo sql
psql -E -U $PGUSER -q -t -o /tmp/$TABLA.sql -d $BD_GEOELECTORAL << EOF
  SELECT 'INSERT INTO resultados(id_eleccion, id_candidato, id_partido, id_tipo_partido, id_dpa, id_tipo_dpa, id_tipo_resultado, resultado) VALUES ';
EOF

# Lista de parámetros:
#   $1 id_eleccion
#   $2 id_partido
#   $3 id_tipo_partido
#   $4 id_tipo_resultado
#   $5 campo con el nombre del partido
#   $6 fecha de la elección
function resultados_muni {
psql -E -U $PGUSER -q -t -o /tmp/$TABLA.tmp.sql -d $BD_GEOELECTORAL << EOF
  SELECT
    '(' || $1 || ', ' ||      -- id_eleccion
    (SELECT id_candidato FROM candidatos WHERE id_partido=$2 LIMIT 1) || ', ' || -- id_candidato
    $2 || ', ' ||             -- id_partido
    $3 || ', ' ||             -- id_tipo_partido
    d.id_dpa  || ', ' ||      -- id_dpa
    d.id_tipo_dpa  || ', ' || -- id_tipo_dpa
    $4  || ', ' ||            -- id_tipo_resultado
    "$5"  || '),'             -- resultado
    FROM "$TABLA" m LEFT JOIN dpa d ON m.codigo=d.codigo
    WHERE fecha_creacion_corte <= '$6' AND '$6' <= d.fecha_supresion_corte;
EOF

cat /tmp/$TABLA.tmp.sql >> /tmp/$TABLA.sql
rm /tmp/$TABLA.tmp.sql
}

# reseter

# CONDEPA 46
resultados_muni 12 46 1 1 "condepa" "2002-06-30"
# UCS 67
resultados_muni 12 67 1 1 "ucs" "2002-06-30"
# NFR 11
resultados_muni 12 11 1 1 "nfr" "2002-06-30"
# MCC 9
resultados_muni 12 9 1 1 "mcc" "2002-06-30"
# ADN 26
resultados_muni 12 26 1 1 "adn" "2002-06-30"
# MIR 37
resultados_muni 12 37 1 1 "mir" "2002-06-30"
# MAS 25
resultados_muni 12 25 1 1 "mas" "2002-06-30"
# MIP 60
resultados_muni 12 60 1 1 "mip" "2002-06-30"
# MNR 78
resultados_muni 12 78 1 1 "mnr" "2002-06-30"
# PS 61
resultados_muni 12 61 1 1 "ps" "2002-06-30"
# LJ 8
resultados_muni 12 8 1 1 "lj" "2002-06-30"

# Eliminación de la tabla temporal $TABLA
psql -U $PGUSER -d $BD_GEOELECTORAL -c "DROP TABLE IF EXISTS $TABLA;"

# Eliminando líneas blancas en el archivo y cambiando la última coma por ";"
sed -i '/^$/d' /tmp/$TABLA.sql
sed -i '$s/,$/;/' /tmp/muni2002.sql

echo
echo "*** Se generó un archivo /tmp/$TABLA.sql con las sentencias SQL. ***"
echo
