require 'spec_helper'

describe Databasedotcom::Rails::Controller do
  class TestController
    include Databasedotcom::Rails::Controller
    
    def reference_Foo
      Foo.create
    end
    
    def reference_Bar
      Bar.create
    end
  end
  
  describe ".dbdc_client" do
    before(:each) do
      config_hash = { "client_id" => "client_id", "client_secret" => "client_secret",  "username" => "foo", "password" => "bar" }
      YAML.should_receive(:load_file).and_return(config_hash)
    end
    
    after(:each) do
      TestController.dbdc_client = nil
    end
    
    it "constructs and authenticates a Databasedotcom::Client" do
      Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "foo", :password => "bar")
      TestController.dbdc_client
    end
    
    it "is memoized" do
      Databasedotcom::Client.any_instance.should_receive(:authenticate).exactly(1).times.with(:username => "foo", :password => "bar")
      TestController.dbdc_client
      TestController.dbdc_client
    end
  end
  
  describe ".sobject_types" do
    before(:each) do
      @client_double = double("client")
      TestController.should_receive(:dbdc_client).any_number_of_times.and_return(@client_double)
    end
    
    after(:each) do
      TestController.instance_variable_set("@sobject_types", nil)
    end
    
    it "requests the sobject types from the client" do
      @client_double.should_receive(:list_sobjects)
      TestController.sobject_types
    end
    
    it "is memoized" do
      @client_double.should_receive(:list_sobjects).exactly(1).times.and_return(%w(foo bar))
      TestController.sobject_types
      TestController.sobject_types      
    end
  end
  
  describe "#dbdc_client" do
    it "calls .dbdc_client" do
      TestController.should_receive(:dbdc_client)
      TestController.new.send(:dbdc_client)
    end
  end
  
  describe "#sobject_types" do
    it "calls .sobject_types" do
      TestController.should_receive(:sobject_types)
      TestController.new.send(:sobject_types)
    end
  end
  
  describe "automatic materialization" do
    before(:each) do
      @client_double = double("client")
      TestController.should_receive(:sobject_types).and_return(%w(Foo))
    end
    
    it "attempts to materialize a referenced constant that is a known sobject type" do
      TestController.should_receive(:dbdc_client).and_return(@client_double)
      @client_double.should_receive(:materialize).with("Foo").and_return(double("foo", :create => true))
      TestController.new.reference_Foo
    end
    
    it "does not attempt to materialize a referenced constant that is not a known sobject type" do
      TestController.should_not_receive(:dbdc_client)
      expect {
        TestController.new.reference_Bar
      }.to raise_error(NameError)
    end
  end
end
