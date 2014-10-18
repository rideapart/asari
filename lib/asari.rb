#require 'ostruct'

require 'asari/support/config_accessors'

module Asari

  API_2013 = '2013-01-01'
  API_2011 = '2011-02-01'

  class BaseError < StandardError ; end
  class ApiVersionException < BaseError ; end

  Config = Struct.new :api_version, :logger, :stub_responses, :region

  class << self
    include Asari::Support::ConfigAccessors

    def build_config
      Asari::Config.new(API_2013, nil, true, 'us-east-1')
    end
  end

end


#require 'asari/search/result'
#require 'asari/search/result_collection'
#Asari.autoload :Geography,   'asari/client/http'


#require 'asari/client'
#Asari::Client.autoload :Http,   'asari/client/http'
#Asari::Client.autoload :Sdk1,   'asari/client/sdk1'
#Asari::Client.autoload :Sdk2,   'asari/client/sdk2'
#require 'asari/clients'
require 'asari/client_manager'

require 'asari/domain/base'
require 'asari/domain/index_field'
require 'asari/domains'

#Asari.autoload :Model, 'asari/model'
#Asari::Model.autoload :ActiveRecord, 'asari/model/active_record'

#require 'asari/rails'
#Asari::Rails.autoload :Migrations, 'asari/migrations'
#Asari::Rails.autoload :Railtie, 'asari/railtie'
#Asari::Rails::Railtie if defined? Rails

#require 'asari/support/deprecation'
#require 'asari/core_deprecated' # refers to Asari::Client::HTTP

require 'asari/version'
