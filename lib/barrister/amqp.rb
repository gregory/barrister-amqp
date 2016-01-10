require "barrister/amqp/version"
require 'bunny'

module Barrister
  module Amqp
    Wrapper = Struct.new(:message) do
      def wrap
        {
          "id"      => Barrister.rand_str(22),
          "message" => JSON.generate(message, { :ascii_only=>true })
        }
      end

      def unwrap
        message
      end
    end

    Config = OpenStruct.new(debug: false, wrapper: Wrapper)

    class Transport
      # NOTE: transport needs to implement request method for the Barrister::Client to
      # send requests to the server
      def initialize(service_name, options={})
        conn = Bunny.new ENV.fetch('AMQP_URL') #"Please set AMQP_URL to something like: amqp://user:password@host:port/vhost"
        conn.start
        @ch             = conn.create_channel
        @service_q      = @ch.queue(service_name, auto_delete: false)
        @reply_q        = @ch.queue('', exclusive: true)
        @x              = @ch.default_exchange
        @response_table = Hash.new { |h,k| h[k] = Queue.new }

        @reply_q.subscribe(block: false) do |delivery_info, properties, payload|
          @response_table[properties[:correlation_id]].push payload # push anything that comes in the response_q
        end
      end

      def request(message)
        enveloppe = Config.wrapper.new(message).wrap
        # NOTE message could be an array
        print "[AMQP TRANSPORT --->] \n #{enveloppe} \n" if Config.debug
        @x.publish(enveloppe['message'], { correlation_id: enveloppe['id'], reply_to: @reply_q.name, routing_key: @service_q.name})

        response = @response_table[enveloppe['id']].pop
        @response_table.delete enveloppe['id']

        begin
          JSON.parse(response).tap do |resp|
            print "[AMQP TRANSPORT <---] \n #{resp} \n" if Config.debug
          end
        rescue JSON::ParserError => e
          raise RpcException.new(-32000, "Bad response #{e.message}")
        end
      end
    end

    class Container
      # NOTE: A container needs to call the Barrister::Server to handle the request
      # and send the response to the client.
      #
      def initialize(json_path, service_name, handlers=[], options={})
        conn = Bunny.new ENV.fetch('AMQP_URL')
        conn.start
        @ch = conn.create_channel
        @service_q = @ch.queue(service_name, auto_delete: false)
        @x = @ch.default_exchange

        contract = Barrister::contract_from_file(json_path)
        @server  = Barrister::Server.new(contract)

        Array(handlers).each do |handler|
          iface_name = handler.class.to_s.split('::').last
          @server.add_handler iface_name, handler
        end
      end

      # TODO: use delegator
      def add_handler(iface_name, handler)
        @server.add_handler iface_name, handler
      end

      def start
        @service_q.subscribe(block: true) do |delivery_info, properties, payload|
          payload = Config.wrapper.new(payload).unwrap
          puts "handling payload:  #{payload}" if Config.debug
          @x.publish(@server.handle_json(payload), { routing_key: properties.reply_to, correlation_id: properties.correlation_id })
        end
      end
    end
  end
end
