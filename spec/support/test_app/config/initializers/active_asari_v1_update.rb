ActiveAsari.load_configuration_constants

# We were unable to set the default region before, had to do it every Asari.new or on asari_index calls
# But now you can:
Asari.default_region = 'us-west-1'

# You can also now add a prefix to all domains that comes before the environment prefix
ActiveAsari.config.domain_app_prefix = 'test-app'