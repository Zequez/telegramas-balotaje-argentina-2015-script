require 'active_record'

class Telegrama < ActiveRecord::Base
  def votos_positivos
    votos_fpv && votos_fpv + votos_cambiemos
  end

  def votos_no_positivos
     votos_nulos && votos_nulos + votos_blancos + votos_impugnados + votos_recurridos
  end

  def votos
    votos_positivos && votos_positivos + votos_no_positivos
  end

  def self.votos_totales
    @totales ||= {
      cambiemos:   where.not(votos_cambiemos: nil).pluck(:votos_cambiemos).inject(0, &:+),
      fpv:         where.not(votos_fpv: nil).pluck(:votos_fpv).inject(0, &:+),
      nulos:       where.not(votos_nulos: nil).pluck(:votos_nulos).inject(0, &:+),
      blancos:     where.not(votos_blancos: nil).pluck(:votos_blancos).inject(0, &:+),
      recurridos:  where.not(votos_recurridos: nil).pluck(:votos_recurridos).inject(0, &:+),
      impugnados:  where.not(votos_impugnados: nil).pluck(:votos_impugnados).inject(0, &:+),
    }
  end

  def self.votos_totales_porcentaje
    t = votos_totales
    total = t[:cambiemos] + t[:fpv] + t[:blancos] + t[:recurridos] + t[:impugnados] + t[:nulos]
    {
      cambiemos: porc(t[:cambiemos], total),
      fpv: porc(t[:fpv], total),
      blancos: porc(t[:blancos], total),
      recurridos: porc(t[:recurridos], total),
      impugnados: porc(t[:impugnados], total),
      nulos: porc(t[:nulos], total),
    }
  end

  def self.votos_totales_positivos_porcentaje
    t = votos_totales
    total = t[:cambiemos] + t[:fpv]
    {
      cambiemos: porc(t[:cambiemos], total),
      fpv: porc(t[:fpv], total),
    }
  end

  def self.porc(votos, total)
    (votos.to_f / total * 100).round(2)
  end
end
