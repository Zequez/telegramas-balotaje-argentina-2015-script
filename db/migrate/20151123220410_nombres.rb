class Nombres < ActiveRecord::Migration
  def change
    add_column :telegramas, :distrito_nombre, :string
    add_column :telegramas, :seccion_nombre, :string
  end
end
