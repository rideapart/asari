require_relative '../../asari_spec_helper'

describe Asari::Domain::IndexField do
  subject {Asari::Domain::IndexField}

  #
  # Set up shared examples so we can test with various APIs and Clients
  #
  RSpec.shared_examples "index_field" do

    describe '#initialize' do
      it 'can be created with just a domain name, defaulting to asari region and version' do
        instance = subject.new('awesome-domain-name')
        expect(instance.name).to eq 'awesome-domain-name'
        expect(instance.api_version).to eq Asari.config.api_version
        expect(instance.region).to eq Asari.config.region
      end

      it 'takes options to override region and version' do
        instance = subject.new('awesome-domain-name',
                               api_version: '2015-10-25',
                               region: 'botswana-7',
                               describe: false )
        expect(instance.api_version).to eq '2015-10-25'
        expect(instance.region).to eq 'botswana-7'
      end

      it "isn't created by default" do
        instance = subject.new('awesome-domain-name')
        expect(instance.created?).to be false
      end
=begin
    # still need these?
      #instance = subject.new('awesome-domain-name', create: true)
      # we can't stub the client, or expect anything to be called in it, until after init
      # so this is hard to test

    it 'can optionally trigger remote creation' do
      # expect().to receive(:create_domain).with('awesome-domain-name')
    end
=end
    end

    context "Access Policies" do

    end

    context "Analysis Schemes" do

    end

    context "Availability Options" do
      describe '#multi_az=' do
        it 'updates the remote if necessary' do
        end
        it "doesn't issue a request if we already know the current state" do
        end
      end
    end

    context "Creation and Deletion" do
      describe '#create' do
        it "creates the remote" do

          instance = subject.new('awesome-domain-name')
          instance.connection.
            stub_responses(:create_domain,
                           domain_status: {
                             domain_name: 'awesome-domain-name',
                             created: false,
                             processing: true})
          instance.create

          expect(instance.created?).to be false
          expect(instance.processing?).to be true

        end
      end

      describe '#delete' do
        it "deletes the remote if it exists" do
          instance = subject.new('awesome-domain-name')
          instance.connection.
            stub_responses(:delete_domain,
                           domain_status: {
                             domain_name: 'awesome-domain-name',
                             deleted: false,
                             processing: true})
          instance.delete

          expect(instance.deleted?).to be false
          expect(instance.processing?).to be true
        end
      end
    end

    context "Expressions" do

    end

    context "Index Fields" do
=begin
    describe '#index_fields, #add_index_fields' do

      it "holds some index fields and syncs them by default" do
        domain_name = 'awesome-domain-name'
        instance = subject.new(domain_name)
        expect(instance.index_fields).to eq([])

        fields = [
          { index_field_name: "NumberOfFoos",
            index_field_type: "int",
            int_options: {
              default_value: 1,
              source_field: "FieldName",
              facet_enabled: true,
              search_enabled: true,
              return_enabled: true,
              sort_enabled: true,
            },
          },
          { index_field_name: "FooTitle",
            index_field_type: "int",
            int_options: {
              default_value: 1,
              source_field: "FieldName",
              facet_enabled: true,
              search_enabled: true,
              return_enabled: true,
              sort_enabled: true,
            }
          }
        ]

        instance.client_manager.stub_responses(:define_index_field, {index_field: {options: fields[0]}})
        instance.add_index_field(fields[0])
        instance.client_manager.stub_responses(:define_index_field, {index_field: {options: fields[1]}})
        instance.add_index_field(fields[1])

        expect(instance.index_fields).to eq(fields)
      end

      it "holds some index fields and syncs them by default" do
        domain_name = 'awesome-domain-name'
        instance = subject.new(domain_name)
        expect(instance.index_fields).to eq([])

        fields = [
          { index_field_name: "NumberOfFoos",
             index_field_type: "int",
             int_options: {
               default_value: 1,
               source_field: "FieldName",
               facet_enabled: true,
               search_enabled: true,
               return_enabled: true,
               sort_enabled: true,
             },
          },
         { index_field_name: "FooTitle",
           index_field_type: "int",
           int_options: {
             default_value: 1,
             source_field: "FieldName",
             facet_enabled: true,
             search_enabled: true,
             return_enabled: true,
             sort_enabled: true,
           }
         }
        ]

        instance.client_manager.stub_responses(:define_index_field, {index_field: {options: fields[0]}})
        instance.add_index_field(fields[0])
        instance.client_manager.stub_responses(:define_index_field, {index_field: {options: fields[1]}})
        instance.add_index_field(fields[1])

        expect(instance.index_fields).to eq(fields)
      end

      it 'fetches existing index settings before making changes' do
      end

      describe '#sync_index_fields' do
      end

    end
=end
    end

    context "Scaling Parameters" do
      describe 'scaling_parameters=' do
        it 'updates multiple parameters at once if necessary' do
        end
        it "doesn't issue a request if we already know the current state" do
        end
      end

      describe '#instance_type=' do
      end
      describe '#replication_count=' do
      end
      describe '#partition_count=' do
      end
    end

    context "Status" do
=begin

    describe '#describe' do
      it "describes the remote" do
        instance = subject.new('awesome-domain-name')
        instance.client_manager.
          stub_responses(:describe_domains,
                         domain_status_list: [{
                           domain_name: 'awesome-domain-name',
                           created: true,
                           doc_service: {endpoint: 'doc-searchable'}}])
        instance.describe

        expect(instance.created).to be true
        expect(instance.doc_endpoint).to eq 'doc-searchable'
      end
  end
=end
    end

  end


  #
  # Run domain examples with all the various clients
  #
  context 'using the 2013 API with sdk2' do
    before :all do
      Asari.config.api_version = Asari::API_2013
    end

    it_behaves_like "domain"

    after :all do
      Asari.reset_config
    end
  end

  context 'using the 2013 API with sdk1 and asari client' do
    before :all do
      Asari.config.api_version = Asari::API_2013
      Asari::ClientManager.avoid_sdk2 = true
    end

    it_behaves_like "domain"

    after :all do
      Asari.reset_config
      Asari::ClientManager.avoid_sdk2 = false
    end
  end

  context 'using the 2011 API with sdk1 and asari client' do
    before :all do
      Asari.config.api_version = Asari::API_2011
    end

    it_behaves_like "domain"

    after :all do
      Asari.reset_config
    end
  end



end