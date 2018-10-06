## fluent-plugin-storm

[storm](https://storm.apache.org/) [stats](https://github.com/apache/storm/blob/master/STORM-UI-REST-API.md#apiv1topologyid-get) input plugin

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-storm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-storm

When you use with td-agent, install it as below:

    $ sudo /opt/td-agent/embedded/bin/fluent-gem install fluent-plugin-storm

## Configuration

### Example

    <source>
      @type storm
      tag storm
      interval 60
      url http://localhost:8080
      window 600
      sys 0
    </source>

    <match storm>
      @type stdout
    </match>

## Copyright

Copyright (c) 2015 Hidenori Suzuki. See [LICENSE](LICENSE) for details.

