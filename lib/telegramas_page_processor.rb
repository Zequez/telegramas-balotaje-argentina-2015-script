class TelegramasPageProcessor < Scrapers::BasePageProcessor
  def self.inject(all_data, data)
    all_data ||= []
    all_data.push data if data
    all_data
  end

  def process_page
    d = {}
    d[:url] = @url
    d[:distrito], d[:distrito_nombre] = css('.cabdistrito + td').text.strip.split(' - ')
    d[:seccion], d[:seccion_nombre] = css('.cabseccion + td').text.strip.split(' - ')
    d[:circuito] = css('.cabcircuito + td').text.strip
    d[:mesa] = css('.cabmesa + td')[0].text.strip
    d[:estado] = css('.cabmesa + td')[1].text.strip
    d[:pdf] = @base_url + css('#caja_pdf').first['src']

    d[:votos_nulos]      = int(css('.pt1 tbody tr:nth-child(1) td').text)
    d[:votos_blancos]    = int(css('.pt1 tbody tr:nth-child(2) td').text)
    d[:votos_recurridos] = int(css('.pt1 tbody tr:nth-child(3) td').text)
    d[:votos_impugnados] = int(css('.pt2 tbody td').text)
    d[:votos_fpv]        = int(css('#TVOTOS tbody tr:nth-child(1) td').text)
    d[:votos_cambiemos]  = int(css('#TVOTOS tbody tr:nth-child(2) td').text)

    d
  end

  def int(text)
    text.empty? ? 0 : Integer(text)
  end
end
