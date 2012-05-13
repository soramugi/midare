require 'rubygems'
require 'sequel'
DB = Sequel.connect('sqlite://midare.db')
word = DB[:word]

word.delete

f = open('word.txt')
num = 0
f.each do |line|
    num += 1
    word.insert(:id => num, :word => line.chomp, :status_flag => 0)
end
f.close
