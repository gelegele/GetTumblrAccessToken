require 'app'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_root
    get '/'
    assert last_response.ok?
    #assert_equal 'Hello World', last_response.body
  end

  def test_post_root_ok
    post '/', :consumer_key => 'xL2YvVRUuf4IbWLrOcUdbzeQqoI41gIoI1pBzjhpeELtMmJpus', :consumer_secret => '8va4ZdBuX79lvoVjwjYuMqJ50w4Ql5LqSuPG1EAEiakeJTptLV'
    #assert last_response.body.ok?
  end
end