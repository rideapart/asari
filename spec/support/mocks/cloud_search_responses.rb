module ActiveAsari::MockCloudSearchResponses
  DESCRIBE_DOMAINS_RESPONSE = {
    :domain_status_list => [
      {
        :search_partition_count => 1,
        :search_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:search/test-lance-event",
          :endpoint => "search-test-lance-event-7yopqryvjnumbe547ha7xhmjwi.us-east-1.cloudsearch.amazonaws.com"
        },
        :num_searchable_docs => 0,
        :search_instance_type => "search.m1.small",
        :created => true,
        :domain_id => "658167492042/test-lance-event",
        :processing => false,
        :search_instance_count => 1,
        :domain_name => "test-lance-event",
        :requires_index_documents => false,
        :deleted => false,
        :doc_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:doc/test-lance-event",
          :endpoint => "doc-test-lance-event-7yopqryvjnumbe547ha7xhmjwi.us-east-1.cloudsearch.amazonaws.com"
        }
      },
      {
        :search_partition_count => 1,
        :search_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:search/lance",
          :endpoint => "search-test-lance-lagja54pf5qhpzayza4awcw7wu.us-east-1.cloudsearch.amazonaws.com"
        },
        :num_searchable_docs => 28005,
        :search_instance_type => "search.m1.small",
        :created => true,
        :domain_id => "658167492042/test-lance",
        :processing => false,
        :search_instance_count => 1,
        :domain_name => "test-lance",
        :requires_index_documents => true,
        :deleted => false,
        :doc_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:doc/lance",
          :endpoint => "doc-test-lance-lagja54pf5qhpzayza4awcw7wu.us-east-1.cloudsearch.amazonaws.com"
        }
      },
      {
        :search_partition_count => 1,
        :search_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:search/beavis",
          :endpoint => "search-beavis-bg3kl446fx2bm5s4in2rltsoui.us-east-1.cloudsearch.amazonaws.com"
        },
        :num_searchable_docs => 0,
        :search_instance_type => "search.m1.small",
        :created => true,
        :domain_id => "658167492042/beavis",
        :processing => false,
        :search_instance_count => 1,
        :domain_name => "test-beavis",
        :requires_index_documents => false,
        :deleted => false,
        :doc_service => {
          :arn => "arn:aws:cs:us-east-1:658167492042:doc/beavis",
          :endpoint => "doc-beavis-bg3kl446fx2bm5s4in2rltsoui.us-east-1.cloudsearch.amazonaws.com"

        }
      }
    ],
    :response_metadata => {:request_id => "2b782398-fb82-11e2-a681-9b8b1f7eca45"}
  }

  CREATE_DOMAIN_RESPONSE = {
    :domain_status => {
      :search_partition_count => 0,
      :search_service => {
        :arn => "arn:aws:cs:us-east-1:888167492042:search/beavis"
      },
      :num_searchable_docs => 0,
      :created => true,
      :domain_id => "888167492042/beavis",
      :processing => false,
      :search_instance_count => 0,
      :domain_name => "beavis",
      :requires_index_documents => false,
      :deleted => false,
      :doc_service => {:arn => "arn:aws:cs:us-east-1:888167492042:doc/beavis"}
    },
    :response_metadata => {:request_id => "88e3adcb-f999-11e2-ba8b-ab9a7c0903a8"}
  }

  CREATE_LITERAL_INDEX_RESPONSE = {
    :index_field => {
      :status => {
        :creation_date => '2013-07-30 20:47:55 UTC',
        :pending_deletion => "false",
        :update_version => 20,
        :state => "RequiresIndexDocuments",
        :update_date => '2013-07-30 20:47:55 UTC'
      },
      :options => {
        :source_attributes => [],
        :literal_options => {
          :search_enabled => false
        },
        :index_field_type => "literal",
        :index_field_name => "test"}},
    :response_metadata => {:request_id => "8885505e-f959-11e2-b89b-2d5c6f978750"}
  }

  CREATE_TEXT_INDEX_RESPONSE = {
    :index_field => {
      :status => {
        :creation_date => '2013-07-30 20:47:55 UTC',
        :pending_deletion => "false",
        :update_version => 20,
        :state => "RequiresIndexDocuments",
        :update_date => '2013-07-30 20:47:55 UTC'
      },
      :options => {
        :source_attributes => [],
        :text_options => {:result_enabled => true},
        :index_field_type => "text",
        :index_field_name => "test"}
    },
    :response_metadata => {
      :request_id => "8885505e-f959-11e2-b89b-2d5c6f978750"}
  }

  CREATE_UINT_INDEX_RESPONSE = {
    :index_field => {
      :status => {
        :creation_date => '2013-07-30 20:47:55 UTC',
        :pending_deletion => "false",
        :update_version => 20,
        :state => "RequiresIndexDocuments",
        :update_date => '2013-07-30 20:47:55 UTC'},
      :options => {
        :source_attributes => [],
        :index_field_type => "int",
        :index_field_name => "num_tvs"}},
    :response_metadata => {:request_id => "8885505e-f959-11e2-b89b-2d5c6f978750"}
  }
end