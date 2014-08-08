module Buttercoin
  class Client
    module OrderMethods

      # Retrieve the order by id
      #
      # @orderId string
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing order info

      def get_order_by_id(orderId, timestamp=nil)
        get '/orders/'+orderId, timestamp
      end

      # Retrieve the order by url
      #
      # @param url full url of the order request
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing order info

      def get_order_by_url(url, timestamp=nil)
        index = url.rindex('/orders')
        raise Error.new('Url not correctly formatted for orders') if index.nil?
        path = url[index..-1]
        get path, timestamp
      end

      # Get list of orders by search criteria
      # 
      # @param timestamp integer (optional)
      # @param options Hash (optional) criteria to filter list
      #
      # @return Hashie object containing list of orders

      def get_orders(options={}, timestamp=nil)
        mash = get '/orders', timestamp, options
        mash.results
      end

      # Create new order with the given params
      # 
      # @param timestamp integer (optional)
      # @param options Hash (required) order params
      #
      # @return string containing response location header url

      def create_order(options, timestamp=nil)
        post '/orders', timestamp, options
      end

      # Cancel order by id
      #
      # @orderId string
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing status and success message

      def cancel_order(orderId, timestamp=nil)
        delete '/orders/'+orderId, timestamp
      end

    end
  end
end
