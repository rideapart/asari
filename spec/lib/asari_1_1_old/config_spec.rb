# If you'd like to test with the v1 configuration syntax, set TEST_USING_V1_CONFIG = TRUE in the spec helper
require_relative '../../asari_spec_helper'
=begin

module Asari
  describe Config do
    subject{Asari}
    after :each do
      subject.reset_config
    end

    describe 'client options' do
      describe 'default_api_version' do
        it 'defaults to 2013' do
          expect(subject.config.default_api_version).to eq '2013-01-01'
        end

        it "modifies the default api version for new clients" do
          subject.config.default_api_version = '2011-01-01'
          expect(subject.config.default_api_version).to         eq '2011-01-01'
          expect(subject::Client.config.default_api_version).to eq '2011-01-01'
          expect(subject::Client::Http.new.api_version).to      eq '2011-01-01'

          # The SDK clients only support 2013
          expect{subject::Client::Sdk1.new}.
            to raise_error(subject::Client::Errors::VersionException)
          expect{subject::Client::Sdk2.new}.
            to raise_error(subject::Client::Errors::VersionException)
        end
      end

      describe 'default_logger' do
        it 'defaults to nil' do
          expect(subject.config.default_logger).to eq nil
        end

        it "modifies the default logger for new clients" do
          logger = Logger.new(STDOUT)
          subject.config.default_logger = logger
          expect(subject.config.default_logger).to be logger
          expect(subject::Client.config.default_logger).to be logger
          expect(subject::Client::Http.new.logger).to be logger
          expect(subject::Client::Sdk1.new.logger).to be logger
          expect(subject::Client::Sdk2.new.logger).to be logger
        end
      end

      describe 'default_region' do
        it 'defaults to us-east-1' do
          expect(subject.config.default_region).to eq 'us-east-1'
        end

        it "modifies the default region for new clients" do
          subject.config.default_region = 'the-couch'
          expect(subject.config.default_region).to eq 'the-couch'
          expect(subject::Client.config.default_region).to eq 'the-couch'
          expect(subject::Client::Http.new.region).to eq 'the-couch'
          expect(subject::Client::Sdk1.new.region).to eq 'the-couch'
          expect(subject::Client::Sdk2.new.region).to eq 'the-couch'
        end
      end
    end

  end
end


=end