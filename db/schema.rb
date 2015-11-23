# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151123220410) do

  create_table "telegramas", force: :cascade do |t|
    t.string  "url"
    t.string  "distrito"
    t.string  "seccion"
    t.string  "circuito"
    t.string  "mesa"
    t.string  "estado"
    t.string  "pdf"
    t.integer "votos_nulos"
    t.integer "votos_blancos"
    t.integer "votos_recurridos"
    t.integer "votos_impugnados"
    t.integer "votos_fpv"
    t.integer "votos_cambiemos"
    t.string  "distrito_nombre"
    t.string  "seccion_nombre"
  end

end
