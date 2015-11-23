# Telegramas Resultados Argentina Balotaje 2015

El escraper es específico de un proyecto personal que no lo tengo opensourceado y que todavía no lo convertí en una librería aparte así que van a tener que excusar el código extra en `/lib/scrapers`. El importante es `/lib/telegramas_page_processors.rb` y `/lib/urls_page_processor.rb`.

Los datos están en `telegramas.json` y los pdf están en `/telegramas/<distrito>/<seccion>/<circuito>/<mesa>.pdf`.

También los mismos datos están en telegramas.sqlite3

Cada telegrama tiene el siguiente formato:

```json
{
  "url": "",
  "distrito": "",
  "distrito_nombre": "",
  "seccion": "",
  "seccion_nombre": "",
  "circuito": "",
  "mesa": "",
  "estado": "",
  "pdf": "",
  "votos": {
    "nulos": 0,
    "blancos": 0,
    "recurridos": 0,
    "impugnados": 0,
    "fpv": 0,
    "cambiemos": 0
  }
}
```

## Correr el script vos mismo

Para usar el script necesitan Ruby.

Instalar las dependencias:

```sh
bundle install
```

Para crear la base de datos:

```sh
rake db:create
rake db:migrate
```

Luego hacen el scraping de todas las URLs de los telegramas, que las almacena en la base de datos:

```sh
rake scrap:urls # Demora 15 minutos más o menos
```

Luego hacen el scraping de los telegramas, usando las URLs scrapeadas anteriormente:

```sh
rake scrap:telegramas # Demora 20 minutos más o menos
```

Luego usan el siguiente comando para dumpear toda la base de datos en un `telegramas.json` y `telegramas.min.json`:

```sh
rake dump_json
```

Y finalmente, otro comando para descargar todos los PDF y ponerlos en `/telegramas`

```ruby
bundle rake pdf
```
