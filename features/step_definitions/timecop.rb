require 'chronic'
require 'timecop'

module TemporalHelpers
  def travel_to(time, &block)
    Timecop.travel parse_time(time), &block
  end

  def freeze_time_at(time, &block)
    Timecop.freeze parse_time(time), &block
  end

  private

  def parse_time(time)
    Chronic.parse(time) || Time.parse(time)
  end
end

World(TemporalHelpers)

Given /^it is currently (.+)$/ do |time|
  travel_to time
end

Given /^time is frozen at (.+)$/ do |time|
  freeze_time_at time
end

Given /^we return to the present$/ do
  Timecop.return
end
