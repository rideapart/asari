require 'asari_spec_helper'

=begin
require_relative '../helpers/active_record_fake_no_auto_index'

describe ActiveAsari do
  describe ActiveAsari::Searchable do




    it 'should add new records to cloud search and alias object id and active_asari_id' do
      @model.id.should eq @model.active_asari_id
    end

    describe 'asari index' do
      it 'should call asari index with the correct parameters' do
        TestModel.should_receive(:asari_index).with('test-test-model-7yopqryvjnumbe547ha7xhmjwi',
                                                    [:name, :amount, :last_updated, :bee_larvae_type, :active_asari_id])
        ENV['RAILS_ENV'] = 'development'
        ENV['RACK_ENV'] = 'development'
        ActiveAsari.should_receive(:asari_domain_name).and_return 'test-test-model-7yopqryvjnumbe547ha7xhmjwi'
        TestModel.send(:active_asari_index, 'TestModel')
      end
    end

    describe "when CloudSearch is responding without error" do
      describe "with automatic indexing" do
        before :each do
          @asari = double()
          ActiveRecordFake.class_variable_set(:@@asari_instance, @asari)
        end

        it "will automatically attempt to remove itself from the index" do
          @asari.should_receive(:remove_item).with(1)
          ActiveRecordFake.new.asari_remove_from_index
        end

        it "will automatically add itself to the index" do
          @asari.should_receive(:add_item).with(1, {:name => "Fritters", :email => "fritters@aredelicious.com"})
          ActiveRecordFake.new.asari_add_to_index
        end

        it "will automatically update itself in the index" do
          @asari.should_receive(:update_item).with(1, {:name => "Fritters", :email => "fritters@aredelicious.com"})
          ActiveRecordFake.new.asari_update_in_index
        end


        it "will allow you to search for items with the index" do
          @asari.should_receive(:search).with("fritters", {}).and_return(["1"])

          ActiveRecordFake.asari_find("fritters")
        end

        it "will return a list of model objects when you search" do
          @asari.should_receive(:search).with("fritters", {}).and_return(["1"])

          results = ActiveRecordFake.asari_find("fritters")
          expect(results.class).to eq(Array)
          expect(results[0].class).to eq(ActiveRecordFake)
        end

        it "will return an empty list when you search for a term that isn't in the index" do
          @asari.should_receive(:search).with("veggie burgers", {}).and_return([])

          results = ActiveRecordFake.asari_find("veggie burgers")
          expect(results.class).to eq(Array)
          expect(results.size).to eq(0)
        end
      end

      describe 'multiple indexes at once' do
        let(:record_1) {ActiveRecordFake.new}
        let(:record_2) {ActiveRecordFake.new id: 2, name: 'Honey Badger', email: 'honey@badger.com'}
        describe 'deleting' do
          before :each do
            @asari = Asari.new 'honeybadger-testdomain'
            @asari.should_receive(:api_version).and_return '2013-01-01'
            ActiveRecordFake.class_variable_set(:@@asari_instance, @asari)
            Time.should_receive(:now).at_least(:once).and_return(1)
            stub_const("HTTParty", double())
          end

          it 'will delete multiple records' do
            HTTParty.stub(:post).and_return(fake_post_success)
            HTTParty.should_receive(:post).with("http://doc-honeybadger-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/documents/batch", {:body=>"[{\"type\":\"delete\",\"id\":\"12\",\"version\":1},{\"type\":\"delete\",\"id\":\"16a\",\"version\":1}]", :headers=>{"Content-Type"=>"application/json"}})
            ActiveRecordFake.asari_remove_items(['12', '16a']).should eql nil
          end

          it 'will not delete multiple records if there is an error' do
            HTTParty.stub(:post).and_return(fake_error_response)
            HTTParty.should_receive(:post).with("http://doc-honeybadger-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/documents/batch", {:body=>"[{\"type\":\"delete\",\"id\":\"12\",\"version\":1},{\"type\":\"delete\",\"id\":\"16a\",\"version\":1}]", :headers=>{"Content-Type"=>"application/json"}})
            expect{ActiveRecordFake.asari_remove_items(['12', '16a'])}.to raise_error(Asari::DocumentUpdateException)
          end
        end

        describe 'adding' do
          context 'calling out to cloud search' do
            before :each do
              @asari = Asari.new 'honeybadger-testdomain'
              @asari.should_receive(:api_version).and_return '2013-01-01'
              ActiveRecordFake.class_variable_set(:@@asari_instance, @asari)
              Time.should_receive(:now).at_least(:once).and_return(1)
              ActiveRecordFake.should_receive(:asari_when).at_least(:once).and_return true
              stub_const("HTTParty", double())
            end

            it 'will add multiple records' do
              HTTParty.stub(:post).and_return(fake_post_success)
              ActiveRecordFake.should_receive(:asari_should_index?).at_least(:once).and_return true
              HTTParty.should_receive(:post).with("http://doc-honeybadger-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/documents/batch", {:body=>"[{\"type\":\"add\",\"id\":\"1\",\"version\":1,\"lang\":\"en\",\"fields\":{\"name\":\"Fritters\",\"email\":\"fritters@aredelicious.com\"}},{\"type\":\"add\",\"id\":\"2\",\"version\":1,\"lang\":\"en\",\"fields\":{\"name\":\"Honey Badger\",\"email\":\"honey@badger.com\"}}]", :headers=>{"Content-Type"=>"application/json"}})
              ActiveRecordFake.asari_add_items([record_1, record_2]).should eql nil
            end

            it 'will not add records that are not indexable' do
              HTTParty.stub(:post).and_return(fake_post_success)
              ActiveRecordFake.should_receive(:asari_should_index?).with(record_1).and_return true
              ActiveRecordFake.should_receive(:asari_should_index?).with(record_2).and_return false

              HTTParty.should_receive(:post).with("http://doc-honeybadger-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/documents/batch", {:body=>"[{\"type\":\"add\",\"id\":\"1\",\"version\":1,\"lang\":\"en\",\"fields\":{\"name\":\"Fritters\",\"email\":\"fritters@aredelicious.com\"}}]", :headers=>{"Content-Type"=>"application/json"}})
              ActiveRecordFake.asari_add_items([record_1, record_2]).should eql nil
            end


            it 'will not add multiple records if there is an error' do
              HTTParty.stub(:post).and_return(fake_error_response)
              ActiveRecordFake.should_receive(:asari_should_index?).at_least(:once).and_return true

              HTTParty.should_receive(:post).with("http://doc-honeybadger-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/documents/batch", {:body=>"[{\"type\":\"add\",\"id\":\"1\",\"version\":1,\"lang\":\"en\",\"fields\":{\"name\":\"Fritters\",\"email\":\"fritters@aredelicious.com\"}},{\"type\":\"add\",\"id\":\"2\",\"version\":1,\"lang\":\"en\",\"fields\":{\"name\":\"Honey Badger\",\"email\":\"honey@badger.com\"}}]", :headers=>{"Content-Type"=>"application/json"}})
              expect{ActiveRecordFake.asari_add_items([record_1, record_2])}.to raise_error(Asari::DocumentUpdateException)
            end
          end

          it 'will not make a call to cloud search if there are not indexable documents' do
            HTTParty.stub(:post).and_return(fake_post_success)
            ActiveRecordFake.should_receive(:asari_when).at_least(:once).and_return true
            ActiveRecordFake.should_receive(:asari_should_index?).with(record_1).and_return false
            ActiveRecordFake.should_receive(:asari_should_index?).with(record_2).and_return false

            HTTParty.should_receive(:post).never
            ActiveRecordFake.asari_add_items([record_1, record_2]).should eql nil
          end
        end
      end

      describe "with automatic indexing turned off" do

        before :each do
          @asari = double()
          ActiveRecordFakeNoAutoIndex.class_variable_set(:@@asari_instance, @asari)
        end

        it "does not set up a before_destroy listener" do
          expect(ActiveRecordFakeNoAutoIndex.instance_variable_get(:@before_destroy)).to eq(nil)
        end

        it "does not set up a after_create listener" do
          expect(ActiveRecordFakeNoAutoIndex.instance_variable_get(:@after_create)).to eq(nil)
        end

        it "does not set up a after_update listener" do
          expect(ActiveRecordFakeNoAutoIndex.instance_variable_get(:@after_update)).to eq(nil)
        end
      end
    end

    describe "When CloudSearch is being a problem" do
      before :each do
        ActiveRecordFake.class_variable_set(:@@asari_instance, Asari.new("test-domain"))
        stub_const("HTTParty", double())
        HTTParty.stub(:post).and_return(fake_error_response)
        HTTParty.stub(:get).and_return(fake_error_response)
      end

      it "will raise the Asari exception by default when adding to the index." do
        expect { ActiveRecordFake.new.asari_add_to_index }.to raise_error(Asari::DocumentUpdateException)
      end

      it "will raise the Asari exception by default when updating the index." do
        expect { ActiveRecordFake.new.asari_update_in_index }.to raise_error(Asari::DocumentUpdateException)
      end

      it "will raise the Asari exception by default when removing from index." do
        expect { ActiveRecordFake.new.asari_remove_from_index }.to raise_error(Asari::DocumentUpdateException)
      end

      it "will always raise the Asari exception when searching in the index." do
        expect { ActiveRecordFake.asari_find("fritters") }.to raise_error(Asari::SearchException)
      end

      describe "when we've overridden asari_on_error" do
        it "honors asari_on_error when adding to the index." do
          expect(ActiveRecordFakeWithErrorOverride.new.asari_add_to_index).to eq(false)
        end

        it "honors asari_on_error when updating in the index." do
          expect(ActiveRecordFakeWithErrorOverride.new.asari_update_in_index).to eq(false)
        end

        it "honors asari_on_error when removing from the index." do
          expect(ActiveRecordFakeWithErrorOverride.new.asari_remove_from_index).to eq(false)
        end

        it "still raises the Asari exception when searching." do
          expect { ActiveRecordFakeWithErrorOverride.asari_find("fritters") }.to raise_error(Asari::SearchException)
        end
      end

    end

    describe "conditional indexing" do
      describe "when a :when option is provided" do
        before :each do
          @arcs = ARConditionalsSpy.new
          @arcs.be_indexable = false
          @asari = double()
          ARConditionalsSpy.class_variable_set(:@@asari_instance, @asari)
        end

        it "doesn't add to the index if the :when option returns false" do
          expect(@arcs.was_asked).to eq(false)
          @arcs.asari_add_to_index
          expect(@arcs.was_asked).to eq(true)
        end

        it "doesn't add to the index if the :when option returns false" do
          expect(@arcs.was_asked).to eq(false)
          @arcs.asari_add_to_index
          expect(@arcs.was_asked).to eq(true)
        end

        it "does add to the index if the :when option returns true" do
          expect(@arcs.was_asked).to eq(false)
          @arcs.be_indexable = true
          @asari.should_receive(:add_item).with(1, { :name => "Tommy", :email => "some@email.com"})
          @arcs.asari_add_to_index
          expect(@arcs.was_asked).to eq(true)
        end

        it "deletes the item from the index if the :when option returns false when the item is updated" do
          expect(@arcs.was_asked).to eq(false)
          @asari.should_receive(:remove_item).with(1)
          @arcs.asari_update_in_index
          expect(@arcs.was_asked).to eq(true)
        end

        it "updates the item in the index if the :when option returns true when the item is updated" do
          expect(@arcs.was_asked).to eq(false)
          @arcs.be_indexable = true
          @asari.should_receive(:update_item).with(1, { :name => "Tommy", :email => "some@email.com"})
          @arcs.asari_update_in_index
          expect(@arcs.was_asked).to eq(true)
        end
      end
    end



  end
end
=end