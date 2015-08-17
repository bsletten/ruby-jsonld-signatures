

module JSON
  module LD
    module SIGNATURE
      require 'base64'
      require 'json/ld'
      require 'rdf/normalize'
      
      autoload :Sign, 'json/ld/signature/sign'
      autoload :Verify, 'json/ld/signature/verify'
      
      def generateNormalizedGraph(jsonLDDoc, opts)
        jsonLDDoc.delete 'signature'

        graph = RDF::Graph.new << JSON::LD::API.toRdf(jsonLDDoc)
        # TODO: Parameterize the normalization
        normalized = graph.dump(:normalize)

        digestdoc = ''
        digestdoc << opts['nonce'] unless opts['nonce'].nil?
        digestdoc << opts['created']
        digestdoc << normalized
        digestdoc << '@' + opts['domain'] unless opts['domain'].nil?
        digestdoc
      end
      
      module_function :generateNormalizedGraph
      
      SECURITY_CONTEXT_URL = 'https://w3id.org/security/v1'
      
      class JsonLdSignatureError < JsonLdError
        class InvalidJsonLdDocument < JsonLdSignatureError; @code = "invalid JSON-LD document"; end
        class MissingCreator < JsonLdSignatureError; @code = "missing signature creator"; end
        class MissingKey < JsonLdSignatureError; @code = "missing private PEM formatted string"; end
        class InvalidKeyType < JsonLdSignatureError; @code = "invalid PEM key"; end
        class WrongKeyType < JsonLdSignatureError; @code = "signing requires a private key"; end
        class UnreachableKey < JsonLdSignatureError; @code = "unable to retrieve public key"; end
      end
    end
  end
end

