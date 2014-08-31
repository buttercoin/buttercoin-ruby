Buttercoin Ruby SDK Gem Library
===================
Easy integration with the Buttercoin Trading Platform through our API.

Installation
--------------------------
Add to your Gemfile:

    gem 'buttercoin'

or install from Rubygems:

    gem install buttercoin

Usage
-----

When you first create a new `Buttercoin::Client` instance you can pass `:public_key`, `:private_key`, and `:mode` as configuration settings. These are optional and can be later specified through Setter methods.

For authenticated API Resources, the `:public_key` and `:secret_key` are required and can also be passed to the factory method in the configuration array.  The `mode` configuration setting defaults to `'production'`.

For a list of required and available parameters as well as code samples for the different API Endpoints, please consult the Buttercoin
[API Reference Docs](https://developer.buttercoin.com).

#### Set Keys via the Environment

In order to keep sensitive data out of your codebase, we recommend you use environment variables to set keys. If you're using [foreman](http://ddollar.github.com/foreman/), add this to your `.env` file:

    BUTTERCOIN_PUBLIC_KEY=5ti8pqwejqfcla4se1d7whydryoso5z8
    BUTTERCOIN_SECRET_KEY=JCfcasdfinmKtdHgIlwXi3SEMJoCf4Bg
    BUTTERCOIN_MODE=sandbox

You can also create a script to export the variables before you start your server.

To deploy on Heroku, see [this example](https://devcenter.heroku.com/articles/config-vars).

#### Configuring the Client

Create a unique Buttercoin Webservice Client as follows:

Setting | Property Name | Description
--- | --- | ---
Public Key | `:public_key` | Your Buttercoin API Public Key  
Secret Key | `:secret_key` | Your Buttercoin API Secret Key  
Mode | `:mode` | Your development environment (default: `'production'`, set to `'sandbox'` to test with testnet bitcoins)

###### Example
```ruby
client = Buttercoin::Client.new(:public_key => '5ti8pqwejqfcla4se1d7whydryoso5z8',
																:secret_key => 'JCfcasdfinmKtdHgIlwXi3SEMJoCf4Bg',
																:mode => 'sandbox')
```

#### Configuration can be updated to reuse the same Client:
You can reconfigure the Buttercoin Client configuration options through available getters and setters. You can get and set the following options: 
`:public_key`, `:private_key` & `:mode`

###### Example
```ruby
client.secret_key;
client.secret_key = '<new_secret_key>'
```

**Tips**

A note on the `timestamp` param sent to all client methods: 
This param must always be increasing, and within 5 minutes of Buttercoin server times (GMT). This is to prevent replay attacks on your data. 

Before every call, get a new timestamp.  (You need only set the timezone once)

```ruby
timestamp = ((Time.now.to_f * 1e3).round).to_i
client.get_key(timestamp)
```

Additionally, for convenience, if you don't include the timestamp parameter, it will default to the current timestamp.

```ruby
client.get_key()
```

### Get Data

###### Unauthenticated

**Get Order Book**  
Return a `Hashie::Mash` of current orders in the Buttercoin order book

```ruby
client.get_order_book()
```

**Get Ticker**  
Return the current bid, ask, and last sell prices on the Buttercoin platform

```ruby
client.get_ticker()
```

###### Authenticated

**Key Permissions**  
Returns `Hashie::Mash` of permissions associated with this key

```ruby
client.get_key(timestamp)
```

**Balances**  
Returns `Hashie::Mash` of balances for this account

```ruby
client.get_balances(timestamp)
```

**Deposit Address**  
Returns bitcoin address `string` to deposit your funds into the Buttercoin platform

```ruby
client.get_deposit_address(timestamp)
```

**Get Orders**  
Returns `Hashie::Mash` containing information about buy and sell orders

Valid params include (must be added to array in this order)

Name | Param | Description
--- | --- | ---
Status | `status` | enum: `['opened', 'partial-filled', 'filled', 'canceled']`  
Side | `side` | enum: `['buy', 'sell']`  
Order Type | `orderType` | enum: `['market', 'limit']`  
Date Min | `dateMin` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
Date Max | `dateMax` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`

```ruby
// query for multiple orders
order_params = [ "status" => "canceled", "side" => "sell" ]

client.get_orders(orderParams, timestamp)

// single order by id
order_id = '<order_id>'

client.get_order_by_id(order_id, timestamp)

// single order by url
url = 'https://api.buttercoin.com/v1/orders/{order_id}'

client.get_order_by_url(url, timestamp)
```

**Get Transaction**  
Returns `Hashie::Mash`  containing information about deposit and withdraw action 

Valid params include (must be added to array in this order):

Name | Param | Description
--- | --- | ---
Status | `status` | enum: `['pending', 'processing', 'funded', 'canceled', 'failed']`  
Transaction Type | `transactionType` | enum: `['deposit', 'withdrawal']`  
Date Min | `dateMin` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  
Date Max | `dateMax` | format: ISO-8601, e.g. `'2014-05-06T13:15:30Z'`  

```ruby
// query for multiple transactions
trxn_params = [ "status" => "funded", "transactionType" => "deposit" ]

client.get_transactions(trxn_params, timestamp)

trxn_id = '53a22ce164f23e7301a4fee5';

client.get_transaction_by_id(trxn_id, timestamp)

// single transaction by url
url = 'https://api.buttercoin.com/v1/orders/{order_id}'

client.get_transaction_by_url(url, timestamp)
```

### Create New Actions

**Create Order**  

Valid order params include: 

Name | Param | Description
--- | --- | ---
Instrument | `instrument` | enum: `['BTC_USD, USD_BTC']`
Side | `side` | enum: `['buy', 'sell']`, required `true`  
Order Type | `orderType` | enum: `['limit', 'market']`, required `true`  
Price | `price` | `string`, required `false`  
Quantity | `quantity` | `string`, required `false`

```ruby
// create a hash with the following params
order = {
  :instrument => "BTC_USD",
  :side => "buy",
  :orderType => "limit",
  :price => "700.00"
  :quantity => "5"
}

client.create_order(order, timestamp)
```

**Create Transaction**  

Deposit transaction params include: 

Name | Param | Description
--- | --- | ---
Method | `method` | enum: `['wire']`, required `true`  
Currency | `currency` | enum: `['USD']`, required `true`  
Amount | `amount` | `string`, required `true`

```ruby
// create deposit
trxn = {
  :method => "wire",
  :currency => "USD",
  :amount => "5002"
}

client.create_deposit(trxn, timestamp)
```

Withdrawal transaction params include: 

Name | Param | Description
--- | --- | --- 
Method | `method` | enum: `['check']`, required `true`  
Currency | `currency` | enum: `['USD']`, required `true`  
Amount | `amount` | `string`, required `true`  

```ruby
// create withdrawal
trxn = {
  :method => "check",
  :currency => "USD",
  :amount => "900.23"
}

client.create_withdrawal(trxn, timestamp)
```
Send bitcoin transaction params include: 

Name | Param | Description
--- | --- | --- 
Currency | `currency` | `['USD']`, required `true`  
Amount | `amount` | `string`, required `true`  
Destination | `destination` | address to which to send currency `string`, required `true`  

```ruby
// send bitcoins to an address
trxn = {
  :currency => "BTC",
  :amount => "100.231231",
  :destination => "<bitcoin_address>"
}

client.send_bitcoins(trxn, timestamp)
```


### Cancel Actions

All successful cancel calls to the API return a response status of `204` with a human readable success message

**Cancel Order**  
Cancel a pending buy or sell order

```ruby
client.cancel_order(order_id, timestamp)
```

**Cancel Transaction**  
Cancel a pending deposit or withdraw action

```ruby
client.cancel_transaction(trxn_id, timestamp)
```

## Further Reading

[Buttercoin - Website](https://www.buttercoin.com)  
[Buttercoin API Docs](https://developer.buttercoin.com)

## Contributing

This is an open source project and we love involvement from the community! Hit us up with pull requests and issues. 

The aim is to take your great ideas and make everyone's experience using Buttercoin even more powerful. The more contributions the better!

## Release History

### 0.0.1

- First release.

### 0.0.2

- changed test environment to sandbox

## License
