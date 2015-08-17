#!/usr/bin/env ruby
require 'rubygems'

namespace :gem do
  desc "Build the rdf-jsonld-signature-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build rdf-jsonld-signature.gemspec && mv rdf-jsonld-signature-#{File.read('VERSION').chomp}.gem pkg/"
  end
  
  #TODO: Release
end
