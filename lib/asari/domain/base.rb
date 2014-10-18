module Asari::Domain

  # A Domain represents a specific CloudSearch domain instance
  # It has a static name, api_version
  class Base

    def initialize(name, options = {})
      defaults = {
        api_version: Asari.config.api_version,
        create: false,
        #sync: true,
        region: Asari.config.region
      }
      options = defaults.merge options

      @api_version = options[:api_version]
      @name = name
      @region = options[:region]

      self.create if options[:create]
      #self.sync if options[:sync]
    end

    attr_reader :api_version, :name, :region

    def connection
      @connection ||=
        Asari::ClientManager.new(api_version: api_version, region: region)
    end

=begin
    def client_options

    end

    def connection
      @connection ||= Asari::ClientManager.new(client_options)
    end

    #def reconfigure
    #  @connection = Asari::ClientManager.new(client_options)
    #end
=end
=begin
    #def sync
    #  sync_status

    #  if self.created?
    #    sync_index_fields
    #    sync_availability_options
        # etc
    #  end
    #end
=end


    #
    # Creation and Deletion
    #

    def create
      response = connection.create_domain(domain_name: name)[:domain_status]
      #$stdout.write "response is #{response.inspect}"
      @status = response
    end

    def delete
      @status = connection.delete_domain(domain_name: name)[:domain_status]
    end


    #
    # Index fields
    #
    # We represent an index field as either a Hash or a Struct with
    # {
    #   index_field_name:
    #   index_field_type:
    #   int_options:
    #   ... more type options ...
    #   date_array_options:
    #   ... etc ...
    # }

    def index_fields
      @index_fields || sync_index_fields
    end

    def sync_index_fields
      response = connection.describe_index_fields(domain_name: name)
      @index_fields ||= {}

      response[:index_fields].each do |field_response|
        field = field_response[:options]
        @index_fields[field[:index_field_name]] = field
      end

      @index_fields
    end

    #def sync_index
    #    create_index_field domain, field.first => field.last
    #    create_index_field domain, 'active_asari_id' => {'index_field_type' => 'int', 'return_enabled' => true}
    #connection.index_documents :domain_name => ActiveAsari.amazon_safe_domain_name(domain)
    #end

    def add_index_field(field)

    end
    alias_method :update_index_field, :add_index_field
    #def create_index_field(domain, field)
    #  index_field_name = field.keys.first
    #  index_field_type = field[index_field_name]['index_field_type']
    #  request = {:domain_name => ActiveAsari.amazon_safe_domain_name(domain),
    # :index_field => {:index_field_name => index_field_name,
    # :index_field_type => index_field_type}}
    #  field[index_field_name].delete 'index_field_type'
    #  request[:index_field]["#{index_field_type.tr('-', '_')}_options".to_sym] =
    # field[index_field_name].symbolize_keys! if !field[index_field_name].empty?
    #
    #  connection.define_index_field request
    #end

    def add_index_fields(fields)
      fields.each do |f|
        add_index_field(f)
      end
    end
    alias_method :update_index_fields, :add_index_fields

    def delete_index_field

    end


    #
    # Status
    #
    # CloudSearch stores the highest-level attributes in a domain's "Status"

    def status
      @status ||= sync_status
    end

    def sync_status
      #p "\ngetting remote status", 'connect', connection, 'descript'#, connection.describe_domains(domain_names: [name])
      remote_status = connection.
        describe_domains(domain_names: [name])[:domain_status_list].
        find{|d| d[:domain_name] == name}
      #p 'description is ', connection.
      #    describe_domains(domain_names: [name])[:domain_status_list]
      @status = remote_status || {domain_name: name, created: false}
    end

    [:domain_id, :domain_name, :doc_arn, :search_arn,
     :created, :deleted, :processing, :requires_index_documents,
     :search_instance_type, :search_partition_count, :search_instance_count,
     :maximum_replication_count, :maximum_partition_count,
     :num_searchable_docs
    ].each do |attribute|
      define_method(attribute) do
        #$stdout.write "\ntrying to get #{attribute} from \n #{status.inspect}\n"
        status[attribute]
      end
    end
    alias_method :created?, :created
    alias_method :deleted?, :deleted
    alias_method :processing?, :processing

    #def created?
    #  p "\ntrying to get created", @status
    #  self.created
    #end

    def doc_endpoint
      status[:doc_service][:endpoint]
    end

    def search_endpoint
      status[:search_service][:endpoint]
    end

    def doc_arn
      # SDK1
      #   doc_service[:arn] -> doc_arn
      # SDK2 2013
      #   arn -> doc_arn, search_arn
    end

    def search_arn
      # SDK1
      #   search_service[:arn] -> search_arch
      # SDK2 2013
      #   arn -> doc_arn, search_arn
    end

    def maximum_replication_count
      # SDK1
      #   doesnt exist maximum_replication_count
    end

    def doc_count
      # @todo Enable doc count request in Client::HTTP and attach to SDK1 describe domains
      # SDK2 2013
      #   special request to get -> num_searchable_docs
      #      get_doc_count = options.delete(:get_doc_count)
      #  doc_counts = Asari::Clients[:asari_http].request('q=matchall&q.parser=structured&size=0')
      #  somehow parse these and add them to the response
    end



    # ==== Unsupported features below

    #
    # == Access Policies
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing domain access policies
    #
    # describe_service_access_policies(params = {})
    # update_service_access_policies(params = {})
    #   See http://docs.aws.amazon.com/cloudsearch/latest/developerguide/configuring-access.html
    #def update_service_access_policies(domain)
    #  policy_array = []
    #  asari_env = environment
    #  resource = "arn:aws:cloudsearch:us-east-1:#{ACTIVE_ASARI_ENV[asari_env]['account']}:domain/*"
    #  ACTIVE_ASARI_ENV[asari_env]['access_permissions'].each do |permission|
    #    policy_array << {:Effect => :Allow, :Action => 'cloudsearch:*', :Resource => resource, :Condition => {:IpAddress => {'aws:SourceIp' => [permission['ip_address']]}}}
    #  end
    #  access_policies = {:Statement => policy_array}
    #  connection.update_service_access_policies :domain_name => domain, :access_policies => access_policies.to_json
    #end


    #
    # == Analysis Schemes
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing domain analysis schemes
    #
    #define_analysis_scheme(params = {})
    #delete_analysis_scheme(params = {})
    #describe_analysis_schemes(params = {})


    #
    # == Availability options
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing domain availability options
    #
=begin
    def sync_multi_az
      @multi_az = Asari::Clients.domain.multi_az(name.full)
    end

    def multi_az
      refresh_multi_az if @multi_az.nil?
      @multi_az
    end

    def enable_multi_az
      unless self.multi_az
        @multi_az = Asari::Clients.domain.enable_multi_az(name.full)

        unless self.multi_az
          raise UpdateError, "Failed enabling multi-az on #{name.full}"
        else
          'success'
        end
      else
        'already enabled'
      end
    end

    def disable_multi_az
      if self.multi_az
        @multi_az = Asari::Clients.domain.disable_multi_az(name.full)

        if multi_az
          raise UpdateError, "Failed disabling multi-az on #{name.full}"
        else
          'success'
        end
      else
        'already disabled'
      end
    end
=end


    #
    # == Expressions
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing expressions
    #
    # define_expression(params = {})
    # delete_expression(params = {})
    # describe_expressions(params = {})


    #
    # == Scaling parameters
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing scaling parameters
    #
    # describe_scaling_parameters(params = {})
    # update_scaling_parameters(params = {})


    #
    # == Suggestors
    #
    # Currently not supported, use the AWS console instead
    # @todo Enable viewing and changing domain suggestors
    #
    # build_suggesters(params = {})
    # define_suggester(params = {})
    # delete_suggester(params = {})
    # describe_suggesters(params = {})


  end
end








