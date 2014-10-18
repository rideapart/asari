module Asari
  module Support
    # Expects build_config to be defined according to extending object's defaults
    module ConfigAccessors

      def config(&block)
        @config ||= build_config
        yield(@config) if block_given?
        @config
      end

      def reset_config
        @config = build_config
      end

    end
  end
end
