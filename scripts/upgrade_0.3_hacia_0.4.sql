-------------------------------------------
-- Adición datos de las elecciones 2014 (antes de los resultados)
-------------------------------------------

-------------------------------------------
-- Paso 0 - añadimos restricciones para asegurar la integridad referencial
-------------------------------------------

-- no poder borrar una elección si existen candidatos
ALTER TABLE public.candidatos ADD CONSTRAINT fk_candidatos_elecciones_id_eleccion FOREIGN KEY (id_eleccion)
  REFERENCES public.elecciones (id_eleccion) MATCH FULL
  ON UPDATE NO ACTION ON DELETE NO ACTION;

-- no poder llenar dos veces la misma elección
ALTER TABLE public.elecciones ADD CONSTRAINT elecciones_unique_fecha_descripcion UNIQUE (fecha, descripcion);

-------------------------------------------
-- Paso 1 - creación de los partidos
-------------------------------------------

-- ya existen los partidos MAS (MAS-IPSP) y PDC.
-- creación de los partidos MSM, UD y PVB (PVB-IEP)
INSERT INTO public.partidos (id_tipo_partido, nombre, sigla, color1, color2, color3) VALUES
  (1, 'Movimiento Sin Miedo', 'MSM', '84FE02', '0134FE', ''),
  (1, 'Partido Verde de Bolivia-Instrumento de la Ecología Política', 'PVB-IEP', '375D32', '', ''),
  (1, 'Unidad Demócrata', 'UD', 'FDCA38', 'FFFFFF', '0D944B');
-- corrección de los colores del PDC
UPDATE public.partidos SET
  "color1" = 'FC0000',
  "color2" = 'FEFEFE',
  "color3" = '00A300'
  WHERE "id_partido" = '43';

-- Verificación

SELECT * FROM partidos WHERE sigla IN ('MAS', 'PDC', 'UD', 'MSM', 'PVB-IEP');

-------------------------------------------
-- Paso 2 - creación de las elecciones
-------------------------------------------

-- creación de las elecciones
INSERT INTO public.elecciones (id_tipo_eleccion, fecha, id_tipo_dpa, descripcion, ano) VALUES
  (1, '2014-10-12', 1, '2014 - elecciones plurinominales (resultados parciales)', '2014'),
  (2, '2014-10-12', 1, '2014 - elecciones uninominales (resultados parciales)', '2014'),
  (3, '2014-10-12', 1, '2014 - elecciones especiales (resultados parciales)', '2014');  

-- Verificación

SELECT * FROM elecciones WHERE "ano" = '2014';

-------------------------------------------
-- Paso 3 - creación de los candidatos
-------------------------------------------

-- creación de los candidatos presidenciales
-- MAS
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, 'Juan Evo Morales Ayma' AS p, 'Álvaro Marcelo García Linera' AS vp FROM public.partidos WHERE sigla = 'MAS'
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;
-- MSM
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, 'Juan Fernando Del Granado Cosío' AS p, 'Adriana Gil Moreno' AS vp FROM public.partidos WHERE sigla = 'MSM'
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;
-- PDC
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, 'Jorge Fernando Tuto Quiroga Ramirez' AS p, 'Tomasa Yarhui Jacome' AS vp FROM public.partidos WHERE sigla = 'PDC'
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;
-- PVB-IEP
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, 'Fernando Vargas Mosua' AS p, 'Mary Margot Soria Saravia' AS vp FROM public.partidos WHERE sigla = 'PVB-IEP'
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;
-- UD
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, 'Samuel Jorge Doria Medina Auza' AS p, 'Ernesto Suarez Sattori' AS vp FROM public.partidos WHERE sigla = 'UD'
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;

-- pseudo partidos
INSERT INTO public.candidatos (id_partido, id_tipo_partido, id_eleccion, id_dpa, presidente, vice_presidente)
SELECT p.id_partido, p.id_tipo_partido, e.id_eleccion, 1, p.p, p.vp
FROM (
  SELECT id_partido, id_tipo_partido, '' AS p, '' AS vp FROM public.partidos WHERE sigla IN ('BLANCOS','NULOS','ABSTENCION','VALIDOS','EMITIDOS','INSCRITOS')
) AS p
JOIN (
  SELECT id_eleccion FROM public.elecciones WHERE ano = '2014'
) AS e ON true;

-- Verificación

SELECT c.* FROM public.candidatos AS c
  JOIN public.elecciones AS e USING ("id_eleccion")
  WHERE e.ano=2014;

-------------------------------------------
-- Paso 4 - creación de la función de inserción de un resultado
-------------------------------------------

-- Function: public.f_insert_resultado_2014_plurinacional_votos(integer, integer, integer)
-- entradas:
--  * id_partido
--  * id_dpa
--  * resultado
CREATE OR REPLACE FUNCTION public.f_insert_resultado_2014_plurinacional_votos(
    _id_partido integer
  , _id_dpa integer
  , _resultado integer) RETURNS int
AS $$
  DECLARE
    id_val int;
  BEGIN

  DELETE FROM public.resultados
    WHERE id_resultado IN (
      SELECT id_resultado
      FROM public.resultados AS r
      JOIN (
        SELECT id_eleccion FROM public.elecciones WHERE ano = 2014 AND id_tipo_eleccion=1
      ) AS e ON (r.id_eleccion = e.id_eleccion)
      JOIN (
        SELECT id_eleccion, id_candidato, id_partido, id_tipo_partido FROM public.candidatos WHERE id_partido=_id_partido
      ) AS c ON (c.id_eleccion=e.id_eleccion AND r.id_candidato=c.id_candidato)
      JOIN (
        SELECT id_dpa, id_tipo_dpa FROM public.dpa WHERE id_dpa=_id_dpa
      ) AS d ON r.id_dpa=d.id_dpa);
  
  INSERT INTO public.resultados (id_eleccion, id_candidato, id_partido, id_tipo_partido, id_dpa, id_tipo_dpa, id_tipo_resultado, resultado)
    SELECT e.id_eleccion, c.id_candidato, c.id_partido, c.id_tipo_partido, d.id_dpa, d.id_tipo_dpa, 1, _resultado
    FROM (
      SELECT id_eleccion FROM public.elecciones WHERE ano = 2014 AND id_tipo_eleccion=1
    ) AS e
    JOIN (
      SELECT id_eleccion, id_candidato, id_partido, id_tipo_partido FROM public.candidatos WHERE id_partido=_id_partido
    ) AS c ON (c.id_eleccion=e.id_eleccion)
    JOIN (
      SELECT id_dpa, id_tipo_dpa FROM public.dpa WHERE id_dpa=_id_dpa
    ) AS d ON true
  RETURNING id_resultado INTO id_val;

  RETURN id_val;

  END;
$$
LANGUAGE plpgsql;

-------------------------------------------
-- Paso 5 - eliminación de los resultados de 12/10/2014
-------------------------------------------

-- Por si acaso, borramos los resultados de elecciones del 12/10/2014
DELETE FROM public.resultados AS r
  USING public.elecciones AS e
  WHERE e.fecha = '2014-10-12' AND e.id_eleccion=r.id_eleccion;
