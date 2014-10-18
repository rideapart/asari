# Somewhere along the way...
require 'active_record'
require 'logger'

# And then when initializing:
require 'asari'
active_asari_config_path = File.join(File.dirname(__FILE__), 'active_asari' )
ACTIVE_ASARI_CONFIG, ACTIVE_ASARI_ENV = ActiveAsari.configure(active_asari_config_path)
require 'active_asari/active_record'

ENV['CLOUDSEARCH_API_VERSION'] = '2013-01-01' # either this or every Asari.new you have to set its .api_version

AWS.config(:region => 'us-west-1')       # This works for ActiveAsari, at least
AWS.config(:logger => Logger.new(STDOUT))