## fluent-plugin-storm

[storm](https://storm.apache.org/) [stats](https://github.com/apache/storm/blob/master/STORM-UI-REST-API.md#apiv1topologyid-get) input plugin

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-storm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-storm

## Configuration

### Example

    <source>
      type storm
      tag storm
      interval 60
      url http://localhost:8080
      window 600
      sys 0
    </source>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2015 Hidenori Suzuki. See [LICENSE](LICENSE) for details.

