# Somewhere along the way...
require 'active_record'
require 'logger'

# And then in an initializer:
require 'asari'

ActiveAsari.config do |c|
  c.load_document_schema File.expand_path('active_asari/active_asari_config.yml', File.dirname(__FILE__))
  c.load_environment_settings File.expand_path('active_asari/active_asari_env.yml', File.dirname(__FILE__))
  c.api_version = '2013-01-01'
  c.region = 'us-west-1'
  c.domain_app_prefix = 'test-app'
  c.logger = Logger.new(STDOUT)
end