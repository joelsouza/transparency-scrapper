require "sqlite3"

class Database
  attr_reader :db, :db_name

  def initialize(db_name)
    @db = SQLite3::Database.open(db_name)
    @db_name = db_name
    db.results_as_hash = true
    self.create_tables_if_not_exists
    ap "Database #{db_name} created"
  end

  private

  def create_tables_if_not_exists
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS diarias (
        id INTEGER PRIMARY KEY,
        data_movimentacao TEXT,
        numero_empenho TEXT,
        data_emissao TEXT,
        tipo_empenho TEXT,
        valor_pago REAL,
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
        obs TEXT
      );
    SQL
    db.execute <<-SQL2
      CREATE TABLE IF NOT EXISTS diarias_items (
        id INTEGER PRIMARY KEY,
        numero TEXT,
        quantidade REAL,
        unidade TEXT,
        descricao TEXT,
        valor_unitario REAL,
        valor_total REAL,
        diaria_id INTEGER
      );
    SQL2
  end
end
