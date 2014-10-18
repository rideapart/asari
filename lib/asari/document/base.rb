module Asari

  # Every time this module is included, asari_index *must* be called (see below)
  module Document



    def initialize(model_name)
      @model_name = model_name
    end

    # i.e. some-model -> app-name-production-some-model
    def build_cloudsearch_name
      @model_name.underscore.gsub('_', ActiveAsari.config.domain_model_name_sep) # i.e 'model-name'
    end

    def cloudsearch_name
      @cloudsearch_name ||= build_cloudsearch_name

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def asari_id
      self.send(@@asari_id_method)
    end

    def asari_remove_from_index
      self.class.asari_remove_item(self)
    end

    def asari_add_to_index
      self.class.asari_add_item(self)
    end

    def asari_update_in_index
      self.class.asari_update_item(self)
    end

    module ClassMethods

      # Get the custom attribute/method set as the basis for #asari_id, defaults to #id
      def asari_id_method
        @asari_id_base || :id
      end

      # Set a custom attribute/method as the basis for #asari_id
      def asari_id_method=(sym)
        if self.method_defined?(sym)
          @asari_id_base = sym
        else
          raise StandardError, "#{self} tried to define ActiveAsari id method as undefined method ##{sym}"
        end
      end

      # Public: DSL method for adding this model object to the asari search
      # index.
      #
      # This method *must* be called in any object that includes
      # Asari::Searchable, or your methods will be very sad.
      #
      #   search_domain - the CloudSearch domain to use for indexing this model.
      #   fields - an array of Symbols representing the list of fields that
      #     should be included in this index.
      #   options - a hash of extra options to consider when indexing this
      #     model. Options:
      #       when - a string or symbol representing a method name, or a Proc to
      #         evaluate to determine if this model object should be indexed. On
      #         creation, if the method or Proc specified returns false, the
      #         model will not be indexed and will be removed from the index (if
      #         it exists there).
      #       aws_region - if this model is indexed on an AWS region other than
      #       us-east-1, specify it with this option.
      #
      # Examples:
      #     class User < Object
      #       include Asari::Searchable
      #
      #       asari_index("my-companies-users-asglkj4rsagkjlh34", [:name, :email])
      #       # or
      #       asari_index("my-companies-users-asglkj4rsagkjlh34", [:name, :email], :when => :should_be_indexed)
      #       # or
      #       asari_index("my-companies-users-asglkj4rsagkjlh34", [:name, :email], :when => Proc.new({ |user| user.published && !user.admin? }))
      #
      # asari_index do |i|
      #   i.string :title
      #   i.integer :number, source: Proc.new({...})
      #
      def asari_index(options = {})
        defaults = {
          domain: self.primary_domain,
          domain_name: nil,
          


        }
        aws_region = options.delete(:aws_region)
        self.class_variable_set(:@@asari_instance, Asari.new(search_domain,aws_region))
        self.class_variable_set(:@@asari_fields, fields)
        self.class_variable_set(:@@asari_when, options.delete(:when))
      end

      def asari_instance
        self.class_variable_get(:@@asari_instance)
      end

      def asari_fields
        self.class_variable_get(:@@asari_fields)
      end

      def asari_when
        self.class_variable_get(:@@asari_when)
      end

      # Internal: method for adding a newly created item to the CloudSearch
      # index. Should probably only be called from asari_add_to_index above.
      def asari_add_item(obj)
        if self.asari_when
          return unless asari_should_index?(obj)
        end
        data = self.asari_data_item(obj)
        self.asari_instance.add_item(obj.send(:id), data)
      rescue Asari::DocumentUpdateException => e
        self.asari_on_error(e)
      end

      def asari_add_items(objects)
        amazon_items = []
        objects.each do |object|
          if self.asari_when and asari_should_index?(object)
            data = self.asari_data_item object
            amazon_items << self.asari_instance.create_item_query(object.id, data)
          elsif !self.asari_when
            data = self.asari_data_item object
            amazon_items << self.asari_instance.create_item_query(object.id, data)
          end
        end
        self.asari_instance.doc_request(amazon_items) if amazon_items.size > 0
      rescue Asari::DocumentUpdateException => e
        self.asari_on_error(e)
      end

      def asari_remove_items(ids)
        amazon_items = []
        ids.each do |id|
          amazon_items << self.asari_instance.remove_item_query(id)
        end
        self.asari_instance.doc_request(amazon_items)
      rescue Asari::DocumentUpdateException => e
        self.asari_on_error(e)
      end

      # Internal: method for updating a freshly edited item to the CloudSearch
      # index. Should probably only be called from asari_update_in_index above.
      def asari_update_item(obj)
        if self.asari_when
          unless asari_should_index?(obj)
            self.asari_remove_item(obj)
            return
          end
        end
        data = self.asari_data_item(obj)
        self.asari_instance.update_item(obj.send(:id), data)
      rescue Asari::DocumentUpdateException => e
        self.asari_on_error(e)
      end

      # Gather all the data to send to the CloudSearch
      # Can be overriden by the model to adapt to special cases.
      # Returns a hash of the data to send to the CloudSearch
      def asari_data_item(obj)
        data = {}
        self.asari_fields.each do |field|
          data[field] = obj.send(field) || ""
        end
        data
      end

      # Internal: method for removing a soon-to-be deleted item from the CloudSearch
      # index. Should probably only be called from asari_remove_from_index above.
      def asari_remove_item(obj)
        self.asari_instance.remove_item(obj.send(:id))
      rescue Asari::DocumentUpdateException => e
        self.asari_on_error(e)
      end

      # Internal: method for looking at the when method/Proc (if defined) to
      #   determine whether this model should be indexed.
      def asari_should_index?(object)
        when_test = self.asari_when
        if when_test.is_a? Proc
          return when_test.call(object)
        else
          return object.send(when_test)
        end
      end

      # Public: method for searching the index for the specified term and
      #   returning all model objects that match.
      #
      # Returns: a list of all matching AR model objects, or an empty list if no
      #   records are found that match.
      #
      # Raises: an Asari::SearchException error if there are issues
      #   communicating with the CloudSearch server.
      def asari_find(term, options = {})
        records = self.asari_instance.search(term, options)
        ids = records.map { |id| id.to_i }

        records.replace(Array(self.where("id in (?)", ids)))
      end

      # Public: method for handling errors from Asari document updates. By
      # default, this method causes all such exceptions (generated by issues
      # from updates, creates, or deletes to the index) to be raised immediately
      # to the caller; override this method on your activerecord object to
      # handle the errors in a custom fashion. Be sure to return true if you
      # don't want the AR callbacks to halt execution.
      #
      def asari_on_error(exception)
        raise exception
      end
    end
  end
end

module Asari

  #
  # Domain Usage
  #
  # Either put queries here or on domain, you could have a separate client manager here, but that is sdk2 duplication
  # usually. So just send through domain's client. but then you might as well put the methods there
  # or maybe logically it will make more sense here have to see
  class Document

# For document updates and search we use a domain dependent client - asari http or sdk cloudsearchdomain

=begin

#:field_names => Array<String>
#  A list of the index fields you want to describe. If not specified, information is returned for all configured index fields.
#:deployed => Boolean
#  Whether to display the deployed configuration (true) or include any pending changes (false). Defaults to false.
def describe_index_fields(options = {})
  resp = @client_manager.describe_index_fields(domain_name: name)
  #field_names: ["FieldName", '...'],
  #deployed: true,
  define_index_field
end


def define_index_field(params = {})
  define_index_field
end

def prepare_indexes_for(documents)
  documents.each do
  end
end

def prepare_index
  @domain.prepare_index_fields(index_fields)
end



=end

=begin

       # http://docs.aws.amazon.com/sdkforruby/api/Aws/CloudSearchDomain/Client.html#search-instance_method
       #  cursor: "Cursor",
       #expr: "Expr",
       #  facet: "Facet",
       #  filter_query: "FilterQuery",
       #  highlight: "Highlight",
       #  partial: true,
       #  # required
       #  query: "Query",
       #  query_options: "QueryOptions",
       #  query_parser: "simple|structured|lucene|dismax",
       #  return: "Return",
       #  size: 1,
       #  sort: "Sort",
       #  start: 1,
       #
       #
      def search(params = {})
        domain_client.search(params = {})
      end

      def suggest
        client = domains_client
      end

      def upload
        client = domains_client
      end
=end

  end
end

