# GorgMessageSender
[![Code Climate](https://codeclimate.com/github/Zooip/gorg_message_sender/badges/gpa.svg)](https://codeclimate.com/github/Zooip/gorg_message_sender) [![Test Coverage](https://codeclimate.com/github/Zooip/gorg_message_sender/badges/coverage.svg)](https://codeclimate.com/github/Zooip/gorg_message_sender/coverage) [![Build Status](https://travis-ci.org/Zooip/gorg_message_sender.svg?branch=master)](https://travis-ci.org/Zooip/gorg_message_sender) [![Gem Version](https://badge.fury.io/rb/gorg_message_sender.svg)](https://badge.fury.io/rb/gorg_message_sender) [![Dependency Status](https://gemnasium.com/badges/github.com/Zooip/gorg_message_sender.svg)](https://gemnasium.com/github.com/Zooip/gorg_message_sender)

GorgMessageSender is a very simple RabbitMQ message sender using Gadz.org SOA JSON Schema

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gorg_message_sender'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gorg_message_sender

## Usage
###Configuration
GorgMessageSender can be configure to change its default values :
```ruby
GorgMessageSender.configure do |c|
  
  # Id used to set the event_sender_id
  #c.application_id = "gms"
  
  # RabbitMQ network and authentification
  #c.host = "localhost" 
  #c.port = 5672 
  #c.vhost = "/"
  #c.user = nil
  #c.password = nil
  
  # Exchange configuration
  #c.exchange_name ="exchange"        
  #c.durable_exchange= true
end
```

This based configuration can be overridden when needed :
```ruby
sender=GorgMessageSender.new(host: "my_host",
                             port: 1234,
                             user: "My_user",
                             pass: "1zae125a",
                             exchange_name: "some_exchange",
                             vhost: "/foo",
                             app_id: "bar",
                             durable_exchange: false)
```
###Generating a message
```ruby
sender=GorgMessageSender.new()
sender.message({this_is: "my data hash"},"some.routing.key")

# With default configuration
# => "{\"event_uuid\":\"095dcff6-665d-4194-bdfe-f889f8cedb09\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2016-05-31T08:53:32+02:00\",\"event_sender_id\":\"gms\",\"data\":{\"this_is\":\"my data hash\"}}"
```

`event_uuid`, `event_creation_time` and `event_sender_id` can be overridden :

```ruby
sender=GorgMessageSender.new()

sender.message({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "8c4abe62-26fe-11e6-b67b-9e71128cae77",
               event_creation_time: DateTime.new(2084,05,10,01,57,00),
               event_sender_id: "some_app_id"
               )
# => "{\"event_uuid\":\"8c4abe62-26fe-11e6-b67b-9e71128cae77\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2084-05-10T01:57:00+00:00\",\"event_sender_id\":\"some_app_id\",\"data\":{\"this_is\":\"my data hash\"}}"
```
###Message validation
By default, GorgMessageSender validate message against the Gadz.org SOA JSON Schema. You can force message generation for testing purpose with the option `skip_validation`

```ruby
sender.message({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "this is not a valid uuid"
               )

# With default configuration
# => RAISE JSON::Schema::ValidationError

sender.message({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "this is not a valid uuid",
               skip_validation: true
               )

# With default configuration
# => "{\"event_uuid\":\"this is not a valid uuid\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2016-05-31T09:15:21+02:00\",\"event_sender_id\":\"gms\",\"data\":{\"this_is\":\"my data hash\"}}"

```
###Sending a message
To send a message, use the `send` command. It expects the same params than `message` :
```ruby
sender=GorgMessageSender.new(exchange_name: "my_exchange")
sender.send({this_is: "my data hash"},"some.routing.key")

# Message is sent to the exchange "my_exchange" with routing key "some.routing.key"
# => "{\"event_uuid\":\"095dcff6-665d-4194-bdfe-f889f8cedb09\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2016-05-31T08:53:32+02:00\",\"event_sender_id\":\"gms\",\"data\":{\"this_is\":\"my data hash\"}}"

sender.send({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "8c4abe62-26fe-11e6-b67b-9e71128cae77",
               event_creation_time: DateTime.new(2084,05,10,01,57,00),
               event_sender_id: "some_app_id"
               )
           
# Message is sent to the exchange "my_exchange" with routing key "some.routing.key"
# => "{\"event_uuid\":\"8c4abe62-26fe-11e6-b67b-9e71128cae77\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2084-05-10T01:57:00+00:00\",\"event_sender_id\":\"some_app_id\",\"data\":{\"this_is\":\"my data hash\"}}"


sender.send({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "this is not a valid uuid"
               )

# => RAISE JSON::Schema::ValidationError


sender.message({this_is: "my data hash"},
               "some.routing.key",
               event_uuid: "this is not a valid uuid",
               skip_validation: true
               )

# Message is sent to the exchange "my_exchange" with routing key "some.routing.key"
# => "{\"event_uuid\":\"this is not a valid uuid\",\"event_name\":\"some.routing.key\",\"event_creation_time\":\"2016-05-31T09:15:21+02:00\",\"event_sender_id\":\"gms\",\"data\":{\"this_is\":\"my data hash\"}}"
```

`send`also accepts the `verbose` params to print sending informations in SDOUT

```ruby
sender.message({this_is: "my data hash"},
               "some.routing.key",
               verbose: true
               )
```

##To Do
 - Bunny error handling
 - Allow sending messages in queues

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Zooip/gorg_message_sender.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
