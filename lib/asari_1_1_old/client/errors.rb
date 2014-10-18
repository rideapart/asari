module Asari::Client
  module Errors
    class MissingDomainException             < Asari::Errors::BaseError ; end

    class VersionException            < Asari::Errors::BaseError ; end

    class DocumentServiceException    < Asari::Errors::BaseError ; end
    class SearchServiceException      < Asari::Errors::BaseError ; end
  end
end