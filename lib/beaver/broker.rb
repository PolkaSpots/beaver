require 'bunny'

module Beaver

  class Broker

    attr_accessor :connection, :channel, :exchange

    def initialize(config={})
      @config   = config || Beaver::Config
      @host     = @config[:mq_host]
      @port     = @config[:mq_port]
      @vhost    = @config[:mq_vhost]
      @username = @config[:mq_username]
      @password = @config[:mq_password]
      @tls      = @config[:mq_tls]
      @tls_key  = @config[:mq_tls_cert]
      @tls_cert = @config[:mq_tls_key]
      @ca       = @config[:mq_ca]
    end

    def connect(options)
      connect_to_rabbitmq
    end

    def connect_to_rabbitmq
      open_connection
      create_channel
      bind_exchange
    end

    def open_connection
      @connection = Bunny.new(
        host: @host,
        port: @port,
        vhost: @vhost,
        tls: @tls,
        tls_key: @tls_key,
        tls_cert: @tls_cert,
        tls_ca: @ca,
        username: @username,
        password: @password,
        heartbeat: 10,
        automatically_recover: true,
        network_recovery_interval: 1
      )
      @connection.start
      @connection
    end

    def create_channel
      #logger.info 'opening rabbitmq channel'
      @channel = connection.create_channel.tap do |ch|
        ch.prefetch(@config[:channel_prefetch]) if @config[:channel_prefetch]
      end
    end

    def bind_exchange
      exchange_name = @config[:mq_exchange]
      # logger.info "using topic exchange '#{exchange_name}'"
      @exchange = @channel.topic(exchange_name, durable: true)
    end

    # Create / get a durable queue and apply namespace if it exists.
    def queue(name)
      #with_bunny_precondition_handler('queue') do
      namespace = @config[:namespace].to_s.downcase.gsub(/[^-_:\.\w]/, "")
      name = name.prepend(namespace + ":") unless namespace.empty?
      channel.queue(name, durable: true)
      #end
    end

    def bind_queue(queue, routing_keys)
      routing_keys.each do |routing_key|
        # logger.debug "creating binding #{queue.name} <--> #{routing_key}"
        queue.bind(@exchange, routing_key: routing_key)
      end
    end

    # Each subscriber is run in a thread. This calls Thread#join on each of the
    # subscriber threads.
    def wait_on_threads(timeout)
      # Thread#join returns nil when the timeout is hit. If any return nil,
      # the threads didn't all join so we return false.
      per_thread_timeout = timeout.to_f / work_pool_threads.length
      work_pool_threads.none? { |thread| thread.join(per_thread_timeout).nil? }
    end

    def work_pool_threads
      @channel.work_pool.threads || []
    end

    def stop
      @channel.work_pool.kill
    end

    def ack(delivery_tag)
      @channel.ack(delivery_tag, false)
    end

  end

end
