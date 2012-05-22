#!/usr/bin/ruby
# encoding : utf-8
require 'rubygems'
require 'sequel'
require 'twitter'

DB = Sequel.connect('sqlite:'+ File.expand_path(File.dirname(__FILE__)) +'//midare.db')
twitConsumer = DB[:twitConsumer]
twitOauths = DB[:twitOauth].filter(:status_flag => 0)
words = DB[:word].filter(:status_flag => 0)

CONSUMER_KEY = twitConsumer.first[:key]
CONSUMER_SECRET = twitConsumer.first[:secret]

word = []
words.each do |w|
    word.push(w[:word])
end

twitOauths.each do |oauth|

    Twitter.configure do |config|
        config.consumer_key       = CONSUMER_KEY
        config.consumer_secret    = CONSUMER_SECRET
        config.oauth_token        = oauth[:toekn]
        config.oauth_token_secret = oauth[:toekn_secret]
    end

    if oauth[:name_id] != Twitter.user.screen_name then
        twitOauths.filter(:id => oauth[:id]).update(:name_id => Twitter.user.screen_name)
    end

    text = word[rand(word.length)] + "の乱れ #乱れ"

    Twitter.update(text)
end
