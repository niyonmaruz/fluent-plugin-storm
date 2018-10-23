# coding: utf-8
require 'json'
require 'fluent/plugin/input'
module Fluent::Plugin
  class OsqueryInput < Fluent::Plugin::Input
    Fluent::Plugin.register_input('storm', self)

    helpers :timer

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
    end

    def configure(conf)
      super
    end

    def start
      super
      timer_execute(:in_storm_timer, interval, &method(:execute))
    end

    def shutdown
      super
    end

    private

    def execute
      @time = Fluent::Engine.now
      record = Hash.new(0)
      uri = URI.parse("#{@url}/api/v1/topology/summary")
      log.debug(uri)
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
            log.debug(emit_record)
            router.emit(@tag, @time, emit_record)
          end
        end
      end
    rescue => e
      log.error('faild to run', error: e.to_s, error_class: e.class.to_s)
      log.error_backtrace
    end

  end
end
