#!/usr/bin/ruby
# encoding : utf-8

class DbSet
  require 'sequel'
  require 'pit'
  require 'twitter'

  def initialize
    path = File.expand_path(File.dirname(__FILE__))
    db = Sequel.connect('sqlite:' + path + '//midare.db')
    @users = db[:user]
    @pit = Pit.get("twitter_midare", :require => {
      "consumer_key"    => "consumer key",
      "consumer_secret" => "consumer secret"
    })
  end

  def settings
    thread_max = 500

    jobqueue = Queue.new
    @users.each do |client|
      jobqueue.push(client)
    end

    threads = []
    thread_max.times do
      threads << Thread.start do
        while !jobqueue.empty?
          var = jobqueue.pop
          setting(var)
          sleep rand(0)
        end
      end
    end
    threads.each {|t| t.join}
  end

  private

  def setting(user)
    Twitter.configure do |config|
      config.consumer_key    = @pit['consumer_key']
      config.consumer_secret = @pit['consumer_secret']
    end

    client = Twitter::Client.new(
      :oauth_token        => user[:toekn],
      :oauth_token_secret => user[:toekn_secret]
    )

    begin
      client.user
    rescue
      @users.filter(:id => user[:id]).update(:status_flag => 1)
      return
    end

    if user[:status_flag] == 1 then
      @users.filter(:id => user[:id]).update(:status_flag => 0)
    end

    if user[:twitter_id] != client.user.screen_name then
      @users.filter(:id => user[:id])
      .update(:twitter_id => client.user.screen_name)
    end
  end
end

db_set = DbSet.new
db_set.settings
