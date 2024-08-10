require_relative "lib/calendar"
require_relative "lib/cli"

cal = GoogleCalendar.new

SchedulerCli.start(ARGV, cal: cal)
