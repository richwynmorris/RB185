#! /usr/bin/env ruby

require "pg"

class CLI
  def initialize
    @expenses = ExpenseData.new
  end

  def run(argv)
    user_command = argv.first

    if user_command == 'list' 
      @expenses.list_expense
    elsif user_command == 'add'
      if argv.length == 3
        @expenses.add_expense(argv[1], argv[2])
      else 
        puts "You must provide an amount and memo."
      end
    elsif user_command == 'help' || user_command.empty?
      @expenses.help
    elsif user_command == 'search'
      @expenses.search(argv[1..-1].join(' '))
    end
  end

end

class ExpenseData
  def initialize 
    @expensesdb = PG::connect(dbname: 'expenses')
  end

  def add_expense (cost, memo_text)
    @expensesdb.exec_params("INSERT INTO expenses (created_on, amount, memo) VALUES (NOW(), $1, $2)", [cost, memo_text])
  end

  def list_expense
    recall_information = @expensesdb.exec "SELECT * FROM expenses ORDER BY created_on ASC;"
    format_print_result(recall_information)
  end

  def help
    puts <<~TEXT
    An expense recording system

    Commands:

    add AMOUNT MEMO [DATE] - record a new expense
    clear - delete all expenses
    list - list all expenses
    delete NUMBER - remove expense with id NUMBER
    search QUERY - list expenses with a matching memo field"
    TEXT
  end

  def search(search_term)
    results = @expensesdb.exec_params("SELECT * FROM expenses WHERE memo=$1", ["#{search_term}"])
    format_print_result(results)
  end

  private

  def format_print_result(pg_result)
      pg_result.values.each do |value|
        puts "#{value[0]} | #{value[3]}| #{value[1].rjust(11)}| #{value[2]}"
      end
  end
end


cli = CLI.new
cli.run(ARGV)