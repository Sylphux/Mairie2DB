require 'nokogiri' 
require 'open-uri'

def nokogise(site, element_xpath)
    page = Nokogiri::HTML(URI.open(site))
    cryptoprices = page.xpath(element_xpath)
    return cryptoprices
end

def make_nice_list(keys, values)
    finalhash = []
    keys.count.times do |i|
        finalhash.push({keys[i-1]=>values[i-1]})
    end
    return finalhash
end

def perform
    pagelink = 'https://coinmarketcap.com/all/views/all/'
    puts "voici une liste des cryptos les plus populaires et leur prix"

    #get crypto names. to text
    cryptonames = nokogise(pagelink,'//a[@class="cmc-table__column-name--name cmc-link"]').map{|x| x.text}

    #get prices. to text
    cryptoprices = nokogise(pagelink,'//div[@class="sc-142c02c-0 lmjbLF"]').map{|x| x.text[1...-1].tr(",","")}

    #create array with hashes
    final_board = make_nice_list(cryptonames,cryptoprices)
    puts final_board
end

perform