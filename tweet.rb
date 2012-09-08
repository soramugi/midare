#!/usr/bin/ruby
# encoding : utf-8
require 'pit'
require 'sequel'
require 'twitter'

file_path = File.expand_path(File.dirname(__FILE__))
DB        = Sequel.connect(
  'sqlite:'+ file_path +'//midare.db',
  :timeout => 2000
)

users = DB[:user].filter(:status_flag => 0)
pit = Pit.get(
  "twitter_midare",
  :require => {
    "consumer_key"    => "consumer key",
    "consumer_secret" => "consumer secret"
  }
)

words = open(
  file_path +'/word.txt',
  :encoding => Encoding::UTF_8
).readlines

Twitter.configure do |config|
  config.consumer_key    = pit['consumer_key']
  config.consumer_secret = pit['consumer_secret']
end

clients = []
users.each do |user|
  clients << Twitter::Client.new(
    :oauth_token        => user[:toekn],
    :oauth_token_secret => user[:toekn_secret]
  )
end

clients.each do |client|

  # 認証解除してないか確認
  client.user rescue next

  # ツイートする単語を決定
  word = words.shuffle.first.chomp + "の乱れ #乱れ"

  # ツイート
  client.update(word) rescue next
end
