module Asari

  module Errors
    class DeprecatedError < Asari::Errors::BaseError
      extend Asari::Support::Deprecation

      def new
        deprecation_warning("#{self}", @use_instead)
        super
      end
    end
  end

  class MissingSearchDomainException < Asari::Errors::DeprecatedError
    @use_instead = 'Asari::Client::Errors::DomainException'
  end

  class VersionException < Asari::Errors::DeprecatedError
    @use_instead = 'Asari::Client::Errors::VersionException'
  end

  class DocumentUpdateException < Asari::Errors::DeprecatedError
    @use_instead = 'Asari::Client::Errors::DocumentServiceException'
  end

  class SearchException < Asari::Errors::DeprecatedError
    @use_instead = 'Asari::Client::Errors::SearchException'
  end

end
