# coding: utf-8
require 'rubygems'
require 'sinatra'
require 'logger'
require 'net/http'
require 'haml'
require 'sass'
require 'oauth'
require 'pp'

use Rack::Session::Pool, :expire_after => 2592000 # instead of "enable :sessions" to encrypt

configure do
    Log = Logger.new(STDOUT)
    if ENV["http_proxy"]
        Log.info "http_proxy ==> #{ENV["http_proxy"]}"
    end
    @CALLBACK_URL = 'http://gettumblraccesstoken/callback'
    #@CALLBACK_URL = 'http://localhost:4567/callback'
end

before do
    #@error_message = nil
end

get '/style.css' do
    sass :stylesheet
end


get '/' do
    haml :page_form
end


post '/' do
    consumer_key = params[:consumer_key]
    consumer_secret = params[:consumer_secret]

    consumer = OAuth::Consumer.new(
        consumer_key, consumer_secret, {
            :site => "http://api.tumblr.com",
            :proxy=>ENV["http_proxy"],
            :request_token_url => 'http://www.tumblr.com/oauth/request_token'
        })
    begin
        #request_token = consumer.get_request_token({:oauth_callback=>"http://gettumblraccesstoken/callback"})
        request_token = consumer.get_request_token
    rescue => exc
        Log.warn "Fail to get_request_token. #{exc}"
        @error_message = exc.to_s
        if @error_message.index('400')
            @error_message += ": Did you set the Default callback URL of your app?"
        end
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        return haml :page_form
    end
    pp request_token
    authorize_url = request_token.authorize_url
    Log.info "authorize_url===>#{authorize_url}"

    session["consumer_key"] = consumer_key
    session["consumer_secret"] = consumer_secret
    session["request_token"] = request_token

    redirect authorize_url
end


get '/callback' do
    oauth_verifier = params[:oauth_verifier]
    Log.info "oauth_verifier===>#{oauth_verifier}"
    request_token = session["request_token"]
    begin
        access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    rescue => exc
        Log.warn "Fail to get_access_token. #{exc}"
        @error_message = 'Failed to get access token.'
        @consumer_key = session["consumer_key"]
        @consumer_secret = session["consumer_secret"]
        return haml :page_form
    end
    session.clear

    @consumer_key = access_token.consumer.key
    @consumer_secret = access_token.consumer.secret
    @access_token = access_token.token
    @access_token_secret = access_token.secret

    haml :page_result
end


not_found do
    "NOT FOUND!"
end

error do
    "ERROR!"
end
