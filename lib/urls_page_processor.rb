class UrlsPageProcessor < Scrapers::BasePageProcessor
  def self.inject(all_data, data)
    all_data ||= []
    all_data.concat data if data
    all_data
  end

  def process_page
    css('.iframe.prov').each{ |e| add_to_queue e['src'] }
    css('a[target="secciones"]').each{ |e| add_to_queue e['href'] }
    css('a[target="circuitos"]').each{ |e| add_to_queue e['href'] }
    css('a[target="mesas"]').each{ |e| add_to_queue e['href'] }
    urls = css('a[target="caja_pdf"]').map{ |e| @base_url + e['href'] }
    urls
  end
end
