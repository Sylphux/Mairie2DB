require 'nokogiri'
require 'open-uri'
require 'etc'
require 'json'
require_relative 'lib/app/scrapper'
require 'google_drive'

def verify
    puts "\nBienvenue dans le scrappeur de l'annuaire public."
    puts "\nCONDITION D'UTILISATION : Ce projet est réalisé dans un but éducatif et ne doit pas être utilisé pour d'autres objectif que l'étude de la programmation. Les résultats ne doivent pas être utilisés et doivent être supprimés après les sessions de test."
    puts "\nAcceptez-vous ces conditons ? (y/N)"
    ask = gets.chomp
    if ask != "y"
        puts "Vous avez refusé les conditions d'utilisation."
        exit
    end
    puts "\nIl existe deux méthodes de recherche :"
    puts "\n  Méthode 1 : un lien commençant par https://lannuaire.service-public.fr/"
    puts "  Méthode 2 : 'prefixe_valide votre_recherche'"
    puts "              - Pour une liste des prefixes, utilisez 'h'"
end

def perform
    system "clear"
    verify
    Scrap.new
end

perform