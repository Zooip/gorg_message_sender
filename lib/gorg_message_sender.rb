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

  def to_message(data,routing_key, opts={})
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
  alias_method :message, :to_message

  def send_message(data,routing_key,opts={})
    self.start(verbose: opts[:verbose])
    p_opts={}
    p_opts[:routing_key]= routing_key if routing_key
    msg=self.to_message(data,routing_key,opts)
    @x.publish(msg, p_opts)
    puts " [#] Message sent to exchange '#{@r_exchange}' (#{@r_durable ? "" : "not "}durable) with routing key '#{routing_key}'" if opts[:verbose]
    msg
  end

  def send_raw(msg,routing_key,opts={})
    self.start(verbose: opts[:verbose])
    p_opts={}
    p_opts[:routing_key]= routing_key if routing_key
    @x.publish(msg, p_opts)
    puts " [#] Message sent to exchange '#{@r_exchange}' (#{@r_durable ? "" : "not "}durable) with routing key '#{routing_key}'" if opts[:verbose]
    msg
  end

  def send_batch_raw(msgs,opts={})
    self.start(verbose: opts[:verbose])
    p_opts={}
    msgs.each do |msg|
      @x.publish(msg[:content], routing_key: msg[:routing_key] )
    end
  end


  protected

  def conn_id
    userpart=""
    if @r_user
      userpart=URI.escape(@r_user.to_s,"@:/")
      userpart+=":#{URI.escape(@r_pass.to_s,'%@:/\#^')}" if @r_pass
      userpart+="@"
    end
    portpart= @r_port ? ":#{URI.escape(@r_port.to_s,"@:/")}" : ""
    vhostpart= @r_vhost ? "/#{URI.escape(@r_vhost.to_s,"@:/")}" : ""

    "amqp://#{userpart}#{URI.escape(@r_host,"@:/")}#{portpart}#{vhostpart}"
  end

  def self.conn(url)
    @conns||=Hash.new(nil)
    @conns[url]||=Bunny.new(url)
    @conns[url].start unless @conns[url].connected?
    @conns[url]
  end

  def ch
    @_ch = (@_ch && @_ch.status == :open) ? @_ch : self.class.conn(conn_id).create_channel
  end

  def start(opts)
    @x  = ch.topic(@r_exchange, :durable => @r_durable)
    puts " [#] Connected as user '#{@r_user}' to #{@r_host}:#{@r_port} on vhost '#{@r_vhost}'" if opts[:verbose]
  end
end
