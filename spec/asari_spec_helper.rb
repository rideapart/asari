#require 'ostruct'
#require 'spec_helper'

require 'simplecov'
SimpleCov.start

#require 'rspec/its'


require 'asari'
# Fake production mode to test.
#Asari.mode = :production
# This should be unneccasry now, can use AWS mocks

=begin
def fake_response
  OpenStruct.new(:parsed_response => { "hits" => {
                      "found" => 2,
                      "start" => 0,
                      "hit" => [{"id" => "123"}, {"id" => "456"}]}},
                 :response => OpenStruct.new(:code => "200"))
end

def fake_empty_response
  OpenStruct.new(:parsed_response => { "hits" => { "found" => 0, "start" => 0, "hit" => []}},
                 :response => OpenStruct.new(:code => "200"))
end

def fake_error_response
  OpenStruct.new(:response => OpenStruct.new(:code => "404"))
end

def fake_post_success
  OpenStruct.new(:response => OpenStruct.new(:code => "200"))
end
=end