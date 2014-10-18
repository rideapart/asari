module Asari
=begin
  class MigrationError < AsariError
    def initialize(message = nil)
      message = "\n\n#{message}\n\n" if message
      super
    end
  end

  # Exception that can be raised to stop migrations from going backwards.
  class IrreversibleMigration < MigrationError
  end

  class DuplicateMigrationVersionError < MigrationError#:nodoc:
    def initialize(version)
      super("Multiple migrations have the version number #{version}")
    end
  end
=end
  class Migration

  end
end
