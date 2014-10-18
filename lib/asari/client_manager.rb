require 'aws'
require 'aws-sdk-core'

module Asari

  # Asari::ClientManager manages and interfaces:
  #
  # domain-independent clients
  #   asari-base, sdk1-2011, sdk1-2013, and sdk2-2013 CloudSearch
  # and domain-dependent client
  #   sdk2-2013 CloudSearchDomain
  #
  # It remembers your API version and chooses the most appropriate client for a request
  #
  # The SDK clients have to be rebuilt any time you change
  #   mode, logger, region, or access keys (or endpoint in the case of sdk2-CloudSearchDomain-2013)
  # So it's recommended you include this at a level where those details are
  #   unlikely to change.
  #
  # If it was just endpoint that required rebuilding, we could maintain a single copy of each client
  #   to use for any domain (except the domain-specific sdk2-CloudSearchDomain-2013).
  #   However, it's a common use case to have different regions, access keys, and API versions for different domains.
  #   Thus, each Domain has its own ClientManager with its specific configuration set.
  #   This is a trade-off between the memory requirement of having a new client for every domain vs the
  #   complexity and possible frequent rebuilding of a single copy for multiple domains
  #   I'd love to get some feedback on this architectural choice.
  #
  class ClientManager

    class << self
      attr_accessor :avoid_sdk2 # useful for testing 2011 client choices with 2013 API
    end


    #
    # Hold the current API version and mode and propagate to clients
    #

    def initialize(options = {})
      defaults = {
        api_version: Asari.config.api_version,
        #access_keys: nil,
        #logger: Asari.config.logger,
        region: Asari.config.region,
        stub_responses?: Asari.config.stub_responses
      }

      options = defaults.merge(options)
      @api_version = options[:api_version]
      @region = options[:region]
      @stub_responses = options[:stub_responses?]
    end
=begin
    def api_version
      @api_version || Asari.config.api_version
    end

    def api_version=(version)
      clients.each do |client|
        client.api_version = version if client
      end
      @api_version = version
    end
=end
    def access_key_id
      if Asari.config.stub_responses
        'test-id'
      else
        @access_key_id
      end
    end


    def secret_access_key
      if Asari.config.stub_responses
        'test-key'
      else
        @secret_access_key
      end
    end

    def stub_responses?
      @stub_responses
    end

    def client_options
      {
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: @region,
        stub_responses:  stub_responses?
      }.reject{|k,v| v.nil?}
    end


    #
    # Hold an http, sdk1, and sdk2 client and only create when needed
    #

    def asari_doc_client
=begin
      @asari_doc_client ||= case @api_version
                            when Asari::API_2013
                              Asari::Client::Http.new(version: '2013')
                            when Asari::API_2011
                              Asari::Client::Http.new(version: '2011')
                            else
                              raise Asari::Errors::ApiVersionException
                            end
=end
    end

    def sdk1_domain_client
      options = client_options
      options[:stub_requests] = options.delete(:stub_responses)
      @sdk1_domain_client ||= case @api_version
                              when API_2013
                                AWS::CloudSearch::Client::V20130101.new(options)
                              when API_2011
                                AWS::CloudSearch::Client::V20110201.new(options)
                              else
                                raise Asari::Errors::ApiVersionException
                              end
    end

    def sdk2_doc_client
      @sdk2_doc_client ||= Aws::CloudSearchDomain::Client.new(client_options)
    end

    def sdk2_domain_client
      @sdk2_domain_client ||= ::Aws::CloudSearch::Client.new(client_options)
    end

    def clients
      [@asari_doc_client, @sdk1_domain_client, @sdk2_doc_client, @sdk2_domain_client]
    end
    private :clients


    #
    # Pick the right client for a request depending on current config
    #

    def domain_client
      if @api_version == API_2011 or self.class.avoid_sdk2
        sdk1_domain_client
      elsif @api_version == API_2013
        sdk2_domain_client
      else
        raise Asari::Errors::ApiVersionException
      end
    end

    def doc_client
      if @api_version == API_2011 or self.class.avoid_sdk2
        asari_doc_client
      elsif @api_version == API_2013
        sdk2_doc_client
      else
        raise Asari::Errors::ApiVersionException
      end
    end


    #
    # Send requests on to the chosen client
    #

    DOMAIN_METHODS = [:describe_domains, :create_domain, :delete_domain] +
                     [:describe_index_fields, :define_index_field, :delete_index_field, :index_documents]
    DOMAIN_METHODS.each do |client_method|
      define_method(client_method) do |*args, &block|
        domain_client.send(client_method, *args, &block)
      end
    end

    DOC_METHODS = []
    DOC_METHODS.each do |doc_method|
      define_method(client_method) do |*args, &block|
        doc_client.send(client_method, *args, &block)
      end
    end

    def stub_responses(*args)
      #$stdout.write "\nstubbing for #{@api_version}"
      if @api_version == API_2011 or self.class.avoid_sdk2
        #$stdout.write "\nstubbing #{sdk1_domain_client} with\n#{args}\n"
        element = args[1].keys.first
        sdk1_domain_client.stub_for(args[0]).data[element] = args[1][element]
      elsif @api_version == API_2013
        #$stdout.write "\nstubbing #{sdk2_domain_client} with\n#{args}\n"
        sdk2_domain_client.stub_responses(*args)
      else
        raise Asari::Errors::ApiVersionException
      end
    end


  end
end

