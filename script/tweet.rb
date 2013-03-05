#!/usr/bin/ruby
# encoding : utf-8
class Midare
  require 'pit'
  require 'sequel'
  require 'twitter'
  require 'thread'

  def initialize
    path = File.expand_path(File.dirname(__FILE__)).to_s
    db = Sequel.connect('sqlite:' + path + '//../db/midare.db')

    @users = db[:user].filter(:status_flag => 0)
    @pit = Pit.get("twitter_midare", :require => {
      "consumer_key"    => "consumer key",
      "consumer_secret" => "consumer secret"
    })

    @words = open(path + '/../db/word.txt', :encoding => Encoding::UTF_8).readlines
  end

  def thread_tweet
    thread_max = 100

    jobqueue = Queue.new
    @users.each do |client|
      jobqueue.push(client)
    end

    threads = []
    thread_max.times do
      threads << Thread.start do
        while !jobqueue.empty?
          var = jobqueue.pop
          tweet(var)
          sleep rand(0)
        end
      end
    end
    threads.each {|t| t.join}
  end

  def tweet(user)
    Twitter.configure do |config|
      config.consumer_key       = @pit['consumer_key']
      config.consumer_secret    = @pit['consumer_secret']
      config.oauth_token        = user[:toekn]
      config.oauth_token_secret = user[:toekn_secret]
    end

    Twitter.update(@words.shuffle.first.chomp + "の乱れ #乱れ") rescue return
  end

end

midare = Midare.new
midare.thread_tweet
