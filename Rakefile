require 'json'
require 'active_record'
require 'standalone_migrations'
require 'byebug'
StandaloneMigrations::Tasks.load_tasks

require_relative 'lib/scrapers/scrapers'
require_relative 'lib/telegramas_page_processor'
require_relative 'lib/urls_page_processor'
require_relative 'lib/telegrama'

TELEGRAMAS_URL = 'http://www.resultados.gob.ar/bltgetelegr/Itelegramas.htm'

task :environment do
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'data/telegramas.sqlite3'
  )
  c = ActiveRecord::Base.connection
  c.execute 'PRAGMA main.page_size=4096;'
  c.execute 'PRAGMA main.cache_size=10000;'
  c.execute 'PRAGMA main.locking_mode=EXCLUSIVE;'
  c.execute 'PRAGMA main.synchronous=NORMAL;'
  c.execute 'PRAGMA main.journal_mode=WAL;'
  c.execute 'PRAGMA main.temp_store = MEMORY;'
end

namespace :scrap do
  desc 'Scrapear todas las URLs de las páginas de telegramas'
  task :urls => :environment do
    Telegrama.transaction do
      Scrapers::Loader.new(UrlsPageProcessor, TELEGRAMAS_URL).scrap(collect: false) do |data|
        data.output.each do |url|
          Telegrama.create url: url unless Telegrama.find_by_url url
        end
      end
    end
  end

  desc 'Scrapear todos los telegramas y guardarlos en data.json y scrapers'
  task :telegramas => :environment do
    telegramas = Telegrama.all
    total = telegramas.count
    puts total
    count = 0
    telegramas.find_in_batches do |batch|
      urls = batch.map(&:url)
      Scrapers::Loader.new(TelegramasPageProcessor, urls, nil, batch, continue_with_errors: true)
        .scrap(collect: false) do |req|
          count += 1
          puts "#{count}/#{total}"
          telegrama = req.resource
          telegrama.assign_attributes req.output
          telegrama.save!
        end
    end
  end

  desc 'Inferir datos de las URLs que no cargan, los telegramas perdidos'
  task :perdidos => :environment do
    Telegrama.where(distrito: nil).each do |t|
      distrito, seccion, circuito, mesa = t.url.split('/')[-4..-1]
      mesa = mesa.scan(/_([0-9]+)/).flatten.first

      t.distrito = distrito
      t.seccion = seccion
      t.circuito = circuito
      t.mesa = mesa

      t.distrito_nombre = Telegrama.where(distrito: distrito).where.not(distrito_nombre: nil).first.distrito_nombre
      t.seccion_nombre = Telegrama.where(seccion: seccion).where.not(seccion_nombre: nil).first.seccion_nombre
      t.save!
    end
  end
end


namespace :datos do
  task :resultados => :environment do
    p Telegrama.votos_totales
    p Telegrama.votos_totales_porcentaje
    p Telegrama.votos_totales_positivos_porcentaje
  end

  task :sospechosos => :environment do
    def l(t, i)
      "#{i} | #{t.distrito_nombre} | #{t.seccion_nombre} | #{t.circuito} | #{t.mesa} | #{t.votos} | [Ver telegrama](#{t.url})"
    end

    def links(telegramas)
      "Nro. | Distrito | Sección | Circuito | Mesa | Votos registrados | Link \n --- | --- | --- | --- | --- | --- | ---\n" +
      telegramas.each_with_index.map{|t, i| l(t, i)}.join("\n")
    end

    def make_list(file, title, query)
      File.write "data/#{file}.md", ("## #{title}\n\n" + links(query))
    end

    make_list('fpv_0', 'Lugares donde el FPV obtuvo 0 votos y Cambiemos no',
      Telegrama.where(votos_fpv: 0).where.not(votos_cambiemos: 0))
    make_list('cambiemos_0', 'Lugares donde el Cambiemos obtuvo 0 votos y el FPV no',
      Telegrama.where(votos_cambiemos: 0).where.not(votos_fpv: 0))
    make_list('mesas_perdidas', 'Lugares donde la información sobre la mesa no está disponible',
      Telegrama.where('votos_nulos IS NULL').order('distrito ASC, seccion ASC'))
  end
end

desc 'Crear telegramas.json y telegramas.min.json con los datos en la base de datos'
task :dump_json => :environment do
  data = Telegrama.all.map(&:attributes)
  File.write 'data/telegramas.json', JSON.pretty_generate(data)
  File.write 'data/telegramas.min.json', JSON.dump(data)
end
