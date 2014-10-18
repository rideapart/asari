require_relative '../../asari_spec_helper'

describe Asari::Domain do
=begin
  describe '::name_is_safe?' do
    # below reqs documented at http://docs.aws.amazon.com/cloudsearch/latest/developerguide/creating-domains.html
    it "shouldn't allow a name to be greater than 28 or less than 3 chars" do
      ActiveAsari.config.domain_app_prefix = ''
      ActiveAsari.config.environment_settings['test']['domain_prefix'] = ''
      expect(ActiveAsari::Domain.new('A').cloudsearch_name).to eq 'a00' # adds 0's
      expect{ActiveAsari::Domain.new('TestModelWithSuperLongName').cloudsearch_name}.to raise_error StandardError
    end
    it "shouldn't contain anything except a-z 0-9 or -" do
      ActiveAsari.config.domain_app_prefix = 'test-app%'
      ActiveAsari.config.environment_settings['test']['domain_prefix'] = 't&*est'
      expect(ActiveAsari::Domain.new('TestModel!&%^').cloudsearch_name).to eq 'test-app-test-test-model'
    end
  end

  describe '::sanitize_name' do
    it 'should create names that pass ::name_is_safe' do

    end
  end
=end
end

