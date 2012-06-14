# coding: utf-8
require 'rubygems'
require 'sinatra'
require 'logger'
require 'net/http'
require 'uri'
require 'haml'
require 'sass'
require 'oauth'

use Rack::Session::Pool, :expire_after => 2592000 # instead of "enable :sessions" to encrypt


configure do
    Log = Logger.new(STDOUT)
    if ENV["http_proxy"]
        Log.info "http_proxy ==> #{ENV["http_proxy"]}"
        proxy_url = URI.parse(ENV["http_proxy"])
        @http_client = Net::HTTP.Proxy(proxy_url.host, proxy_url.port)
    else
        @http_client = Net::HTTP
    end
end


before do	
end

get '/style.css' do
    sass :stylesheet
end

get '/' do
    haml :form
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
    request_token = consumer.get_request_token
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
    access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
    @access_token = access_token.token
    @access_token_secret = access_token.secret

    @consumer_key = session["consumer_key"]
    @consumer_secret = session["consumer_secret"]
    session.clear

    haml :result
end


