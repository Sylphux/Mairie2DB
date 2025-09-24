class Scrap

    attr_accessor :instances, :noms_mairies, :liens_mairies, :emails_mairies, :mairies_scrapped, :to_search
    @@instances = []

    def nokogise(site, element_xpath) # returns raw scrapped elements
        page = Nokogiri::HTML(URI.open(site))
        scrapped = page.xpath(element_xpath)
        return scrapped
    end

    def nokogise_one_element(site, element_xpath) # returns first matching element
        page = Nokogiri::HTML(URI.open(site))
        scrapped = page.at_xpath(element_xpath)
        return scrapped
    end

    def get_mairie_email(lien_page_mairie)
        pagelink = lien_page_mairie
        element_xpath = '//li[@id="contentContactEmail"]'
        result = nokogise_one_element(pagelink, element_xpath)
        if result == nil 
            return "None"
        else
            return result.text[13..-1]
        end
    end

    def scrap_mairies_names
        pagelink = @to_search
        element_xpath = '//p[@class="fr-mb-0"]'
        return nokogise(pagelink, element_xpath).map{|x| x.text.split(" - ")[1]} #On rend propre le le nom des mairies
    end

    def scrap_mairies_links
        pagelink = @to_search
        element_xpath = '//div[@class="sp-link fr-mb-3w"]//a[@class="fr-link"]/@href'
        return nokogise(pagelink, element_xpath)
    end

    def scrap_type_search #scrap le type (nom) d'établissement recherché
        pagelink = @to_search
        element_xpath = '//input[@id="whoWhatDirectorySearchForm"]/@value'
        return nokogise(pagelink, element_xpath)
    end

    def scrap_location_search #scrap le lieu recherché
        pagelink = @to_search
        element_xpath = '//input[@id="whereSearchForm"]/@value'
        return nokogise(pagelink, element_xpath)
    end

    def make_nice_list
        @noms_mairies.count.times do |i|
            @mairies_scrapped.push({@noms_mairies[i-1]=>@emails_mairies[i-1]})
        end
    end

    def test_input
        if @to_search == "exit" || @to_search == ""
            puts "Leaving the program"
            exit
        end
        until @to_search.include?("https://lannuaire.service-public.fr/recherche?") || @to_search.include?("mairies")
            puts "Désolé, l'adresse recherché n'est pas valide."
            puts "L'adresse doit commencer par https://lannuaire.service-public.fr"
            puts "Entrez une nouvelle adresse fonctionelle :"
            prompt
        end
    end

    def reassign_input 
        if @to_search == "mairies"
            @to_search = 'https://lannuaire.service-public.fr/recherche?whoWhat=Mairie&where='
        elsif
            @to_search.include? "mairies "
            @to_search = "https://lannuaire.service-public.fr/recherche?whoWhat=Mairie&where=#{@to_search.gsub("mairies ", '')}"
        end
    end

    def prompt
        print "\nprompt/exit"
        print "\nScrap : "
        @to_search = gets.chomp.to_s
    end

    def go_scrap
        prompt
        test_input #tests input corresponds to website
        reassign_input #sort of aliases function
        @noms_mairies = scrap_mairies_names #scrap mairies names from list page
        @liens_mairies = scrap_mairies_links #Scrap mairies links from list page
        @noms_mairies.count.times do |i| #Scrap mairies emails
            @emails_mairies.push(get_mairie_email(@liens_mairies[i]))
        end
        make_nice_list #combines arrays in @mairies_scrapped
        puts "\nVoici les 20 premiers emails pour votre recherche de #{scrap_type_search}s en #{scrap_location_search}\n\n"
        puts @mairies_scrapped
        puts
        Scrap.new
    end

    def self.all
        @@instances
    end

    def self.one
        @@instances[0]
    end

    def initialize
        @to_search
        @noms_mairies = []
        @liens_mairies = []
        @emails_mairies = []
        @mairies_scrapped = []
        @@instances << self
        go_scrap
    end

end