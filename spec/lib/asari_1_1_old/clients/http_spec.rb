#require_relative "../asari_spec_helper"
=begin
describe Asari do
  describe "updating the index" do
    before :each do
      @asari = Asari.new("testdomain")
      stub_const("HTTParty", double())
      HTTParty.stub(:post).and_return(fake_post_success)
      Time.should_receive(:now).and_return(1)
      Asari.mode = :production
    end

    after :all do
      Asari.mode = :sandbox
    end

    context "when region is not specified" do
      it "allows you to add an item to the index using default region." do
        HTTParty.should_receive(:post).with("http://doc-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "1", "version" => 1, "lang" => "en", "fields" => { :name => "fritters"}}].to_json, :headers => { "Content-Type" => "application/json"}})

        expect(@asari.add_item("1", {:name => "fritters"})).to eq(nil)
      end
    end

    context "when region is specified" do
      before(:each) do
        @asari.aws_region = 'my-region'
      end
      it "allows you to add an item to the index using specified region." do
        HTTParty.should_receive(:post).with("http://doc-testdomain.my-region.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "1", "version" => 1, "lang" => "en", "fields" => { :name => "fritters"}}].to_json, :headers => { "Content-Type" => "application/json"}})

        expect(@asari.add_item("1", {:name => "fritters"})).to eq(nil)
      end
    end

    it "converts Time, DateTime, and Date fields to timestamp integers for rankability" do
      date = Date.new(2012, 4, 1)
      HTTParty.should_receive(:post).with("http://doc-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "1", "version" => 1, "lang" => "en", "fields" => { :time => 1333263600, :datetime => 1333238400, :date => date.to_time.to_i }}].to_json, :headers => { "Content-Type" => "application/json"}})
      expect(@asari.add_item("1", {:time => Time.at(1333263600), :datetime => DateTime.new(2012, 4, 1), :date => date})).to eq(nil)
    end

    it "allows you to update an item to the index." do
      HTTParty.should_receive(:post).with("http://doc-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "1", "version" => 1, "lang" => "en", "fields" => { :name => "fritters"}}].to_json, :headers => { "Content-Type" => "application/json"}})

      expect(@asari.update_item("1", {:name => "fritters"})).to eq(nil)
    end

    it "converts Time, DateTime, and Date fields to timestamp integers for rankability on update as well" do
      date = Date.new(2012, 4, 1)
      HTTParty.should_receive(:post).with("http://doc-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "1", "version" => 1, "lang" => "en", "fields" => { :time => 1333263600, :datetime => 1333238400, :date => date.to_time.to_i }}].to_json, :headers => { "Content-Type" => "application/json"}})

      expect(@asari.update_item("1", {:time => Time.at(1333263600), :datetime => DateTime.new(2012, 4, 1), :date => date})).to eq(nil)
    end

    it "allows you to delete an item from the index." do
      HTTParty.should_receive(:post).with("http://doc-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "delete", "id" => "1", "version" => 1}].to_json, :headers => { "Content-Type" => "application/json"}})

      expect(@asari.remove_item("1")).to eq(nil)
    end

    describe "when there are internet issues" do
      before :each do
        HTTParty.stub(:post).and_raise(SocketError.new)
      end

      it "raises an exception when you try to add an item to the index" do
        expect { @asari.add_item("1", {})}.to raise_error(Asari::DocumentUpdateException)
      end

      it "raises an exception when you try to update an item in the index" do
        expect { @asari.update_item("1", {})}.to raise_error(Asari::DocumentUpdateException)
      end

      it "raises an exception when you try to remove an item from the index" do
        expect { @asari.remove_item("1")}.to raise_error(Asari::DocumentUpdateException)
      end
    end

    describe "when there are CloudSearch issues" do
      before :each do
        HTTParty.stub(:post).and_return(fake_error_response)
      end

      it "raises an exception when you try to add an item to the index" do
        expect { @asari.add_item("1", {})}.to raise_error(Asari::DocumentUpdateException)
      end

      it "raises an exception when you try to update an item in the index" do
        expect { @asari.update_item("1", {})}.to raise_error(Asari::DocumentUpdateException)
      end

      it "raises an exception when you try to remove an item from the index" do
        expect { @asari.remove_item("1")}.to raise_error(Asari::DocumentUpdateException)
      end

    end

  end
end
=end

=begin
describe Asari do
  before :each do
    @asari = Asari.new("testdomain")
    stub_const("HTTParty", double())
    HTTParty.stub(:get).and_return(fake_response)
    Asari.mode = :production
  end

  after :all do
    Asari.mode = :sandbox
  end

  describe "searching" do
    shared_examples_for 'code that does basic searches' do
      before(:each) {ENV['CLOUDSEARCH_API_VERSION'] = api_version}
      after(:each) {ENV['CLOUDSEARCH_API_VERSION'] = '2011-02-01'}
      context "when region is not specified" do
        it "allows you to search using default region." do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/#{api_version}/search?q=testsearch&size=10")
          @asari.search("testsearch")
        end
      end

      context "when region is not specified" do
        before(:each) do
          @asari.aws_region = 'my-region'
        end
        it "allows you to search using specified region." do
          HTTParty.should_receive(:get).with("http://search-testdomain.my-region.cloudsearch.amazonaws.com/#{api_version}/search?q=testsearch&size=10")
          @asari.search("testsearch")
        end
      end

      it "escapes dangerous characters in search terms." do
        HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/#{api_version}/search?q=testsearch%21&size=10")
        @asari.search("testsearch!")
      end

      it "honors the page_size option" do
        HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/#{api_version}/search?q=testsearch&size=20")
        @asari.search("testsearch", :page_size => 20)
      end

      it "honors the page option" do
        HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/#{api_version}/search?q=testsearch&size=20&start=40")
        @asari.search("testsearch", :page_size => 20, :page => 3)
      end

    end

    context 'the 2011-02-01 api' do
      let(:api_version) {'2011-02-01'}
      it_behaves_like 'code that does basic searches'

      describe "boolean searching" do
        it "builds a query string from a passed hash" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=&bq=%28and+foo%3A%27bar%27+baz%3A%27bug%27%29&size=10")
          @asari.search(filter: { and: { foo: "bar", baz: "bug" }})
        end

        it "honors the logic types" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=&bq=%28or+foo%3A%27bar%27+baz%3A%27bug%27%29&size=10")
          @asari.search(filter: { or: { foo: "bar", baz: "bug" }})
        end

        it "supports nested logic" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=&bq=%28or+is_donut%3A%27true%27%28and+round%3A%27true%27+frosting%3A%27true%27+fried%3A%27true%27%29%29&size=10")
          @asari.search(filter: { or: { is_donut: true, and:
                                        { round: true, frosting: true, fried: true }}
          })
        end

        it "fails gracefully with empty params" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=&bq=%28or+is_donut%3A%27true%27%29&size=10")
          @asari.search(filter: { or: { is_donut: true, and:
                                        { round: "", frosting: nil, fried: nil }}
          })
        end

        it "supports full text search and boolean searching" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=nom&bq=%28or+is_donut%3A%27true%27%28and+fried%3A%27true%27%29%29&size=10")
          @asari.search("nom", filter: { or: { is_donut: true, and:
                                               { round: "", frosting: nil, fried: true }}
          })
        end
      end

      describe "the rank option" do
        it "takes a plain string" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=testsearch&size=10&rank=some_field")
          @asari.search("testsearch", :rank => "some_field")
        end

        it "takes an array with :asc" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=testsearch&size=10&rank=some_field")
          @asari.search("testsearch", :rank => ["some_field", :asc])
        end

        it "takes an array with :desc" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=testsearch&size=10&rank=-some_field")
          @asari.search("testsearch", :rank => ["some_field", :desc])
        end
      end
    end

    context 'the 2013-01-01 api' do
      let(:api_version) {'2013-01-01'}
      it_behaves_like 'code that does basic searches'
      before(:each) {ENV['CLOUDSEARCH_API_VERSION'] = api_version}
      after(:each) {ENV['CLOUDSEARCH_API_VERSION'] = '2011-02-01'}

      describe 'boolean searching,  structured queries' do
        it "builds a query string from a passed hash" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=%28and+foo%3A%27bar%27+baz%3A%27bug%27%29&q.parser=structured&size=10")
          @asari.search(filter: { and: { foo: "bar", baz: "bug" }})
        end

        it "honors the logic types" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=%28or+foo%3A%27bar%27+baz%3A%27bug%27%29&q.parser=structured&size=10")
          @asari.search(filter: { or: { foo: "bar", baz: "bug" }})
        end

        it "supports nested logic" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=%28or+is_donut%3A%27true%27%28and+round%3A%27true%27+frosting%3A%27true%27+fried%3A%27true%27%29%29&q.parser=structured&size=10")
          @asari.search(filter: { or: { is_donut: true, and:
                                        { round: true, frosting: true, fried: true }}
          })
        end

        it "fails gracefully with empty params" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=%28or+is_donut%3A%27true%27%29&q.parser=structured&size=10")
          @asari.search(filter: { or: { is_donut: true, and:
                                        { round: "", frosting: nil, fried: nil }}
          })
        end

        it "ignores full text search when filter option is used" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=%28or+is_donut%3A%27true%27%28and+fried%3A%27true%27%29%29&q.parser=structured&size=10")
          @asari.search("nom", filter: { or: { is_donut: true, and:
                                               { round: "", frosting: nil, fried: true }}
          })
        end
      end

      describe "the rank option" do
        it "takes a plain string" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=testsearch&size=10&sort=some_field+asc")
          @asari.search("testsearch", :rank => "some_field")
        end

        it "takes an array with :asc" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=testsearch&size=10&sort=some_field+asc")
          @asari.search("testsearch", :rank => ["some_field", :asc])
        end

        it "takes an array with :desc" do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=testsearch&size=10&sort=some_field+desc")
          @asari.search("testsearch", :rank => ["some_field", :desc])
        end
      end
    end


    it "returns a list of document IDs for search results." do
      result = @asari.search("testsearch")

      expect(result.size).to eq(2)
      expect(result[0]).to eq("123")
      expect(result[1]).to eq("456")
      expect(result.total_pages).to eq(1)
      expect(result.current_page).to eq(1)
      expect(result.page_size).to eq(10)
      expect(result.total_entries).to eq(2)
    end

    it "returns an empty list when no search results are found." do
      HTTParty.stub(:get).and_return(fake_empty_response)
      result = @asari.search("testsearch")
      expect(result.size).to eq(0)
      expect(result.total_pages).to eq(1)
      expect(result.current_page).to eq(1)
      expect(result.total_entries).to eq(0)
    end

    context 'return_fields option' do
      let(:return_struct) {{"123" => {"name" => "Beavis", "address" => "arizona"},
                            "456" => {"name" => "Honey Badger", "address" => "africa"}}}

      context '2011-02-01 api' do
        let(:response_with_field_data) {  OpenStruct.new(:parsed_response => { "hits" => {
          "found" => 2,
          "start" => 0,
          "hit" => [{"id" => "123",
                     "data" => {"name" => "Beavis", "address" => "arizona"}},
          {"id" => "456",
           "data" => {"name" => "Honey Badger", "address" => "africa"}}]}},
        :response => OpenStruct.new(:code => "200"))
        }
        before :each do
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=testsearch&size=10&return-fields=name,address").and_return response_with_field_data
        end

        subject { @asari.search("testsearch", :return_fields => [:name, :address])}
        it {should eql return_struct}
      end

      context '2013-01-01 api' do
        let(:response_with_field_data) {  OpenStruct.new(:parsed_response => { "hits" => {
          "found" => 2,
          "start" => 0,
          "hit" => [{"id" => "123",
                     "fields" => {"name" => "Beavis", "address" => "arizona"}},
          {"id" => "456",
           "fields" => {"name" => "Honey Badger", "address" => "africa"}}]}},
        :response => OpenStruct.new(:code => "200"))
        }
        before :each do
          ENV['CLOUDSEARCH_API_VERSION'] = '2013-01-01'
          HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2013-01-01/search?q=testsearch&size=10&return=name,address").and_return response_with_field_data
        end
        after(:each) {ENV['CLOUDSEARCH_API_VERSION'] = '2011-02-01'}

        subject { @asari.search("testsearch", :return_fields => [:name, :address])}
        it {should eql return_struct}
      end
    end

    it "raises an exception if the service errors out." do
      HTTParty.stub(:get).and_return(fake_error_response)
      expect { @asari.search("testsearch)") }.to raise_error Asari::SearchException
    end

    it "raises an exception if there are internet issues." do
      HTTParty.stub(:get).and_raise(SocketError.new)
      expect { @asari.search("testsearch)") }.to raise_error Asari::SearchException
    end

  end


  describe "geography searching" do
    it "builds a proper query string" do
      HTTParty.should_receive(:get).with("http://search-testdomain.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=&bq=%28and+lat%3A2505771415..2506771417+lng%3A2358260777..2359261578%29&size=10")
      @asari.search filter: { and: Asari::Geography.coordinate_box(meters: 5000, lat: 45.52, lng: 122.6819) }
    end
  end
end
=end