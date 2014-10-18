module Asari
=begin
  # Asari::Client::Changeable exists to let you switch between client versions with #api_version
  # It caches a client of whatever version it needs, then changes clients if versions change
  #
  # I can't imagine there are many people who need to switch between versions mid-execution,
  # but this is necessary to provide backwards compatability with Asari 1.0
  class Client::Changeable < Client

    # At the class level, we store the default version for each instance, which can itself be changed
    # via class method or by supplying ENV['CLOUDSEARCH_API_VERSION'] at any time
    # We pass Asari::default_version and Asari::default_version= to this class
    class << self
      def default_version
        @default_version || ENV['CLOUDSEARCH_API_VERSION'] || Asari::DEFAULT_DEFAULT_VERSION
      end

      attr_writer :default_version
    end


    # Retrieve the cached client, or build one if it doesn't yet exist
    def versioned_client
      @versioned_client ||= build_versioned_client
    end

    # Create a versioned client for self.version
    def build_versioned_client
      case version
      when '2013-01-01'
        Client::V2013.new(@domain, @region)
      when '2011-02-01'
        Client::V2011.new(@domain, @region)
      else
        raise UnknownVersionException, "ActiveAsari doesn't recognize AWS CloudSearch api version #{api_version}"
      end
    end

    #    else
    #AWS::Dummy::Client.new
    #  def self.reconfigure
    #@aws_client = nil
    #end

    # Get the current client version
    def version
      @version || self.class.default_version
    end

    # Set the current client version
    # If we already have a cached versioned client of a different version,
    #   rebuild using the new version number
    def version=(new_version)
      @version = new_version
      if @versioned_client and new_version != @versioned_client.version
        @versioned_client = build_versioned_client
      end
    end

    # Pass region changes down to the versioned client
    def region=(region)
      @versioned_client.region = region if @versioned_client
      super
    end

    # Pass client methods on to the client
    %w(search add_item update_item remove_item).each do |method|
      define_method(method) {|*args| self.versioned_client.send(method.to_sym, *args)}
    end

    # Aliases for deprecated methods
    alias_method :api_version, :version
    alias_method :'api_version=', :'version='
  end
=end
end