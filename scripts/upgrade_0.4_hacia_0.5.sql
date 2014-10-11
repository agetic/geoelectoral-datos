-------------------------------------------
-- Adición resultados de las elecciones 2014
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
  
  INSERT INTO public.resultados (id_eleccion, id_candidato, id_partido, id_tipo_partido, id_dpa, id_tipo_dpa, id_tipo_resultado, resultado)
    SELECT e.id_eleccion, c.id_candidato, c.id_partido, c.id_tipo_partido, d.id_dpa, d.id_tipo_dpa, 1, _resultado
    FROM public.resultados AS a
    JOIN (
      SELECT id_eleccion FROM public.elecciones WHERE ano = 2014 AND id_tipo_eleccion=1
    ) AS e ON true
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

-- Supresión de todos los resultados de la elección 2014
DELETE
  FROM public.resultados AS r
  USING public.elecciones AS e
  WHERE e.ano = '2014' AND e.id_tipo_eleccion='1' AND r.id_eleccion = e.id_eleccion;

-- Llenado de todos los resultados de la elección 2014
