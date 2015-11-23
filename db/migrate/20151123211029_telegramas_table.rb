class TelegramasTable < ActiveRecord::Migration
  def change
    create_table :telegramas do |t|
      t.string :url, unique: true
      t.string :distrito
      t.string :seccion
      t.string :circuito
      t.string :mesa
      t.string :estado
      t.string :pdf
      t.integer :votos_nulos
      t.integer :votos_blancos
      t.integer :votos_recurridos
      t.integer :votos_impugnados
      t.integer :votos_fpv
      t.integer :votos_cambiemos
    end
  end
end
