module Asari::Domain
  
  class Config
    attr_writer :environment_prefixes, :environment

    def environment_prefix
      environment_prefixes[environment]
    end

  end

  class << self
    def build_config
      Asari::Client::Config.new
    end

    include Asari::Support::ConfigAccessors
  end

end