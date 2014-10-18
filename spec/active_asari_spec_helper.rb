=begin
require 'spec_helper'
require 'factory_girl'

ENV['RACK_ENV'] = 'test'
#ACTIVE_ASARI_TEST_SEARCH_DOMAIN = 'my_great_domain' #think not needed

TEST_USING_V1_CONFIG = false

if TEST_USING_V1_CONFIG
  require_relative 'support/test_app/config/initializers/active_asari_v1.rb'
  require_relative 'support/test_app/config/initializers/active_asari_v1_update.rb'
else
  require_relative 'support/test_app/config/initializers/asari.rb'
end
=end