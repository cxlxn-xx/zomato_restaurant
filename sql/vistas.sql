
USE zomato_restaurante;
 
-- Vista 1: datos completos de cada restaurante
CREATE OR REPLACE VIEW v_restaurantes_completo AS
SELECT r.id, r.rest AS restaurante, r.direccion,
       ci.nom AS ciudad, l.loca AS localidad, c.cod AS codigo_pais,
       r.rating, t.rat_text AS valoracion, r.votos,
       r.cost_med_pare AS costo_para_dos, m.moneda
FROM restaurante r
JOIN localidad l ON l.id = r.id_loca
JOIN ciudad ci ON ci.id = l.id_ciudad
JOIN codigopais c ON c.id = ci.cod_id
JOIN moneda m ON m.id = r.moneda_id
JOIN resena_textual t ON t.id_text = r.resena_tex;
 
-- Vista 2: rating promedio y cantidad de restaurantes por ciudad
CREATE OR REPLACE VIEW v_rating_por_ciudad AS
SELECT ci.nom AS ciudad,
       COUNT(*) AS total_restaurantes,
       ROUND(AVG(r.rating), 2) AS rating_promedio
FROM restaurante r
JOIN localidad l ON l.id = r.id_loca
JOIN ciudad ci ON ci.id = l.id_ciudad
GROUP BY ci.id, ci.nom;
 
-- Vista 3: cocinas con mas restaurantes
CREATE OR REPLACE VIEW v_cocinas_populares AS
SELECT co.nom AS cocina, COUNT(*) AS total_restaurantes
FROM restaurante_cocina rc
JOIN cocina co ON co.id = rc.id_cocina
GROUP BY co.id, co.nom
ORDER BY total_restaurantes DESC;
 
-- Vista 4: restaurantes por pais
CREATE OR REPLACE VIEW v_restaurantes_por_pais AS
SELECT c.cod AS codigo_pais, COUNT(*) AS total_restaurantes
FROM restaurante r
JOIN localidad l ON l.id = r.id_loca
JOIN ciudad ci ON ci.id = l.id_ciudad
JOIN codigopais c ON c.id = ci.cod_id
GROUP BY c.id, c.cod;
 
-- Vista 5: mejores restaurantes (rating alto y con varios votos)
CREATE OR REPLACE VIEW v_mejores_restaurantes AS
SELECT r.rest AS restaurante, ci.nom AS ciudad, r.rating, r.votos
FROM restaurante r
JOIN localidad l ON l.id = r.id_loca
JOIN ciudad ci ON ci.id = l.id_ciudad
WHERE r.rating >= 4.5 AND r.votos >= 100
ORDER BY r.rating DESC, r.votos DESC;
 