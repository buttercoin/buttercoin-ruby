require 'spec_helper'
require 'rspec'
require 'buttercoin'

describe Buttercoin do
  describe "Setup default client" do
    describe "configuring from environment variables" do
      before do
        Buttercoin.instance_variable_set(:@default_client, nil)
        ENV['BUTTERCOIN_PUBLIC_KEY'] = "PUBLIC_KEY"
        ENV['BUTTERCOIN_SECRET_KEY'] = "SECRET_KEY"
        ENV['BUTTERCOIN_MODE'] = "MODE"
      end

      let(:client) { Buttercoin.send(:default_client) }

      it "should pick up public key from environment" do
        expect(client.public_key).to eq "PUBLIC_KEY"
      end

      it "should pick up secret key from environment" do
        expect(client.secret_key).to eq "SECRET_KEY"
      end

      it "should pick up public key from environment" do
        expect(client.mode).to eq "MODE"
      end
    end
  end

  describe "Default client delegation" do
    it "should overwrite value in default client, retaining settings" do
      Buttercoin.public_key = "NEW_PUBLIC_KEY"
      expect(Buttercoin.public_key).to eq "NEW_PUBLIC_KEY"
    end

    after do
      Buttercoin.instance_variable_set(:@default_client, nil)
    end
  end

  describe "forwardable" do
    before do
      @default_client = double("client")
      allow(Buttercoin).to receive(:default_client).and_return(@default_client)
    end

    [:public_key, :secret_key, :mode].each do |_method|
      it "should forward the #{_method} method" do
        expect(@default_client).to receive _method
        Buttercoin.send(_method)
      end
    end

    # pull the Unauthenticated methods list at runtime in order to ensure
    # any new methods have a corresponding delegator
    Buttercoin::Client::UnauthMethods.instance_methods.each do |_method|
      it "should forward the #{_method} unauth method" do
        allow(@default_client). to receive(_method)
        Buttercoin.send(_method)
      end
    end

    # pull the AccountQuery methods list at runtime in order to ensure
    # any new methods have a corresponding delegator
    Buttercoin::Client::AccountQueryMethods.instance_methods.each do |_method|
      it "should forward the #{_method} account query method" do
        allow(@default_client). to receive(_method).with(1444444444444)
        Buttercoin.send(_method, 1444444444444)
      end
    end
  end

  describe "logger" do
    it "should be set to info" do
      expect(Buttercoin.logger.level).to eq Logger::INFO
    end
  end
end
