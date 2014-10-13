-------------------------------------------
-- Recalcular las dos "closure table"
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
