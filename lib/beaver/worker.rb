require_relative './message'

module Beaver

  class Worker

    def initialize(broker, consumers)
      self.consumers = consumers
      @broker        = broker
    end

    def consumers=(val)
      if val.empty?
        #puts "OMGGGG There's no values"
        logger.warn "no consumer loaded, ensure there's no configuration issue"
      end
      @consumers = val
    end

    def run
      setup_queues
      register_signal_handlers
      handle_signals until @broker.wait_on_threads(0.1)
    end

    # Register handlers for SIG{QUIT,TERM,INT} to shut down the worker
    # gracefully. Forceful shutdowns are very bad!
    def register_signal_handlers
      Thread.main[:signal_queue] = []
      %w(QUIT TERM INT).map(&:to_sym).each do |sig|
        # This needs to be reentrant, so we queue up signals to be handled
        # in the run loop, rather than acting on signals here
        trap(sig) do
          Thread.main[:signal_queue] << sig
        end
      end
    end

    # Handle any pending signals
    def handle_signals
      signal = Thread.main[:signal_queue].shift
      if signal
        logger.info "caught sig#{signal.downcase}, stopping the eager Beaver..."
        stop
      end
    end

    def stop
      @broker.stop
    end

    def setup_queues
      @consumers.each { |consumer| setup_queue(consumer) }
    end

    def setup_queue(consumer)
      queue = @broker.queue(consumer.get_queue_name)

      @broker.bind_queue(queue, consumer.routing_keys)
      queue.subscribe(ack: true) do |delivery_info, properties, payload|
        handle_message(consumer, delivery_info, properties, payload)
      end

    end

    def handle_message(consumer, delivery_info, properties, payload)
      logger.info("message(#{properties.message_id || '-'}): " +
                  "routing key: #{delivery_info.routing_key}, " +
                  "consumer: #{consumer}, " +
                  "payload: #{payload}")

      broker = @broker
      message = Message.new(delivery_info, properties, payload)
      consumer.new.process(message)
      broker.ack(delivery_info.delivery_tag)
    end

  end
end
