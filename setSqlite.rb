require 'rubygems'
require 'sequel'
DB = Sequel.connect('sqlite://midare.db')

DB.create_table :user do
  primary_key :id
  text :twitter_id
  text :toekn
  text :toekn_secret
  text :create_at
  integer :status_flag
end
