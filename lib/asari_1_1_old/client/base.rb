module Asari::Client

  # Asari::Client::Base is extended by the three primary clients
  # It stores the working domain, logger, region, and API version
  #
  # Child clients are expected to extend setter methods to
  # validate input and ensure config changes flow to internal clients
  class Base

    # You can set region and domain when initializing
    def initialize(*args)
      defaults = {
        api_version: Asari::Client.config.default_api_version,
        domain: nil,
        logger: Asari::Client.config.default_logger,
        mode: Asari::Client.config.default_mode,
        region: Asari::Client.config.default_region
      }

      # support for Asari < 1.1, where this was called
      # with (domain = nil, region = nil) instead of
      # with (options = {})
      if args.empty?
        options = {}
      elsif args[0].is_a? Hash
        options = args[0]
      else
        options = {domain: args[0]}
        options[:region] = args[1] if args.count > 1
      end

      options = defaults.merge(options)

      self.api_version = options[:api_version]
      self.domain = options[:domain]
      self.logger = options[:logger]
      self.mode = options[:mode]
      self.region = options[:region]
    end

    attr_accessor :api_version, :logger, :mode, :region

    # If we got here, it means no domain was supplied to the action,
    #   so raise an error if none is stored on the client either
    def domain
      @domain || raise(Asari::Client::Errors::MissingDomainException.new)
    end
    attr_writer :domain

    %w(describe_domain create_domain delete_domain).each do |method|
      define_method(:"#{method}") do |domain_name|
        self.send(:"#{method}s", [domain_name])
      end
    end

  end
end