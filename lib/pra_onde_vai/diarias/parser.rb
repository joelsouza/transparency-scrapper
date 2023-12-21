# frozen_string_literal: true

module PraOndeVai
  # Diarias
  module Diarias
    # Parser
    class Parser
      attr_reader :document

      def initialize(html)
        raise ArgumentError unless html

        @document = Nokogiri::HTML(html)
      end

      private

      def parse
        tables = document.css('#relatorio > table')
        items = tables.each_slice(3).to_a
        items.map do |item|
          diaria = parse_diaria(item[0])
          detalhes = parse_detalhes(item[1])
          items = parse_items(item[2])
          params = diaria.merge(detalhes).merge(items)
          Diaria.new(params)
        end
      end
    end
  end
end
