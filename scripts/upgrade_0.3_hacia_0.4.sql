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

-------------------------------------------
-- Paso 5 - recalcular las dos "closure table"
-------------------------------------------

TRUNCATE public.jerarquia_partidos, public.jerarquia_dpa;

-- Llenar la tabla jerarquia_partidos
-- Creación de la distancia 0
-- Insertamos todos los partidos
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT p.id_partido, p.id_partido, 0, tp.id_tipo_partido, tp.id_tipo_partido
    FROM public.partidos AS p
    JOIN public.tipos_partido AS tp USING (id_tipo_partido);
-- Creación del vínculo entre "INSCRITOS" y sus descendientes directos
-- Los partidos "ABSTENCION", "ANULADOS" y "EMITIDOS" son hijos 
-- de "INSCRITOS" 
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 1, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='INSCRITOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE pd.sigla ~ '(ABSTENCION|ANULADOS|EMITIDOS)';
-- Descendientes directos de "EMITIDOS"
--   Los partidos "BLANCOS", "NULOS" y "VALIDOS" son hijos de "EMITIDOS"
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 1, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='EMITIDOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE pd.sigla ~ '(BLANCOS|NULOS|VALIDOS)';
--   También son descendientes de "INSCRITOS", con una distancia de 2:
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 2, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='INSCRITOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE pd.sigla ~ '(BLANCOS|NULOS|VALIDOS)';
-- Descendientes directos de "VALIDOS"
--   Todos los partidos "normales" son hijos de "VALIDOS" 
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 1, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='VALIDOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE tpd.nombre='normal';
-- También son descendientes de "EMITIDOS", con una distancia de 2: 
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 2, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='EMITIDOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE tpd.nombre='normal';
-- También son descendientes de "INSCRITOS", con una distancia de 3:
INSERT INTO public.jerarquia_partidos (id_partido_antecesor, id_partido_descendiente, distancia, id_tipo_partido_antecesor, id_tipo_partido_descendiente)
    SELECT pa.id_partido, pd.id_partido, 3, tpa.id_tipo_partido, tpd.id_tipo_partido
    FROM public.partidos AS pd
    JOIN public.tipos_partido AS tpd ON (tpd.id_tipo_partido=pd.id_tipo_partido)
    JOIN public.partidos AS pa ON (pa.sigla='INSCRITOS')
    JOIN public.tipos_partido AS tpa ON (tpa.id_tipo_partido=pa.id_tipo_partido)
    WHERE tpd.nombre='normal';

-- Llenado de la tabla public.jerarquia_dpa
--  distancia 0
INSERT INTO public.jerarquia_dpa (id_dpa_antecesor, id_dpa_descendiente, distancia, id_tipo_dpa_antecesor, id_tipo_dpa_descendiente)
    SELECT d.id_dpa, d.id_dpa, 0, td.id_tipo_dpa, td.id_tipo_dpa
    FROM public.dpa AS d
    JOIN public.tipos_dpa AS td USING (id_tipo_dpa);
--  distancia 1
INSERT INTO public.jerarquia_dpa (id_dpa_antecesor, id_dpa_descendiente, distancia, id_tipo_dpa_antecesor, id_tipo_dpa_descendiente)
    SELECT jd.id_dpa_antecesor, d.id_dpa, jd.distancia+1, jd.id_tipo_dpa_antecesor, td.id_tipo_dpa
    FROM public.jerarquia_dpa AS jd
    JOIN public.dpa AS d ON (d.id_dpa_superior = jd.id_dpa_descendiente)
    JOIN public.tipos_dpa AS td USING (id_tipo_dpa)
    WHERE jd.distancia = 0;
--  distancia 2
INSERT INTO public.jerarquia_dpa (id_dpa_antecesor, id_dpa_descendiente, distancia, id_tipo_dpa_antecesor, id_tipo_dpa_descendiente)
    SELECT jd.id_dpa_antecesor, d.id_dpa, jd.distancia+1, jd.id_tipo_dpa_antecesor, td.id_tipo_dpa
    FROM public.jerarquia_dpa AS jd
    JOIN public.dpa AS d ON (d.id_dpa_superior = jd.id_dpa_descendiente)
    JOIN public.tipos_dpa AS td USING (id_tipo_dpa)
    WHERE jd.distancia = 1;
--  distancia 3
INSERT INTO public.jerarquia_dpa (id_dpa_antecesor, id_dpa_descendiente, distancia, id_tipo_dpa_antecesor, id_tipo_dpa_descendiente)
    SELECT jd.id_dpa_antecesor, d.id_dpa, jd.distancia+1, jd.id_tipo_dpa_antecesor, td.id_tipo_dpa
    FROM public.jerarquia_dpa AS jd
    JOIN public.dpa AS d ON (d.id_dpa_superior = jd.id_dpa_descendiente)
    JOIN public.tipos_dpa AS td USING (id_tipo_dpa)
    WHERE jd.distancia = 2;
