# coding: utf-8
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'logger'

use Rack::Session::Pool, :expire_after => 2592000 # instead of "enable :sessions" to encrypt


configure do
    Log = Logger.new(STDOUT)
    @http_proxy = ENV["http_proxy"]
    if @http_proxy
        Log.info "http_proxy ==> #@http_proxy"
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

