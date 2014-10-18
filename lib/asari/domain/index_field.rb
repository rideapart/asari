module Asari::Domain

  #
  # IndexField
  #
  # has a name, a domain, a type, type options, and status
  # name and domain can't be changed, to rename you must delete and recreate
  #
  class IndexField

    def initialize(options)
      defaults = {
        type: nil,
        type_options: {},
        auto_sync: Asari.config.auto_sync?
      }
      options = defaults.merge options

      if !options[:name] or !options[:domain]
        raise ArgumentError, ':domain and :name are required options'
      end

      @domain = options[:domain]
      @name = options[:name]
      self.auto_sync = options[:auto_sync]
      self.type = options[:type]
      self.type_options = options[:type_options]

      sync if auto_sync
    end

    attr_accessor :auto_sync, :raw
    attr_reader :domain, :name


    #
    # == Communication with remote version
    #
    private

    def connection
      domain.connection
    end

    attr_accessor :raw

    def create

    end

    def delete

    end

    def fetch
      response = connection.describe_index_fields(
        domain_name: domain.name,
        field_names: [name]
      )[:index_fields].first

      raw = response if response
    end

    def define
      response = connection.define_index_field(
        domain_name: domain.name,
        index_field: raw
      )[:index_field]

      case response[:status][:state]
      when 'FailedToValidate'
        raise AsariError, ''
      when 'RequiresIndexDocuments', 'Processing', 'Active'
        raw = response
      end
    end

    public

    def sync
      type ? define : fetch
    end






    #
    # == Option Attributes
    #

    def raw_options
      raw[:options]
    end
    private :raw_options

    def type ; raw_options[:index_field_type] end

    def type=(new_type)
      raw_options[:index_field_type] = new_type
      sync if auto_sync
    end

    def type_options
      raw_options[:"#{type}_options"]
    end

    def type_options=(new_options)
      if type
        raw_options[:"#{type}_options"] = new_options
        sync if auto_sync
      end
    end


    #
    # == Status attributes
    #

    def raw_status
      raw[:status]
    end
    private :raw_status

    def created_at       ; raw_status[:creation_date]    end
    def updated_at       ; raw_status[:update_date]      end
    def version          ; raw_status[:update_version]   end
    def state            ; raw_status[:state]            end
    def pending_deletion ; raw_status[:pending_deletion] end

    
  end
end

=begin
    def describe
      response = connection.describe_index_fields(
        domain_name: domain.name,
        field_names: [name]
      )[:index_fields]


      response || {
        options: {
          index_field_name: name,
          index_field_type: type
        }
      }
    end
=end

=begin
    def describe

    end

    alias_method :create, :define

    def created?
      !!describe
    end

    def ensure_created
      create unless created?
    end
    def sync
      define
    end
=end