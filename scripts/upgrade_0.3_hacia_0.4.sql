-------------------------------------------
-- Adición datos de las elecciones 2014 (antes de los resultados)
-------------------------------------------

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
  (1, '2014-10-12', 1, '2014 - elecciones plurinominales', '2014'),
  (2, '2014-10-12', 1, '2014 - elecciones uninominales', '2014'),
  (3, '2014-10-12', 1, '2014 - elecciones especiales', '2014');  

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
