# frozen_string_literal: true

require './refunds/scrapper'

RSpec.describe Refunds::Scrapper do
  let(:url) { 'https://transparencia.teutonia.rs.gov.br/gerador.php?secao=diarias&tipo=P&exercicio=2023&relatorio=00/2023&id_entidade=1,2,3' }
  describe '#crawl' do
    it 'returns the body of the response' do
      VCR.use_cassette('diarias') do
        scrapper = Refunds::Scrapper.new(url)
        expect(scrapper.crawl).to be_an_instance_of(String)
      end
    end
  end
end
