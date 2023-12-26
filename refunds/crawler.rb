# frozen_string_literal: true

require 'pry'
require 'nokogiri'

module Refunds
  # Crawler
  class Crawler
    attr_reader :document

    def initialize(html)
      @document = Nokogiri::HTML(html, nil, 'ISO-8859-1')
    end

    def parse
      tables = document.css('#relatorio > table:has(> tbody > tr + tr + tr)')
      items = tables.each_slice(3).to_a
      items.map do |item|
        diaria = parse_diaria(item[0])
        detalhes = parse_despesa(item[1])
        items = parse_items(item[2])
        diaria.merge(detalhes).merge({ items: items })
      end
    end

    private

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def parse_diaria(table)
      tbody = table.css('> tbody')
      {
        movimento: tbody.css('> tr:nth-child(2) > td:nth-child(1)').text,
        numero_empenho: tbody.css('> tr:nth-child(2) > td:nth-child(2)').text,
        data_emissao: tbody.css('> tr:nth-child(2) > td:nth-child(3)').text,
        tipo_empenho: tbody.css('> tr:nth-child(2) > td:nth-child(4)').text.gsub(/Ordinï¿½rio/, 'Ordinário'),
        valor_pago: tbody.css('> tr:nth-child(2) > td:nth-child(5)').text.gsub('.', '').gsub(',', '.').to_f,
        tipo_licitacao: tbody.css('> tr:nth-child(4) > td:nth-child(2)').text.gsub(/Nï¿½o/, 'Não'),
        numero_licitacao: tbody.css('> tr:nth-child(4) > td:nth-child(3)').text.to_i,
        numero_solicitacao: tbody.css('> tr:nth-child(4) > td:nth-child(4)').text.to_i,
        numero_processo_compra: tbody.css('> tr:nth-child(4) > td:nth-child(5)').text.to_i
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def parse_despesa(table)
      {
        orgao: table.css('> tbody > tr:nth-child(1) > td:nth-child(4)').text,
        unidade: table.css('> tbody > tr:nth-child(2) > td:nth-child(4)').text,
        categoria: table.css('> tbody tr:nth-child(3) > td:nth-child(4)').text,
        fonte_de_recurso: table.css('> tbody > tr:nth-child(4) > td:nth-child(4)').text,
        entidade: table.css('> tbody > tr:nth-child(5) > td:nth-child(4)').text,
        credor: table.css('> tbody > tr:nth-child(6) > td:nth-child(4)').text,
        cargo: table.css('> tbody > tr:nth-child(7) > td:nth-child(4)').text || ''
      }
    end

    def parse_items(table)
      items = table.css('> tbody > tr:not(:first-child)').to_a
      # debugger
      items.map do |item|
        {
          item: item.css('> td:nth-child(1)').text.to_i,
          quantidade: item.css('> td:nth-child(2)').text.gsub('.', '').gsub(',', '.').to_f,
          unidade: item.css('> td:nth-child(3)').text,
          descricao: item.css('> td:nth-child(4)').text,
          valor_unitario: item.css('> td:nth-child(5)').text.gsub('.', '').gsub(',', '.').to_f,
          valor_total: item.css('> td:nth-child(6)').text.gsub('.', '').gsub(',', '.').to_f
        }
      end
    end
  end
end
