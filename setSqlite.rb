require 'rubygems'
require 'sequel'
DB = Sequel.connect('sqlite://midare.db')

KEY = ''
SECRET = ''

DB.create_table :twitConsumer do
  primary_key :id
  text :key
  text :secret
end

twitConsumer = DB[:twitConsumer]
twitConsumer.insert(:key => KEY, :secret => SECRET)

DB.create_table :twitOauth do
  primary_key :id
  text :name_id
  text :toekn
  text :toekn_secret
  text :posted_date
  Float :status_flag
end
