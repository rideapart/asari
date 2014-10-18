=begin
it 'supports 1.0 syntax by pretending to be Client::Changeable' do
  expect(subject.new.class).to eq Asari::Client::Changeable

  expect(subject.default_region).to eq Asari::Client::Changeable.default_region
  subject.default_region = 'the-shire-1'
  expect(subject.default_region).to eq 'the-shire-1'
  expect(Asari::Client::Changeable.default_region).to eq 'the-shire-1'

  expect(subject.default_version).to eq Asari::Client::Changeable.default_version
  subject.default_version = '2015-99-47'
  expect(subject.default_version).to eq '2015-99-47'
  expect(Asari::Client::Changeable.default_version).to eq '2015-99-47'
end
=end