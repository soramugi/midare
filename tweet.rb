#!/usr/bin/ruby
# encoding : utf-8
require 'pit'
require 'sequel'
require 'twitter'

file_path = File.expand_path(File.dirname(__FILE__))
DB        = Sequel.connect('sqlite:'+ file_path +'//midare.db')

twitOauths   = DB[:twitOauth].filter(:status_flag => 0)
pit = Pit.get("twitter_midare", :require => {
  "consumer_key"    => "consumer key",
  "consumer_secret" => "consumer secret"
})

CONSUMER_KEY    = pit['consumer_key']
CONSUMER_SECRET = pit['consumer_secret']
words           = open(file_path +'/word.txt').readlines

twitOauths.each do |oauth|

  Twitter.configure do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.oauth_token        = oauth[:toekn]
    config.oauth_token_secret = oauth[:toekn_secret]
  end

  Twitter.user rescue next

  if oauth[:name_id] != Twitter.user.screen_name then
    twitOauths.filter(:id => oauth[:id]).update(:name_id => Twitter.user.screen_name)
  end

  word = words.shuffle.first.chomp + "の乱れ #乱れ"

  Twitter.update(word) rescue next
end
