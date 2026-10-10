from flask import Flask, request, render_template_string
import pymysql
web = Flask(__name__)
def consultar(sql, datos=()):
    # abre la conexion, ejecuta el select y devuelve las filas
    con = pymysql.connect(host="localhost", user="root", password="",
   database="zomato_restaurante",
  cursorclass=pymysql.cursors.DictCursor)
    cur = con.cursor()
    cur.execute(sql, datos)
    filas = cur.fetchall()
    con.close()
    return filas
# opciones para ordenar la tabla
ORDENES = {
    "rating": "rating DESC",
    "votos": "votos DESC",
    "costo": "costo_para_dos DESC",
    "nombre": "restaurante ASC",
}
PAGINA = """
<h1>Restaurantes Zomato</h1>
<a href="/">Buscar</a> | <a href="/estadisticas">Estadisticas</a>
<hr>
<form method="get">
  Nombre: <input name="nombre" value="{{ nombre }}">
  Ciudad: <input name="ciudad" value="{{ ciudad }}">
  Cocina:
  <select name="cocina">
    <option value="">todas</option>
    {% for c in cocinas %}
    <option {% if c.nom == cocina %}selected{% endif %}>{{ c.nom }}</option>
    {% endfor %}
  </select>
  Rating minimo: <input name="rating" size="3" value="{{ rating }}">
  Ordenar por:
  <select name="orden">
    {% for o in ordenes %}
    <option {% if o == orden %}selected{% endif %}>{{ o }}</option>
    {% endfor %}
  </select>
  <button>Buscar</button>
</form>
<p>Se encontraron {{ filas|length }} restaurantes (maximo 50)</p>
<table border="1" cellpadding="4">
  <tr><th>Restaurante</th><th>Ciudad</th><th>Rating</th><th>Votos</th><th>Costo para dos</th></tr>
  {% for f in filas %}
  <tr>
    <td>{{ f.restaurante }}</td><td>{{ f.ciudad }}</td><td>{{ f.rating }}</td>
    <td>{{ f.votos }}</td><td>{{ f.costo_para_dos }} {{ f.moneda }}</td>
  </tr>
  {% endfor %}
</table>
"""
ESTADISTICAS = """
<h1>Estadisticas</h1>
<a href="/">Buscar</a> | <a href="/estadisticas">Estadisticas</a>
<hr>
<h3>Ciudades con mejor rating promedio (con al menos 5 restaurantes)</h3>
<table border="1" cellpadding="4">
  <tr><th>Ciudad</th><th>Promedio</th><th>Restaurantes</th></tr>
  {% for f in ciudades %}
  <tr><td>{{ f.ciudad }}</td><td>{{ f.rating_promedio }}</td><td>{{ f.total_restaurantes }}</td></tr>
  {% endfor %}
</table>
<h3>Cocinas mas comunes</h3>
<table border="1" cellpadding="4">
  <tr><th>Cocina</th><th>Restaurantes</th></tr>
  {% for f in cocinas %}
  <tr><td>{{ f.cocina }}</td><td>{{ f.total_restaurantes }}</td></tr>
  {% endfor %}
</table>
<h3>Restaurantes por pais (codigo)</h3>
<table border="1" cellpadding="4">
  <tr><th>Codigo pais</th><th>Restaurantes</th></tr>
  {% for f in paises %}
  <tr><td>{{ f.codigo_pais }}</td><td>{{ f.total_restaurantes }}</td></tr>
  {% endfor %}
</table>
"""
@web.route("/")
def inicio():
    nombre = request.args.get("nombre", "")
    ciudad = request.args.get("ciudad", "")
    cocina = request.args.get("cocina", "")
    rating = request.args.get("rating", "")
    orden = request.args.get("orden", "rating")

    # uso la vista que hicimos en el trabajo
    sql = "SELECT * FROM v_restaurantes_completo WHERE 1 = 1"
    datos = []

    if nombre:
        sql += " AND restaurante LIKE %s"
        datos.append("%" + nombre + "%")
    if ciudad:
        sql += " AND ciudad LIKE %s"
        datos.append("%" + ciudad + "%")
    if cocina:
        sql += """ AND id IN (SELECT rc.id_rest FROM restaurante_cocina rc
        JOIN cocina c ON c.id = rc.id_cocina
        WHERE c.nom = %s)"""
        datos.append(cocina)
    if rating:
        sql += " AND rating >= %s"
        datos.append(rating)

    sql += " ORDER BY " + ORDENES.get(orden, "rating DESC") + " LIMIT 50"

    filas = consultar(sql, datos)
    cocinas = consultar("SELECT nom FROM cocina ORDER BY nom")
    return render_template_string(PAGINA, filas=filas, cocinas=cocinas,
   ordenes=list(ORDENES), nombre=nombre,
   ciudad=ciudad, cocina=cocina,
   rating=rating, orden=orden)

@web.route("/estadisticas")
def estadisticas():
    ciudades = consultar("""SELECT * FROM v_rating_por_ciudad
   WHERE total_restaurantes >= 5
    ORDER BY rating_promedio DESC LIMIT 10""")
    cocinas = consultar("SELECT * FROM v_cocinas_populares LIMIT 10")
    paises = consultar("""SELECT * FROM v_restaurantes_por_pais
   ORDER BY total_restaurantes DESC""")
    return render_template_string(ESTADISTICAS, ciudades=ciudades,
     cocinas=cocinas, paises=paises)

if __name__ == "__main__":
    web.run(debug=True, use_reloader=False)