module Buttercoin
  class Client
    module UnauthMethods

      # Retrieve the ticker
      #
      # @return Hashie object containing market price info

      def get_ticker
        get '/ticker', nil, {}, false
      end

      # Retrieve the orderbook
      #
      # @return Hashie object containing order book info

      def get_order_book
        get '/orderbook', nil, {}, false
      end

      # Retrieve the last 100 trades
      #
      # @return Hashie object containing trade history

      def get_trade_history
        mash = get '/trades', nil, {}, false
        mash.trades
      end
      
    end
  end
end
