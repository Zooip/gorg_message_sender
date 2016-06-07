require "gorg_message_sender/version"
require "gorg_message_sender/configuration"
require "gorg_message_sender/json_schema"
require "bunny"
require "json"
require 'securerandom'

class GorgMessageSender
  def initialize(host: self.class.configuration.host,
                 port: self.class.configuration.port,
                 user: self.class.configuration.user,
                 pass:self.class.configuration.password,
                 exchange_name:self.class.configuration.exchange_name,
                 vhost: self.class.configuration.vhost,
                 app_id: self.class.configuration.application_id,
                 durable_exchange: self.class.configuration.durable_exchange)
    @r_host=host
    @r_port=port
    @r_user=user
    @r_pass=pass
    @r_exchange=exchange_name
    @r_vhost=vhost
    @app_id=app_id
    @r_durable=durable_exchange
  end

  def message(data,routing_key, opts={})
    json_msg={
      "event_uuid" => opts[:event_uuid]||SecureRandom.uuid,
      "event_name" => routing_key,
      "event_creation_time" => (opts[:event_creation_time]&&(opts[:event_creation_time].respond_to?(:iso8601) ? opts[:event_creation_time].iso8601 : opts[:event_creation_time].to_s)) ||DateTime.now.iso8601,
      "event_sender_id" => opts[:event_sender_id]|| @app_id,
      "data"=> data,
    }.to_json
    JSON::Validator.validate!(GorgMessageSender::JSON_SCHEMA,json_msg) unless opts[:skip_validation]
    json_msg
  end

  def send_message(data,routing_key,opts={})
    self.start(verbose: opts[:verbose])
    p_opts={}
    p_opts[:routing_key]= routing_key if routing_key
    msg=message(data,routing_key,opts)
    @x.publish(msg, p_opts)
    puts " [#] Message sent to exchange '#{@r_exchange}' (#{@r_durable ? "" : "not "}durable) with routing key '#{routing_key}'" if opts[:verbose]
    self.stop(verbose: opts[:verbose])
    msg
  end

  def send_raw(msg,routing_key,opts={})
    self.start(verbose: opts[:verbose])
    p_opts={}
    p_opts[:routing_key]= routing_key if routing_key
    @x.publish(msg, p_opts)
    puts " [#] Message sent to exchange '#{@r_exchange}' (#{@r_durable ? "" : "not "}durable) with routing key '#{routing_key}'" if opts[:verbose]
    self.stop(verbose: opts[:verbose])
    msg
  end

  protected

  def start(opts)
    @conn||=Bunny.new(
      :hostname => @r_host,
      :port => @r_port,
      :user => @r_user,
      :pass => @r_pass,
      :vhost => @r_vhost
      )
    @conn.start
    ch = @conn.create_channel
    @x  = ch.topic(@r_exchange, :durable => @r_durable)
    puts " [#] Connected as user '#{@r_user}' to #{@r_host}:#{@r_port} on vhost '#{@r_vhost}'" if opts[:verbose]

  end

  def stop(opts)
    @conn.close
    puts " [#] Connection closed" if opts[:verbose]
  end
end
