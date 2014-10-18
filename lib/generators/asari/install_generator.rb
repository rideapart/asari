require 'rails/generators/base'


# http://guides.rubyonrails.org/generators.html

module SomeGem
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __FILE__)

      desc 'Creates an Asari initializer and does other stuff too'
      #class_option :orm

      def copy_initializer
        copy_file "asari_test.rb", "config/initializers/asari_test.rb"
      end

      def add_to_production_environment
        # in config/environments/production.rb add Asari.mode == : production
        #copy_file "asari_test.rb", "config/initializers/asari_test.rb"
      end

      #def copy_locale
        #template "devise.rb", "config/initializers/devise.rb"
      #create_file "config/initializers/initializer.rb", "# Add initialization content here"
      #end

      #def show_readme
      #  readme "README" if behavior == :invoke
      #end

      #def rails_4?
      #  Rails::VERSION::MAJOR == 4
      #end
    end
  end
end