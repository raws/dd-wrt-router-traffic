require 'bundler/setup'
require 'chartkick'
require 'haml'
require 'json'
require './router_traffic_parser'

class RouterTrafficPresenter
  include Chartkick::Helper

  attr_reader :traffic

  def initialize(traffic)
    @traffic = traffic
  end

  def render
    template = File.read(File.join(File.dirname(__FILE__), 'template.haml'))
    engine = Haml::Engine.new(template)
    engine.render(self, {
      monthly_chart_data: JSON.dump(monthly_chart_data)
    })
  end

  private

  def monthly_chart_data
    [{
      name: 'Incoming GB',
      data: monthly_incoming_chart_data
    }, {
      name: 'Outgoing GB',
      data: monthly_outgoing_chart_data
    }]
  end

  def monthly_incoming_chart_data
    chart_data = []

    traffic.data.sort.each do |year, months|
      months.sort.each do |month, data|
        key = Time.new(year, month)
        val = data[:in] / 1000.0
        chart_data << [key, val]
      end
    end

    chart_data
  end

  def monthly_outgoing_chart_data
    chart_data = []

    traffic.data.sort.each do |year, months|
      months.sort.each do |month, data|
        key = Time.new(year, month)
        val = data[:out] / 1000.0
        chart_data << [key, val]
      end
    end

    chart_data
  end
end

if $0 == __FILE__
  traffic = RouterTrafficParser.new(ARGV.shift)

  File.open(File.expand_path(ARGV.shift), 'w') do |io|
    io.write RouterTrafficPresenter.new(traffic).render
  end
end
