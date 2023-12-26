# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

module Refunds
  # Scrapper
  class Scrapper
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def crawl
      response = HTTParty.get(url)
      response.body
    end
  end
end

# module PraOndeVai
#   # Diarias
#   module Diarias
#     # Scrapper
#     class Scrapper
#       attr_reader :url

#       def initialize(url)
#         @url = url
#       end

#       def scrap
#         response = HTTParty.get(url)
#         document = Nokogiri::HTML(response.body)
#         document.css('#relatorio > table').to_html
#       end
#     end
#   end
# end
