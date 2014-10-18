module Asari::Client
  class Base
    extend Asari::Support::Deprecation
    deprecated_alias :search_domain, :domain
    deprecated_alias :'search_domain=', :'domain='
    deprecated_alias :aws_region, :region
    deprecated_alias :'aws_region=', :'region='
  end
end