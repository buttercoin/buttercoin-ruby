require 'httparty'
require 'hashie'
require 'buttercoin/version'
require 'buttercoin/client/unauth_methods'
require 'buttercoin/client/account_query_methods'
require 'buttercoin/client/order_methods'
require 'buttercoin/client/transaction_methods'
#require 'openssl'
require 'base64'

module Buttercoin
  class Client
    include HTTParty
    include Buttercoin::Client::UnauthMethods
    include Buttercoin::Client::AccountQueryMethods
    include Buttercoin::Client::OrderMethods
    include Buttercoin::Client::TransactionMethods

    attr_accessor :public_key, :secret_key, :mode

    CONFIG = {
      :mode => "production"
    }

    PRODUCTION_URI = 'https://api.buttercoin.com/v1'
    SANDBOX_URI = 'https://sandbox.buttercoin.com/v1'

    CA_CERT = 'cert/ca-cert.crt'

    def initialize(*args)
      options = args[0]
      unless options.is_a?(Hash)
        # deprecated, pass a hash of options instead
        options = {
          :public_key => args[0],
          :secret_key => args[1],
          :mode => args[2]
        }
      end

      self.public_key, self.secret_key = options.values_at(:public_key, :secret_key)
      self.mode = options[:mode] || CONFIG[:mode]
      self.class.base_uri (self.mode == 'production') ? PRODUCTION_URI : SANDBOX_URI
    end

    # Wrappers for the main HTTP verbs

    def get(path, timestamp=nil, options={}, authenticate=true)
      http_request :get, path, timestamp, options, authenticate
    end

    def post(path, timestamp=nil, options={}, authenticate=true)
      http_request :post, path, timestamp, options, authenticate
    end

    def delete(path, timestamp=nil, options={}, authenticate=true)
      http_request :delete, path, timestamp, options, authenticate
    end

    def http_request(verb, path, timestamp=nil, options={}, authenticate=true)
      request_options = {}
      if (authenticate)
        timestamp ||= ((Time.now.to_f * 1e3).round).to_i
        message = build_message(verb, path, timestamp, options)
        signature = get_signature(message)
        request_options = {body: options.to_json} if [:post].include? verb
        request_options[:headers] = get_headers(signature, timestamp)
      end
      set_cert()
      r = self.class.send(verb, path, request_options)
      process_response(r.code, r.body, r.headers)
    end

    private

    def set_cert
      path = File.expand_path( CA_CERT, __FILE__)
      self.class.ssl_ca_file path
    end

    def build_message(verb, path, timestamp, options)
      if [:get, :delete].include? verb
        path = "#{path}?#{URI.encode_www_form(options)}" if !options.empty?
        message = timestamp.to_s + self.class.base_uri + path
      else
        message = timestamp.to_s + self.class.base_uri + path + options.to_json
      end
      return message
    end

    def get_signature(message)
      message = Base64.encode64(message).gsub(/\n/, "")
      return Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), self.secret_key, message))
    end

    def get_headers(signature, timestamp)
      return {
        'X-Buttercoin-Access-Key' => self.public_key,
        'X-Buttercoin-Signature' => signature,
        'X-Buttercoin-Date' => timestamp.to_s,
        "Content-Type" => "application/json"
      }
    end

    def process_response(status_code, response_body, response_headers)
      case status_code.to_i
      when 200
        return Hashie::Mash.new(JSON.parse(response_body))
      when 201
        return Hashie::Mash.new({ "status" => status_code, "message" => 'This operation requires email confirmation' })
      when 202
        return response_headers["location"]
      when 204
        return Hashie::Mash.new({ "status" => status_code, "message" => 'This operation has completed successfully' })
      when 400
        mash = Hashie::Mash.new(JSON.parse(response_body))
        raise BadRequestError.new(mash.errors.first.message)
      when 401
        mash = Hashie::Mash.new(JSON.parse(response_body))
        raise AuthenticationError.new(mash.errors.first.message)
      when 404
        mash = Hashie::Mash.new(JSON.parse(response_body))
        raise NotFoundError.new(mash.errors.first.message)
      else
        begin
          mash = Hashie::Mash.new(JSON.parse(response_body))
          raise HttpError.new(mash.errors.first.message)
        end
      end
    end

  end
end
