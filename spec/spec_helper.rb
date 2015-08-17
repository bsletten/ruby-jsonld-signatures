$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'bundler/setup'
require 'json/ld/signature'

require 'openssl'
require 'yaml'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  pub = File.read("data/pub_key.pem")
  config.before(:each) do
    stub_request(:get, "http://example.com/foo/key/1").
      to_return(:status => 200, :body => pub, :headers => {})
  end
end
