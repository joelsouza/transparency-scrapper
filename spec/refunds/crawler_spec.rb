# frozen_string_literal: true

require './refunds/crawler'

RSpec.describe Refunds::Crawler do
  let(:html) { File.read('spec/fixtures/diarias.html') }
  let(:crawler) { Refunds::Crawler.new(html) }
  let(:html_table_diaria) { crawler.document.css('#relatorio > table')[0] }
  let(:html_table_despesa) { crawler.document.css('#relatorio > table')[1] }
  let(:html_table_items) { crawler.document.css('#relatorio > table')[2] }

  describe '#parse' do
    it 'returns an array of hashes' do
      expect(crawler.parse).to be_an_instance_of(Array)
    end
  end

  describe '#parse_diaria' do
    it 'returns a hash' do
      expect(crawler.send(:parse_diaria, html_table_diaria)).to be_an_instance_of(Hash)
    end

    it 'returns a hash with the correct keys' do
      table = crawler.document.css('#relatorio > table')[0]
      keys = %i[
        movimento
        numero_empenho
        data_emissao
        tipo_empenho
        valor_pago
        tipo_licitacao
        numero_licitacao
        numero_solicitacao
        numero_processo_compra
      ]
      crawler.send(:parse_diaria, table).inspect
      expect(crawler.send(:parse_diaria, html_table_diaria).keys).to eq(keys)
    end

    it 'returns a hash with the correct values' do
      table = crawler.document.css('#relatorio > table')[0]
      values = ['12/01/2023', '2023/219', '02/01/2023', 'Ordinário', 662.50, 'NSA - Não se aplica', 31, 55, 173]
      expect(crawler.send(:parse_diaria, html_table_diaria).values).to eq(values)
    end
  end

  describe '#parse_despesa' do
    it 'returns a hash' do
      table = crawler.document.css('#relatorio > table')[1]
      expect(crawler.send(:parse_despesa, table)).to be_an_instance_of(Hash)
    end

    it 'returns a hash with the correct keys' do
      table = crawler.document.css('#relatorio > table')[1]
      keys = %i[orgao unidade categoria fonte_de_recurso entidade credor cargo]
      expect(crawler.send(:parse_despesa, table).keys).to eq(keys)
    end

    it 'returns a hash with the correct values' do
      table = crawler.document.css('#relatorio > table')[1]
      values = [
        '6 - SECRETARIA MUNICIPAL DA SAUDE',
        '1 - FUNDO MUNICIPAL DA SAUDE',
        '333901496000000 - DIÁRIAS PAGAMENTO ANTECIPADO',
        '40 - ACOES SERV.PUB. DE SAUDE-ASPS',
        '1 - MUNICIPIO DE TEUTONIA - CNPJ: 88661400000199',
        'ELOIR RAFAEL RUCKERT',
        ''
      ]
      expect(crawler.send(:parse_despesa, table).values).to eq(values)
    end
  end

  describe '#parse_items' do
    it 'returns an array of hashes' do
      table = crawler.document.css('#relatorio > table')[2]
      expect(crawler.send(:parse_items, table)).to be_an_instance_of(Array)
      expect(crawler.send(:parse_items, table).first).to be_an_instance_of(Hash)
    end

    it 'returns first element of array with a hash with the correct keys' do
      table = crawler.document.css('#relatorio > table')[2]
      keys = %i[item quantidade unidade descricao valor_unitario valor_total]
      expect(crawler.send(:parse_items, table).first.keys).to eq(keys)
    end

    it 'returns first element of array with a hash with the correct values' do
      table = crawler.document.css('#relatorio > table')[2]
      values = [1, 100000.0, 'DIA', 'DIÁRIA SEM PERNOITE', 66.25, 662.50]
      expect(crawler.send(:parse_items, table).first.values).to eq(values)
    end
  end
end
