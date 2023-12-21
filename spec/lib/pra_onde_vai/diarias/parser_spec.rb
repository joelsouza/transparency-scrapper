require 'pra_onde_vai/diarias/parser'

RSpec.describe PraOndeVai::Diarias::Parser do
  describe '#initialize' do
    it 'receives an Nokogiri::HTML object' do
      html = '<html></html>'
      parser = PraOndeVai::Diarias::Parser.new(html)
      expect(parser.html).to be_a(Nokogiri::HTML::Document)
    end
    it 'fails when no html is provided' do
      expect { PraOndeVai::Diarias::Parser.new }.to raise_error(ArgumentError)
    end
  end

  describe '#parse' do
    # it 'returns an array of diaria model' do
    #   html = '<html></html>'
    #   parser = PraOndeVai::Diarias::Parser.new(html)
    #   diarias = parser.parse
    #   expect(diarias).to be_an(Array)
    #   expect(diarias.first).to be_a(Diaria)
    # end
  end


end
