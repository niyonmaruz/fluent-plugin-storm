# coding: utf-8
require 'fluent/input'
module Fluent
  class StormInput < Fluent::Input
    Fluent::Plugin.register_input('storm', self)
    config_param :tag, :string, default: 'storm'
    config_param :interval, :integer, default: 60
    config_param :url, :string, default: 'http://localhost:8080'
    config_param :window, :string, :default => nil
    config_param :sys, :string, :default => nil

    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def initialize
      super
      require 'net/http'
      require 'uri'
      require 'json'
    end

    def configure(conf)
      super
    end

    def start
      @loop = Coolio::Loop.new
      @tw = TimerWatcher.new(interval, true, log, &method(:execute))
      @tw.attach(@loop)
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      @tw.detach
      @loop.stop
      @thread.join
    end

    def run
      @loop.run
    rescue => e
      @log.error 'unexpected error', error: e.to_s
      @log.error_backtrace
    end

    private

    def execute
      @time = Engine.now
      record = Hash.new(0)
      uri = URI.parse("#{@url}/api/v1/topology/summary")
      @log.debug(uri)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request) do |response|
          record = JSON.parse(response.body) rescue next
          record["topologies"].each do |line|
            topology_id = line["id"]
            #@log.debug(line["id"])
            uri = URI.parse("#{@url}/api/v1/topology/#{topology_id}")
            if @window && @sys
              uri = URI.parse("#{@url}/api/v1/topology/#{topology_id}?window=#{@window}&sys=#{@sys}")
            elsif @window
              uri = URI.parse("#{@url}/api/v1/topology/#{topology_id}?window=#{@window}")
            elsif @sys
              uri = URI.parse("#{@url}/api/v1/topology/#{topology_id}?sys=#{@sys}")
            end
            #@log.debug(uri)
            emit_record = Hash.new(0)
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new(uri.request_uri)
              http.request(request) do |response|
                emit_record = JSON.parse(response.body) rescue next
                emit_record.delete("visualizationTable")
                emit_record.delete("configuration")
              end
            end
            @log.debug(emit_record)
            router.emit(@tag, @time, emit_record)
          end
        end
      end
    rescue => e
      @log.error('faild to run', error: e.to_s, error_class: e.class.to_s)
      @log.error_backtrace
    end

    class TimerWatcher < Coolio::TimerWatcher
      def initialize(interval, repeat, log, &callback)
        @log = log
        @callback = callback
        super(interval, repeat)
      end

      def on_timer
        @callback.call
      rescue => e
        @log.error e.to_s
        @log.error_backtrace
      end
    end
  end
end
