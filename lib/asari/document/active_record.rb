require 'active_record'

module ActiveAsari
  module ActiveRecord
    include Asari::Searchable

    def delay_index
      @delay_index || false
    end

    attr_writer :delay_index

    # Public: This module should be included in any class inheriting from ActiveRecord::Base that needs to be indexed.
    # Every time this module is included, asari_index *must* be called (see Document).
    # Including this module will automatically create before_destroy, after_create, and after_update AR callbacks to
    #   remove, add, and update items in the CloudSearch index (respectively).

    def self.included(base)
      unless ActiveAsari.config.delay_index
        base.class_eval do
          before_destroy :asari_remove_from_index
          after_create :asari_add_to_index
          after_update :asari_update_in_index
        end
      end
    end

    # class methods

    def active_asari_index(class_name)
      active_asari_index_array = ACTIVE_ASARI_CONFIG[class_name].symbolize_keys.keys.concat [:active_asari_id]
      asari_index ActiveAsari.asari_domain_name(class_name),  active_asari_index_array #if Asari.production? # need to find a way to localize asari fails to prod only, i.e. for host application tests
    end

  end
end
