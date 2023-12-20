require "httparty"
require "awesome_print"
require "nokogiri"
require "pg"
# require "./database"


conn = PG.connect('postgres://postgres:postgres@localhost/spinne')
conn.exec(<<-SQL
  DROP TABLE IF EXISTS diarias_items;
  DROP TABLE IF EXISTS diarias;
  CREATE TABLE IF NOT EXISTS diarias (
    id INT GENERATED ALWAYS AS IDENTITY,
    data_movimentacao TEXT,
    numero_empenho TEXT,
    data_emissao TEXT,
    tipo_empenho TEXT,
    valor_pago FLOAT,
    tipo_licitacao TEXT,
    numero_licitacao TEXT,
    numero_solicitacao TEXT,
    numero_processo_compra TEXT,
    orgao TEXT,
    unidade TEXT,
    categoria TEXT,
    fonte_recurso TEXT,
    entidate TEXT,
    cnpj TEXT,
    credor TEXT,
    cargo_funcao TEXT,
    obs TEXT,
    PRIMARY KEY(id)
  );

  CREATE TABLE IF NOT EXISTS diarias_items (
    id INT GENERATED ALWAYS AS IDENTITY,
    numero TEXT,
    quantidade FLOAT,
    unidade TEXT,
    descricao TEXT,
    valor_unitario FLOAT,
    valor_total FLOAT,
    diaria_id INTEGER,
    PRIMARY KEY(id),
    CONSTRAINT fk_diarias
          FOREIGN KEY(diaria_id)
            REFERENCES diarias(id)
  );
SQL
)

# clear tables
conn.exec('DELETE FROM diarias_items')
conn.exec('DELETE FROM diarias')

params = {
  secao: 'diarias',
  tipo: 'P',
  exercicio: '2023',
  id_entidade: '1,2,3'
}

months = (1..12)
year = 2023

months.each do |month|
  params = params.merge(relatorio: "#{month.to_s.rjust(2, '0')}/#{year}")
  response = HTTParty.get('https://transparencia.teutonia.rs.gov.br/gerador.php', query: params)
  document = Nokogiri::HTML(response.body)

  tables = document.css('#relatorio > table')

  # chunks of 3
  chuhks = tables.each_slice(3).to_a
  chuhks.each do |chuhk|
    # diaria
    table_diaria = chuhk[0]

    # detalhes diaria
    table_detalhes = chuhk[1]

    # items
    table_items = chuhk[2]

    diaria = table_diaria.css('tr').map { |tr| tr.css('td').map(&:text) }
    next if diaria.size < 4

    data_movimentacao = diaria[1][0]
    numero_empenho = diaria[1][1]
    data_emissao = diaria[1][2]
    tipo_empenho = diaria[1][3]
    valor_pago = diaria[1][4].gsub('.', '').gsub(',', '.').to_f
    tipo_licitacao = diaria[3][1]
    numero_licitacao = diaria[3][2]
    numero_solicitacao = diaria[3][3]
    numero_processo_compra = diaria[3][4]

    detalhes = table_detalhes.css('tr').map { |tr| tr.css('td').map(&:text) }
    orgao = detalhes[0][3]
    unidade = detalhes[1][3]
    categoria = detalhes[2][3]
    fonte_recurso = detalhes[3][3]
    entidate = detalhes[4][3]
    credor = detalhes[5][3]
    cargo_funcao = detalhes[6][3]

    if conn.exec('SELECT * FROM diarias WHERE numero_empenho = $1', [numero_empenho]).any?
      next
    end

    begin
      sql = 'INSERT INTO diarias (data_movimentacao, numero_empenho, data_emissao, tipo_empenho, valor_pago, tipo_licitacao, numero_licitacao, numero_solicitacao, numero_processo_compra, orgao, unidade, categoria, fonte_recurso, entidate, credor, cargo_funcao) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10 , $11, $12, $13, $14, $15, $16)'
      conn.exec_params(
        sql,
        [
          data_movimentacao,
          numero_empenho,
          data_emissao,
          tipo_empenho,
          valor_pago,
          tipo_licitacao,
          numero_licitacao,
          numero_solicitacao,
          numero_processo_compra,
          orgao,
          unidade,
          categoria,
          fonte_recurso,
          entidate,
          credor,
          cargo_funcao
        ]
      )
    rescue StandardError => e
      ap "error on #{numero_empenho}"
      ap e.message
    end
    diaria_id = conn.sync_exec_params('SELECT id FROM diarias WHERE numero_empenho = $1', [numero_empenho]).first['id'].to_i

    # ap table_items.css('tr').map { |tr| tr.css('td').map(&:text) }
    items = table_items.css('tr').map { |tr| tr.css('td').map(&:text) }
    items.shift # remove header

    items.each do |item|
      numero = item[0] unless item[0].empty?
      quantidade = item[1].to_i unless item[1].empty?
      unidade = item[2] unless item[2].empty?
      descricao = item[3] unless item[3].empty?

      valor_unitario = format('%.2f', item[4].gsub('.', '').gsub(',', '.')).to_f unless item[4].empty?
      valor_total = format('%.2f', item[5].gsub('.', '').gsub(',', '.')).to_f unless item[5].empty?

      # detalhes da diaria adicionado como linha item
      if numero.nil? && quantidade.nil? && unidade.nil?
        obs = descricao
        conn.exec_params('UPDATE diarias SET obs = $1 WHERE id = $2', [obs, diaria_id])
      end

      begin
        conn.exec_params(
          'INSERT INTO diarias_items (numero, quantidade, unidade, descricao, valor_unitario, valor_total, diaria_id) values ($1, $2, $3, $4, $5, $6, $7)',
          [numero, quantidade, unidade, descricao, valor_unitario, valor_total, diaria_id]
        )
      rescue StandardError => e
        ap "error on #{numero_empenho} items"
        ap e.message
        break
      end
    end
  end
  puts "month #{month} done"
  puts 'sleeping 2 seconds...'
  sleep 2
end
