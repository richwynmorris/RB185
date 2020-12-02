#! /usr/bin/env ruby

require "pg"

expensesdb = PG.connect(dbname: 'expenses')

@information = expensesdb.exec "SELECT * FROM expenses ORDER BY created_on ASC;"

def list 
  @information.values.each do |value|
    puts "#{value[0]} | #{value[3]}| #{value[1].rjust(11)}| #{value[2]}"
  end

  sleep (5)
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

  sleep (5)
end

user_command = ARGV

if user_command.first == 'list'
  list
else 
  help
end
