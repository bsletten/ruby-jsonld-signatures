require 'spec_helper'

describe JSON::LD::SIGNATURE::Sign do
  before :each do
    @pub = OpenSSL::PKey::RSA.new File.read 'data/pub_key.pem'
    @priv = OpenSSL::PKey::RSA.new File.read 'data/priv_key.pem'
  end
  
  context "test files" do
    test_files = {
        "basic_jsonld" => "data/rop_media_type.jsonld"
    }
    
    it "is possible to sign a basic document" do
      file = File.read(test_files['basic_jsonld'])
      signed = JSON::LD::SIGNATURE::Sign.sign file, { 'privateKeyPem' => @priv, 'creator' => 'http://example.com/foo/key/1'}
    end
  end
  
#  describe "sign" do
#    it "is possible to sign a basic document" do
#      file = File.read(test_files['basic_jsonld'])
#      signed = 
#      puts @pub
#      puts @priv    
#    end
#  end
end