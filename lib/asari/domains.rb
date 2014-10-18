module Asari

  # Asari::Domains provides a way to remember domains in a global context
  # This could be useful if you want to manage and use domains that aren't
  # backed by local models
  module Domains
    class << self

      def build_hash

      end

      def hash
        @hash || build_hash     
      end
      attr_writer :hash

      def load_schema(path)
        self.schema = YAML.load_file(path)

      end

      def load_env_settings(path)
        self.env_settings = YAML.load_file(path)
      end

      attr_accessor :document_schema, :environment_settings, :domain_app_prefix

      # have this here or somewhere else??

      #
      #
      #


      def domain_environment_prefix
        environment_settings[environment]['domain_prefix']
      end

# If you have long model names and issues with domain name length you could set this to ''
      def domain_model_name_sep
        @domain_model_name_sep || '-'
      end
      attr_writer :domain_model_name_sep







    end
  end

end