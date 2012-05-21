#!/usr/bin/ruby
# encoding : utf-8

require 'rubygems'
require 'sinatra'
require 'twitter'
require 'oauth'
require 'sequel'
DB = Sequel.connect('sqlite://midare.db')

error do
    redirect '/'
end

not_found do
    redirect '/'
end

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end

#起動時に一回だけ
configure do
    use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
end

#現在のURL取得
def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    "#{request.scheme}://#{request.host}#{port}"
end

def oauth_consumer
    twitConsumer = DB[:twitConsumer]
    OAuth::Consumer.new(
        twitConsumer.first[:key],
        twitConsumer.first[:secret],
        :site => "http://twitter.com"
    )
end

get '/style.css' do
    content_type 'text/css', :charaset => 'utf-8'
    sass :style
end

get'/' do
    @search = Twitter.search('乱れ -RT', :length => 'ja', :rpp => 2)
    haml :index
end


get '/request_token' do
    callback_url = "#{base_url}/access_token"
    request_token = oauth_consumer.get_request_token(
        :oauth_callback => callback_url
    )
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect request_token.authorize_url
end

get '/access_token' do
    twitConsumer = DB[:twitConsumer]
    twitOauth = DB[:twitOauth]

    request_token = OAuth::RequestToken.new(
        oauth_consumer,
        session[:request_token],
        session[:request_token_secret]
    )
    access_token = request_token.get_access_token(
        {},
        :oauth_token => params[:oauth_token],
        :oauth_verifier => params[:oauth_verifier]
    )
    #トークンの再登録防止
    twitOauth.each do | oauth |
        if oauth[:toekn] == access_token.token then
            redirect '/'
        end
    end
    #登録
    twitOauth.insert(
        :toekn => access_token.token,
        :toekn_secret => access_token.secret,
        :posted_date => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        :status_flag => 0
    )

    #登録通知
    Twitter.configure do |config|
        config.consumer_key       = twitConsumer.first[:key]
        config.consumer_secret    = twitConsumer.first[:secret]
        config.oauth_token        = access_token.token
        config.oauth_token_secret = access_token.secret
    end
    Twitter.update("精神の乱れに登録しました #{base_url} #乱れ")

    redirect '/'
end

