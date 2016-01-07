# Barrister::Amqp

A Amqp server-container and transport for [Barrister RPC](http://barrister.bitmechanic.com)

Feel free to go read about the concepts at [http://barrister.bitmechanic.com](http://barrister.bitmechanic.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'barrister-amqp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barrister-amqp

## Usage

Since we are using AMQP, you'll have to setup an `AMQP_URL` in your environment.

On your service side, you'll wrap your Barrister server in the AMQP container like this:

```rb
ENV['AMQP_URL']="amqp://user:password@hostname/vhost"
server = Barrister::Amqp::Container.new('full_path_to_your_service.json', 'com.company.services.my_barrister_service')
server.add_handler('ServiceA', ServiceA)
server.start
```

Calling `start`on the Amqp container will connect to your AMQP server and begin to
listen for messages

On your client side, you'll wrap the transport layer of your client like this:

```rb
ENV['AMQP_URL']="amqp://user:password@hostname/vhost"
amqp_transport = Barrister::Amqp::Transport.new('com.company.services.my_barrister_service')
client = Barrister::Client.new(amqp_transport)

client.ServiceA.my_awesome_rpc_method
```

## TODO

- [ ] write specs
- [ ] write example
- [ ] see if we can make it more robust like gocardless did with [hutch](https://github.com/gocardless/hutch/tree/master/lib/hutch/error_handlers)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/barrister-amqp/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
