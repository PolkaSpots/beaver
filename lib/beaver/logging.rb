require 'logger'
require 'time'

module Beaver

  module Logging

    def self.logger
      @logger || setup_logger
    end

    def self.setup_logger(target = $stdout)
      require 'beaver/config'
      @logger = Logger.new(target)
      @logger.level = Beaver::Config.log_level
      @logger
    end

    def self.logger=(logger)
      @logger = logger
    end

    def logger
      Beaver::Logging.logger
    end

  end

end
