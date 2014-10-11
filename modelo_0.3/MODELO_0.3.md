# Modelo v0.3

Los datos electorales y geográficos están dentro de la mismo base de datos, en el esquema `public`.

## Modelo geográfico

Las tablas geográficas son:

* `dpa`
* `jerarquia_dpa`
* `jerarquia_tipos_dpa`
* `tipos_dpa`

Para más detalles, ver https://intranet.geo.gob.bo/proyectos/projects/vice-atlas-electoral/wiki/Dise%C3%B1o_nuevo_-_datos_geogr%C3%A1ficos.

Ver las dos tablas principales
![Tablas principales del modelo geográfico v0.3](../../../raw/master/modelo_0.3/modelo_0.3_img_geo_simple.png "Tablas principales del modelo geográfico v0.3")

y el modelo geográfico completo con las dos tablas opcionales.

![Modelo geográfico v0.3 completo](../../../raw/master/modelo_0.3/modelo_0.3_img_geo_completo.png "Modelo geográfico v0.3 completo")

### Divisiones Politico-Administrativas (DPA)

La tabla `dpa` contiene las **Divisiones Politico-Administrativas (DPA) de Bolivia**, es decir, en una misma tabla se encuentran el país, los departamentos, las provincias, los municipios y las circunscripciones. Estos niveles son listados en la tabla `tipos_dpa`, y la tabla `dpa` tiene una columna `id_tipo_dpa` para hacer el vínculo.

Las tabla `dpa` contiene también columnas para los detalles de identificación de cada DPA:

* `id_dpa`: el identificador en la tabla
* `id_tipo_dpa`: el identificador del tipo de dpa
* `nombre`: nombre de la DPA, por ejemplo `Achacachi`
* `codigo`: para cada tipo de DPA, el código es un identificador único :
 * país: el [código ISO 3166-2](https://es.wikipedia.org/wiki/ISO_3166-2:BO), por ejemplo `BO` para Bolivia,
 * departamento: dos cifras, por ejemplo `02` para La Paz
 * provincia: cuatro cifras, las dos primeras son las del departamento, por ejemplo `0202` para Omasuyos
 * municipio: seis cifras, las cuatro primeras son las de la provincia, por ejemplo `020201` para Achacachi
 * circunscripcion: dos cifras, por ejemplo `09` para la circunscripción C09 (código interno de la Corte)
* `codigo_parcial`: es solo la parte del código que difiere de su superior, por ejemplo `01` para Achacachi, es decir las dos últimas cifras del código para un municipio
* `codigo_ine`: este código solo existe para los municipios, y corresponde a las cinco últimas cifras de la columna `codigo`
* `seccion`: solamente para los municipios, por ejemplo `Primera` para Achachaci

y sus datos geográficos:

* `the_geom`: geometría, en formato postgis (MULTIPOLYGON)
* `extent`: extensión espacial, ie. bounding box
* `area_km2`: superficie en km^2

### Relación jerarquica entre DPA

Adicionalmente, la tabla `dpa` contiene el tipo de DPA y la relación jerarquica entre las DPA (ie. el municipio de Achacachi esta dentro de la provincia de Omasuyos):

* `id_dpa_superior` identifica la línea de la DPA superior en la misma tabla

La tabla `tipos_dpa` también contiene los datos de los niveles jerarquicos en Bolivia:

* `id_tipo_dpa`: el identificador
* `nombre`: por ejemplo `provincia`
* `id_tipo_dpa_superior`: el identificador del tipo de DPA superior, por ejemplo el identificador de `departamento`, para `provincia`

La tabla `tipos_dpa` es la siguiente:

```
| id_tipo_dpa | nombre          | id_tipo_dpa_superior |
|-------------|-----------------|----------------------|
| 1           | pais            |                      |
| 2           | departamento    | 1                    |
| 3           | provincia       | 2                    |
| 4           | municipio       | 3                    |
| 5           | circunscripcion | 2                    |
```

Existen también dos tablas adicionales y opcionales `jerarquia_dpa` y `jerarquia_tipos_dpa` que permiten representar la jerarquía (ie. un arbol) en la base de datos. Están creadas como "closure tables", ver:

* http://karwin.blogspot.com/2010/03/rendering-trees-with-closure-tables.html
* http://kylecordes.com/2008/transitive-closure

Gracias a estas dos tablas, es facil navegar en la jerarquía y buscar hijos, padres, etc. Tienen más que todo un rol de caché, para acelerar las búsquedas, y son totalmente opcionales.

### Modelo temporal para las DPA

Finalmente, la tabla `dpa` contiene también informaciones temporales, todavía solamente para los municipios. En efecto, 311 municipios fueron creados en 1994 en Bolivia, y otros han sido creados en el transcurso del tiempo, por subdivisión de municipios existentes. Para poder modelizar esta relación de subdivisión, la tabla `dpa` contiene las siguientes columnas:

* `id_dpa_madre` identifica el municipio que existía anteriormente y ha sido dividido en 2 (o a veces 3) nuevos municipios
* `fecha_creacion_oficial` es la fecha de creación del municipio en la ley (1994 para la mayoría),
* `fecha_supresion_oficial` es la fecha de supresión del municipio en la ley (para los que han sido divididos en 2),
* `fecha_creacion_corte` y `fecha_supresion_corte` contiene las fechas utilizadas por la Corte Electoral, para reflejar el hecho que algunos municipios recien creados no están tomados en cuenta en los resultados de la elección siguiente. En algunos casos, estas fechas son diferentes de las fechas oficiales.

Por omisión estas fechas toman el valor `-infinity::date` para la fecha de creación, y `+infinity::date` para la fecha de supresión, lo que corresponde a decir que la DPA siempre existió, y siempre existirá.

### Claves, restricciones y trigger

Ver el código para el detalle de las claves (primaria, foreana), restricciones (CONSTRAINT) y funciones de trigger (lanzadas al momento de un INSERT, UPDATE o DELETE) para asegurar la coherencia de los datos. Seguramente se puede mejorar, y habría que documentarlo.

## Modelo electoral

### Tablas principales

Las principales tablas son:
* `elecciones`: las elecciones en Bolivia
* `partidos`: los partidos póliticos que presentan candidatos en las elecciones
* `candidatos`: listas de partidos que se han presentado a cada elección
* `resultados`: resultados de cada candidato en cada elección

Para más detalles, ver https://intranet.geo.gob.bo/proyectos/projects/vice-atlas-electoral/wiki/Dise%C3%B1o_nuevo_-_datos_electorales.

### Tablas secundarias

Las otras tablas son:
* `tipos_eleccion`: tipo de elección entre "general plurinominal", "general uninominal", "constituyente uninominal", etc.
* `tipos_partido`: distinción técnica entre los partidos: `normal` para los partidos póliticos, `tecnico` para los votos en blanco, nulos, etc. y `grupo` para las agrupaciones de "partidos" (más que todo: votos validos, votos emitidios...)
* `jerarquia_partidos`: tabla técnica, de tipo "closure table", para formar los grupos de partidos
* `tipos_resultado`: tipo de resultado (votos, numero de diputados, etc.)
* `tipos_resultado_eleccion_dpa`: relaciona los tipos de resultado, de elección y de DPA. Por ej. para una elección de tipo "gen_plurinominal", a nivel "departamento", debe tener resultados de  "votos", "diputados" y "senadores"

Ver las tablas principales

![Tablas principales del modelo electoral v0.3](../../../raw/master/modelo_0.3/modelo_0.3_img_elec_simple.png "Tablas principales del modelo electoral v0.3")

y el modelo electoral completo

![Modelo electoral v0.3 completo](../../../raw/master/modelo_0.3/modelo_0.3_img_elec_completo.png "Modelo electoral v0.3 completo").
