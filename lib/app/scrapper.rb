class Scrap

    attr_accessor :instances, :noms_mairies, :liens_mairies, :emails_mairies, :mairies_scrapped, :to_search
    @@instances = []
    
    def save_as_csv
        File.open('db/emails.csv', 'w') do |f|
            i = 0
            l = 1
            while @emails_mairies[i] != nil
                    if @emails_mairies[i] != "None"
                        f.write("#{l},\"#{@noms_mairies[i].to_s}\",\"#{@emails_mairies[i].to_s}\"\n")
                        l += 1
                    end
                    i += 1
            end
        end
        puts "\nDonnées enregistrées dans db/emails.csv"
    end

    def save_as_JSON
        File.open('db/emails.json', 'w') do |f|
            f.write(@mairies_scrapped.to_json)
        end
        puts "\nDonnées enregistrées dans db/emails.json"
    end

    def test_json_gdrive
        if File.exist?("lib/gdrive/config.json") == false #check if config.json exist, if not, create it
            if File.exist?(".env")
                File.open("lib/gdrive/config.json", 'w') do |f|
                    f.write("{\n")
                    f.write("  \"client_id\": \"#{ENV['ID']}\",\n")
                    f.write("  \"client_secret\": \"#{ENV['SECRET']}\"\n")
                    f.write("}")
                end
                puts "Fichier config.json créé."
            else
                puts "\nVous devez créer un fichier .env à la racine avec à l'intérieur :"
                puts "ID='votre id d'API google'"
                puts "SECRET='votre code secret d'API google'"
                puts "Pour plus d'informations sur la création de ces identifiants, suivez cette consigne : https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md"
                puts "\nAbandon."
                return false
            end
        else
            puts "Fichier config.json trouvé."
        end
        return true
    end

    def save_as_gdrive
        if test_json_gdrive == false
            return
        end
        puts "Quelle est la clé du document google drive ? (trouvable dans l'url)"
        print "Clé : "
        ask = gets.chomp.to_s
        session = GoogleDrive::Session.from_config("lib/gdrive/config.json")
        ws = session.spreadsheet_by_key(ask).worksheets[0]
        i = 0
        y = 1
        while ws[y, 1].to_s != ""
            y += 1
        end
        while @emails_mairies[i] != nil
            if @emails_mairies[i] != "None"
                ws[y, 1] = @noms_mairies[i]
                ws[y, 2] = @emails_mairies[i]
                y += 1
            end
            i += 1
        end
        ws.save
        puts "\nEnregistré à https://docs.google.com/spreadsheets/d/#{ask}"
    end

    def save_as_txt
        File.open("db/emails.txt", 'w') do |f|
            i = 0
            while @emails_mairies[i] != nil
                if @emails_mairies[i] != "None"
                    f.write("#{@noms_mairies[i].to_s} | #{@emails_mairies[i].to_s}\n")
                end
                i += 1
            end 
        end
        puts "\nDonnées enregistrées dans db/emails.txt"
    end

    def self.all
        @@instances
    end

    def self.one
        @@instances[0]
    end

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

    def show_help
        puts "\nPrefixes disponibles"
        puts "   'mairies'\n   'ft' (france travail)\n   'prefec' (prefecture)\n   'missl' (mission locale)"
        puts "\nUtilisez x/exit/quit pour quitter le programme"
    end

    def test_input
        if @to_search == "h" or @to_search == "help"
            show_help
            prompt
        end
        if @to_search == "exit" || @to_search == "" || @to_search == "quit" || @to_search == "x"
            puts "Leaving the program\n\n"
            exit
        end
        until @to_search.include?("https://lannuaire.service-public.fr/recherche?") || @to_search.include?("mairies") || @to_search.include?("ft") || @to_search.include?("prefec")|| @to_search.include?("missl")
            puts "\nDésolé, l'adresse recherchée n'est pas valide."
            puts "L'adresse doit commencer par https://lannuaire.service-public.fr ou un prefixe valide."
            puts "Pour voir les prefixes disponibles, utilisez 'h' ou 'help'"
            prompt
        end
    end

    def reassign_input 
        if @to_search.include? "mairies"
            @to_search = "https://lannuaire.service-public.fr/recherche?whoWhat=Mairie&where=#{@to_search.gsub("mairies", '')}"
        end
        if @to_search.include? "ft" #france travail
            @to_search = "https://lannuaire.service-public.fr/recherche?whoWhat=France+Travail&where=#{@to_search.gsub("ft", '')}"
        end
        if @to_search.include? "prefec" #prefecture
            @to_search = "https://lannuaire.service-public.fr/recherche?whoWhat=Pr%C3%A9fecture&where=#{@to_search.gsub("prefec", '')}"
        end
        if @to_search.include? "missl" #mission locale
            @to_search = "https://lannuaire.service-public.fr/recherche?whoWhat=Mission+locale+pour+l%27insertion+professionnelle+et+sociale+des+jeunes+%2816-25+ans%29&where=#{@to_search.gsub("missl", '')}"
        end
    end

    def prompt
        print "\n#{Etc.getlogin} : "
        @to_search = gets.chomp.to_s
        test_input
    end

    def save_prompt
        puts "\nSave as ? (txt/json/gdrive/csv/skip)"
        ask = gets.chomp.to_s
        if ask == "txt"
            save_as_txt
        elsif ask == "json"
            save_as_JSON
        elsif ask == "gdrive"
            save_as_gdrive
        elsif ask == "csv"
            save_as_csv
        elsif ask == "" or ask == "skip"
            return
        end
    end

    def go_scrap
        prompt
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
        save_prompt
        Scrap.new
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