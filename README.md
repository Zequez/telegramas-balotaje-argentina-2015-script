# Telegramas Argentina Balotaje 2015 - Script

Este script es para descargar todos los telegramas del balotaje encontrados en
la siguiente dirección: http://www.resultados.gob.ar/bltgetelegr/Itelegramas.htm

Si no carga la página es porque ya la bajaron.

Los resultados con los datos los podés encontrar en [Zequez/telegramas-balotaje-argentina-2015](https://github.com/Zequez/telegramas-balotaje-argentina-2015)

# Formato

El formato de los telegramas es el siguiente (con ejemplo):

```json
{
  "id": 5742,
  "url": "http://www.resultados.gob.ar/bltgetelegr/02/038/0302/020380302_0048.htm",
  "distrito": "02",
  "seccion": "038",
  "circuito": "0302",
  "mesa": "0048",
  "estado": "Grabada",
  "pdf": "http://www.resultados.gob.ar/bltgetelegr/02/038/0302/020380302_0048.pdf",
  "votos_nulos": null,
  "votos_blancos": 4,
  "votos_recurridos": 0,
  "votos_impugnados": 0,
  "votos_fpv": 180,
  "votos_cambiemos": 111,
  "distrito_nombre": "Buenos Aires",
  "seccion_nombre": "Florencio Varela"
}
```

Los PDF no fueron descargados porque pesaban aproximadamente 105KB c/u, y con 92mil
telegramas, eso nos lleva a aproximadamente 9GB de PDFs. Estás invitado a descargarlos y
hostearlos en algún otro lado, porque Github no los va a aceptar.

# Correr el script vos mismo

Para usar el script necesitás Ruby.

Instalar las dependencias:

```sh
bundle install
```

Para crear la base de datos:

```sh
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

Recomendado que lo corran un par de veces el script, ya que cuando una URL tira error, simplemente
sigue con la próxima. Corriendo el script 2 veces va a intentar cargar únicamente las URL que no pudo cargar previamente.

Luego usan el siguiente comando para dumpear toda la base de datos en un `telegramas.json` y `telegramas.min.json`:

```sh
rake dump_json
```
