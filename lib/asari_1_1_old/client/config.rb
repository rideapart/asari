module Asari::Client
  
  class Config
    attr_writer :default_api_version, :default_logger, :default_mode, :default_region

    def default_api_version
      @default_api_version || Asari.config.default_api_version
    end

    def default_logger
      @default_logger || Asari.config.default_logger
    end

    def default_mode
      @default_mode || Asari.config.default_mode
    end

    def default_region
      @default_region || Asari.config.default_region
    end
  end

  class << self
    def build_config
      Asari::Client::Config.new
    end

    include Asari::Support::ConfigAccessors
  end

end