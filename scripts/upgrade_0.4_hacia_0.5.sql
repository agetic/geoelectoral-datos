-------------------------------------------
-- Adición resultados de las elecciones 2014
-------------------------------------------

-------------------------------------------
-- Paso 1 - supresión de todos los resultados existentes
-------------------------------------------

-- Supresión de todos los resultados de la elección 2014
DELETE
  FROM public.resultados AS r
  USING public.elecciones AS e
  WHERE e.ano = '2014' AND e.id_tipo_eleccion='1' AND r.id_eleccion = e.id_eleccion;

-------------------------------------------
-- Paso 1 - llenado de los resultados de la elección 2014
-------------------------------------------

-- Por ejemplo, para ingresar el resultado 3000000 votos para el MAS en Bolivia: SELECT f_insert_resultado_2014_plurinacional_votos(25, 1, 3000000);
