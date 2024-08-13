require "thor"
require_relative "calendar"
require_relative "utils"

class SchedulerCli < Thor
  include Utils

  def initialize(args = [], options = {}, config = {})
    super(args, options, config)
    @cal = config[:cal]
    @wc = config[:wc]
  end

  desc "list", "List all events"

  def list
    @cal.events.each { |ev| puts ev.summary }
  end

  desc "delete", "Delete events with prompting"

  def delete
    @cal.events.each do |ev|
      puts ev.summary
      choice = choice_prompt("delete this event?")
      @cal.delete_event(ev.id) if choice == "y"
      puts
    end
  end

  desc "add", "Adds event to calendar"

  def add
    summary = normal_prompt("insert event title:")

    start_date = normal_prompt("event start date (yyyy-mm-dd): ")

    end_date = normal_prompt("event end date (yyyy-mm-dd): ")

    @cal.insert_event(summary, start_date, end_date)
  end

  desc "import", "imports schedule from clic to google calendar"

  def import
    @wc.authorize
    data = @wc.get_schedule
    @cal.import_to_calendar data
  end
end
