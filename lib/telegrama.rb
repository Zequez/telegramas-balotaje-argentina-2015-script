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
end
