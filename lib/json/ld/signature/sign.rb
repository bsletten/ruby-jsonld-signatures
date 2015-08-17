module JSON::LD::SIGNATURE
  class Sign
    def self.sign(input, options = {} )
      
      # We require a creator to identify the signing key
      
      if options['creator'].nil?
        raise JsonLdSignatureError::MissingCreator, "the creator of the signature must be identified"
      end
      
      creator = options['creator']
      
      # TODO: Validate the resolvability of the URL?

      # We require a privateKeyPem in the options hash
      if options['privateKeyPem'].nil?
        raise JsonLdSignatureError::MissingKey, "options parameter must include privateKeyPem"
      end

      # The privateKeyPem can be either a String or a parsed RSA key
      privateKey = case options['privateKeyPem']
      when String then OpenSSL::PKey::RSA.new options['privateKeyPem']
      when OpenSSL::PKey::RSA then options['privateKeyPem']
      else 
        raise JsonLdSignatureError::InvalidKeyType, "key must be RSA Key or PEM String"
      end

      unless privateKey.private?
        raise JsonLdSignatureError::WrongKeyType, "submitted key is a public key"
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
      
      jsonld.delete 'signature'
      created = Time.now.iso8601
      nonce = options['nonce']
      domain = options['domain']
            
      normOpts = {
        'nonce' => nonce,
        'domain' => options['domain'],
        'created' => created,
        'creator' => creator
      }
      
      normalizedGraph = JSON::LD::SIGNATURE::generateNormalizedGraph jsonld, normOpts
      
      digest = OpenSSL::Digest::SHA256.new
      signature = privateKey.sign digest, normalizedGraph
      enc = Base64.strict_encode64(signature)
      
       # "@context" : "https://w3id.org/security/v1",

      sigobj = JSON.parse %({
        "type" : "GraphSignature2012",
        "creator" : "#{creator}",
        "created" : "#{created}",
        "signatureValue" : "#{enc}"
      })
      
      sigobj['domain'] = domain unless options['domain'].nil?
      sigobj['nonce'] = nonce unless nonce.nil?
      
      jsonld['signature'] = sigobj
      jsonld.to_json
    end
  end
end