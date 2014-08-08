require 'spec_helper'
require 'fakeweb'
require 'buttercoin'

describe Buttercoin::Client do

  let(:public_key) { 'public key' }
  let(:secret_key) { 'secret key' }
  let(:mode) { 'sandbox' }
  let(:client) { Buttercoin::Client.new(:public_key => public_key, :secret_key => secret_key) }
  

  before :all do
    FakeWeb.allow_net_connect = false
  end

  describe "Initialize client" do
    it "should initialize with the given options" do
      client = Buttercoin::Client.new(
        :public_key => public_key,
        :secret_key => secret_key,
        :mode => mode
      )
      expect(client.public_key).to eq('public key')
      expect(client.secret_key).to eq('secret key')
      expect(client.mode).to eq('sandbox')
    end

    it "should set the base_uri to the sandbox" do
      expect(Buttercoin::Client.new.class.base_uri).to eq(Buttercoin::Client::SANDBOX_URI)
    end
  end

  describe "Sign the request" do
    let(:build_message) { client.method(:build_message) }
    let(:get_signature) { client.method(:get_signature) }
    let(:get_headers) { client.method(:get_headers) }
    let(:timestamp) { 1444444444444 }
    let(:path) { '/orders' }
    let(:options) do { :status => "opened" } end
    let(:message) { "1444444444444https://api.qa.dcxft.com/v1/orders?status=opened" }
    let(:signature) { "0OBOwbOX3npNPyI6TLq+PN2jpW1NhLn+St0FOpcKvMc=\n" }

    it "should build proper get request message for signing" do
      expect(build_message.call(:get, path, timestamp, options)).to eq("1444444444444https://api.qa.dcxft.com/v1/orders?status=opened")
    end

    it "should build proper get request message for signing" do
      expect(build_message.call(:post, path, timestamp, options)).to eq("1444444444444https://api.qa.dcxft.com/v1/orders{\"status\":\"opened\"}")
    end

    it "should properly sign a message with the given key" do
      expect(get_signature.call(message)).to eq (signature)
    end

    it "should properly build the request headers" do
      headers = {
        'X-Buttercoin-Access-Key' => public_key,
        'X-Buttercoin-Signature' => signature,
        'X-Buttercoin-Date' => timestamp.to_s,
        "Content-Type" => "application/json"
      }
      expect(get_headers.call(signature, timestamp)).to eq (headers)
    end
  end

  describe "process_response" do
    let(:body) { "{ \"text\": \"stuff\" }" }
    let(:error_body) { "{ \"errors\": [ {\"message\": \"stuff\"} ] }" }
    let(:headers) { JSON.parse("{ \"location\": \"http://fake.api.buttercoin.com\" }") }
    let (:process_response) { client.method(:process_response) }

    it "should return a Hashie::Mash object for a 200" do
      expect(process_response.call(200, body, headers).text).to eq "stuff"
    end

    it "should return a success message in a Hashie::Mash object for a 201" do
      expect(process_response.call(201, body, headers).message).to eq "This operation requires email confirmation"
    end

    it "should return a location header string for a 202" do
      expect(process_response.call(202, body, headers)).to eq "http://fake.api.buttercoin.com"
    end

    it "should return a Hashie::Mash object for a 204" do
      expect(process_response.call(204, body, headers).message).to eq "This operation has completed successfully"
    end

    it "should raise a BadRequestError for a 400" do
      expect{process_response.call(400, error_body, headers)}.to raise_error(Buttercoin::BadRequestError, "Buttercoin Exception: stuff") 
    end

    it "should raise a BadRequestError for a 401" do
      expect{process_response.call(401, error_body, headers)}.to raise_error(Buttercoin::AuthenticationError, "Buttercoin Exception: stuff") 
    end

    it "should raise a BadRequestError for a 404" do
      expect{process_response.call(404, error_body, headers)}.to raise_error(Buttercoin::NotFoundError, "Buttercoin Exception: stuff") 
    end

    it "should raise a BadRequestError for a 429" do
      expect{process_response.call(429, error_body, headers)}.to raise_error(Buttercoin::HttpError, "Buttercoin Exception: stuff") 
    end
  end
end
