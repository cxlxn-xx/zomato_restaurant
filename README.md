# zomato_restaurant
Integrantes: Amaro Medina y Celene Romero

 Descripción del proyecto

Este trabajo consiste en diseñar y construir una base de datos relacional a partir de un archivo público de restaurantes de Zomato. El archivo original tenía una sola tabla con 9551 filas, así que lo analizamos, lo dividimos en tablas relacionadas y cargamos los datos con sentencias SQL.

- Motor: MariaDB
- Herramientas: MySQL Workbench y Python (Flask) para la web
- Nombre de la base: `zomato_restaurante`

## 2. Análisis de los datos

El archivo tiene una fila por restaurante y estas columnas:

Grupo - Columnas 

 Identificación - Restaurant ID, Restaurant Name 
 Ubicación - Country Code, City, Address, Locality, Locality Verbose, Longitude, Latitude 
 Cocina - Cuisines (varias separadas por coma) 
 Costos - Average Cost for two, Currency, Price range 
 Servicios - Has Table booking, Has Online delivery, Is delivering now, Switch to order menu 
 Valoración - Aggregate rating, Rating color, Rating text, Votes 

## 3. Diseño de la base de datos

La base tiene 9 tablas y 5 vistas

 Tabla - lo que guarda - Clave primaria 

 `codigopais` : Códigos de país - `id` 
 `ciudad` : Ciudades, cada una de un país - `id` 
 `localidad` :Zonas de una ciudad - `id` 
 `moneda` : Monedas - `id` 
 `resena_textual` : Valoración en texto (Excellent, Good...) : `id_text` 
 `resena_color` : Color de la valoración : `id_color` 
 `cocina` : Tipos de cocina : `id` 
 `restaurante` : Datos de cada restaurante - `id` 
 `restaurante_cocina` : Une restaurantes con sus cocinas : (`id_rest`, `id_cocina`) 

### Relaciones (claves foráneas)

 `ciudad` - `cod_id` - `codigopais.id` 
 `localidad` - `id_ciudad` - `ciudad.id` 
 `restaurante` - `id_loca` - `localidad.id` 
 `restaurante` - `moneda_id` - `moneda.id` 
 `restaurante` - `resena_tex` - `resena_textual.id_text` 
 `restaurante` - `resena_co` - `resena_color.id_color` 
 `restaurante_cocina` - `id_rest` - `restaurante.id` 
 `restaurante_cocina` - `id_cocina` - `cocina.id` 

 de las claves primarias y los índices de las claves foráneas, creamos estos índices:

 Índice - Tabla (columnas) - Tipo - Para qué sirve -
 `uq_codigopais_cod` - `codigopais` (`cod`) - UNIQUE - No repetir códigos de país 
 `uq_ciudad_nom_pais` - `ciudad` (`nom`, `cod_id`) - UNIQUE | No repetir una ciudad dentro del mismo país 
 `loca_detallada_UNIQUE` - `localidad` (`loca_detallada`) - UNIQUE | Cada localidad detallada aparece una sola vez 
 `idx_localidad_loca` - `localidad` (`loca`) - Común - Buscar localidades por nombre 
 `uq_moneda` - `moneda` (`moneda`)  UNIQUE - No repetir monedas 
 `uq_rat_text`-  `resena_textual` (`rat_text`) - UNIQUE - No repetir valoraciones 
 `uq_rat_color` - `resena_color` (`rat_color`) - UNIQUE - No repetir colores 
 `nom_UNIQUE` - `cocina` (`nom`) - UNIQUE - No repetir cocinas 
 `idx_rest_nombre` - `restaurante` (`rest`) - Común . Buscar restaurantes por nombre 
 `idx_rest_rating` - `restaurante` (`rating`) - Común - Filtrar y ordenar por rating 

### Diagrama
Diagrama hecho en MySQL Workbench
restaurante_zomato.png

### Vistas

`v_restaurantes_completo` : Datos completos de cada restaurante con ciudad, país y moneda 
`v_rating_por_ciudad` : Rating promedio y cantidad de restaurantes por ciudad.
 `v_cocinas_populares` : Cocinas ordenadas por cantidad de restaurantes.
 `v_restaurantes_por_pais` : Cantidad de restaurantes por país |
`v_mejores_restaurantes` : Restaurantes con rating de 4.5 o más y al menos 100 votos.

## 4. Sentencias DDL
creación de tablas y relaciones
ddl.sql

## 5. Importación y carga de datos

1. Importamos el archivo CSV en Workbench (*Table Data Import Wizard*). Quedó en la tabla `importar.zomato restaurant dataset 1`.
2. Con sentencias `INSERT ... SELECT` llenamos las tablas en orden, respetando las claves foráneas: `codigopais`, `ciudad`, `localidad`, `moneda`, `resena_textual`, `resena_color`, `cocina`, `restaurante` y por último `restaurante_cocina`.
carga de datos:
cargadatos.sql

## 6. Consultas de ejemplo con las vistas
 Los 10 restaurantes mejor valorados
SELECT * FROM v_mejores_restaurantes LIMIT 10;

mejoresrestaurantes.png

 Las 10 ciudades con mejor rating promedio (mínimo 5 restaurantes)
SELECT * FROM v_rating_por_ciudad
WHERE total_restaurantes >= 5
ORDER BY rating_promedio DESC LIMIT 10;

ratingporciudad.png

 Cocinas más comunes
SELECT * FROM v_cocinas_populares LIMIT 10;
cocinapopulares.png

## 7. Aplicación web

Además hicimos una web sencilla en Python (Flask) para consultar los datos. Permite buscar restaurantes por nombre, ciudad, cocina y rating mínimo, ordenar los resultados, y ver estadísticas por ciudad, cocina y país. Usa las vistas de la base.

 Cómo ejecutarla

1. Instalar las librerías:
 en la terminal ejecutar:
   python -m pip install flask pymysql
   
2. Abrir `web.py` y, en la función `consultar`, escribir el usuario y la contraseña de su MariaDB.
3. Ejecutar:
   ```bash
   python web.py
   ```
4. Abrir `http://127.0.0.1:5000` en el navegador.

La base de datos debe estar importada 

captura de la web

web.zomato.png

## 8. Cómo importar el respaldo

El archivo de respaldo es `respaldo/zomato_backup.sql`(respaldo/zomato_backup.sql). Incluye la creación de la base `zomato_restaurante`, las tablas, los datos y las vistas.

 Con la terminal

mysql -u root -p < respaldo/zomato_backup.sql


 Con MySQL Workbench

1. Conectarse al servidor.
2. Ir a Server > Data Import
3. Elegir Import from Self-Contained File** y seleccionar `zomato_backup.sql`.
4. Elegir Dump Structure and Data
5. Pulsar Start Import


  Estructura del repositorio


─ README.md
─ web.py                 --aplicación web
─ datos/                 --archivo CSV original
─ respaldo/              --zomato_backup.sql
─ sql/
   ─ ddl.sql             --creación de tablas, relaciones e índices
   ─ cargadatos.sql      --carga de datos
   ─ vistas.sql          --vistas
─ img/                   --diagrama y capturas
