module Asari
  class << self
    extend Asari::Support::Deprecation

    # Pretend to be Asari::Client::HTTP for support of Asari < 1.1
    def new(*args)
      deprecation_warning('Asari.new', 'Asari::Client::HTTP.new')
      Asari::Client::HTTP.new(*args)
    end
  end


=begin
   #
   # Helpers for Asari < 1.1
   #

   # Legacy configuration helper method
  def self.configure(yaml_file_dir)
    active_asari_config = YAML.load_file(File.expand_path(yaml_file_dir) + '/active_asari_config.yml')
    active_asari_env = YAML.load_file(File.expand_path(yaml_file_dir) + '/active_asari_env.yml')
    return active_asari_config, active_asari_env
  end

  # Helper you can add after a legacy config to make it still work
  def self.load_configuration_constants
    Asari::Domain.load_schema ACTIVE_ASARI_CONFIG
    Asari::Domain.load_env_settings ACTIVE_ASARI_ENV
    end
  end


end
=end
end

