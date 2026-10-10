
USE zomato_restaurante;
-- 1: codigopais
-- Un registro por cada codigo de pais distinto.
INSERT INTO codigopais (cod)
SELECT DISTINCT `Country Code`
FROM importar.`zomato restaurant dataset 1`
WHERE `Country Code` IS NOT NULL;
 
 
--  2: ciudad
-- Una fila por cada combinacion ciudad + pais. Se une con codigopais

INSERT INTO ciudad (nom, cod_id)
SELECT DISTINCT s.`City`, c.id
FROM importar.`zomato restaurant dataset 1` s
JOIN codigopais c ON c.cod = s.`Country Code`;
 
 
 
--  3: localidad
-- con GROUP BY. MIN() elige un solo valor
-- para loca y para id_ciudad dentro de cada grupo

INSERT INTO localidad (loca, loca_detallada, id_ciudad)
SELECT MIN(s.`Locality`), s.`Locality Verbose`, MIN(ci.id)
FROM importar.`zomato restaurant dataset 1` s
JOIN codigopais c ON c.cod = s.`Country Code`
JOIN ciudad ci ON ci.nom = s.`City` AND ci.cod_id = c.id
GROUP BY s.`Locality Verbose`;

--  4: moneda

INSERT INTO moneda (moneda)
SELECT DISTINCT `Currency`
FROM importar.`zomato restaurant dataset 1`
WHERE `Currency` IS NOT NULL;

 -- PASO 5: resena_textual y resena_color
-- Valores que se repiten en miles de filas (Excellent, Good, etc.).
INSERT INTO resena_textual (rat_text)
SELECT DISTINCT `Rating text`
FROM importar.`zomato restaurant dataset 1`
WHERE `Rating text` IS NOT NULL;
 
INSERT INTO resena_color (rat_color)
SELECT DISTINCT `Rating color`
FROM importar.`zomato restaurant dataset 1`
WHERE `Rating color` IS NOT NULL;
 
--  6: cocina
-- La columna Cuisines trae varias cocinas en la misma celda
-- para separar en MariaDB:
--  Se crea una tabla auxiliar "nums" con los numeros 1 a 10.

--   El JOIN con nums repite cada restaurante una vez por cocina.
--  TRIM quita el espacio que queda despues de la coma.
-- tabla auxiliar que despues debemos borrarla cuando terminemos de cargar todos los datos
CREATE TABLE IF NOT EXISTS nums (n INT PRIMARY KEY);
INSERT IGNORE INTO nums (n) VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
 
INSERT INTO cocina (nom)
SELECT DISTINCT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(s.`Cuisines`, ',', nums.n), ',', -1))
FROM importar.`zomato restaurant dataset 1` s
JOIN nums ON nums.n <= 1 + LENGTH(s.`Cuisines`) - LENGTH(REPLACE(s.`Cuisines`, ',', ''))
WHERE s.`Cuisines` IS NOT NULL;

--  7: restaurante
-- Se toman los datos de cada restaurante y se cambian los textos por
-- los ids de las tablas anteriores (JOIN por el texto):
INSERT INTO restaurante
  (id, rest, direccion, long_latit, rating, votos, cost_med_pare,
   permite_reserv, tiene_deliver, deliver_dispo, tiene_cambio_menu,
   resena_tex, resena_co, precio_med, id_loca, moneda_id)
SELECT
  s.`Restaurant ID`,
  s.`Restaurant Name`,
  s.`Address`,
  POINT(s.`Longitude`, s.`Latitude`),
  s.`Aggregate rating`,
  s.`Votes`,
  s.`Average Cost for two`,
  s.`Has Table booking`    = 'Yes',
  s.`Has Online delivery`  = 'Yes',
  s.`Is delivering now`    = 'Yes',
  s.`Switch to order menu` = 'Yes',
  rt.id_text,
  rc.id_color,
  s.`Price range`,
  l.id,
  m.id
FROM importar.`zomato restaurant dataset 1` s
JOIN resena_textual rt ON rt.rat_text      = s.`Rating text`
JOIN resena_color   rc ON rc.rat_color     = s.`Rating color`
JOIN localidad      l  ON l.loca_detallada = s.`Locality Verbose`
JOIN moneda         m  ON m.moneda         = s.`Currency`;
 
COMMIT;

--  8: restaurante_cocina (tabla intermedia)

INSERT INTO restaurante_cocina (id_rest, id_cocina)
SELECT DISTINCT r.id, co.id
FROM importar.`zomato restaurant dataset 1` s
JOIN restaurante r ON r.id = s.`Restaurant ID`
JOIN nums ON nums.n <= 1 + LENGTH(s.`Cuisines`) - LENGTH(REPLACE(s.`Cuisines`, ',', ''))
JOIN cocina co ON co.nom = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(s.`Cuisines`, ',', nums.n), ',', -1))
WHERE s.`Cuisines` IS NOT NULL;
 
COMMIT;
-- eliminar la tabla auxiliar que ya no hace falta
DROP TABLE nums;  
 