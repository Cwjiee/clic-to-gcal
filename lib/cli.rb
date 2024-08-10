require "thor"
require_relative "calendar"

class SchedulerCli < Thor
  def initialize(args = [], options = {}, config = {})
    super(args, options, config)
    @cal = config[:cal]
  end

  desc "list events", "List all events"

  def list
    @cal.events.each { |ev| puts ev.summary }
  end

  desc "delete events", "delete events with prompting"

  def delete
    @cal.events.each do |ev|
      puts ev.summary
      print "delete this event?: [y/n]: "
      choice = $stdin.gets.chomp
      @cal.delete_event(ev.id) if choice == "y"
      puts
    end
  end

  desc "add event", "add event to calendar"

  def add
    print "insert event title: "
    summary = $stdin.gets.chomp

    print "event start date (yyyy-mm-dd): "
    start_date = $stdin.gets.chomp

    print "event end date (yyyy-mm-dd): "
    end_date = $stdin.gets.chomp

    @cal.insert_event(summary, start_date, end_date)
  end
end
