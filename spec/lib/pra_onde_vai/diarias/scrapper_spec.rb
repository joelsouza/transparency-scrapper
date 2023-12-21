require 'pra_onde_vai/diarias/scrapper'
require 'vcr'

RSpec.describe PraOndeVai::Diarias::Scrapper do
  describe '#initialize' do
    it 'receives an url as argument' do
      url = 'https://example.com'
      scrapper = PraOndeVai::Diarias::Scrapper.new(url)
      expect(scrapper.url).to eq(url)
    end

    it 'fails when no url is provided' do
      expect { PraOndeVai::Diarias::Scrapper.new }.to raise_error(ArgumentError)
    end
  end

  describe '#scrap' do
    it 'get the data from the url' do
      VCR.use_cassette('diarias') do
        url = 'https://transparencia.teutonia.rs.gov.br/gerador.php?secao=diarias&tipo=P&exercicio=2023&relatorio=00/2023&id_entidade=1,2,3'
        scrapper = PraOndeVai::Diarias::Scrapper.new(url)
        data = scrapper.scrap
        expect(data).to be_a(String)
      end
    end
  end
end
