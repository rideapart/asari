=begin
require_relative '../asari_spec_helper'
require_relative '../helpers/active_record_fake_no_auto_index'

db_config = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + 'support/db/database.yml')
ActiveRecord::Base.establish_connection db_config['test']
ActiveRecord::Base.connection

describe Asari do
  describe Asari::ActiveRecord do

    context 'models' do
      before :each do
        asari_instance = double 'asari instance'
        asari_instance.should_receive(:update_item).
          with(1, {:name => 'test', :amount => 2, :last_updated => '', :bee_larvae_type => ''})
        asari_instance.should_receive(:add_item).
          with(1, {:name => 'test', :amount => 2, :last_updated => '', :bee_larvae_type => ''})
        TestModel.class_variable_set(:@@asari_when, nil)
        TestModel.class_variable_set(:@@asari_fields, [:name, :amount, :last_updated, :bee_larvae_type])
        TestModel.class_variable_set(:@@asari_instance, asari_instance)
        CreateTestModel.up
        @model = TestModel.create :name => 'test', :amount => 2
        @model.save
      end

      it 'should add new records to cloud search and alias object id and active_asari_id' do
        @model.id.should eq @model.active_asari_id
      end

      after :each do
        CreateTestModel.down
      end
    end

    it "correctly sets up a before_destroy listener" do
      expect(ActiveRecordFake.instance_variable_get(:@before_destroy)).to eq(:asari_remove_from_index)
    end

    it "correctly sets up an after_create listener" do
      expect(ActiveRecordFake.instance_variable_get(:@after_create)).to eq(:asari_add_to_index)
    end

    it "correctly sets up an after_update listener" do
      expect(ActiveRecordFake.instance_variable_get(:@after_update)).to eq(:asari_update_in_index)
    end


  end
end
=end