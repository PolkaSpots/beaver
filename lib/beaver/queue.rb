require 'sneakers'
require "json"
# require 'active_record'

module Beaver

  class Queue

    include Sneakers::Worker

    def initialize(consumer)
      self.consumer = consumer
    end

    def consumer=(val)
      @consumer = val
    end

    def run
      from_queue(
        :sneakers,
        exchange: 'sneakers',
        durable: true,
        auto_delete: false,
        exchange_type: 'topic',
        routing_key: [*@consumer.routing_keys]
      )
    end

  end

end
