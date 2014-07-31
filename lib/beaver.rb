require "beaver/version"
require "beaver/broker"
require "beaver/config"
require 'beaver/logging'
require 'set'

module Beaver

  def self.included(base)
    base.extend ClassMethods
    Beaver.register_consumer(base)
  end

  def self.register_consumer(consumer)
    puts "Registering consumer #{consumer}"
    self.consumers << consumer
  end

  def self.consumers
    @consumers ||= []
  end

  def self.broker
    @broker
  end

  def self.connect(options = {}, config = Beaver::Config)
    unless connected?
      @broker = Beaver::Broker.new(config)
      @broker.connect(options)
      @connected = true
      logger.info "Beaver booted with pid #{Process.pid}"
    end
  end

  def self.connected?
    @connected
  end

  def self.logger
    Beaver::Logging.logger
  end

  module ClassMethods

    def consume(*routing_keys)
      @routing_keys = self.routing_keys.union(routing_keys)
    end

    def routing_keys
      @routing_keys ||= Set.new
    end

    ### Shamelessly borrowed from Hutch ###
    def queue_name(name)
      @queue_name = name
    end

    def get_queue_name
      return @queue_name unless @queue_name.nil?
      queue_name = self.name.gsub(/::/, ':')
      queue_name.gsub!(/([^A-Z:])([A-Z])/) { "#{$1}_#{$2}" }
      queue_name.downcase
    end

  end

end
