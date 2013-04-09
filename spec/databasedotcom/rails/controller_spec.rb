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
    after(:each) do
      TestController.dbdc_client = nil
    end

    describe "if the config has an entry that matches Rails.env" do
#      [:production, :development, :test].each do |env|
        before (:each) do
          config_hash = { :production => { "client_id" => "production_client_id", "client_secret" => "production_client_secret",  "username" => "production_foo", "password" => "production_bar" },
                          :development => { "client_id" => "development_client_id", "client_secret" => "development_client_secret",  "username" => "development_foo", "password" => "development_bar" },
                          :test => { "client_id" => "test_client_id", "client_secret" => "test_client_secret",  "username" => "test_foo", "password" => "test_bar" }
                        }
          YAML.should_receive(:load).and_return(config_hash)
          File.stub(:read).and_return("")
          ::Rails.stub!(:env).and_return(:production)
        end
        it "should use the corresponding entry" do
          Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "production_foo", :password => "production_bar")
          TestController.dbdc_client
         end
#      end
    end
    describe "if the config does not have an entry that matches Rails.env" do
      it "should use the top level config" do
        conf_hash = { "client_id" => "client_id", "client_secret" => "client_secret",  "username" => "foo", "password" => "bar" }
        ::Rails.stub!(:env).and_return(:production)
        File.stub(:read).and_return("")
        YAML.should_receive(:load).and_return(conf_hash)
        Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "foo", :password => "bar")
        TestController.dbdc_client
      end
    end
    
    describe "if the config has an erb tag" do
      it "should be evaluated" do
        conf_file_contents = %q{
          client_id: client_foo
          client_secret: secret_bar
          username: <%= FAKE_ENV['DATABASEDOTCOM_USERNAME'] %>
          password: <%= FAKE_ENV['DATABASEDOTCOM_PASSWORD'] %>
        }
        ::Rails.stub(:env).and_return(:test)
        
        FAKE_ENV = {}
        
        FAKE_ENV.stub(:[]).with("DATABASEDOTCOM_USERNAME").and_return('foo')
        FAKE_ENV.stub(:[]).with("DATABASEDOTCOM_PASSWORD").and_return('bar')
        
        File.should_receive(:read).and_return(conf_file_contents)
        
        Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "foo", :password => "bar")
        TestController.dbdc_client
      end
    end

    describe "foo" do
      before(:each) do
        config_hash = { "client_id" => "client_id", "client_secret" => "client_secret",  "username" => "foo", "password" => "bar" }
        File.stub(:read).and_return("")
        YAML.should_receive(:load).and_return(config_hash)
        ::Rails.stub!(:env).and_return(:test)
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
