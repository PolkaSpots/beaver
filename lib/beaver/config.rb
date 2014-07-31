## Much clever stuff in here with thanks to gocardless#hutch
## https://github.com/gocardless/hutch


module Beaver

  class UnknownAttributeError < StandardError; end

  module Config
    require 'yaml'

    def self.initialize
      @config = {
        mq_host: 'localhost',
        mq_port: 5672,
        mq_exchange: 'beaver',
        mq_vhost: '/',
        mq_tls: false,
        mq_tls_cert: nil,
        mq_tls_key: nil,
        mq_ca: nil,
        mq_username: 'guest',
        mq_password: 'guest',
        log_level: Logger::INFO,
        require_paths: [],
        autoload_rails: true,
        namespace: nil,
        channel_prefetch: 0
      }
    end

    def self.get(attr)
      check_attr(attr)
      user_config[attr]
    end

    def self.set(attr, value)
      check_attr(attr)
      user_config[attr] = value
    end

    class << self
      alias_method :[],  :get
      alias_method :[]=, :set
    end

    def self.check_attr(attr)
      unless user_config.key?(attr)
        raise UnknownAttributeError, "#{attr} is not a valid config attribute"
      end
    end

    def self.user_config
      initialize unless @config
      @config
    end

    def self.load_from_file(file)
      YAML.load(file).each do |attr, value|
        puts value
        Beaver::Config.send("#{attr}=", value)
      end
    end

    def self.method_missing(method, *args, &block)
      attr = method.to_s.sub(/=$/, '').to_sym
      return super unless user_config.key?(attr)

      if method =~ /=$/
        set(attr, args.first)
      else
        get(attr)
      end
    end
  end
end

