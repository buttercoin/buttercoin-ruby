module Buttercoin
  class Client
    module TransactionMethods

      # Retrieve the transaction by id
      #
      # @transactionId string
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing transaction info

      def get_transaction_by_id(transactionId, timestamp=nil)
        get '/transactions/'+transactionId, timestamp
      end

      # Retrieve the transaction by url
      #
      # @param url full url of the transaction request
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing transaction info

      def get_transaction_by_url(url, timestamp=nil)
        index = url.rindex('/transactions')
        raise Error.new('Url not correctly formatted for transactions') if index.nil?
        path = url[index..-1]
        get path, timestamp
      end

      # Get list of transactions by search criteria
      # 
      # @param timestamp integer (optional)
      # @param options Hash (optional) criteria to filter list
      #
      # @return Hashie object containing list of transactions

      def get_transactions(options={}, timestamp=nil)
        mash = get '/transactions', timestamp, options
        mash.results
      end

      # Create new deposit with the given params
      # 
      # @param timestamp integer (optional)
      # @param options Hash (required) transaction params
      #
      # @return string containing response location header url

      def create_deposit(options, timestamp=nil)
        post '/transactions/deposit', timestamp, options
      end

      # Create new withdrawal with the given params
      # 
      # @param timestamp integer (optional)
      # @param options Hash (required) transaction params
      #
      # @return string containing response location header url

      def create_withdrawal(options, timestamp=nil)
        post '/transactions/withdraw', timestamp, options
      end

      # Create new bitcoin withdrawal with the given params
      # 
      # @param timestamp integer (optional)
      # @param options Hash (required) transaction params
      #
      # @return string containing response location header url

      def send_bitcoin(options, timestamp=nil)
        post '/transactions/send', timestamp, options
      end

      # Cancel transaction by id
      #
      # @transactionId string
      # @param timestamp integer (optional)
      #
      # @return Hashie object containing status and success message

      def cancel_transaction(transactionId, timestamp=nil)
        delete '/transactions/'+transactionId, timestamp
      end

    end
  end
end

