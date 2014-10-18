require_relative '../../../asari_spec_helper'
=begin

describe Asari::Client::Base do

  it 'initializes with Client default options' do



    logger = Logger.new
    Asari::Client.config.default_api_version = '2015-10-21'
    Asari::Client.config.default_domain = 'rls1-test-user-list'
    Asari::Client.config.default_logger = logger
    Asari::Client.config.default_region = 'venezuela-13'
    instance = subject.new
    expect(subject.api_version).to eq '2015-10-21'
    expect(subject.domain).to eq '2015-10-21'
    expect(subject.logger).to eq '2015-10-21'
    expect(subject.region).to eq '2015-10-21'


    self.api_version = options[:api_version]
    self.domain = options[:domain]
    self.logger = options[:logger]
    self.region = options[:region]

  end

  describe 'region' do
    it "defaults to the class default" do
      subject.default_region = 'antarctica-3'
      expect(subject.new.region).to eq 'antarctica-3'
      subject.default_region = nil
    end

    it "is writeable" do
      instance = subject.new
      instance.region = 'some-other-region'
      expect(instance.region).to eq('some-other-region')
    end

    it 'can be set through the constructor' do
      instance = subject.new(nil, 'us-best-1')
      expect(instance.region).to eq 'us-best-1'
    end
  end

  describe 'domain' do
    it 'if not provided causes an exception on read' do
      expect{client.new.domain}.to raise_error Asari::MissingDomainException
    end

    it "is changeable on a client instance" do
      instance = client.new
      instance.domain = 'theroyaldomainofawesome'
      expect(instance.domain).to eq 'theroyaldomainofawesome'
    end

    it 'can be set through the initializer' do
      instance = client.new('theroyaldomainofawesome', nil)
      expect(instance.domain).to eq 'theroyaldomainofawesome'
    end
  end

end



=begin
  #[Asari, Asari::Client::V2011, Asari::Client::V2013].each do |client|






      describe 'domain' do


        it 'supports v1.0 method syntax' do
          instance = client.new
          instance.search_domain = 'theroyaldomainofawesome'
          expect(instance.search_domain).to eq 'theroyaldomainofawesome'
          expect(instance.domain).to eq 'theroyaldomainofawesome'
        end
      end

    end
  end

  describe '1.0 changeable' do
    [Asari, Asari::Client::Changeable].each do |client| # these should act equivalently for these methods

      describe 'version' do
        it "defaults to #{Asari::DEFAULT_DEFAULT_VERSION}" do
          expect(client.default_version).to eq Asari::DEFAULT_DEFAULT_VERSION
          expect(client.new.version).to eq Asari::DEFAULT_DEFAULT_VERSION
        end

        it "has a default changeable via class method" do
          client.default_version = '2047-99-03'
          expect(client.default_version).to eq '2047-99-03'
          expect(client.new.version).to eq '2047-99-03'
          client.default_version = nil
        end

        it "has a default changeable via an environment variable" do
          ENV['CLOUDSEARCH_API_VERSION'] = '2013-01-01'
          expect(client.default_version).to eq '2013-01-01'
          expect(client.new.version).to eq '2013-01-01'
          ENV['CLOUDSEARCH_API_VERSION'] = nil
        end

        it "can be set for a specific instance" do
          client.default_version = '2047-99-03'
          instance = client.new
          instance.version = '2015-10-21' # WE'VE GOT TO GO BACK
          expect(instance.version).to eq '2015-10-21'
        end

        it 'supports v1.0 method syntax' do
          instance = client.new
          instance.api_version = '2015-10-21'
          expect(instance.api_version).to eq '2015-10-21'
          expect(instance.version).to eq '2015-10-21'
        end

      end

      describe 'versioned client' do
        it 'stores a cached versioned client' do
          client.default_version = '2013-01-01'
          instance = client.new
          client1 = instance.versioned_client
          client2 = instance.versioned_client
          expect(client1.class).to eq(Asari::Client::V2013)
          expect(client1.object_id).to eq(client2.object_id)
        end

        it 'raises an error if asked for a client of an unrecognized version' do
          client.default_version = '2015-10-21'
          expect{client.new.versioned_client}.to raise_error(Asari::UnknownVersionException)
        end

        it 'updates the cached version on region and version changes' do
          client.default_version = '2013-01-01'
          instance = client.new
          expect(instance.versioned_client.class).to eq(Asari::Client::V2013)
          client.default_version = '2011-02-01'
          expect(instance.versioned_client.class).to eq(Asari::Client::V2013)
        end
      end

    end
  end

  describe '2011 and 2013' do
    [Asari::Client::V2011, Asari::Client::V2013].each do |client|


    end
  end
=end
