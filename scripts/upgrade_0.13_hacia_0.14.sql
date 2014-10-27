CREATE TABLE versiones
(
   descripcion character varying(255),
   fechahora timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS = FALSE
)
;
COMMENT ON COLUMN versiones.descripcion IS 'Descripción de las versiones migradas en la base de datos';


INSERT INTO versiones(descripcion) VALUES
('upgrade_0.3_hacia_0.4.sql'),
('upgrade_0.4_hacia_0.5.sql'),
('upgrade_0.5_hacia_0.6.sql'),
('upgrade_0.6_hacia_0.7.sql'),
('upgrade_0.7_hacia_0.8.sql'),
('upgrade_0.8_hacia_0.9.sql'),
('upgrade_0.9_hacia_0.10.sql'),
('upgrade_0.10_hacia_0.11.sql'),
('upgrade_0.11_hacia_0.12.sql'),
('upgrade_0.12_hacia_0.13.sql'),
('upgrade_0.13_hacia_0.14.sql');
