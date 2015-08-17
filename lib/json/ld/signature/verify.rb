module JSON::LD::SIGNATURE

  class Verify
    
    def self.verify(input, options = {})
      
      # We require a publicKeyPem in the options hash
      if options['publicKeyPem'].nil?
        raise JsonLdSignatureError::MissingKey, "options parameter must include publicKeyPem"
      end

      # The publicKeyPem can be either a String or a parsed RSA key
      publicKey = case options['publicKeyPem']
      when String then OpenSSL::PKey::RSA.new options['publicKeyPem']
      when OpenSSL::PKey::RSA then options['publicKeyPem']
      else 
        raise JsonLdSignatureError::InvalidKeyType, "key must be RSA Key or PEM String"
      end
      
      # Check the input, it should either be a String or a parsed JSON object

      jsonld = case input
      when String then 
      begin
          JSON.parse(input)        
        rescue JSON::ParserError => e
            raise JsonLdSignatureError::InvalidJsonLdDocument, e.message
      end 
      when Hash then input
      else
        raise JsonLdSignatureError::InvalidJsonLdDocument
      end
      
      signature = jsonld['signature']
      
      created = signature['created']
      creator = signature['creator']
      signatureValue = signature['signatureValue']
      domain = signature['domain']
      nonce = signature['nonce']
      
      uri = URI(creator)
      response = Net::HTTP.get_response(uri)
      
      case response.code
        when "200"
          publicKey = OpenSSL::PKey::RSA.new response.body
        else
          raise JsonLdSignatureError::UnreachableKey, 
             "Key #{creator} could not be retrieved. Error: #{response.code}, #{response.message}"
      end
      
      normOpts = {
        'nonce' => nonce,
        'domain' => domain,
        'created' => created,
        'creator' => creator
      }
      
      normalizedGraph = JSON::LD::SIGNATURE::generateNormalizedGraph jsonld, normOpts

      digest = OpenSSL::Digest::SHA256.new
      publicKey.verify digest, Base64.decode64(signatureValue), normalizedGraph
    end
  end
end