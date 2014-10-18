# http://edgeapi.rubyonrails.org/classes/Rails/Railtie.html
require 'rails'

module ActiveAsari
  class Railtie < Rails::Railtie

    puts 'in ActiveAsari railtie'

    # To add an initialization step from your Railtie to Rails boot process, you just need to create an initializer block:
    # If specified, the block can also receive the application object, in case you need to access some application
    #   specific configuration, like middleware:
    #initializer "my_railtie.configure_rails_initialization" do |app|
    #  app.middleware.use MyRailtie::Middleware
    #end
    initializer "my_railtie.configure_rails_initialization" do
      puts "in ActiveAsari railtie initializer"
    end

    # Add a to_prepare block which is executed once in production
    # and before each request in development
    #config.to_prepare do
    #  MyRailtie.setup!
    #end

    rake_tasks do
      puts 'in ActiveAsari rake tasks block'
      Dir[File.expand_path("../../tasks/active_asari/*.rake", __FILE__)].each {|file| File.load file}
    end

  end
end