# frozen_string_literal: true

require 'pg'
require 'pry'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'budget')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_expenses
    sql = <<~SQL
      SELECT expenses.id, expenses.name AS expense, amount, created_on, categories.name as category
      FROM expenses
      JOIN categories ON expenses.category_id = categories.id
      ORDER BY created_on DESC
    SQL

    result = query(sql)

    result.map do |tuple|
      { id: tuple['id'].to_i,
        name: tuple['expense'],
        amount: tuple['amount'],
        date: tuple['created_on'],
        category: tuple['category'] }
    end
  end

  def total_amount
    sql = 'SELECT SUM(amount) AS sum FROM expenses'
    result = query(sql)
    result.first['sum'].to_f
  end

  def find_expense(id)
    sql = <<~SQL
      SELECT expenses.*, categories.name AS category#{' '}
      FROM expenses#{' '}
      JOIN categories ON expenses.category_id = categories.id
      WHERE expenses.id = $1
    SQL

    result = query(sql, id)

    { id: result.first['id'].to_i,
      name: result.first['name'],
      amount: result.first['amount'],
      date: result.first['created_on'],
      category: result.first['category'] }
  end

  def update_expense(id, info)
    sql = <<~SQL
      UPDATE expenses
      SET name = $1, amount = $2
      WHERE id = $3
    SQL

    query(sql, info[0], info[1], id)
  end

  def delete_expense(id)
    sql = 'DELETE FROM expenses WHERE id = $1'
    query(sql, id)
  end

  def add_expense(info)
    category_id = find_category_id(info[2])

    sql = <<~SQL
      INSERT INTO expenses (name, amount, category_id, created_on)
      VALUES ($1, $2, $3, $4)
    SQL

    query(sql, info[0], info[1], category_id, info[3])
  end

  def delete_all_expenses
    query('DELETE FROM expenses')
  end

  private

  def find_category_id(category)
    sql = 'SELECT id FROM categories WHERE name = $1'
    result = query(sql, category)
    result.first['id']
  end
end
