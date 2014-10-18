require_relative '../../asari_spec_helper'

describe Asari do
  describe '::domains, ::domains='
=begin
    it "stores a hash" do
      subject.domains = nil
      expect(subject.domains.is_a? Hash).to be true
    end

    it 'adds it to to the domain list' do
      instance = subject.new('awesome-domain-name')
      expect(Asari::Domains[:"#{instance.name}"]).to be instance
    end

  context 'configuration' do
    shared_examples "domain hash" do

      it 'provides a hash of the loaded domain schema' do
        expect(Asari::Domains.hash[:test_domain]).to eq ({
          name: {index_field_type: 'text', search_enabled: true},
          amount: { index_field_type: 'int', search_enabled: true},
          last_updated: { index_field_type: 'int', search_enabled: false},
          bee_larvae_type: {index_field_type: 'literal'}
        })

        expect(Asari::Domains.hash[:honey_badger]).to eq ({
          name: {index_field_type: 'text'},
        })
      end

    end

    context 'loading through files' do
      schema_path = File.expand_path("../support/test_app/config/initializers/asari/active_asari_config.yml", __FILE__)
      env_settings_path = File.expand_path("../support/test_app/config/initializers/asari/active_asari_env.yml", __FILE__)
      Asari::Domains.load_schema(schema_path)
      Asari::Domains.load_env_settings(env_settings_path)

      it_behaves_like "domain hash"
    end
  end
=end


  after :all do
    #Asari::Domains.clear
  end
end