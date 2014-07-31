require 'optparse'
require 'beaver/config'


module Beaver

  class CLI

    def run
      parse_options
      puts "Loading the eager Beaver..."
      if load_app
        start_workers
        puts "Application loaded..."
      end
    end

    def load_app
      rails_path = File.expand_path(File.join('.', 'config/environment.rb'))
      require rails_path
      ::Rails.application.eager_load!
      return true
    end

    def start_workers
      load_config
      Beaver.connect
      @worker = Beaver::Worker.new(Beaver.broker, Beaver.consumers)
      @worker.run
      return true
    end

    def load_config
    end

    def parse_options(args = ARGV)
      OptionParser.new do |opts|
        opts.banner = 'usage: beaver [options]'
        opts.on('--config FILE', 'Load Beaver configuration from a file') do |file|
          File.open(file) { |fp| Beaver::Config.load_from_file(fp) }
        end
      end.parse!(args)
    end

  end

end
