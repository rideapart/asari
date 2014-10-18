require_relative '../../asari_spec_helper'
=begin
describe Asari::Client do

  describe 'config' do
    after :each do
      subject.reset_config
    end

    describe 'default_api_version' do
      it 'defaults to 2013' do
        expect(subject.config.default_api_version).to eq '2013-01-01'
      end

      it "modifies the default api version for new clients" do
        subject.config.default_api_version = '2011-01-01'
        expect(subject.config.default_api_version).to eq '2011-01-01'
        expect(Asari::Client::Http.new.api_version).to eq '2011-01-01'

        # The SDK clients only support 2013
        expect{Asari::Client::Sdk1.new}.
          to raise_error(subject::Errors::VersionException)
        expect{Asari::Client::Sdk2.new}.
          to raise_error(subject::Errors::VersionException)
      end
    end

    describe 'default_logger' do
      it 'defaults to nil' do
        expect(Asari.config.default_logger).to eq nil
      end

      it "modifies the default logger for new clients" do
        logger = Logger.new(STDOUT)
        subject.config.default_logger = logger
        expect(subject.config.default_logger).to be logger
        expect(Asari::Client::Http.new.logger).to be logger
        expect(Asari::Client::Sdk1.new.logger).to be logger
        expect(Asari::Client::Sdk2.new.logger).to be logger
      end
    end

    describe 'default_region' do
      it 'defaults to us-east-1' do
        expect(subject.config.default_region).to eq 'us-east-1'
      end

      it "modifies the default region for new clients" do
        subject.config.default_region = 'the-couch'
        expect(subject.config.default_region).to eq 'the-couch'
        expect(Asari::Client::Http.new.region).to eq 'the-couch'
        expect(Asari::Client::Sdk1.new.region).to eq 'the-couch'
        expect(Asari::Client::Sdk2.new.region).to eq 'the-couch'
      end
    end
  end


end
=end