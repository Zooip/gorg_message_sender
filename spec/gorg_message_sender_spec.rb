require 'spec_helper'
require 'json'

describe GorgMessageSender do
  it 'has a version number' do
    expect(GorgMessageSender::VERSION).not_to be nil
  end

  describe "configuration" do
    it "has a default configuration" do
      GorgMessageSender.configuration=nil
      expect(GorgMessageSender.configuration).not_to be_nil
    end

    it "is configurable" do
      GorgMessageSender.configure do |c|
        c.application_id = "my_testing_app"
        c.host ="my.host" 
        c.port =1234 
        c.exchange_name ="some_exchange" 
        c.user ="my_user" 
        c.password ="1a45e6za" 
        c.vhost ="some_vhost" 
        c.durable_exchange=false
      end

      expect(GorgMessageSender.configuration.application_id).to eq("my_testing_app")
      expect(GorgMessageSender.configuration.host).to eq("my.host")
      expect(GorgMessageSender.configuration.port).to eq(1234)
      expect(GorgMessageSender.configuration.exchange_name).to eq("some_exchange")
      expect(GorgMessageSender.configuration.user).to eq("my_user")
      expect(GorgMessageSender.configuration.password).to eq("1a45e6za")
      expect(GorgMessageSender.configuration.vhost).to eq("some_vhost")
      expect(GorgMessageSender.configuration.durable_exchange).to eq(false)
    end

    it "is reset at each configuration" do
      GorgMessageSender.configure do |c|
        c.application_id = "my_testing_app"
        c.host ="my.host" 
        c.port =1234 
        c.exchange_name ="some_exchange" 
        c.user ="my_user" 
        c.password ="1a45e6za" 
        c.vhost ="some_vhost" 
      end

      GorgMessageSender.configure do |c|
        c.user ="other_user" 
      end

      expect(GorgMessageSender.configuration.application_id).not_to eq("my_testing_app")
      expect(GorgMessageSender.configuration.user).to eq("other_user")

    end
  end

  describe "JSON message" do
    it "is valid against JSON schema" do
      sender=GorgMessageSender.new(app_id:"my_app")
      json_msg=sender.message({content: "my_message"},"some.key")
      expect(JSON::Validator.fully_validate(GorgMessageSender::JSON_SCHEMA,json_msg)).to match_array([])
    end
  end
end
