require_relative '../../asari_spec_helper'
=begin
describe Asari do
  after :all do
    Asari.mode = nil
  end

  it 'defaults to not production' do
    expect(subject.production?).to be false
  end

  it 'allows you to set the mode' do
    subject.mode = :some_sym
    expect(subject.mode).to eq :some_sym
    expect(subject.production?).to be false

    subject.mode = :production
    expect(subject.production?).to be true
  end

  it 'provides constants for the API version ids' do
    expect(subject::API_2013).to eq '2013-01-01'
    expect(subject::API_2011).to eq '2011-02-01'
  end
end
=end