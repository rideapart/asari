=begin
  require_relative '../support/mocks/cloud_search_responses'
  include ActiveAsari::MockCloudSearchResponses
  context 'using AWS Client Mock' do
    before :each do
      mock_client = double 'AWS Client'
      expect(mock_client).to receive(:describe_domains).once.and_return DESCRIBE_DOMAINS_RESPONSE
      expect(ActiveAsari).to receive(:aws_client).once.and_return mock_client

    end
    let (:domain) {ActiveAsari::Domain.new('LanceEvent')}
=end