=begin
require_relative '../active_asari_spec_helper'
#require '../support/lib/active_asari_spec_data'
#include ActiveAsariSpecData

describe ActiveAsari do

  describe '.active_asari_raw_search' do
    let(:asari) {double 'Asari'}

    before :each do
      ActiveAsari.should_receive(:asari_domain_name).with('TestModel').and_return('test-model-666')
    end

    it 'should search for all available fields for a item' do
      asari.should_receive(:response).with('foo', :return_fields => [:name, :amount, :last_updated, :bee_larvae_type, :active_asari_id]).and_return(
        {'33' => {'name' => ['beavis'], 'amount' => ['22'], 'last_updated' => ['4543457887875']}})
      Asari.should_receive(:new).with('test-model-666').and_return asari
      ActiveAsari.active_asari_raw_search 'TestModel', 'foo'
    end

    it 'should search for all available fields for a item with a binary search' do
      asari.should_receive(:response).with('foo', :return_fields => [:name, :amount, :last_updated, :bee_larvae_type, :active_asari_id], :query_type => :boolean).and_return(
        {'33' => {'name' => ['beavis'], 'amount' => ['22'], 'last_updated' => ['4543457887875']}})
      Asari.should_receive(:new).with('test-model-666').and_return asari
      ActiveAsari.active_asari_raw_search 'TestModel', 'foo', :query_type => :boolean
    end
  end

  describe '.active_asari_domain_name' do
    it 'should get the correct domain name and only call Amazon once' do
      aws_client = double 'AWS Client'
      aws_client.should_receive(:describe_domains).once.and_return DESCRIBE_DOMAINS_RESPONSE
      ActiveAsari.should_receive(:aws_client).once.and_return aws_client
      ActiveAsari.asari_domain_name('lance-event').should eq 'test-lance-event-7yopqryvjnumbe547ha7xhmjwi'
      ActiveAsari.asari_domain_name('lance-event').should eq 'test-lance-event-7yopqryvjnumbe547ha7xhmjwi'
    end
  end

  describe '.active_asari_search' do
    let(:raw_result) {{'33' => {'name' => ['beavis'], 'amount' => ['22'], 'last_updated' => ['4543457887875']}}}
    it 'should call out to do a raw search and then objectify the results' do
      ActiveAsari.should_receive(:active_asari_raw_search).with('TestModel', 'foo', {}).and_return(raw_result) 
      ActiveAsari.should_receive(:objectify_results).with(raw_result).and_return({'33' => 'stuff'})
      ActiveAsari.active_asari_search 'TestModel', 'foo'
    end
     
    it 'should pass on the parameters for a boolean search' do 
      ActiveAsari.should_receive(:active_asari_raw_search).with('TestModel', 'foo', :query_type => :boolean).and_return(raw_result) 
      ActiveAsari.should_receive(:objectify_results).with(raw_result).and_return({'33' => 'stuff'})
      ActiveAsari.active_asari_search 'TestModel', 'foo', :query_type => :boolean
    end
  end

  describe '.objectify_results' do
    let(:hash_results) {{'33' => {'name' => ['beavis'], 'amount' => ['22', '33'], 'last_updated' => ['4543457887875']},
      '34' => {'name' => ['butthead'], 'amount' => ['666'], 'last_updated' => ['454333457887875']}}}
    let(:objectified_results) {ActiveAsari.objectify_results(hash_results)}

    it 'should create an object with a reference to the raw results' do
      objectified_results['33'].raw_result.should eq hash_results['33']
      objectified_results['34'].raw_result.should eq hash_results['34']
    end

    context 'method_missing' do
      it 'should create methods on the fly for hash items in an object' do
        objectified_results['33'].name.should eq 'beavis'
        objectified_results['34'].name.should eq 'butthead'
      end

      it 'should return a array of items is an array accessor is used' do
        objectified_results['33'].amount_array.should eq ['22', '33']
        objectified_results['34'].amount_array.should eq ['666']
      end

      it 'should raise an error if a invalid parameter is specified' do
        expect {objectified_results['33'].foo}.to raise_error(NoMethodError)
      end
    end

    context 'respond_to?' do
      it 'should return true if the method exists' do
        objectified_results['33'].respond_to?(:amount_array).should eq true
        objectified_results['33'].respond_to?(:name).should eq true
      end

      it 'should return true if the method exists' do
        objectified_results['33'].respond_to?(:cornholio).should eq false
      end
    end
  end 
end
=end