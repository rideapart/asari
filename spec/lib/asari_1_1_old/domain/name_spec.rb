require_relative '../../../asari_spec_helper'
=begin
describe Asari::Domain::Name do
  subject{Asari::Domain::Name}
  after(:each) do
    Asari::Domain::Name.reset_config
    Asari.reset_config
  end

  describe 'class' do
    describe 'config' do
      subject{Asari::Domain::Name.config}

      it 'has some sensible defaults' do
        expect(subject.app_prefix).to eq ''
        expect(subject.env_prefixes).to eq(
          { 'development' => 'dev', 'test' => 'tst', 'production'  => 'prd'})
        expect(subject.invalid_char_replacement).to eq '1'
        expect(subject.filler_char).to eq '0'
        expect(subject.warn_on_transform).to be false
        expect(subject.error_on_transform).to be true
      end

      it 'allows all options to be changed' do
        subject.app_prefix = 'appp'
        subject.env_prefixes = {'staging' => 'stg'}
        subject.invalid_char_replacement = 'z'
        subject.filler_char = 'c'
        subject.warn_on_transform = true
        subject.error_on_transform = false

        expect(subject.app_prefix).to eq 'appp'
        expect(subject.env_prefixes).to eq({'staging' => 'stg'})
        expect(subject.invalid_char_replacement).to eq 'z'
        expect(subject.filler_char).to eq 'c'
        expect(subject.warn_on_transform).to be true
        expect(subject.error_on_transform).to be false
      end

      it 'can be reset' do
        expect(subject.app_prefix).to eq ''
      end
    end

    describe 'prefixing' do
      it 'returns the currently configured app prefix' do
        expect(subject.app_prefix).to eq ''
        subject.config.app_prefix = 'rls'
        expect(subject.app_prefix).to eq 'rls'
      end

      it 'returns the currently configured env prefix' do
        subject.config.env_prefixes = {
          'development' => 'dev',
          'condition-yellow' => 'yellow'
        }
        subject.environment = 'development'
        expect(subject.env_prefix).to eq 'dev'
        subject.environment = 'condition-yellow'
        expect(subject.env_prefix).to eq 'yellow'
      end

      it 'prefixes a domain name with app and env' do
        subject.config.app_prefix = '1337'
        subject.config.env_prefixes = {'test' => 'testz'}
        subject.environment = 'test'
        expect(subject.prefix('enterprise')).to eq '1337-testz-enterprise'
      end

      it "doesn't add extra hyphens when the prefixes are blank" do
        subject.config.app_prefix = ''
        subject.config.env_prefixes = {}
        expect(subject.prefix('enterprise')).to eq 'enterprise'
      end
    end

    describe 'sanitation' do
      it 'knows if a name is sanitary' do
        expect(subject.sanitary?('a-fine-d0m4in-name')).to be true
        expect(subject.sanitary?('af')).to be false
        expect(subject.sanitary?('an-overly-loooong-domain-name')).to be false
        expect(subject.sanitary?('silly-symbols-&$(@)')).to be false
      end

      it 'can correct unsanitary names' do
        subject.config.invalid_char_replacement = '9'
        subject.config.filler_char = '8'
        subject.config.warn_on_transform = false
        subject.config.error_on_transform = false

        expect(subject.sanitize('a-fine-d0m4in-name')).to eq 'a-fine-d0m4in-name'
        expect(subject.sanitize('af')).to eq 'af8'
        expect(subject.sanitize('an-overly-loooong-domain-name')).to eq 'an-overly-loooong-domain-nam'
        expect(subject.sanitize('silly-symbols-&$(@)')).to eq 'silly-symbols-99999'
      end

      it 'errors on unsanitary names by default' do
        exception = Asari::Domain::Errors::NameException
        expect{subject.sanitize('af')}.to raise_error(exception)
        expect{subject.sanitize('an-overly-loooong-domain-name')}.to raise_error(exception)
        expect{subject.sanitize('silly-symbols-&$(@)')}.to raise_error(exception)
      end
    end
  end

  describe 'instance' do
    it 'takes an name stem for initialization and stores it' do
      instance = subject.new('abc')
      expect(instance.class).to be Asari::Domain::Name
      expect(instance.stem).to eq 'abc'
      instance.stem = 'def'
      expect(instance.stem).to eq 'def'
    end

    it 'sanitizes the provided name stems' do
      expect{subject.new('')}.to raise_error(Asari::Domain::Errors::NameException)
      instance = subject.new('abc')
      expect{instance.stem='d'}.to raise_error(Asari::Domain::Errors::NameException)
    end

    it 'builds a prefixed full name' do
      subject.config.app_prefix = 'app'
      subject.config.env_prefixes = {'test' => 'tst'}
      subject.environment = 'test'
      expect(subject.new('abc').full).to eq 'app-tst-abc'
    end

    it 'sanitizes prefixes' do
      subject.config.invalid_char_replacement = ''
      subject.config.app_prefix = 'app&%'
      subject.config.env_prefixes = {'test' => 'tst_^'}
      subject.environment = 'test'
      subject.config.error_on_transform = false
      expect(subject.new('abcccccccccccccccccccccc').full).to eq 'app-tst-abcccccccccccccccccc'
    end

    it 'optionally will avoid prefixing' do
      subject.config.app_prefix = 'app'
      subject.config.env_prefixes = {}
      instance = subject.new('abc', skip_prefixes: true)
      expect(instance.full).to eq 'abc'
      instance.skip_prefixes = false
      expect(instance.full).to eq 'app-abc'
    end
  end

end
=end