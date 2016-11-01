#!/usr/bin/env ruby

require 'net/https'
require 'open-uri'

###################
#
# Essas duas URLs são mudadas todo o semestre. É preciso entrar no site
# www.supac.ufba.br para obter as novas URLs
#

#Alterações feitas por David [davidsodre_ba@hotmail.com] para o semestre 2016.2
# link com o guia novo: https://supac.ufba.br/guiamatriculaunidade_2016.2
# URL Antiga
#BASE_URL = 'https://twiki.ufba.br/twiki/bin/view/SUPAC/GradGuia'
#BASE_URL_UNIDADE = 'https://twiki.ufba.br/twiki/bin/view/SUPAC/MatriculaGraduacaoUnidade1'

BASE_URL = 'https://supac.ufba.br/guiamatriculaunidade_2016.2'
BASE_URL_UNIDADE = 'https://supac.ufba.br/guiamatriculaunidade_2016.2'

###################

def download(url, dest=nil)
  f = open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
  contents = f.read
  if dest
    filename = url.split('/').last
    path = File.join(dest, filename)
    File.open(path, 'w') { |file| file.write(contents) }
    STDERR.puts("Wrote to file #{path}")
  end
  contents
end

###################
# Guia de graduacao

AREAS = ['AreaI', '&Aacute;rea I',
    'AreaII', '&Aacute;rea II',
    'AreaIII', '&Aacute;rea III',
    'AreaIV', '&Aacute;rea IV',
    'AreaV', '&Aacute;rea V',
    'IHAC', 'Bacharelados Interdisciplinares e Tecn&oacute;logos',
    'IMS', 'Campus Vit&oacute;ria da Conquista - Instituto Multidisciplinar em Sa&uacute;de']

index = StringIO.new

AREAS.each_slice(2) do |area, nome_area|
  url = "#{BASE_URL}#{area}1"
  puts url
  page = download(url)

  index.puts "<h2>#{nome_area}</h2>"

  page.scan(/(\d{3}) <a href="(.+?)".*?>(.+?)</) do |m|
    codigo, url, nome = m
    download(url, '../php/guia')
    index.puts %Q{<a href="mostramaterias.php?curso=#{codigo}">#{nome}</a> &nbsp; }
  end
end

s = index.string.encode('iso-8859-1', 'utf-8')
File.open('../php/listacursos.htm', 'w') { |f| f.write(s) }

#############
# Por unidade

PUB_URL_UNIDADE = BASE_URL_UNIDADE.gsub('bin/view', 'pub')
page = download(BASE_URL_UNIDADE)
page.scan(/href="#{Regexp.quote(PUB_URL_UNIDADE)}\/(...)[.]html"/) do |m|
	codigo = m[0]
	download("#{PUB_URL_UNIDADE}/#{codigo}.html", '../php/guia')
end
