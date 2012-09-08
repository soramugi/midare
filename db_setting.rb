#!/usr/bin/ruby
# encoding : utf-8
require 'sequel'
require 'pit'
require 'twitter'

file_path = File.expand_path(File.dirname(__FILE__))
DB        = Sequel.connect(
  'sqlite:'+ file_path +'//midare.db',
  :timeout => 2000
)

user = DB[:user]
pit = Pit.get(
  "twitter_midare",
  :require => {
    "consumer_key"    => "consumer key",
    "consumer_secret" => "consumer secret"
  }
)

Twitter.configure do |config|
  config.consumer_key    = pit['consumer_key']
  config.consumer_secret = pit['consumer_secret']
end

user.each do |oauth|

  @client = Twitter::Client.new(
    :oauth_token        => oauth[:toekn],
    :oauth_token_secret => oauth[:toekn_secret]
  )

  # 認証解除してないか確認
  begin
    @client.user
  rescue
    user.filter(:id => oauth[:id]).update(:status_flag => 1)
    next
  end

  # 認証確認、再有効
  if oauth[:status_flag] == 1 then
    user.filter(:id => oauth[:id]).update(:status_flag => 0)
  end

  # 前回からTwitterIDが変わっていないか、変わっていたら登録し直し
  if oauth[:twitter_id] != @client.user.screen_name then
    user.filter(
      :id => oauth[:id]
    ).update(
      :twitter_id => @client.user.screen_name
    )
  end
end
