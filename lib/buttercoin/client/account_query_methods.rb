module Buttercoin
  class Client
    module AccountQueryMethods

      # Retrieve the ticker
      #
      # @param timestamp integer (optional)

      def get_key(timestamp=nil)
        get '/key', timestamp
      end

      # Retrieve the account balanaces for all currencies
      #
      # @param timestamp integer (optional)

      def get_balances(timestamp=nil)
        get '/account/balances', timestamp
      end

      # Retrieve the bitcoin deposit address
      #
      # @param timestamp integer (optional)

      def get_deposit_address(timestamp=nil)
        mash = get '/account/depositAddress', timestamp
        mash.address
      end

    end
  end
end
