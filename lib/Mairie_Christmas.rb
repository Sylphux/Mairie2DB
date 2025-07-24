require 'nokogiri'
require 'open-uri'


def nokogise(site, element_xpath) # feeds url and xpath and returns the raw scrapped content
    page = Nokogiri::HTML(URI.open(site))
    scrapped = page.xpath(element_xpath)
    return scrapped
end

def nokogise_one_element(site, element_xpath) # feeds url and xpath and returns the first matching element
    page = Nokogiri::HTML(URI.open(site))
    scrapped = page.at_xpath(element_xpath)
    return scrapped
end


##########################################################################################################

def get_mairie_email(lien_page_mairie) # scrap l'adresse email sur la page de la mairie
    pagelink = lien_page_mairie
    element_xpath = '//li[@id="contentContactEmail"]'
    result = nokogise_one_element(pagelink,element_xpath)
    if result == nil 
        return "None"
    else
        return result.text[13..-1]
    end
end

def scrap_mairies_names(to_search) #scrap le nom des mairies dans un array
    pagelink = to_search
    element_xpath = '//p[@class="fr-mb-0"]'
    return nokogise(pagelink,element_xpath).map{|x| x.text.split(" - ")[1]} #On rend propre le le nom des mairies
end

def scrap_mairies_links(to_search) #scrap le lien vers les pages de mairie dans un array
    pagelink = to_search
    element_xpath = '//div[@class="sp-link fr-mb-3w"]//a[@class="fr-link"]/@href'
    return nokogise(pagelink,element_xpath)
end

def scrap_type_search(to_search) #scrap le type d'établissement recherché
    pagelink = to_search
    element_xpath = '//input[@id="whoWhatDirectorySearchForm"]/@value'
    return nokogise(pagelink,element_xpath)
end

def scrap_location_search(to_search) #scrap le lieu recherché
    pagelink = to_search
    element_xpath = '//input[@id="whereSearchForm"]/@value'
    return nokogise(pagelink,element_xpath)
end

def make_nice_list(nom, adresse)
    finalhash = []
    nom.count.times do |i|
        finalhash.push({nom[i-1]=>adresse[i-1]})
    end
    return finalhash
end

###########################################################################################################


def perform

    puts
    puts "Bienvenue dans le scrappeur de l'annuaire du service public."
    puts "Choisissez une page listant des établissement dont vous souhaitez scrap les emails."
    puts "L'adresse doit commencer par https://lannuaire.service-public.fr"
    puts "Sinon, tapez mairies pour chercher parmi les mairies du val d'oise."
    puts
    print "Scrap : "
    to_search = gets.chomp.to_s

    #choisir le lien à scrap
    if to_search == "mairies"
        to_search = 'https://lannuaire.service-public.fr/recherche?whoWhat=Mairie&where=Val+D%27oise+95'
    end

    #On test si l'adresse recherchée est scrappable par le programme
    until to_search.include?("https://lannuaire.service-public.fr/recherche?")
        puts "Désolé, l'adresse recherché n'est pas valide."
        puts "L'adresse doit commencer par https://lannuaire.service-public.fr"
        to_search = gets.chomp.to_s
    end

    #scrap le nom des mairies de la page d'accueil
    noms_mairies = scrap_mairies_names(to_search)
    # puts noms_mairies

    #scrap le liens des mairies
    liens_mairies = scrap_mairies_links(to_search)
    # puts liens_mairies

    #va chercher les emails des mairies sur les pages respectives
    emails_mairies = []
    noms_mairies.count.times do |i|
        emails_mairies.push(get_mairie_email(liens_mairies[i]))
    end
    # puts emails_mairies

    # Of affiche le résultat des mairies scrappées
    mairies_scrapped = make_nice_list(noms_mairies,emails_mairies)
    puts
    puts "Voici les 20 premiers emails pour votre recherche de #{scrap_type_search(to_search)}s en #{scrap_location_search(to_search)}"
    puts
    puts mairies_scrapped

end

perform