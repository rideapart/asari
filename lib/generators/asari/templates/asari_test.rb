# config/initializers/asari.rb

Asari.config do |c|

  #
  # Clients
  #

  # Set your AWS region
  # c.client.default_region = 'us-west-1'  # Any valid region, default 'us-east-1'

  # Set your API version if using 2011
  # Asari can use the HTTParty client for the 2011 API to update and search
  #   documents, but will be unable to manage domains as Asari currently doesn't
  #   support the SDK1 with 2011
  #
  # c.client.api_version = '2011'      # '2011' or '2013', default '2013'

  # If you're using HTTParty for any required operations, you'll need to
  #   authorize your accessing server IPs to manage CloudSearch. See
  #   http://docs.aws.amazon.com/cloudsearch/latest/developerguide/configuring-access.htm
  #   Asari::Searchable can do this for its managed domains using an SDK
  #   client, see the end of the Searchable config section.

  # If you're using an SDK for any required operations and want to use IAM users
  #   instead of attaching a role to your EC2 instance, you can store your
  #   credentials in a local YAML file organized by environment. We use an
  #   external file so you can dynamically generate it during deployment or
  #   create it manually, instead of checking it into version control. Example:
  #
  #     test:
  #       access_key_id: AKIAEEEOOOOOOOOO
  #       secret_access_key: not_a_big_secret
  #     production:
  #       access_key_id: AKIAWWWEEEOOOOOO
  #       secret_access_key: hopefully_a_bigger_secret
  #
  # This would load the file from config/initializers/asari/iam_users.yml :
  #
  # c.client.load_iam_users File.join(File.dirname(__FILE__), 'asari', 'iam_users.yml')


  #
  # Searchable Models
  #

  # If you'd like to store the schema for your various Searchable models in a
  #   single file, instead of using the index helpers in individual model files,
  #   you can load it from YAML:
  #
  #     ModelName:
  #       stored_field_name:
  #         attribute: value
  #     TestModel:
  #       name:
  #         type: text
  #         returnable: true
  #
  # c.searchable.load_schema File.join(File.dirname(__FILE__), 'asari', 'schema.yml')


  #
  # Searchable Model Domains
  #

  # Asari clients can be asked to access any domain at any time, but Asari will
  #   remember one Searchable domain per model per environment. This is done to
  #   reduce complications involved with sharing different models in the same
  #   index, but if you'd like to share an index it can be done (with great
  #   caution and skill) via providing each model with the same domain alias.
  #
  # Domain names are stored in app-env-model-name format by default, which can
  #   quickly surpass CloudSearch's 28 character maximum, so it's recommended
  #   you keep prefixes short (or non-existent) and provide aliases for models
  #   with long names (see the Searchable Model examples).
  #
  # Only the domains run in production need to actually exist.
  #

  # If you're running multiple apps on the same CloudSearch account, you'll
  #   probably want an app prefix. If not, keep it blank and the trailing - will
  #   be excluded, i.e. simply env-model instead of app-env-model
  #
  # c.searchable.domain.app_prefix = 'rls'  # Any short string, default nil

  # Set the prefixes Asari::Searchable should use for each Rails/Rack
  #   environment. Keep these short but recognizable. If you never need to run
  #   multiple env domains on CloudSearch you can keep these blank or share
  #   them, but for flexibility the below exists by default.
  #
  # c.searchable.domain.env_prefixes = {
  #   development: 'dev',
  #          test: 'test',
  #    production: 'prod'
  # }

  # If you're using HTTParty for any required operations and would like to
  #   configure your domains to accept your server IPs using your already
  #   authorized SDK1 client, you can also store those IPs in a local YAML file,
  #   organized by environment:
  #
  #     test:
  #     - 192.168.66.23/32
  #     - 23.44.23.25/32
  #     production:
  #     - 192.168.66.23/32
  #
  # c.searchable.domain.load_access_ips File.join(File.dirname(__FILE__), 'asari', 'domain_access_ips.yml')

end