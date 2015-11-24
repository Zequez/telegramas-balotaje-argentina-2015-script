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
    telegramas = Telegrama.all.where(votos_nulos: nil)
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
end

task :datos => :environment do
  File.write 'data/fpv_0.json', JSON.pretty_generate(Telegrama
    .where(votos_fpv: 0)
    .where.not(votos_cambiemos: 0)
    .map(&:attributes))
  File.write 'data/cambiemos_0.json', JSON.pretty_generate(Telegrama
    .where(votos_cambiemos: 0)
    .where.not(votos_fpv: 0)
    .map(&:attributes))
  File.write 'data/todos_0.json', JSON.pretty_generate(Telegrama
    .where(votos_nulos: 0)
    .where(votos_impugnados: 0)
    .where(votos_blancos: 0)
    .where(votos_recurridos: 0)
    .where(votos_cambiemos: 0)
    .where(votos_fpv: 0)
    .map(&:attributes))
end

desc 'Crear telegramas.json y telegramas.min.json con los datos en la base de datos'
task :dump_json => :environment do
  data = Telegrama.all.map(&:attributes)
  File.write 'data/telegramas.json', JSON.pretty_generate(data)
  File.write 'data/telegramas.min.json', JSON.dump(data)
end
