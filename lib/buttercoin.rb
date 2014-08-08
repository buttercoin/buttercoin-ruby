require "forwardable"
require "logger"
require "json"
require "buttercoin/client"

module Buttercoin
  class Error < RuntimeError
    attr_accessor :original_error
    def initialize(message, _original_error=nil)
      self.original_error = _original_error
      super(message)
    end

    def to_s
      "Buttercoin Exception: #{super}"
    end
  end

  class ConfigurationError < Error; end
  class HttpError < Error; end
  class BadRequestError < HttpError; end
  class AuthenticationError < HttpError; end
  class NotFoundError < HttpError; end

  class << self
    extend Forwardable

    def_delegators :default_client,
      :public_key, :public_key=,
      :secret_key, :secret_key=,
      :mode, :mode=

    def_delegators :default_client,
      :get_ticker,
      :get_order_book

    def_delegators :default_client,
      :get_key,
      :get_balances,
      :get_deposit_address

    def_delegators :default_client,
      :get_order_by_url,
      :get_order_by_id,
      :get_orders,
      :create_order,
      :cancel_order

    def_delegators :default_client,
      :get_transaction,
      :get_transaction_by_id,
      :get_transactions,
      :create_deposit,
      :create_withdrawal,
      :send_bitcoin,
      :cancel_transaction

    attr_writer :logger

    def logger
      @logger ||= lambda {
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        logger
      }.call
    end

    private

    def default_client
      @default_client ||= Buttercoin::Client.new(
        :public_key => ENV['BUTTERCOIN_PUBLIC_KEY'],
        :secret_key => ENV['BUTTERCOIN_SECRET_KEY'],
        :mode => ENV['BUTTERCOIN_MODE'],
      )
    end
  end
end
