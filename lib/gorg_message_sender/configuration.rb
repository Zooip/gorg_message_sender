# Add configuration features to GorgService
class GorgMessageSender
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= GorgMessageSender::Configuration.new
    end


    def configure
      @configuration = GorgMessageSender::Configuration.new
      yield(configuration)
    end
  end

  # Hold configuration of GorgService in instance variables
  class Configuration
    attr_accessor :application_id,
                  :host,
                  :port,
                  :exchange_name,
                  :user,
                  :password,
                  :vhost,
                  :durable_exchange


    def initialize
      @application_id          = "gms" 
      @host           = "localhost"
      @port           = 5672
      @exchange_name  = "exchange"
      @user           = nil
      @password       = nil
      @vhost          = "/"
      @durable_exchange = true
    end
  end
end