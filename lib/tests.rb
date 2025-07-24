require 'nokogiri' 
require 'open-uri'

#pointe vers la page choisie, utilise open_uri
page = Nokogiri::HTML(URI.open("http://ruby.bastardsbook.com/chapters/html-parsing/"))
#récupère toutes les balises h6, et map pour extraire leur texte
allh6 = page.xpath('//h6').map{|el| el.text}

#affiche les titres h6
puts allh6


# Autre façon d'afficher les titres mais avec une loop
# allh6.each do |titre|
#     puts titre.text
# end