class RouterTrafficParser
  PATTERN = /traff-(?<month>\d+)-(?<year>\d+)=(?<days>(?:\d+:\d+\s+)+)\[(?<total_in>\d+):(?<total_out>\d+)\]/

  attr_reader :data

  def initialize(path)
    File.open(File.expand_path(path), 'r') do |io|
      unless io.gets.chomp == 'TRAFF-DATA'
        raise ArgumentError, "#{path} is not a valid traffic file"
      end

      @data = {}

      while month = io.gets do
        parse_month(month.chomp)
      end
    end
  end

  private

  def parse_day(day)
    total_in, total_out = *day.split(':').map { |megabytes| megabytes.to_i }
    { in: total_in, out: total_out }
  end

  def parse_month(month)
    if month =~ PATTERN
      year, month = $~[:year].to_i, $~[:month].to_i
      total_in, total_out = $~[:total_in].to_i, $~[:total_out].to_i
      days = $~[:days].split(/\s+/).map { |day| parse_day(day) }

      @data[year] ||= {}
      @data[year][month] = {}

      days.each_with_index do |day, index|
        @data[year][month][index] = day
      end

      @data[year][month][:in] = total_in
      @data[year][month][:out] = total_out
    else
      $stderr.puts "Discarding malformed line: #{month.inspect}"
    end
  end
end

if $0 == __FILE__
  require 'pp'
  pp RouterTrafficParser.new(ARGV.pop).data
end
