module Asari::Domain

  # Asari::Domain::Name provides an interface for storing parts of a CloudSearch domain name,
  # applying environment and app prefixes, and ensuring the name meets CloudSearch requirements
  class Name

    #
    # Class methods & data
    #
    # The class holds the transformation options and requirements,
    #   provides app and environment prefixes,
    #   and performs sanitation

    # AWS specs
    MIN_CHARS = 3
    MAX_CHARS = 28
    DISALLOWED_CHARS = /[^a-z0-9\-]/

    # Config holder and defaults
    Config = Struct.new :app_prefix, :env_prefixes,
                        :invalid_char_replacement, :filler_char,
                        :warn_on_transform, :error_on_transform

    DEFAULTS = [
      APP_PREFIX = '',
      ENV_PREFIXES = { 'development' => 'dev', 'test' => 'tst', 'production'  => 'prd'},
      INVALID_CHAR_REPLACEMENT = '1',
      FILLER_CHAR = '0',
      WARN_ON_TRANSFORM = false,
      ERROR_ON_TRANSFORM = true,
    ]

    class << self
      # Access and reset config
      def build_config
        Asari::Domain::Name::Config.new(*DEFAULTS)
      end
      include Asari::Support::ConfigAccessors

      def app_prefix
        config.app_prefix
      end

      def environment
        @environment || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      end
      attr_writer :environment

      def env_prefix
        config.env_prefixes[environment]
      end

      def prefix(stem)
        [app_prefix, env_prefix, stem].
          reject{|p| p.respond_to?(:empty?) ? !!p.empty? : !p}. # aka &:blank?
          join('-')
      end

      def prefix_and_sanitize(stem)
        sanitize(prefix(stem))
      end

      # Prepare a domain name to meet CloudSearch reqs. Because this requires changing
      #   a unsanitary name, there's the possibility that it will lead to name collisions
      #   if you made the same naming mistake a lot. Thus, we offer raising errors and warnings
      #   when changes are made.
      def sanitize(name)
        sanitized = name.gsub(DISALLOWED_CHARS, "#{config.invalid_char_replacement}")
        sanitized = sanitized[0..MAX_CHARS-1] if sanitized.length > MAX_CHARS
        needed_chars = 3 - sanitized.length
        sanitized += config.filler_char * needed_chars if needed_chars > 0

        if name != sanitized
          if config.error_on_transform
            raise Asari::Domain::Errors::NameException,
              "Tried to use unsanitary domain name #{name}, try #{sanitized} instead"
          end

          if config.warn_on_transform and config.logger
            config.logger.warn "Asari::Domain::Name - Using domain name #{sanitized} instead of unsanitary" +
              " name #{name}. This may cause conflicts with existing domain names."
          end
        end

        sanitized
      end

      def sanitary?(name)
        length = name.length
        length > MIN_CHARS && length < MAX_CHARS && !name.match(DISALLOWED_CHARS)
      end
    end


    #
    # Instance methods & data
    #

    def initialize(stem, options = {})
      self.stem = stem
      self.skip_prefixes = true if options[:skip_prefixes]
    end

    # stem - a general descriptor of the document, i.e. searchable-model,
    #   sanitized upon storage
    attr_reader :stem
    def stem=(name)
      @stem = Asari::Domain::Name.sanitize(name)
    end

    # prefixed - stem plus app and env prefixes, i.e. rls-test-searchable-model,
    #   sanitized on read since the prefixes can change without being sanitized
    def prefixed
      Asari::Domain::Name.prefix_and_sanitize(stem)
    end

    # skip_prefixes - on a whim, decide if you want full to return with or without prefixes
    attr_writer :skip_prefixes
    def skip_prefixes? ; @skip_prefixes end

    # full - prefixed, unless you just want the base name
    def full
      skip_prefixes? ? stem : prefixed
    end

  end
end
